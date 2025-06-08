import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
// Conditional import for platform-specific zlib support
import 'compression_stub.dart'
    if (dart.library.io) 'compression_io.dart'
    if (dart.library.html) 'compression_web.dart' as compression;

class Service {
  static const int RTC = 1;
  static const int RTM = 2;
  static const int CHAT = 3;
  static const int EDUCATION = 4;
}

class Privileges {
  // RTC Privileges
  static const int JOIN_CHANNEL = 1;
  static const int PUBLISH_AUDIO_STREAM = 2;
  static const int PUBLISH_VIDEO_STREAM = 3;
  static const int PUBLISH_DATA_STREAM = 4;

  // RTM Privileges
  static const int LOGIN = 1;
}

abstract class ServiceBase {
  int get serviceType;
  Map<int, int> privileges = {};

  void addPrivilege(int privilege, int expire) {
    privileges[privilege] = expire;
  }

  Uint8List packType() {
    var buffer = ByteBuffer();
    buffer.putUint16(serviceType);
    return buffer.pack();
  }

  Uint8List packPrivileges() {
    var buffer = ByteBuffer();
    buffer.putTreeMapUint32(privileges);
    return buffer.pack();
  }

  Uint8List pack() {
    var typeData = packType();
    var privilegeData = packPrivileges();
    var specificData = packSpecific();

    var result =
        Uint8List(typeData.length + privilegeData.length + specificData.length);
    var offset = 0;

    result.setRange(offset, offset + typeData.length, typeData);
    offset += typeData.length;

    result.setRange(offset, offset + privilegeData.length, privilegeData);
    offset += privilegeData.length;

    result.setRange(offset, offset + specificData.length, specificData);

    return result;
  }

  Uint8List packSpecific();
}

class ServiceRTC extends ServiceBase {
  @override
  int get serviceType => Service.RTC;

  String channelName;
  String uid;

  ServiceRTC(this.channelName, this.uid);

  @override
  Uint8List packSpecific() {
    var buffer = ByteBuffer();
    buffer.putString(channelName);
    buffer.putString(uid);
    return buffer.pack();
  }
}

class ServiceRTM extends ServiceBase {
  @override
  int get serviceType => Service.RTM;

  String userId;

  ServiceRTM(this.userId);

  @override
  Uint8List packSpecific() {
    var buffer = ByteBuffer();
    buffer.putString(userId);
    return buffer.pack();
  }
}

class AccessToken {
  static const String VERSION = "007";
  static const int APP_ID_LENGTH = 32;

  String appId;
  String appCertificate;
  late int issueTs;
  int expire;
  late int salt;
  Map<int, ServiceBase> services = {};

  AccessToken(this.appId, this.appCertificate, this.expire) {
    issueTs = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    var random = Random.secure();
    salt = random.nextInt(99999999) + 1;
  }

  void addService(ServiceBase service) {
    services[service.serviceType] = service;
  }

  bool _buildCheck() {
    return _isUUID(appId) && _isUUID(appCertificate) && services.isNotEmpty;
  }

  bool _isUUID(String data) {
    if (data.length != APP_ID_LENGTH) {
      return false;
    }
    // Check if all characters are valid hex characters
    for (int i = 0; i < data.length; i++) {
      String char = data[i];
      if (!RegExp(r'[0-9a-fA-F]').hasMatch(char)) {
        return false;
      }
    }
    return true;
  }

  Uint8List _signing() {
    // Step 1: HMAC-SHA256(key=issueTs as bytes, message=appCertificate as string)
    var buffer1 = ByteBuffer();
    buffer1.putUint32(issueTs);
    var signing = _encodeHMac(utf8.encode(appCertificate), buffer1.pack());

    // Step 2: HMAC-SHA256(key=salt as bytes, message=previous result)
    var buffer2 = ByteBuffer();
    buffer2.putUint32(salt);
    signing = _encodeHMac(signing, buffer2.pack());

    return signing;
  }

