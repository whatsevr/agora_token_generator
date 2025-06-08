# Agora Token Generator for Dart/Flutter

[![Pub Version](https://img.shields.io/pub/v/agora_token_generator)](https://pub.dev/packages/agora_token_generator)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter Platform](https://img.shields.io/badge/platform-flutter-blue.svg)](https://flutter.dev)

A powerful and lightweight Flutter package for generating **Agora Dynamic Keys** and **Access Tokens** for use with Agora.io SDKs. This package provides a pure Dart implementation of Agora's token generation mechanism with **zero native dependencies**.

🌐 **[Live Demo](https://mohamedabd0.github.io/agora_token_generator/)**

## 🚀 Features

- ✅ **RTC Token Generation** - For Agora Real-Time Communications (Video/Audio calls)
- ✅ **RTM Token Generation** - For Agora Real-Time Messaging
- ✅ **Multi-Service Tokens** - Combined tokens for both RTC and RTM services
- ✅ **Latest Token Format** - Supports AccessToken2 (007) format
- ✅ **Zero Native Dependencies** - Pure Dart implementation
- ✅ **Flutter Web Support** - Works seamlessly on all Flutter platforms
- ✅ **Type Safety** - Full Dart type safety with comprehensive documentation
- ✅ **Production Ready** - Used in real-world applications

## 📦 Installation

Add this package to your `pubspec.yaml` file:

```yaml
dependencies:
  agora_token_generator: ^0.0.1
```

Then install it:

```bash
flutter pub get
```

## 🏃‍♂️ Quick Start

### Basic RTC Token (Video Calling)

```dart
import 'package:agora_token_generator/agora_token_generator.dart';

void main() {
  // Your Agora project credentials
  const String appId = 'YOUR_APP_ID';
  const String appCertificate = 'YOUR_APP_CERTIFICATE';
  const String channelName = 'my_video_call';
  const int uid = 12345;
  const int tokenExpireSeconds = 3600; // 1 hour

  // Generate RTC token
  String token = RtcTokenBuilder.buildTokenWithUid(
    appId: appId,
    appCertificate: appCertificate,
    channelName: channelName,
    uid: uid,
    tokenExpireSeconds: tokenExpireSeconds,
  );

  print('🎯 RTC Token: $token');
}
```

### RTM Token (Messaging)

```dart
import 'package:agora_token_generator/agora_token_generator.dart';

void main() {
  const String appId = 'YOUR_APP_ID';
  const String appCertificate = 'YOUR_APP_CERTIFICATE';
  const String userId = 'user_123';
  const int tokenExpireSeconds = 3600;

  String token = RtmTokenBuilder.buildToken(
    appId: appId,
    appCertificate: appCertificate,
    userId: userId,
    tokenExpireSeconds: tokenExpireSeconds,
  );

  print('💬 RTM Token: $token');
}
```

## 📚 Comprehensive Usage Guide

### 1. RTC Tokens for Video/Audio Calling

#### Token with Numeric User ID

Perfect for scenarios where you use numeric user identifiers:

```dart
String rtcToken = RtcTokenBuilder.buildTokenWithUid(
  appId: 'your_app_id',
  appCertificate: 'your_app_certificate',
  channelName: 'gaming_room_1',
  uid: 12345,
  tokenExpireSeconds: 7200, // 2 hours
);
```

#### Token with String User Account

Ideal when using string-based user accounts:

```dart
String rtcToken = RtcTokenBuilder.buildTokenWithAccount(
  appId: 'your_app_id',
  appCertificate: 'your_app_certificate',
  channelName: 'meeting_room_abc',
  account: 'john.doe@example.com',
  tokenExpireSeconds: 3600,
);
```

#### Token with UID = 0 (Wildcard)

Useful for guest users or when UID is assigned dynamically:

```dart
String rtcToken = RtcTokenBuilder.buildTokenWithUid(
  appId: 'your_app_id',
  appCertificate: 'your_app_certificate',
  channelName: 'public_broadcast',
  uid: 0, // Wildcard UID
  tokenExpireSeconds: 3600,
);
```

### 2. RTM Tokens for Real-Time Messaging

```dart
String rtmToken = RtmTokenBuilder.buildToken(
  appId: 'your_app_id',
  appCertificate: 'your_app_certificate',
  userId: 'user_unique_id',
  tokenExpireSeconds: 86400, // 24 hours
);
```

### 3. Multi-Service Tokens (Advanced)

For applications that need both RTC and RTM services:

```dart
import 'package:agora_token_generator/agora_token_generator.dart';

String generateMultiServiceToken() {
  const String appId = 'your_app_id';
  const String appCertificate = 'your_app_certificate';
  const String channelName = 'multi_service_channel';
  const String userId = 'user123';
  const int uid = 12345;
  const int expireSeconds = 3600;

  // Create access token
  var token = AccessToken(appId, appCertificate, expireSeconds);

  // Add RTC service with permissions
  var rtcService = ServiceRTC(channelName, uid.toString());
  rtcService.addPrivilege(Privileges.JOIN_CHANNEL, expireSeconds);
  rtcService.addPrivilege(Privileges.PUBLISH_AUDIO_STREAM, expireSeconds);
  rtcService.addPrivilege(Privileges.PUBLISH_VIDEO_STREAM, expireSeconds);
  token.addService(rtcService);

  // Add RTM service
  var rtmService = ServiceRTM(userId);
  rtmService.addPrivilege(Privileges.LOGIN, expireSeconds);
  token.addService(rtmService);

  return token.build();
}
```

## 🛠️ Advanced Configuration

### Token Expiration Best Practices

```dart
class TokenConfig {
  // Short-lived tokens for production (recommended)
  static const int shortLived = 3600;    // 1 hour
  static const int mediumLived = 7200;   // 2 hours
  static const int longLived = 86400;    // 24 hours

  // For development/testing only
  static const int development = 2592000; // 30 days
}
```

### Error Handling

```dart
String? generateTokenSafely({
  required String appId,
  required String appCertificate,
  required String channelName,
  required int uid,
}) {
  try {
    if (appId.isEmpty || appCertificate.isEmpty) {
      throw ArgumentError('App ID and Certificate cannot be empty');
    }

    return RtcTokenBuilder.buildTokenWithUid(
      appId: appId,
      appCertificate: appCertificate,
      channelName: channelName,
      uid: uid,
      tokenExpireSeconds: 3600,
    );
  } catch (e) {
    print('❌ Token generation failed: $e');
    return null;
  }
}
```

### Flutter Integration Example

```dart
class AgoraTokenService {
  static const String _appId = 'YOUR_APP_ID';
  static const String _appCertificate = 'YOUR_APP_CERTIFICATE';

  static Future<String> getRtcToken({
    required String channelName,
    required int uid,
    int expireSeconds = 3600,
  }) async {
    return RtcTokenBuilder.buildTokenWithUid(
      appId: _appId,
      appCertificate: _appCertificate,
      channelName: channelName,
      uid: uid,
      tokenExpireSeconds: expireSeconds,
    );
  }

  static Future<String> getRtmToken({
    required String userId,
    int expireSeconds = 3600,
  }) async {
    return RtmTokenBuilder.buildToken(
      appId: _appId,
      appCertificate: _appCertificate,
      userId: userId,
      tokenExpireSeconds: expireSeconds,
    );
  }
}
```

## 🎮 Interactive Demo

This package includes a comprehensive **Flutter Web demo** that showcases:

- 🎛️ **Interactive Token Generator** - Generate tokens with a modern UI
- 📺 **Video Conference Simulator** - See how tokens work in real-time
- 🔐 **Security Best Practices** - Learn about proper token handling
- 📱 **Responsive Design** - Works on all screen sizes

### Running the Demo

```bash
cd example
flutter run -d chrome --web-port=8080
```

Visit `http://localhost:8080` to try the interactive demo!

## 🔐 Getting Agora Credentials

### Step 1: Create Agora Account

1. Visit [Agora Console](https://console.agora.io/)
2. Sign up for a free account
3. Complete email verification

### Step 2: Create Project

1. Click "Create Project" in the console
2. Choose "Secured mode: APP ID + Token"
3. Note down your **App ID**

### Step 3: Generate App Certificate

1. Go to your project settings
2. Click "Generate" next to App Certificate
3. **⚠️ Keep your App Certificate secure - never expose it in client code!**

### Step 4: Test Connection

```dart
// Test with the provided demo credentials (for testing only)
const demoAppId = '970CA35de60c44645bbae8a215061b33';
const demoAppCertificate = '5CFd2fd1755d40ecb72977518be15d3b';
```

## 🏗️ Token Architecture

### AccessToken2 (007) Format

This package implements Agora's latest token format with enhanced security:

- **Header**: Token version and algorithm
- **Payload**: Encrypted service privileges and metadata
- **Signature**: HMAC-SHA256 signature for verification

### Supported Services & Privileges

| Service | Privileges             | Description                |
| ------- | ---------------------- | -------------------------- |
| **RTC** | `JOIN_CHANNEL`         | Join audio/video channel   |
| **RTC** | `PUBLISH_AUDIO_STREAM` | Publish audio stream       |
| **RTC** | `PUBLISH_VIDEO_STREAM` | Publish video stream       |
| **RTC** | `PUBLISH_DATA_STREAM`  | Publish data stream        |
| **RTM** | `LOGIN`                | Login to messaging service |

## 🔧 API Reference

### RtcTokenBuilder

#### `buildTokenWithUid()`

```dart
static String buildTokenWithUid({
  required String appId,
  required String appCertificate,
  required String channelName,
  required int uid,
  required int tokenExpireSeconds,
})
```

#### `buildTokenWithAccount()`

```dart
static String buildTokenWithAccount({
  required String appId,
  required String appCertificate,
  required String channelName,
  required String account,
  required int tokenExpireSeconds,
})
```

### RtmTokenBuilder

#### `buildToken()`

```dart
static String buildToken({
  required String appId,
  required String appCertificate,
  required String userId,
  required int tokenExpireSeconds,
})
```

### AccessToken

#### Constructor

```dart
AccessToken(String appId, String appCertificate, int expireSeconds)
```

#### Methods

```dart
void addService(Service service)
String build()
```

## 🚨 Security Best Practices

### ✅ Do's

- ✅ Generate tokens on your **backend server**
- ✅ Use **short-lived tokens** (1-2 hours max)
- ✅ Implement **token refresh** mechanism
- ✅ Validate user permissions before token generation
- ✅ Use HTTPS for token transmission
- ✅ Log token generation for audit trails

### ❌ Don'ts

- ❌ **Never** expose App Certificate in client code
- ❌ Don't use long-lived tokens in production
- ❌ Don't generate tokens on client devices
- ❌ Don't share tokens between different users
- ❌ Don't ignore token expiration

### Recommended Architecture

```
[Mobile App] -> [Your Backend API] -> [Agora Token Generator] -> [Agora Services]
```

## 🤝 Contributing

Contributions are welcome!

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Agora.io** - For providing the real-time communication platform
- **Flutter Team** - For the amazing cross-platform framework
- **Dart Community** - For the robust language and ecosystem

- 🐛 **Issues**: [GitHub Issues](https://github.com/YourUsername/agora_token_generator/issues)
- 📧 **Email**: [developer@agora.io](mailto:developer@agora.io)

---

<div align="center">

**Made with ❤️ for the Flutter community**

[⭐ Star on GitHub](https://github.com/agora_token_generator/agora_token_generator) • [📦 View on Pub.dev](https://pub.dev/packages/agora_token_generator)

</div>
