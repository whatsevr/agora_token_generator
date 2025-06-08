import 'package:flutter_test/flutter_test.dart';
import 'package:agora_token_generator/agora_token_generator.dart';

void main() {
  // Use valid 32-character hex strings for App ID and App Certificate
  const String appId = '058d2e1e94a24c8089b1eef96e3f3e9b';
  const String appCertificate = '74a10499bd2d4c188b48a89b4c2a47d0';
  const String channelName = 'test-channel';
  const int uid = 12345;
  const String userId = 'test-user';
  const int tokenExpireSeconds = 3600;

  group('RTC Token Builder', () {
    test('buildTokenWithUid returns a non-empty token', () {
      final token = RtcTokenBuilder.buildTokenWithUid(
        appId: appId,
        appCertificate: appCertificate,
        channelName: channelName,
        uid: uid,
        tokenExpireSeconds: tokenExpireSeconds,
      );

      expect(token, isNotEmpty);
      expect(token.startsWith('007'), isTrue);
    });

    test('buildTokenWithAccount returns a non-empty token', () {
      final token = RtcTokenBuilder.buildTokenWithAccount(
        appId: appId,
        appCertificate: appCertificate,
        channelName: channelName,
        account: userId,
        tokenExpireSeconds: tokenExpireSeconds,
      );

      expect(token, isNotEmpty);
      expect(token.startsWith('007'), isTrue);
    });
  });

  group('RTM Token Builder', () {
    test('buildToken returns a non-empty token', () {
      final token = RtmTokenBuilder.buildToken(
        appId: appId,
        appCertificate: appCertificate,
        userId: userId,
        tokenExpireSeconds: tokenExpireSeconds,
      );

      expect(token, isNotEmpty);
      expect(token.startsWith('007'), isTrue);
    });
  });
}
