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

const fruitEmojis = <String>[
  '🍌',
  '🍊',
  '🥭',
  '🍎',
  '🍇',
  '🍓',
  '🥝',
  '🟢',
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
      duration: const Duration(seconds: 10),
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
            Color(0xFF062E1A),
            Color(0xFF0A4828),
            Color(0xFF11643A),
            Color(0xFF0A3A22),
          ]
        : const [
            Color(0xFFEAF9E7),
            Color(0xFFD8F2D4),
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
              painter: _LeafPainter(
                controller.value,
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

class _LeafPainter extends CustomPainter {
  final double progress;
  final bool dark;

  const _LeafPainter(
    this.progress, {
    this.dark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tau = math.pi * 2;
    for (int i = 0; i < 18; i++) {
      final phase = progress * tau + i * .67;
      final x = (i * 79.0 + 25 + math.sin(phase) * 13) %
              (size.width + 80) -
          40;
      final y = (i * 113.0 + 35 + math.cos(phase * .7) * 18) %
              (size.height + 100) -
          50;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(.25 + math.sin(phase) * .2);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: 42 + (i % 3) * 7,
          height: 17 + (i % 2) * 5,
        ),
        Paint()
          ..color = (dark
                  ? const Color(0xFF74D58C)
                  : const Color(0xFF287B43))
              .withValues(
                alpha: dark
                    ? (i.isEven ? .10 : .065)
                    : (i.isEven ? .075 : .045),
              ),
      );
      canvas.restore();
    }

    final glow = Paint()
      ..color = Colors.white.withValues(alpha: dark ? .08 : .20)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26);
    canvas.drawCircle(Offset(size.width * .18, size.height * .22), 62, glow);
    canvas.drawCircle(Offset(size.width * .82, size.height * .66), 74, glow);
  }

  @override
  bool shouldRepaint(covariant _LeafPainter oldDelegate) =>
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
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFF2F8E9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: .96),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF285C39).withValues(alpha: .18),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          fruitEmojis[id],
          style: TextStyle(
            fontSize: size * .64,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class RealisticTube extends StatelessWidget {
  final int number;
  final List<int> layers;
  final List<Color> palette;
  final bool selected;
  final bool pouringOut;
  final bool pouringIn;
  final VoidCallback onTap;

  const RealisticTube({
    super.key,
    required this.number,
    required this.layers,
    required this.palette,
    required this.selected,
    required this.pouringOut,
    required this.pouringIn,
    required this.onTap,
  });

  bool get solved =>
      layers.length == 4 && layers.every((item) => item == layers.first);

  @override
  Widget build(BuildContext context) {
    const jarWidth = 72.0;
    const jarHeight = 190.0;
    const slotHeight = 39.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: pouringIn ? 1.07 : 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        child: AnimatedRotation(
          turns: pouringOut ? .038 : 0,
          duration: const Duration(milliseconds: 230),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 190),
            transform: Matrix4.translationValues(0, selected ? -13 : 0, 0),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (solved)
                      Container(
                        width: jarWidth + 18,
                        height: jarHeight + 18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFC94C)
                                  .withValues(alpha: .42),
                              blurRadius: 28,
                              spreadRadius: 5,
                            ),
                            BoxShadow(
                              color: const Color(0xFF40A95A)
                                  .withValues(alpha: .20),
                              blurRadius: 36,
                              spreadRadius: 7,
                            ),
                          ],
                        ),
                      ),
                    Container(
                      width: jarWidth,
                      height: jarHeight,
                      padding: const EdgeInsets.fromLTRB(7, 19, 7, 9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .34),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(13),
                          topRight: Radius.circular(13),
                          bottomLeft: Radius.circular(31),
                          bottomRight: Radius.circular(31),
                        ),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF176E3B)
                              : Colors.white.withValues(alpha: .92),
                          width: selected ? 3.2 : 2.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF155D35)
                                .withValues(alpha: .13),
                            blurRadius: 14,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
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
                                final occupied = layerIndex < layers.length;
                                final id = occupied ? layers[layerIndex] : -1;

                                return SizedBox(
                                  height: slotHeight,
                                  child: Center(
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 390),
                                      reverseDuration:
                                          const Duration(milliseconds: 220),
                                      switchInCurve: Curves.elasticOut,
                                      switchOutCurve: Curves.easeIn,
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
                                                    id.toString(),
                                              ),
                                              fruitId: id,
                                              size: 36,
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
                              top: 15,
                              bottom: 25,
                              child: Container(
                                width: 5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: .60),
                                      Colors.white.withValues(alpha: .10),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
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
                          color: Colors.white.withValues(alpha: .90),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: const Color(0xFFB9D9BF),
                            width: 1.8,
                          ),
                        ),
                      ),
                    ),
                    if (pouringIn)
                      Positioned(
                        top: 20,
                        child: Container(
                          width: 30,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC64A)
                                .withValues(alpha: .62),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  number.toString(),
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFF176E3B)
                        : const Color(0xFF5E7963),
                    fontSize: selected ? 13 : 11.5,
                    fontWeight: FontWeight.w900,
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

class _LevelCompleteCelebrationState extends State<LevelCompleteCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String get headline {
    if (widget.stars == 3) return 'PERFECT SORT!';
    if (widget.stars == 2) return 'GREAT JOB!';
    return 'NICE FINISH!';
  }

  @override
  Widget build(BuildContext context) {
    final pop = CurvedAnimation(
      parent: controller,
      curve: const Interval(0, .40, curve: Curves.elasticOut),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
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
                  Color(0xFFFFFFFF),
                  Color(0xFFF4FFF1),
                  Color(0xFFE1F5D8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF185F39).withValues(alpha: .23),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: pop,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFE071), Color(0xFFFFAA2F)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB52F)
                              .withValues(alpha: .36),
                          blurRadius: 22,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: FruitToken(fruitId: 2, size: 66),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  headline,
                  style: const TextStyle(
                    color: Color(0xFF174C2C),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .4,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Fruit Puzzle Cleared!',
                  style: TextStyle(
                    color: Color(0xFF62806B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 11),
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
                          size: 43,
                          color: index < widget.stars
                              ? const Color(0xFFFFBD2F)
                              : const Color(0xFFD9E3D9),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .78),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    widget.moves.toString() +
                        ' moves  •  Par ' +
                        widget.par.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF244A30),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  widget.alreadyRewarded
                      ? 'Reward already collected'
                      : '+' + widget.reward.toString() + ' coins',
                  style: const TextStyle(
                    color: Color(0xFF17824A),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: widget.onContinue,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: const Color(0xFF197844),
                    foregroundColor: Colors.white,
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
    for (int i = 0; i < 52; i++) {
      final x0 = random.nextDouble() * size.width;
      final speed = .58 + random.nextDouble() * .70;
      final y = -18 + progress * (size.height + 85) * speed;
      final x = x0 + math.sin(progress * math.pi * 4 + i) * 12;
      final fade =
          (1 - math.max(0, progress - .82) / .18).clamp(0.0, 1.0).toDouble();
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: fade);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * math.pi * (2 + (i % 4)));
      if (i.isEven) {
        canvas.drawCircle(Offset.zero, 3.5 + random.nextDouble() * 2.5, paint);
      } else {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: 5 + random.nextDouble() * 5,
            height: 3 + random.nextDouble() * 4,
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
