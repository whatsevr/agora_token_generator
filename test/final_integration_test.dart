import 'package:flutter_test/flutter_test.dart';
import 'package:agora_token_generator/agora_token_generator.dart';

void main() {
  group('Final Integration Tests', () {
    const String appId = '970CA35de60c44645bbae8a215061b33';
    const String appCertificate = '5CFd2fd1755d40ecb72977518be15d3b';
    const String channel = 'testChannel';
    const int uid = 12345;
    const String account = 'testUser';
    const int expire = 3600;

    test('RtcTokenBuilder with UID generates valid token', () {
      final token = RtcTokenBuilder.buildTokenWithUid(
        appId: appId,
        appCertificate: appCertificate,
        channelName: channel,
        uid: uid,
        tokenExpireSeconds: expire,
      );

      expect(token, isNotEmpty);
      expect(token, startsWith('007'));
      print('RTC Token with UID: $token');
    });

    test('RtcTokenBuilder with account generates valid token', () {
      final token = RtcTokenBuilder.buildTokenWithAccount(
        appId: appId,
        appCertificate: appCertificate,
        channelName: channel,
        account: account,
        tokenExpireSeconds: expire,
      );

      expect(token, isNotEmpty);
      expect(token, startsWith('007'));
      print('RTC Token with Account: $token');
    });

    test('RtcTokenBuilder with UID=0 generates valid token', () {
      final token = RtcTokenBuilder.buildTokenWithUid(
        appId: appId,
        appCertificate: appCertificate,
        channelName: channel,
        uid: 0,
        tokenExpireSeconds: expire,
      );

      expect(token, isNotEmpty);
      expect(token, startsWith('007'));
      print('RTC Token with UID=0: $token');
    });

    test('RtmTokenBuilder generates valid token', () {
      final token = RtmTokenBuilder.buildToken(
        appId: appId,
        appCertificate: appCertificate,
        userId: account,
        tokenExpireSeconds: expire,
      );

      expect(token, isNotEmpty);
      expect(token, startsWith('007'));
      print('RTM Token: $token');
    });

    test('AccessToken with multiple services generates valid token', () {
      var token = AccessToken(appId, appCertificate, expire);

      // Add RTC service
      var rtcService = ServiceRTC(channel, uid.toString());
      rtcService.addPrivilege(Privileges.JOIN_CHANNEL, expire);
      rtcService.addPrivilege(Privileges.PUBLISH_AUDIO_STREAM, expire);
      token.addService(rtcService);

      // Add RTM service
      var rtmService = ServiceRTM(account);
      rtmService.addPrivilege(Privileges.LOGIN, expire);
      token.addService(rtmService);

      final result = token.build();
      expect(result, isNotEmpty);
      expect(result, startsWith('007'));
      print('Multi-service Token: $result');
    });
  });
}
