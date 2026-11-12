import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../sound_manager.dart';
import 'ad_policy.dart';
import 'ad_consent.dart';
import 'ad_configuration.dart';

abstract class HintAdGateway {
  bool get rewardedReady;
  Future<bool> showRewarded();
}

/// Native package configuration selects test or production inventory.
/// Production ad requests are gated by UMP consent.
class AdService extends ChangeNotifier
    with WidgetsBindingObserver
    implements HintAdGateway {
  AdService._();
  static final instance = AdService._();
  static String get bannerId => instance._configuration!.bannerId;
  static String get interstitialId => instance._configuration!.interstitialId;
  static String get rewardedId => instance._configuration!.rewardedId;
  AdConfiguration? _configuration;
  final consent = AdConsent();
  bool _sdkInitialized = false;
  bool get privacyOptionsRequired => consent.privacyOptionsRequired;
  bool get privacyOptionsBusy => consent.busy;
  Future<bool> showPrivacyOptions() async {
    if (_showing || consent.busy) return false;
    return consent.showPrivacyOptions();
  }

  static const _channel = MethodChannel('com.mehedi.puzzlemix/ads');
  final policy = AdPolicy();
  bool enabled = false;
  bool _started = false;
  bool _showing = false;
  bool _foreground = true;
  bool _loadingInterstitial = false;
  bool _loadingRewarded = false;
  DateTime? _interstitialLoaded;
  DateTime? _rewardedLoaded;
  DateTime? _interstitialAttempt;
  DateTime? _rewardedAttempt;
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  bool get _active =>
      _foreground &&
      WidgetsBinding.instance.lifecycleState != AppLifecycleState.paused &&
      WidgetsBinding.instance.lifecycleState != AppLifecycleState.inactive;
  bool _fresh(DateTime? time) =>
      time != null &&
      DateTime.now().difference(time) < const Duration(minutes: 50);
  @override
  bool get rewardedReady =>
      enabled && !_showing && _rewarded != null && _fresh(_rewardedLoaded);

  Future<void> initialize() async {
    if (_started) return;
    _started = true;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      _configuration = AdConfiguration.fromNative(
          await _channel.invokeMethod<Object?>('getAdConfiguration'));
      if (_configuration == null) return;
      consent.addListener(_consentChanged);
      WidgetsBinding.instance.addObserver(this);
      if (_configuration!.requiresConsent) {
        await consent.gather();
      } else {
        await _startAds();
      }
    } catch (error) {
      debugPrint('Ads unavailable; gameplay continues: $error');
    }
  }

  Future<void> _startAds() async {
    if (enabled ||
        _initializingSdk ||
        (_configuration!.requiresConsent && !consent.canRequestAds)) return;
    _initializingSdk = true;
    try {
      if (!_sdkInitialized) {
        await MobileAds.instance
            .initialize()
            .timeout(const Duration(seconds: 20));
        _sdkInitialized = true;
      }
      if (_configuration!.requiresConsent && !consent.canRequestAds) return;
      enabled = true;
      preload();
      notifyListeners();
    } catch (error) {
      debugPrint('Ads unavailable; gameplay continues: $error');
    } finally {
      _initializingSdk = false;
    }
  }

  bool _initializingSdk = false;
  int _requestGeneration = 0;
  void _consentChanged() {
    if (consent.busy || !consent.canRequestAds) {
      enabled = false;
      _requestGeneration++;
      _loadingInterstitial = false;
      _loadingRewarded = false;
      _interstitial?.dispose();
      _rewarded?.dispose();
      _interstitial = null;
      _rewarded = null;
      _interstitialAttempt = null;
      _rewardedAttempt = null;
      notifyListeners();
    } else {
      unawaited(_startAds());
      notifyListeners();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) preload(); // Never show an ad on resume.
  }

  void preload() {
    if (!enabled || !_foreground) return;
    if (!_fresh(_interstitialLoaded)) {
      _interstitial?.dispose();
      _interstitial = null;
    }
    if (!_fresh(_rewardedLoaded)) {
      _rewarded?.dispose();
      _rewarded = null;
    }
    final now = DateTime.now();
    if (_interstitial == null &&
        !_loadingInterstitial &&
        (_interstitialAttempt == null ||
            now.difference(_interstitialAttempt!) >=
                const Duration(seconds: 30))) {
      _loadingInterstitial = true;
      _interstitialAttempt = now;
      unawaited(_loadInterstitial());
    }
    if (_rewarded == null &&
        !_loadingRewarded &&
        (_rewardedAttempt == null ||
            now.difference(_rewardedAttempt!) >= const Duration(seconds: 30))) {
      _loadingRewarded = true;
      _rewardedAttempt = now;
      unawaited(_loadRewarded());
    }
  }

  Future<void> _loadInterstitial() async {
    final generation = _requestGeneration;
    try {
      await InterstitialAd.load(
          adUnitId: interstitialId,
          request: const AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (ad) {
              if (generation != _requestGeneration) {
                ad.dispose();
                return;
              }
              _loadingInterstitial = false;
              if (!enabled) {
                ad.dispose();
                return;
              }
              _interstitial = ad;
              _interstitialLoaded = DateTime.now();
            },
            onAdFailedToLoad: (error) {
              if (generation != _requestGeneration) return;
              _loadingInterstitial = false;
              debugPrint('Interstitial unavailable: $error');
            },
          ));
    } catch (error) {
      _loadingInterstitial = false;
      debugPrint('Interstitial load: $error');
    }
  }

  Future<void> _loadRewarded() async {
    final generation = _requestGeneration;
    try {
      await RewardedAd.load(
          adUnitId: rewardedId,
          request: const AdRequest(),
          rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (ad) {
              if (generation != _requestGeneration) {
                ad.dispose();
                return;
              }
              _loadingRewarded = false;
              if (!enabled) {
                ad.dispose();
                return;
              }
              _rewarded = ad;
              _rewardedLoaded = DateTime.now();
              notifyListeners();
            },
            onAdFailedToLoad: (error) {
              if (generation != _requestGeneration) return;
              _loadingRewarded = false;
              debugPrint('Rewarded unavailable: $error');
              notifyListeners();
            },
          ));
    } catch (error) {
      _loadingRewarded = false;
      debugPrint('Rewarded load: $error');
    }
  }

  Future<void> afterLevelContinue() async {
    policy.completedLevel();
    preload();
    if (!enabled ||
        !_active ||
        _showing ||
        !policy.canShowInterstitial(DateTime.now())) return;
    final ad = _interstitial;
    if (ad == null || !_fresh(_interstitialLoaded)) return;
    _interstitial = null;
    _showing = true;
    final done = Completer<void>();
    void finish() {
      if (done.isCompleted) return;
      ad.dispose();
      _showing = false;
      done.complete();
      unawaited(SoundManager.instance.resumeAfterAd());
      preload();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) =>
          policy.fullScreenShown(DateTime.now()),
      onAdDismissedFullScreenContent: (_) => finish(),
      onAdFailedToShowFullScreenContent: (_, error) => finish(),
    );
    try {
      await SoundManager.instance.pauseForAd();
      if (!_active) {
        finish();
        return;
      }
      await ad.show();
    } catch (error) {
      finish();
    }
    await done.future;
  }

  @override
  Future<bool> showRewarded() async {
    if (!rewardedReady || !_active) {
      preload();
      return false;
    }
    final ad = _rewarded!;
    _rewarded = null;
    _showing = true;
    notifyListeners();
    final outcome = RewardOutcome();
    final done = Completer<bool>();
    void finish() {
      if (done.isCompleted) return;
      final earned = outcome.close();
      ad.dispose();
      _showing = false;
      done.complete(earned);
      unawaited(SoundManager.instance.resumeAfterAd());
      preload();
      notifyListeners();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) =>
          policy.fullScreenShown(DateTime.now()),
      onAdDismissedFullScreenContent: (_) => finish(),
      onAdFailedToShowFullScreenContent: (_, error) => finish(),
    );
    try {
      await SoundManager.instance.pauseForAd();
      if (!_active) {
        finish();
        return false;
      }
      await ad.show(onUserEarnedReward: (_, reward) => outcome.earned());
    } catch (error) {
      finish();
    }
    return done.future;
  }
}
