import 'dart:math' as math;

import 'package:flutter/material.dart';

const fruitNames = <String>[
  'Banana',
  'Orange',
  'Mango',
  'Apple',
  'Grapes',
  'Strawberry',
  'Kiwi',
  'Jackfruit',
];

class PremiumFruitBackground extends StatefulWidget {
  final Widget child;
  final bool dark;

  const PremiumFruitBackground({
    super.key,
    required this.child,
    this.dark = false,
  });

  @override
  State<PremiumFruitBackground> createState() =>
      _PremiumFruitBackgroundState();
}

class _PremiumFruitBackgroundState extends State<PremiumFruitBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.dark
        ? const [
            Color(0xFF031D11),
            Color(0xFF06351E),
            Color(0xFF0A4A29),
            Color(0xFF0B5B32),
            Color(0xFF062D1B),
          ]
        : const [
            Color(0xFFE9F8E7),
            Color(0xFFD7F1D3),
            Color(0xFFBDE4B7),
          ];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (_, __) => CustomPaint(
              painter: _ForestPainter(
                progress: controller.value,
                dark: widget.dark,
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _ForestPainter extends CustomPainter {
  final double progress;
  final bool dark;

  const _ForestPainter({
    required this.progress,
    required this.dark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tau = math.pi * 2;

    for (int i = 0; i < 22; i++) {
      final phase = progress * tau + i * .61;
      final x = (i * 73.0 + 24 + math.sin(phase) * 16) %
              (size.width + 100) -
          50;
      final y = (i * 107.0 + 38 + math.cos(phase * .73) * 21) %
              (size.height + 120) -
          60;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(.35 + math.sin(phase) * .26);
      final leafPaint = Paint()
        ..color = (dark
                ? const Color(0xFF74D58C)
                : const Color(0xFF287B43))
            .withValues(
          alpha: dark
              ? (i.isEven ? .085 : .045)
              : (i.isEven ? .075 : .045),
        );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: 48 + (i % 3) * 8,
          height: 18 + (i % 2) * 5,
        ),
        leafPaint,
      );
      canvas.restore();
    }

    final bokeh = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    for (int i = 0; i < 6; i++) {
      final px = size.width * (.10 + (i * .17) % .82);
      final py = size.height * (.14 + ((i * 29) % 70) / 100);
      bokeh.color = (i.isEven
              ? const Color(0xFF9BEF87)
              : const Color(0xFFFFD66B))
          .withValues(alpha: dark ? .035 : .08);
      canvas.drawCircle(
        Offset(
          px + math.sin(progress * tau + i) * 8,
          py + math.cos(progress * tau * .8 + i) * 8,
        ),
        28 + (i % 3) * 10,
        bokeh,
      );
    }

    if (dark) {
      final vignette = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: .24),
          ],
          stops: const [.48, 1],
        ).createShader(Offset.zero & size);
      canvas.drawRect(Offset.zero & size, vignette);
    }
  }

  @override
  bool shouldRepaint(covariant _ForestPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.dark != dark;
}

class FruitToken extends StatelessWidget {
  final int fruitId;
  final double size;

  const FruitToken({
    super.key,
    required this.fruitId,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    final id = fruitId % fruitNames.length;
    return Semantics(
      label: fruitNames[id],
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _FruitPainter(id),
        ),
      ),
    );
  }
}

class _FruitPainter extends CustomPainter {
  final int id;

  const _FruitPainter(this.id);

