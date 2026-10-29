import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:puzzlemix_mobile/main.dart';
import 'package:puzzlemix_mobile/color_sort_fx.dart';
import 'package:puzzlemix_mobile/sound_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final channel in [
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers.global/events'
    ]) {
      messenger.setMockMethodCallHandler(
          MethodChannel(channel), (_) async => null);
    }
    messenger.setMockMethodCallHandler(
        const MethodChannel('xyz.luan/audioplayers'), (call) async {
      if (call.method == 'create') {
        final id = (call.arguments as Map)['playerId'];
        messenger.setMockMethodCallHandler(
            MethodChannel('xyz.luan/audioplayers/events/$id'),
            (_) async => null);
      }
      return null;
    });
    SoundManager.instance.enabled = false;
    SharedPreferences.setMockInitialValues({'fruit_tutorial_seen': true});
  });

  Future<void> openBoard(WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(
        home: ColorSortScreen(
      level: PuzzleLevel(id: 2, par: 4, tubes: [
        [0, 0],
        [0],
        [1],
        []
      ]),
    )));
    await tester.pump(const Duration(milliseconds: 50));
  }

  List<RealisticTube> jars(WidgetTester tester) =>
      tester.widgetList<RealisticTube>(find.byType(RealisticTube)).toList();

  testWidgets(
      'multi-fruit move lands one at a time and Undo cannot interrupt it',
      (tester) async {
    await openBoard(tester);
    jars(tester)[0].onTap();
    jars(tester)[1].onTap();
    await tester.pump();
    expect(jars(tester)[1].layers, [0]);
    await tester.pump(const Duration(milliseconds: 360));
    expect(jars(tester)[1].layers, [0, 0]);
    await tester.tap(find.text('Undo'));
    await tester.pump();
    expect(jars(tester)[1].layers, [0, 0]);
    await tester.pump(const Duration(milliseconds: 360));
    expect(jars(tester)[1].layers, [0, 0, 0]);
    expect(jars(tester)[0].layers, isEmpty);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Undo'));
    await tester.pump();
    expect(jars(tester)[0].layers, [0, 0]);
    expect(jars(tester)[1].layers, [0]);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('restart cancels pending fruit arrivals', (tester) async {
    await openBoard(tester);
    jars(tester)[0].onTap();
    jars(tester)[1].onTap();
    await tester.pump();
    await tester.tap(find.text('Restart'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(jars(tester)[0].layers, [0, 0]);
    expect(jars(tester)[1].layers, [0]);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a full matching jar celebrates then unlocks the board',
      (tester) async {
    await openBoard(tester);
    await tester.pumpWidget(const MaterialApp(
        home: ColorSortScreen(
      key: ValueKey('completion-board'),
      level: PuzzleLevel(id: 2, par: 4, tubes: [
        [0, 0],
        [0, 0],
        [1],
        []
      ]),
    )));
    await tester.pump();
    jars(tester)[0].onTap();
    jars(tester)[1].onTap();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 360));
    await tester.pump(const Duration(milliseconds: 360));
    expect(jars(tester)[1].layers, [0, 0, 0, 0]);
    expect(jars(tester)[1].celebrate, isTrue);
    expect(jars(tester)[1].incomingFruit, isNull);
    await tester.pump(const Duration(milliseconds: 960));
    expect(jars(tester)[1].celebrate, isFalse);
    jars(tester)[2].onTap();
    await tester.pump();
    expect(jars(tester)[2].selected, isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
