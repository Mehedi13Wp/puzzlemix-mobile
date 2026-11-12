/// Session-wide pacing; rewarded ads also postpone the next interstitial.
class AdPolicy {
  AdPolicy({DateTime? startedAt})
      : _lastFullScreen = startedAt ?? DateTime.now();
  DateTime _lastFullScreen;
  int _completions = 0;
  void completedLevel() => _completions++;
  bool canShowInterstitial(DateTime now) =>
      _completions >= 3 &&
      now.difference(_lastFullScreen) >= const Duration(seconds: 120);
  void fullScreenShown(DateTime now) {
    _lastFullScreen = now;
    _completions = 0;
  }
}

/// A close/failure is never a reward. Duplicate reward callbacks grant once.
class RewardOutcome {
  bool _earned = false;
  bool _closed = false;
  void earned() {
    if (!_closed) _earned = true;
  }

  bool close() {
    _closed = true;
    return _earned;
  }
}
