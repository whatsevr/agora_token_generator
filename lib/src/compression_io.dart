import 'dart:io';
import 'dart:typed_data';

/// IO implementation for compression using dart:io zlib
Uint8List compressData(Uint8List data) {
  // Use zlib deflate compression (same as Node.js zlib.deflateSync)
  return Uint8List.fromList(zlib.encode(data));
}
