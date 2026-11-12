import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzlemix_mobile/ads/ad_consent.dart';

class FakeConsent implements ConsentGateway {
  bool allowed = false,
      required = true,
      updateError = false,
      statusError = false;
  int updates = 0, forms = 0, options = 0;
  Completer<void>? pending;
  @override
  Future<void> update() async {
    updates++;
    if (pending != null) await pending!.future;
    if (updateError) throw StateError('offline');
  }

  @override
  Future<void> showRequiredForm() async {
    forms++;
  }

  @override
  Future<void> showPrivacyOptions() async {
    options++;
    allowed = false;
  }

  @override
  Future<bool> canRequestAds() async {
    if (statusError) throw StateError('unknown');
    return allowed;
  }

  @override
  Future<bool> privacyOptionsRequired() async => required;
}

void main() {
  test('No ads until UMP explicitly permits requests', () async {
    final sdk = FakeConsent();
    final consent = AdConsent(gateway: sdk);
    expect(consent.canRequestAds, false);
    await consent.gather();
    expect(consent.canRequestAds, false);
    sdk.allowed = true;
    await consent.gather();
    expect(consent.canRequestAds, true);
    expect(consent.privacyOptionsRequired, true);
  });
  test('Concurrent startup calls present one consent form', () async {
    final sdk = FakeConsent()..pending = Completer<void>();
    final consent = AdConsent(gateway: sdk);
    final first = consent.gather();
    final second = consent.gather();
    expect(consent.busy, true);
    sdk.pending!.complete();
    await Future.wait([first, second]);
    expect(sdk.updates, 1);
    expect(sdk.forms, 1);
  });
  test('Offline first launch and unknown consent fail closed', () async {
    final sdk = FakeConsent()..updateError = true;
    final consent = AdConsent(gateway: sdk);
    expect(await consent.gather(), false);
    expect(consent.canRequestAds, false);
    expect(sdk.forms, 0);
    sdk.allowed = true;
    sdk.statusError = true;
    await consent.gather();
    expect(consent.canRequestAds, false);
  });
  test('SDK cached permission can survive an update error', () async {
    final sdk = FakeConsent()
      ..updateError = true
      ..allowed = true;
    final consent = AdConsent(gateway: sdk);
    await consent.gather();
    expect(consent.canRequestAds, true);
  });
  test('Changing privacy choices pauses ads and refreshes permission',
      () async {
    final sdk = FakeConsent()..allowed = true;
    final consent = AdConsent(gateway: sdk);
    await consent.gather();
    final seen = <bool>[];
    consent.addListener(() => seen.add(consent.canRequestAds));
    await consent.showPrivacyOptions();
    expect(sdk.options, 1);
    expect(seen.every((value) => !value), true);
    expect(consent.canRequestAds, false);
  });
}