  Paint _gradient(
    Rect rect,
    List<Color> colors, {
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    return Paint()
      ..shader = LinearGradient(
        colors: colors,
        begin: begin,
        end: end,
      ).createShader(rect);
  }

  void _softShadow(Canvas canvas, Rect rect) {
    canvas.drawOval(
      rect.translate(1.5, 3),
      Paint()
        ..color = Colors.black.withValues(alpha: .24)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  void _shine(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: .34)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    switch (id) {
      case 0:
        _banana(canvas, size);
        break;
      case 1:
        _orange(canvas, size);
        break;
      case 2:
        _mango(canvas, size);
        break;
      case 3:
        _apple(canvas, size);
        break;
      case 4:
        _grapes(canvas, size);
        break;
      case 5:
        _strawberry(canvas, size);
        break;
      case 6:
        _kiwi(canvas, size);
        break;
      default:
        _jackfruit(canvas, size);
    }
  }

  void _banana(Canvas canvas, Size s) {
    final path = Path()
      ..moveTo(s.width * .18, s.height * .32)
      ..cubicTo(
        s.width * .30,
        s.height * .77,
        s.width * .64,
        s.height * .91,
        s.width * .83,
        s.height * .53,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: .20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s.width * .23
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFFFF18B),
            Color(0xFFFFD12F),
            Color(0xFFE8A914),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Offset.zero & s)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s.width * .20
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: .34)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s.width * .035
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(s.width * .17, s.height * .31),
      s.width * .035,
      Paint()..color = const Color(0xFF755623),
    );
  }

  void _orange(Canvas canvas, Size s) {
    final rect = Rect.fromCenter(
      center: Offset(s.width * .50, s.height * .55),
      width: s.width * .65,
      height: s.height * .65,
    );
    _softShadow(canvas, rect);
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.35, -.40),
          colors: const [
            Color(0xFFFFC457),
            Color(0xFFFF8D1A),
            Color(0xFFD95D0B),
          ],
        ).createShader(rect),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s.width * .61, s.height * .20),
        width: s.width * .27,
        height: s.height * .12,
      ),
      _gradient(
        Offset.zero & s,
        const [
          Color(0xFF72CF65),
          Color(0xFF267B3E),
        ],
      ),
    );
    _shine(
      canvas,
      Offset(s.width * .38, s.height * .40),
      s.width * .08,
    );
  }

  void _mango(Canvas canvas, Size s) {
    canvas.save();
    canvas.translate(s.width * .50, s.height * .55);
    canvas.rotate(-.25);
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: s.width * .60,
      height: s.height * .72,
    );
    _softShadow(canvas, rect);
    canvas.drawOval(
      rect,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFFFEB68),
            Color(0xFFFFB52D),
            Color(0xFFF27624),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect),
    );
    canvas.restore();
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s.width * .62, s.height * .18),
        width: s.width * .28,
        height: s.height * .12,
      ),
      Paint()..color = const Color(0xFF398A43),
    );
    _shine(
      canvas,
      Offset(s.width * .38, s.height * .38),
      s.width * .07,
    );
  }

  void _apple(Canvas canvas, Size s) {
    final p = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-.35, -.45),
        colors: [
          Color(0xFFFF8B8E),
          Color(0xFFE94350),
          Color(0xFF9C1728),
        ],
      ).createShader(Offset.zero & s);

    final shadow = Rect.fromCenter(
      center: Offset(s.width * .50, s.height * .58),
      width: s.width * .64,
      height: s.height * .58,
    );
    _softShadow(canvas, shadow);
    canvas.drawCircle(
      Offset(s.width * .39, s.height * .52),
      s.width * .25,
      p,
    );
    canvas.drawCircle(
      Offset(s.width * .61, s.height * .52),
      s.width * .25,
      p,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s.width * .50, s.height * .66),
        width: s.width * .48,
        height: s.height * .36,
      ),
      p,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * .48,
          s.height * .13,
          s.width * .06,
          s.height * .22,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF5A3B25),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s.width * .65, s.height * .20),
        width: s.width * .26,
        height: s.height * .11,
      ),
      Paint()..color = const Color(0xFF4FA951),
    );
    _shine(
      canvas,
      Offset(s.width * .36, s.height * .38),
      s.width * .065,
    );
  }

  void _grapes(Canvas canvas, Size s) {
    final pts = <Offset>[
      Offset(.50, .34),
      Offset(.36, .47),
      Offset(.63, .47),
      Offset(.28, .61),
      Offset(.50, .61),
      Offset(.72, .61),
      Offset(.39, .75),
      Offset(.61, .75),
      Offset(.50, .86),
    ];
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: .18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    for (final p in pts) {
      canvas.drawCircle(
        Offset(s.width * p.dx + 1.5, s.height * p.dy + 2.5),
        s.width * .125,
        shadowPaint,
      );
    }
    for (int i = 0; i < pts.length; i++) {
      final p = pts[i];
      final rect = Rect.fromCircle(
        center: Offset(s.width * p.dx, s.height * p.dy),
        radius: s.width * .125,
      );
      canvas.drawCircle(
        rect.center,
        rect.width / 2,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-.35, -.40),
            colors: i.isEven
                ? const [
                    Color(0xFFC38CFF),
                    Color(0xFF7F43BD),
                    Color(0xFF4A237D),
                  ]
                : const [
                    Color(0xFFAE73ED),
                    Color(0xFF6D35A7),
                    Color(0xFF401E6B),
                  ],
          ).createShader(rect),
      );
    }
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s.width * .59, s.height * .16),
        width: s.width * .31,
        height: s.height * .12,
      ),
      Paint()..color = const Color(0xFF4B9D4C),
    );
  }

  void _strawberry(Canvas canvas, Size s) {
    final path = Path()
      ..moveTo(s.width * .22, s.height * .35)
      ..quadraticBezierTo(
        s.width * .50,
        s.height * .17,
        s.width * .78,
        s.height * .35,
      )
      ..quadraticBezierTo(
        s.width * .73,
        s.height * .74,
        s.width * .50,
        s.height * .88,
      )
      ..quadraticBezierTo(
        s.width * .27,
        s.height * .74,
        s.width * .22,
        s.height * .35,
      )
      ..close();
    final bounds = path.getBounds();
    canvas.save();
    canvas.translate(1.5, 3);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: .20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.restore();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFFF8794),
            Color(0xFFF14256),
            Color(0xFFB91431),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
    );
    final seed = Paint()..color = const Color(0xFFFFE999);
    for (final p in const [
      Offset(.38, .48),
      Offset(.59, .46),
      Offset(.48, .61),
      Offset(.34, .66),
      Offset(.64, .65),
      Offset(.50, .76),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(s.width * p.dx, s.height * p.dy),
          width: s.width * .035,
          height: s.height * .055,
        ),
        seed,
      );
    }
    final leaf = Paint()..color = const Color(0xFF46A64D);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s.width * .40, s.height * .27),
        width: s.width * .29,
        height: s.height * .12,
      ),
      leaf,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s.width * .60, s.height * .27),
        width: s.width * .29,
        height: s.height * .12,
      ),
      leaf,
    );
    _shine(
      canvas,
      Offset(s.width * .37, s.height * .39),
      s.width * .055,
    );
  }

  void _kiwi(Canvas canvas, Size s) {
    final outer = Rect.fromCircle(
      center: Offset(s.width * .50, s.height * .54),
      radius: s.width * .34,
    );
    _softShadow(canvas, outer);
    canvas.drawCircle(
      outer.center,
      outer.width / 2,
      Paint()..color = const Color(0xFF8A673D),
    );
    final inner = Rect.fromCircle(
      center: outer.center,
      radius: s.width * .29,
    );
    canvas.drawCircle(
      inner.center,
      inner.width / 2,
      Paint()
        ..shader = const RadialGradient(
          colors: [
            Color(0xFFD9F58D),
            Color(0xFF86C84C),
            Color(0xFF4D9C31),
          ],
        ).createShader(inner),
    );
    canvas.drawCircle(
      inner.center,
      s.width * .085,
      Paint()..color = const Color(0xFFF3F0BD),
    );
    final seed = Paint()..color = const Color(0xFF24351D);
    for (int i = 0; i < 12; i++) {
      final a = i * math.pi * 2 / 12;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            inner.center.dx + math.cos(a) * s.width * .18,
            inner.center.dy + math.sin(a) * s.width * .18,
          ),
          width: s.width * .025,
          height: s.height * .045,
        ),
        seed,
      );
    }
    _shine(
      canvas,
      Offset(s.width * .36, s.height * .38),
      s.width * .055,
    );
  }

  void _jackfruit(Canvas canvas, Size s) {
    final rect = Rect.fromCenter(
      center: Offset(s.width * .50, s.height * .55),
      width: s.width * .58,
      height: s.height * .70,
    );
    _softShadow(canvas, rect);
    canvas.drawOval(
      rect,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFD0E56D),
            Color(0xFF8DB83E),
            Color(0xFF5C8E2E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect),
    );
    final dot = Paint()..color = const Color(0xFF527D2B);
    for (int y = 0; y < 5; y++) {
      for (int x = 0; x < 4; x++) {
        canvas.drawCircle(
          Offset(
            s.width * (.32 + x * .12 + (y.isOdd ? .03 : 0)),
            s.height * (.33 + y * .12),
          ),
          s.width * .018,
          dot,
        );
      }
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * .47,
          s.height * .11,
          s.width * .06,
          s.height * .17,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF526735),
    );
    _shine(
      canvas,
      Offset(s.width * .39, s.height * .34),
      s.width * .055,
    );
  }

  @override
  bool shouldRepaint(covariant _FruitPainter oldDelegate) =>
      oldDelegate.id != id;
}