  String build() {
    if (!_buildCheck()) {
      return '';
    }

    var signing = _signing();

    // Build signing info
    var signingInfo = ByteBuffer();
    signingInfo.putString(appId);
    signingInfo.putUint32(issueTs);
    signingInfo.putUint32(expire);
    signingInfo.putUint32(salt);
    signingInfo.putUint16(services.length);

    var signingInfoData = signingInfo.pack();

    // Add service data
    for (var service in services.values) {
      var serviceData = service.pack();
      var newData = Uint8List(signingInfoData.length + serviceData.length);
      newData.setRange(0, signingInfoData.length, signingInfoData);
      newData.setRange(signingInfoData.length, newData.length, serviceData);
      signingInfoData = newData;
    }

    // Generate signature from signing key and signing info
    var signature = _encodeHMac(signingInfoData, signing);

    // Build content: signature as raw bytes + signing info (Node.js format)
    var contentBuffer = ByteBuffer();
    contentBuffer.putBytes(signature);
    var signatureData = contentBuffer.pack();

    // Combine signature data + signing info
    var finalContent = Uint8List(signatureData.length + signingInfoData.length);
    finalContent.setRange(0, signatureData.length, signatureData);
    finalContent.setRange(
        signatureData.length, finalContent.length, signingInfoData);

    // Compress the content using deflate (zlib without header/trailer)
    var compressed = _compressData(finalContent);

    return "$VERSION${base64Encode(compressed)}";
  }

  Uint8List _compressData(Uint8List data) {
    // Use platform-specific compression
    return compression.compressData(data);
  }

  Uint8List _encodeHMac(Uint8List message, Uint8List key) {
    var hmac = Hmac(sha256, key);
    var digest = hmac.convert(message);
    return Uint8List.fromList(digest.bytes);
  }
}

class ByteBuffer {
  final List<int> _buffer = [];

  void putUint16(int value) {
    // Little-endian byte order
    _buffer.add(value & 0xFF);
    _buffer.add((value >> 8) & 0xFF);
  }

  void putUint32(int value) {
    // Little-endian byte order
    _buffer.add(value & 0xFF);
    _buffer.add((value >> 8) & 0xFF);
    _buffer.add((value >> 16) & 0xFF);
    _buffer.add((value >> 24) & 0xFF);
  }

  void putString(String str) {
    var bytes = utf8.encode(str);
    putUint16(bytes.length);
    _buffer.addAll(bytes);
  }

  void putBytes(Uint8List bytes) {
    putUint16(bytes.length);
    _buffer.addAll(bytes);
  }

  void putTreeMapUint32(Map<int, int> map) {
    putUint16(map.length);
    var sortedKeys = map.keys.toList()..sort();
    for (var key in sortedKeys) {
      putUint16(key);
      putUint32(map[key]!);
    }
  }

  Uint8List pack() {
    return Uint8List.fromList(_buffer);
  }
}

// CRC32 implementation (keeping for compatibility)
class CRC32 {
  static const int _MASK = 0xFFFFFFFF;
  int _crc = ~0;

  static final List<int> _table = _makeTable();

  static List<int> _makeTable() {
    List<int> table = List<int>.filled(256, 0);

    for (int i = 0; i < 256; i++) {
      int c = i;
      for (int j = 0; j < 8; j++) {
        if ((c & 1) == 1) {
          c = 0xEDB88320 ^ (c >> 1);
        } else {
          c = c >> 1;
        }
      }
      table[i] = c;
    }

    return table;
  }

  void update(List<int> bytes) {
    int crc = _crc;

    for (int i = 0; i < bytes.length; i++) {
      crc = _table[(crc ^ bytes[i]) & 0xFF] ^ (crc >> 8);
    }

    _crc = crc;
  }

  int finalizeAsInt() {
    return (~_crc) & _MASK;
  }
}
