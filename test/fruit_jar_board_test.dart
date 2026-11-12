import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzlemix_mobile/fruit_jar_board.dart';
import 'package:puzzlemix_mobile/color_sort_fx.dart';

void main() {
  for (final size in [
    const Size(320, 568),
    const Size(360, 800),
    const Size(800, 400)
  ]) {
    for (final count in [4, 8, 11]) {
      testWidgets('$count jars stay visible and tappable at $size',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final tapped = <int>{};
        await tester.pumpWidget(MaterialApp(
            home: Scaffold(
                body: Column(children: [
          const SizedBox(height: 112),
          Expanded(
              child: FruitJarBoard(
                  children: List.generate(
                      count,
                      (i) => RealisticTube(
                            number: i + 1,
                            layers: const [0, 1, 0, 1],
                            palette: const [Colors.red, Colors.green],
                            selected: false,
                            pouringOut: false,
                            pouringIn: false,
                            onTap: () => tapped.add(i),
                          )))),
          const SizedBox(height: 110),
        ]))));
        await tester.pump();
        final board = tester.getRect(find.byType(FruitJarBoard));
        for (var i = 0; i < count; i++) {
          final jar = find.byType(RealisticTube).at(i);
          final bounds = tester.getRect(jar);
          expect(bounds.width, greaterThan(20));
          expect(board.contains(bounds.topLeft + const Offset(.1, .1)), isTrue);
          expect(board.contains(bounds.bottomRight - const Offset(.1, .1)),
              isTrue);
          await tester.tap(jar);
        }
        expect(tapped.length, count);
        expect(find.byType(Scrollable), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
