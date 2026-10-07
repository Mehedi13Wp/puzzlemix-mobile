import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundManager extends ChangeNotifier {
  SoundManager._();

  static final SoundManager instance = SoundManager._();

  final AudioPlayer _music = AudioPlayer();
  final AudioPlayer _tap = AudioPlayer();
  final AudioPlayer _pour = AudioPlayer();
  final AudioPlayer _match = AudioPlayer();
  final AudioPlayer _error = AudioPlayer();
  final AudioPlayer _success = AudioPlayer();
  final AudioPlayer _whoosh = AudioPlayer();
  final AudioPlayer _pop = AudioPlayer();

  bool enabled = true;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    enabled = prefs.getBool('sound_enabled') ?? true;

    await _music.setReleaseMode(ReleaseMode.loop);
    await _music.setVolume(.48);
  }

  Future<void> startBackground() async {
    if (!enabled) return;
    await _music.stop();
    await _music.setVolume(.48);
    await _music.play(AssetSource('sounds/background.wav'));
  }

  Future<void> toggle() async {
    enabled = !enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', enabled);

    if (enabled) {
      await startBackground();
      await tap();
    } else {
      await _music.stop();
      await stopEffects();
    }

    notifyListeners();
  }

  Future<void> stopEffects() async {
    await Future.wait([
      _tap.stop(),
      _pour.stop(),
      _match.stop(),
      _error.stop(),
      _success.stop(),
      _whoosh.stop(),
      _pop.stop(),
    ]);
  }

  Future<void> tap() async {
    if (!enabled) return;
    await _tap.stop();
    await _tap.play(AssetSource('sounds/tap.wav'), volume: .88);
  }

  Future<void> pour() async {
    if (!enabled) return;
    await _pour.stop();
    await _pour.play(AssetSource('sounds/pour.wav'), volume: .92);
  }

  Future<void> match() async {
    if (!enabled) return;
    await _match.stop();
    await _match.play(AssetSource('sounds/match.wav'), volume: .98);
  }

  Future<void> error() async {
    if (!enabled) return;
    await _error.stop();
    await _error.play(AssetSource('sounds/error.wav'), volume: .78);
  }

  Future<void> success() async {
    if (!enabled) return;
    await _success.stop();
    await _success.play(AssetSource('sounds/success.wav'), volume: 1.0);
  }

  Future<void> whoosh() async {
    if (!enabled) return;
    await _whoosh.stop();
    await _whoosh.play(AssetSource('sounds/whoosh.wav'), volume: .88);
  }

  Future<void> pop() async {
    if (!enabled) return;
    await _pop.stop();
    await _pop.play(AssetSource('sounds/pop.wav'), volume: .92);
  }
}
