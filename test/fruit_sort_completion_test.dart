import 'package:flutter_test/flutter_test.dart';
import 'package:puzzlemix_mobile/main.dart';

void main() {
  group('Fruit Sort solved-state regression', () {
    test('recognizes the exact Level 1 completed board', () {
      expect(
        isFruitSortSolved([
          <int>[],
          <int>[],
          <int>[1, 1, 1, 1],
          <int>[0, 0, 0, 0],
        ]),
        isTrue,
      );
    });

    test('rejects partially filled matching jars', () {
      expect(
        isFruitSortSolved([
          <int>[1, 1, 1],
          <int>[0, 0, 0, 0],
          <int>[],
          <int>[],
        ]),
        isFalse,
      );
    });

    test('rejects a full mixed jar', () {
      expect(
        isFruitSortSolved([
          <int>[1, 1, 1, 0],
          <int>[0, 0, 0, 0],
          <int>[],
          <int>[],
        ]),
        isFalse,
      );
    });
  });
}
