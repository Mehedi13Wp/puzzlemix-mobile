import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:puzzlemix_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('30 sequential levels, each new puzzle has a replayable solution', () {
    expect(levels.length, 30);
    expect(levels.map((l) => l.id), List.generate(30, (i) => i + 1));
    final proofs = jsonDecode(
        File('test/fixtures/new_fruit_level_solutions.json')
            .readAsStringSync()) as List;
    expect(proofs.length, 15);
    for (final proof in proofs) {
      final level = levels[(proof['id'] as int) - 1];
      final tubes = level.tubes.map((t) => List<int>.from(t)).toList();
      final counts = <int, int>{};
      for (final fruit in tubes.expand((t) => t)) {
        counts.update(fruit, (n) => n + 1, ifAbsent: () => 1);
      }
      expect(counts.values.every((n) => n == 4), isTrue);
      expect(tubes.where((t) => t.isEmpty).length, 2);
      expect(level.par, (proof['moves'] as List).length);
      for (final pair in proof['moves'] as List) {
        final source = tubes[pair[0] as int], target = tubes[pair[1] as int];
        expect(source, isNotEmpty);
        expect(target.length, lessThan(4));
        expect(target.isEmpty || target.last == source.last, isTrue);
        final fruit = source.last;
        while (source.isNotEmpty && source.last == fruit && target.length < 4) {
          target.add(source.removeLast());
        }
      }
      expect(
          tubes.every((t) =>
              t.isEmpty || t.length == 4 && t.every((f) => f == t.first)),
          isTrue,
          reason: 'Level ${level.id} must finish with matching full jars');
    }
  });
  test('Existing level-15 completion unlocks 16 without altering saves',
      () async {
    SharedPreferences.setMockInitialValues({
      'highest_level': 15,
      'level_done_15': true,
      'coins': 710,
      'stars': 40
    });
    final prefs = await SharedPreferences.getInstance();
    expect(highestUnlockedFruitLevel(prefs), 16);
    expect(prefs.getInt('coins'), 710);
    expect(prefs.getInt('stars'), 40);
    expect(prefs.getInt('highest_level'), 15);
  });
  test('Unfinished progress stays locked and last level stays in range',
      () async {
    SharedPreferences.setMockInitialValues({'highest_level': 10});
    final prefs = await SharedPreferences.getInstance();
    expect(highestUnlockedFruitLevel(prefs), 10);
    await prefs.setInt('highest_level', 30);
    await prefs.setBool('level_done_30', true);
    expect(highestUnlockedFruitLevel(prefs), 30);
  });
}
