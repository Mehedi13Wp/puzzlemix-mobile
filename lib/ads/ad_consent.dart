import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract class ConsentGateway {
  Future<void> update();
  Future<void> showRequiredForm();
  Future<void> showPrivacyOptions();
  Future<bool> canRequestAds();
  Future<bool> privacyOptionsRequired();
}

class GoogleConsentGateway implements ConsentGateway {
  @override
  Future<void> update() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        if (!done.isCompleted) done.complete();
      },
      (error) {
        if (!done.isCompleted) done.completeError(StateError(error.message));
      },
    );
    return done.future;
  }

  @override
  Future<void> showRequiredForm() async {
    FormError? error;
    await ConsentForm.loadAndShowConsentFormIfRequired(
        (value) => error = value);
    if (error != null) throw StateError(error!.message);
  }

  @override
  Future<void> showPrivacyOptions() async {
    FormError? error;
    await ConsentForm.showPrivacyOptionsForm((value) => error = value);
    if (error != null) throw StateError(error!.message);
  }

  @override
  Future<bool> canRequestAds() => ConsentInformation.instance.canRequestAds();
  @override
  Future<bool> privacyOptionsRequired() async =>
      await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
      PrivacyOptionsRequirementStatus.required;
}

/// Only UMP decides whether requests are permitted. Never infer consent from saves.
class AdConsent extends ChangeNotifier {
  AdConsent({ConsentGateway? gateway})
      : _gateway = gateway ?? GoogleConsentGateway();
  final ConsentGateway _gateway;
  bool canRequestAds = false;
  bool privacyOptionsRequired = false;
  bool busy = false;
  String? lastError;
  Future<bool>? _operation;

  Future<bool> gather() =>
      _operation ??= _run(false).whenComplete(() => _operation = null);
  Future<bool> showPrivacyOptions() {
    if (!privacyOptionsRequired) return Future.value(false);
    return _operation ??= _run(true).whenComplete(() => _operation = null);
  }

  Future<bool> _run(bool privacyOptions) async {
    busy = true;
    lastError = null;
    canRequestAds = false;
    notifyListeners();
    var success = true;
    try {
      if (privacyOptions) {
        await _gateway.showPrivacyOptions();
      } else {
        await _gateway.update();
        await _gateway.showRequiredForm();
      }
    } catch (error) {
      success = false;
      lastError =
          'Privacy choices are temporarily unavailable. Please try again.';
      debugPrint('Consent form unavailable: $error');
    }
    try {
      // UMP may allow cached consent after an update error; unknown status stays off.
      canRequestAds = await _gateway.canRequestAds();
      privacyOptionsRequired = await _gateway.privacyOptionsRequired();
    } catch (error) {
      canRequestAds = false;
      success = false;
      lastError = 'Privacy status is unavailable. Ads are paused.';
    }
    busy = false;
    notifyListeners();
    return success;
  }
}
