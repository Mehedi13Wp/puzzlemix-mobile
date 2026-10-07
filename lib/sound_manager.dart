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
    await _music.setVolume(.12);

    if (enabled) {
      await _music.play(AssetSource('sounds/background.wav'));
    }
  }

  Future<void> toggle() async {
    enabled = !enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', enabled);

    if (enabled) {
      await _music.stop();
      await _music.play(AssetSource('sounds/background.wav'));
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
    await _tap.play(AssetSource('sounds/tap.wav'), volume: .34);
  }

  Future<void> pour() async {
    if (!enabled) return;
    await _pour.stop();
    await _pour.play(AssetSource('sounds/pour.wav'), volume: .44);
  }

  Future<void> match() async {
    if (!enabled) return;
    await _match.stop();
    await _match.play(AssetSource('sounds/match.wav'), volume: .58);
  }

  Future<void> error() async {
    if (!enabled) return;
    await _error.stop();
    await _error.play(AssetSource('sounds/error.wav'), volume: .40);
  }

  Future<void> success() async {
    if (!enabled) return;
    await _success.stop();
    await _success.play(AssetSource('sounds/success.wav'), volume: .68);
  }

  Future<void> whoosh() async {
    if (!enabled) return;
    await _whoosh.stop();
    await _whoosh.play(AssetSource('sounds/whoosh.wav'), volume: .44);
  }

  Future<void> pop() async {
    if (!enabled) return;
    await _pop.stop();
    await _pop.play(AssetSource('sounds/pop.wav'), volume: .46);
  }
}
