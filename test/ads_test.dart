import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzlemix_mobile/ads/ad_policy.dart';
import 'package:puzzlemix_mobile/ads/ad_service.dart';
import 'package:puzzlemix_mobile/ads/ad_widgets.dart';

class FakeHintAds implements HintAdGateway {
  @override
  bool rewardedReady = true;
  int shows = 0;
  final result = Completer<bool>();
  @override
  Future<bool> showRewarded() {
    shows++;
    return result.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Production identity never initializes the advertising SDK', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    int sdkCalls = 0;
    messenger.setMockMethodCallHandler(
        const MethodChannel('com.mehedi.puzzlemix/ads'), (call) async => false);
    messenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/google_mobile_ads'),
        (call) async {
      sdkCalls++;
      return null;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(
          const MethodChannel('com.mehedi.puzzlemix/ads'), null);
      messenger.setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/google_mobile_ads'), null);
    });
    await AdService.instance.initialize();
    expect(AdService.instance.enabled, false);
    expect(sdkCalls, 0);
  });
  test('Interstitial requires both three completions and a two minute break',
      () {
    final start = DateTime(2026, 11, 11);
    final policy = AdPolicy(startedAt: start);
    final later = start.add(const Duration(minutes: 2));
    expect(policy.canShowInterstitial(later), false);
    policy.completedLevel();
    policy.completedLevel();
    expect(policy.canShowInterstitial(later), false);
    policy.completedLevel();
    expect(policy.canShowInterstitial(start.add(const Duration(seconds: 119))),
        false);
    expect(policy.canShowInterstitial(later), true);
    policy.fullScreenShown(later); // Also called for a rewarded ad.
    expect(policy.canShowInterstitial(later.add(const Duration(minutes: 5))),
        false);
    policy.completedLevel();
    policy.completedLevel();
    policy.completedLevel();
    expect(policy.canShowInterstitial(later.add(const Duration(seconds: 119))),
        false);
    expect(policy.canShowInterstitial(later.add(const Duration(minutes: 2))),
        true);
  });
  test('Close/failure never earns a hint, including a late reward callback',
      () {
    final outcome = RewardOutcome();
    expect(outcome.close(), false);
    outcome.earned();
    expect(outcome.close(), false);
  });
  test('Earned reward survives dismissal and duplicate callbacks', () {
    final outcome = RewardOutcome();
    outcome.earned();
    outcome.earned();
    expect(outcome.close(), true);
  });

  Future<void> openChoice(
      WidgetTester tester, FakeHintAds ads, void Function(int?) onResult,
      {int coins = 200}) async {
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                  body: TextButton(
                      onPressed: () async {
                        onResult(
                            await chooseHintCost(context, coins, ads: ads));
                      },
                      child: const Text('Hint')),
                ))));
    await tester.tap(find.text('Hint'));
    await tester.pumpAndSettle();
  }

  testWidgets('Cancel returns no authorization and never opens an ad',
      (tester) async {
    final ads = FakeHintAds();
    int? cost = -1;
    await openChoice(tester, ads, (value) => cost = value);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(cost, isNull);
    expect(ads.shows, 0);
  });
  testWidgets(
      'Paid hint is an explicit 30 coin choice, independent of ad availability',
      (tester) async {
    final ads = FakeHintAds()..rewardedReady = false;
    int? cost;
    await openChoice(tester, ads, (value) => cost = value);
    await tester.tap(find.text('Use 30 coins'));
    await tester.pumpAndSettle();
    expect(cost, 30);
    expect(ads.shows, 0);
  });
  testWidgets('Insufficient coins and no ad leaves Cancel usable',
      (tester) async {
    final ads = FakeHintAds()..rewardedReady = false;
    int? cost = -1;
    await openChoice(tester, ads, (value) => cost = value, coins: 0);
    final paid = tester
        .widget<TextButton>(find.widgetWithText(TextButton, 'Use 30 coins'));
    final reward = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Ad unavailable'));
    expect(paid.onPressed, isNull);
    expect(reward.onPressed, isNull);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(cost, isNull);
  });
  testWidgets(
      'Reward is opt-in, guards repeated taps and returns zero cost only after completion',
      (tester) async {
    final ads = FakeHintAds();
    int? cost = -1;
    await openChoice(tester, ads, (value) => cost = value, coins: 0);
    expect(ads.shows, 0);
    await tester.tap(find.text('Watch ad — free hint'));
    await tester.tap(find.text('Watch ad — free hint'));
    await tester.pump();
    expect(ads.shows, 1);
    expect(cost, -1);
    expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Cancel'))
            .onPressed,
        isNull);
    ads.result.complete(true);
    await tester.pumpAndSettle();
    expect(cost, 0);
  });
  testWidgets('Skipped or failed reward keeps dialog open and grants nothing',
      (tester) async {
    final ads = FakeHintAds();
    int? cost = -1;
    await openChoice(tester, ads, (value) => cost = value);
    await tester.tap(find.text('Watch ad — free hint'));
    await tester.pump();
    ads.result.complete(false);
    await tester.pumpAndSettle();
    expect(cost, -1);
    expect(find.textContaining('No coins were spent'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(cost, isNull);
  });
  testWidgets('SDK show exception grants nothing and leaves navigation usable',
      (tester) async {
    final ads = FakeHintAds();
    int? cost = -1;
    await openChoice(tester, ads, (value) => cost = value);
    await tester.tap(find.text('Watch ad — free hint'));
    await tester.pump();
    ads.result.completeError(StateError('ad unavailable'));
    await tester.pumpAndSettle();
    expect(cost, -1);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(cost, isNull);
  });
}
