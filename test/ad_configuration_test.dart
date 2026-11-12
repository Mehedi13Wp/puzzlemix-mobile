import 'package:flutter_test/flutter_test.dart';
import 'package:puzzlemix_mobile/ads/ad_configuration.dart';

void main() {
  test('Unknown or disabled native configuration cannot request ads', () {
    expect(AdConfiguration.fromNative(false), isNull);
    expect(
        AdConfiguration.fromNative({
          'packageName': 'other',
          'mode': 'production',
          'requiresConsent': true
        }),
        isNull);
    expect(
        AdConfiguration.fromNative(
            {'packageName': 'com.mehedi.puzzlemix', 'mode': 'test'}),
        isNull);
  });
  test('DEV always uses sample units regardless of supplied live IDs', () {
    final config = AdConfiguration.fromNative({
      'packageName': 'com.mehedi.puzzlemix.dev',
      'mode': 'test',
      'bannerId': 'live'
    });
    expect(config!.production, false);
    expect(config.bannerId, 'ca-app-pub-3940256099942544/9214589741');
  });
  test('Production requires consent and distinct matching live inventory', () {
    final values = <String, Object>{
      'packageName': 'com.mehedi.puzzlemix',
      'mode': 'production',
      'requiresConsent': true,
      'bannerId': 'ca-app-pub-7388769334096676/6201028876',
      'interstitialId': 'ca-app-pub-7388769334096676/1970139820',
      'rewardedId': 'ca-app-pub-7388769334096676/3474793181'
    };
    expect(AdConfiguration.fromNative(values)!.production, true);
    values['requiresConsent'] = false;
    expect(AdConfiguration.fromNative(values), isNull);
    values['requiresConsent'] = true;
    values['rewardedId'] = values['bannerId']!;
    expect(AdConfiguration.fromNative(values), isNull);
    values['rewardedId'] = 'ca-app-pub-3940256099942544/5224354917';
    expect(AdConfiguration.fromNative(values), isNull);
  });
}
