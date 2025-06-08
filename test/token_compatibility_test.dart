import 'package:flutter_test/flutter_test.dart';
import 'package:agora_token_generator/agora_token_generator.dart';

void main() {
  // Test data from Node.js implementation
  const String appId = '970CA35de60c44645bbae8a215061b33';
  const String appCertificate = '5CFd2fd1755d40ecb72977518be15d3b';
  const String channel = '7d72365eb983485397e3e3f9d460bdda';
  const int uid = 2882341273;
  const String uidStr = '2882341273';
  const int ts = 1111111;
  const int expire = 600;
  const int salt = 1;
  const String userId = 'test_user';

  group('Token Compatibility Tests', () {
    test('RTC Token with fixed salt should match Node.js implementation', () {
      // Expected token from Node.js test
      const String expectedToken =
          '007eJxTYBBbsMMnKq7p9Hf/HcIX5kce9b518kCiQgSr5Zrp4X1Tu6UUGCzNDZwdjU1TUs0Mkk1MzExMk5ISUy0SjQxNDcwMk4yN3b8IMEQwMTAwMoAwBIL4CgzmKeZGxmamqUmWFsYmFqbGluapxqnGaZYpJmYGSSkpiVwMRhYWRsYmhkbmxgDCaiTj';

      // Create token with fixed parameters to match Node.js test
      var token = AccessToken(appId, appCertificate, expire);
      token.issueTs = ts;
      token.salt = salt;

      var rtcService = ServiceRTC(channel, uid.toString());
      rtcService.addPrivilege(Privileges.JOIN_CHANNEL, expire);
      token.addService(rtcService);

      final actualToken = token.build();

      print('Expected: $expectedToken');
      print('Actual:   $actualToken');

      expect(actualToken, equals(expectedToken));
    });

    test('RTC Token with uid=0 should match Node.js implementation', () {
      const String expectedToken =
          '007eJxTYLhzZP08Lxa1Pg57+TcXb/3cZ3wi4V6kbpbOog0G2dOYk20UGCzNDZwdjU1TUs0Mkk1MzExMk5ISUy0SjQxNDcwMk4yN3b8IMEQwMTAwMoAwBIL4CgzmKeZGxmamqUmWFsYmFqbGluapxqnGaZYpJmYGSSkpiQwMADacImo=';

      var token = AccessToken(appId, appCertificate, expire);
      token.issueTs = ts;
      token.salt = salt;

      var rtcService = ServiceRTC(channel, ''); // uid=0 becomes empty string
      rtcService.addPrivilege(Privileges.JOIN_CHANNEL, expire);
      token.addService(rtcService);

      final actualToken = token.build();

      print('Expected: $expectedToken');
      print('Actual:   $actualToken');

      expect(actualToken, equals(expectedToken));
    });

    test('Multi-service token should match Node.js implementation', () {
      const String expectedToken =
          '007eJxTYOAQsrQ5s3TfH+1tvy8zZZ46EpCc0V43JXdGd2jS8porKo4KDJbmBs6OxqYpqWYGySYmZiamSUmJqRaJRoamBmaGScbG7l8EGCKYGBgYGRgYmBgYGVgYGMF8JjDJDCZZwKQCg3mKuZGxmWlqkqWFsYmFqbGleapxqnGaZYqJmUFSSkoiF4ORhYWRsYmhkbkxyCyISZwMJanFJfGlxalFACKnKng=';

      var token = AccessToken(appId, appCertificate, expire);
      token.issueTs = ts;
      token.salt = salt;

      // Add RTC service with all privileges
      var rtcService = ServiceRTC(channel, uid.toString());
      rtcService.addPrivilege(Privileges.JOIN_CHANNEL, expire);
      rtcService.addPrivilege(Privileges.PUBLISH_AUDIO_STREAM, expire);
      rtcService.addPrivilege(Privileges.PUBLISH_VIDEO_STREAM, expire);
      rtcService.addPrivilege(Privileges.PUBLISH_DATA_STREAM, expire);
      token.addService(rtcService);

      // Add RTM service
      var rtmService = ServiceRTM(userId);
      rtmService.addPrivilege(Privileges.LOGIN, expire);
      token.addService(rtmService);

      final actualToken = token.build();

      print('Expected: $expectedToken');
      print('Actual:   $actualToken');

      expect(actualToken, equals(expectedToken));
    });
  });
}
