import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_service.dart';

class HomeAdBanner extends StatefulWidget {
  const HomeAdBanner({super.key});
  @override
  State<HomeAdBanner> createState() => _HomeAdBannerState();
}

class _HomeAdBannerState extends State<HomeAdBanner> {
  static bool _dismissedForSession = false;
  int _loadGeneration = 0;
  BannerAd? _ad;
  bool _loaded = false;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    AdService.instance.addListener(_serviceChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  void _serviceChanged() {
    if (!mounted) return;
    if (!AdService.instance.enabled) {
      _loadGeneration++;
      final old = _ad;
      setState(() {
        _ad = null;
        _loaded = false;
        _loading = false;
      });
      old?.dispose();
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    if (_dismissedForSession ||
        !AdService.instance.enabled ||
        _ad != null ||
        _loading ||
        !mounted) return;
    _loading = true;
    final generation = ++_loadGeneration;
    try {
      final width = MediaQuery.sizeOf(context).width.floor();
      final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
      if (!mounted ||
          generation != _loadGeneration ||
          !AdService.instance.enabled ||
          _dismissedForSession ||
          size == null) {
        if (generation == _loadGeneration) _loading = false;
        return;
      }
      final ad = BannerAd(
          adUnitId: AdService.bannerId,
          size: size,
          request: const AdRequest(),
          listener: BannerAdListener(
            onAdLoaded: (ad) {
              if (!mounted ||
                  generation != _loadGeneration ||
                  !AdService.instance.enabled ||
                  _dismissedForSession ||
                  !identical(_ad, ad)) {
                ad.dispose();
                return;
              }
              setState(() {
                _loaded = true;
                _loading = false;
              });
            },
            onAdFailedToLoad: (ad, error) {
              ad.dispose();
              if (mounted && identical(_ad, ad))
                setState(() {
                  _ad = null;
                  _loading = false;
                  _loaded = false;
                });
            },
          ));
      _ad = ad;
      await ad.load();
    } catch (error) {
      if (generation != _loadGeneration) return;
      _ad?.dispose();
      _ad = null;
      _loading = false;
    }
  }

  @override
  void dispose() {
    AdService.instance.removeListener(_serviceChanged);
    _ad?.dispose();
    super.dispose();
  }

  void _dismiss() {
    _loadGeneration++;
    final ad = _ad;
    setState(() {
      _dismissedForSession = true;
      _ad = null;
      _loaded = false;
      _loading = false;
    });
    ad?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              const SizedBox(width: 48),
              const Expanded(
                  child: Text('Advertisement',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10))),
              IconButton(
                  tooltip: 'Close advertisement',
                  onPressed: _dismiss,
                  icon: const Icon(Icons.close),
                  constraints:
                      const BoxConstraints(minWidth: 48, minHeight: 48)),
            ]),
            SizedBox(
                width: ad.size.width.toDouble(),
                height: ad.size.height.toDouble(),
                child: AdWidget(ad: ad)),
          ]),
        ));
  }
}

/// Keeps the board covered until dismissal, preventing moves while earning a hint.
Future<int?> chooseHintCost(BuildContext context, int coins,
    {HintAdGateway? ads}) {
  final gateway = ads ?? AdService.instance;
  AdService.instance.preload();
  return showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _HintChoice(coins: coins, ads: gateway));
}

class _HintChoice extends StatefulWidget {
  const _HintChoice({required this.coins, required this.ads});
  final int coins;
  final HintAdGateway ads;
  @override
  State<_HintChoice> createState() => _HintChoiceState();
}

class _HintChoiceState extends State<_HintChoice> {
  @override
  void initState() {
    super.initState();
    final ads = widget.ads;
    if (ads is Listenable) (ads as Listenable).addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    final ads = widget.ads;
    if (ads is Listenable) (ads as Listenable).removeListener(_refresh);
    super.dispose();
  }

  bool _waiting = false;
  String? _message;
  Future<void> _watch() async {
    if (_waiting) return;
    setState(() => _waiting = true);
    bool earned = false;
    try {
      earned = await widget.ads.showRewarded();
    } catch (_) {/* Fail closed. */}
    if (!mounted) return;
    if (earned) {
      Navigator.pop(context, 0);
      return;
    }
    setState(() {
      _waiting = false;
      _message = 'Ad not completed or unavailable. No coins were spent.';
    });
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_waiting,
        child: AlertDialog(
          title: const Text('Get one hint'),
          content: Text(_message ??
              'Use 30 coins, or choose to watch an ad for one free hint. The free hint is granted only after the ad reward is earned.'),
          actions: [
            TextButton(
                onPressed: _waiting ? null : () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
                onPressed: !_waiting && widget.coins >= 30
                    ? () => Navigator.pop(context, 30)
                    : null,
                child: const Text('Use 30 coins')),
            FilledButton(
                onPressed:
                    !_waiting && widget.ads.rewardedReady ? _watch : null,
                child: Text(_waiting
                    ? 'Playing ad…'
                    : widget.ads.rewardedReady
                        ? 'Watch ad — free hint'
                        : 'Ad unavailable')),
          ],
        ),
      );
}

bool _continuing = false;
Future<void> continueAfterCompletion(BuildContext context) async {
  if (_continuing) return;
  _continuing = true;
  try {
    await AdService.instance.afterLevelContinue();
    if (!context.mounted) return;
    Navigator.of(context).pop();
    Navigator.of(context).pop(true);
  } finally {
    _continuing = false;
  }
}