class RealisticTube extends StatelessWidget {
  final int number;
  final List<int> layers;
  final List<Color> palette;
  final bool selected;
  final bool pouringOut;
  final bool pouringIn;
  final int? incomingFruit;
  final VoidCallback onTap;

  const RealisticTube({
    super.key,
    required this.number,
    required this.layers,
    required this.palette,
    required this.selected,
    required this.pouringOut,
    required this.pouringIn,
    this.incomingFruit,
    required this.onTap,
  });

  bool get solved =>
      layers.length == 4 &&
      layers.every((fruit) => fruit == layers.first);

  @override
  Widget build(BuildContext context) {
    const jarWidth = 76.0;
    const jarHeight = 194.0;
    const slotHeight = 39.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: pouringIn ? 1.075 : (selected ? 1.035 : 1),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        child: AnimatedRotation(
          turns: pouringOut ? .042 : 0,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeInOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 190),
            transform: Matrix4.translationValues(
              0,
              selected ? -14 : 0,
              0,
            ),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    if (solved)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(38),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD15B)
                                    .withValues(alpha: .42),
                                blurRadius: 30,
                                spreadRadius: 6,
                              ),
                              BoxShadow(
                                color: const Color(0xFF68E589)
                                    .withValues(alpha: .28),
                                blurRadius: 38,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    Container(
                      width: jarWidth,
                      height: jarHeight,
                      padding: const EdgeInsets.fromLTRB(7, 19, 7, 9),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: .20),
                            Colors.white.withValues(alpha: .08),
                            const Color(0xFFBCEFD0).withValues(alpha: .08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
                          bottomLeft: Radius.circular(33),
                          bottomRight: Radius.circular(33),
                        ),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFFB9FF9A)
                              : Colors.white.withValues(alpha: .62),
                          width: selected ? 3.0 : 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .26),
                            blurRadius: 16,
                            offset: const Offset(0, 9),
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: .10),
                            blurRadius: 6,
                            offset: const Offset(-3, -2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: List.generate(4, (visualIndex) {
                                final layerIndex = 3 - visualIndex;
                                final occupied =
                                    layerIndex < layers.length;
                                final fruitId =
                                    occupied ? layers[layerIndex] : -1;

                                return SizedBox(
                                  height: slotHeight,
                                  child: Center(
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 420),
                                      reverseDuration:
                                          const Duration(milliseconds: 230),
                                      switchInCurve: Curves.elasticOut,
                                      switchOutCurve: Curves.easeInCubic,
                                      transitionBuilder:
                                          (child, animation) =>
                                              ScaleTransition(
                                        scale: animation,
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      ),
                                      child: occupied
                                          ? FruitToken(
                                              key: ValueKey(
                                                'fruit-' +
                                                    layerIndex.toString() +
                                                    '-' +
                                                    fruitId.toString(),
                                              ),
                                              fruitId: fruitId,
                                              size: 42,
                                            )
                                          : SizedBox(
                                              key: ValueKey(
                                                'empty-' +
                                                    layerIndex.toString(),
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            Positioned(
                              left: 8,
                              top: 14,
                              bottom: 26,
                              child: Container(
                                width: 5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: .52),
                                      Colors.white.withValues(alpha: .05),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 45,
                              height: 58,
                              child: Container(
                                width: 2.4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .14),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 3,
                      child: Container(
                        width: jarWidth + 10,
                        height: 16,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: .90),
                              const Color(0xFFBCEFD0)
                                  .withValues(alpha: .58),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .72),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .16),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (pouringIn && incomingFruit != null)
                      Positioned(
                        top: -24,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: -22, end: 24),
                          duration: const Duration(milliseconds: 310),
                          curve: Curves.easeInCubic,
                          builder: (_, y, child) => Transform.translate(
                            offset: Offset(0, y),
                            child: child,
                          ),
                          child: FruitToken(
                            fruitId: incomingFruit!,
                            size: 36,
                          ),
                        ),
                      ),
                    if (solved)
                      Positioned(
                        right: -6,
                        top: 24,
                        child: Container(
                          width: 23,
                          height: 23,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFD15B),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Color(0xFF23452D),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFB9FF9A)
                            .withValues(alpha: .16)
                        : Colors.black.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    number.toString(),
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFFD9FFC8)
                          : const Color(0xFFC0E0C8),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LevelCompleteCelebration extends StatefulWidget {
  final int stars;
  final int moves;
  final int par;
  final int reward;
  final bool alreadyRewarded;
  final VoidCallback onContinue;

  const LevelCompleteCelebration({
    super.key,
    required this.stars,
    required this.moves,
    required this.par,
    required this.reward,
    required this.alreadyRewarded,
    required this.onContinue,
  });

  @override
  State<LevelCompleteCelebration> createState() =>
      _LevelCompleteCelebrationState();
}

class _LevelCompleteCelebrationState
    extends State<LevelCompleteCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    )..forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String get headline {
    if (widget.stars == 3) return 'PERFECT SORT!';
    if (widget.stars == 2) return 'AMAZING!';
    return 'FRUIT MASTER!';
  }

  @override
  Widget build(BuildContext context) {
    final pop = CurvedAnimation(
      parent: controller,
      curve: const Interval(0, .42, curve: Curves.elasticOut),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 21),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: controller,
                builder: (_, __) => CustomPaint(
                  painter: _CelebrationPainter(controller.value),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0C4B2B),
                  Color(0xFF073A22),
                  Color(0xFF052B19),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: const Color(0xFF76D98A).withValues(alpha: .34),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .34),
                  blurRadius: 34,
                  offset: const Offset(0, 18),
                ),
                BoxShadow(
                  color: const Color(0xFF65D881).withValues(alpha: .11),
                  blurRadius: 38,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: pop,
                  child: Container(
                    width: 98,
                    height: 98,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFE272),
                          Color(0xFFFFB42D),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFC34A)
                              .withValues(alpha: .34),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: FruitToken(fruitId: 2, size: 66),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  headline,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .35,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Juicy puzzle cleared!',
                  style: TextStyle(
                    color: Color(0xFFA7D7B2),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final begin = .10 + index * .10;
                    final anim = CurvedAnimation(
                      parent: controller,
                      curve: Interval(
                        begin,
                        math.min(1.0, begin + .35),
                        curve: Curves.elasticOut,
                      ),
                    );
                    return ScaleTransition(
                      scale: anim,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Icon(
                          Icons.star_rounded,
                          size: 44,
                          color: index < widget.stars
                              ? const Color(0xFFFFC94E)
                              : const Color(0xFF436850),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 13),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .075),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .08),
                    ),
                  ),
                  child: Text(
                    widget.moves.toString() +
                        ' moves  •  Par ' +
                        widget.par.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFE8F8EC),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.alreadyRewarded
                      ? 'Reward already collected'
                      : '+' + widget.reward.toString() + ' coins',
                  style: const TextStyle(
                    color: Color(0xFFFFD15B),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 17),
                FilledButton.icon(
                  onPressed: widget.onContinue,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: const Color(0xFFFFC34A),
                    foregroundColor: const Color(0xFF183D27),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text(
                    'CONTINUE',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: .4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CelebrationPainter extends CustomPainter {
  final double progress;

  const _CelebrationPainter(this.progress);

  static const colors = [
    Color(0xFFFFD43B),
    Color(0xFFFF922B),
    Color(0xFFE94A55),
    Color(0xFF8458C8),
    Color(0xFF56AA4B),
    Color(0xFFF34E64),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(51);
    for (int i = 0; i < 54; i++) {
      final x0 = random.nextDouble() * size.width;
      final speed = .58 + random.nextDouble() * .72;
      final y = -18 + progress * (size.height + 88) * speed;
      final x = x0 + math.sin(progress * math.pi * 4 + i) * 13;
      final fade =
          (1 - math.max(0, progress - .82) / .18)
              .clamp(0.0, 1.0)
              .toDouble();

      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: fade);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * math.pi * (2 + (i % 4)));
      if (i.isEven) {
        canvas.drawCircle(
          Offset.zero,
          3.5 + random.nextDouble() * 2.5,
          paint,
        );
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: 5 + random.nextDouble() * 5,
              height: 3 + random.nextDouble() * 4,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
