import 'dart:math' as math;

import 'package:flutter/material.dart';

class RealisticTube extends StatefulWidget {
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

  @override
  State<RealisticTube> createState() => _RealisticTubeState();
}

class _RealisticTubeState extends State<RealisticTube>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wave;

  @override
  void initState() {
    super.initState();
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  bool get _solved {
    if (widget.layers.length != 4) return false;
    return widget.layers.every((c) => c == widget.layers.first);
  }

  @override
  Widget build(BuildContext context) {
    const tubeWidth = 64.0;
    const tubeHeight = 172.0;
    const innerHeight = 148.0;
    const segmentHeight = innerHeight / 4;

    final turns = widget.pouringOut ? .026 : 0.0;
    final scale = widget.pouringIn ? 1.055 : 1.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: AnimatedRotation(
          turns: turns,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(
              0,
              widget.selected ? -12 : 0,
              0,
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_solved)
                      Container(
                        width: tubeWidth + 12,
                        height: tubeHeight + 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(34),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFC94A)
                                  .withValues(alpha: .30),
                              blurRadius: 24,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    Container(
                      width: tubeWidth,
                      height: tubeHeight,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .18),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        border: Border.all(
                          color: widget.selected
                              ? const Color(0xFF7658F4)
                              : Colors.white.withValues(alpha: .78),
                          width: widget.selected ? 3.2 : 2.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .08),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: .65),
                            blurRadius: 2,
                            offset: const Offset(-2, -1),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(6, 12, 6, 7),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(23),
                            bottomRight: Radius.circular(23),
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: List.generate(4, (visualIndex) {
                                  final layerIndex = 3 - visualIndex;
                                  final occupied =
                                      layerIndex < widget.layers.length;
                                  final colorId =
                                      occupied ? widget.layers[layerIndex] : -1;
                                  final isTop = occupied &&
                                      layerIndex == widget.layers.length - 1;

                                  return SizedBox(
                                    height: segmentHeight,
                                    width: double.infinity,
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 360),
                                      reverseDuration:
                                          const Duration(milliseconds: 260),
                                      switchInCurve: Curves.easeOutCubic,
                                      switchOutCurve: Curves.easeInCubic,
                                      transitionBuilder: (child, animation) {
                                        return ClipRect(
                                          child: Align(
                                            alignment: Alignment.bottomCenter,
                                            heightFactor: animation.value,
                                            child: FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            ),
                                          ),
                                        );
                                      },
                                      child: occupied
                                          ? _LiquidLayer(
                                              key: ValueKey(
                                                'slot-$layerIndex-color-$colorId',
                                              ),
                                              color:
                                                  widget.palette[colorId],
                                              isTop: isTop,
                                              wave: _wave,
                                              layerIndex: layerIndex,
                                            )
                                          : SizedBox(
                                              key: ValueKey(
                                                'slot-$layerIndex-empty',
                                              ),
                                            ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              Positioned(
                                left: 8,
                                top: 10,
                                bottom: 18,
                                child: Container(
                                  width: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: .42),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 8,
                                top: 34,
                                height: 54,
                                child: Container(
                                  width: 2.5,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: .24),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      child: Container(
                        width: tubeWidth + 7,
                        height: 13,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .90),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFD7D0DE),
                            width: 1.6,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .06),
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.pouringIn)
                      Positioned(
                        top: 18,
                        child: Container(
                          width: 26,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7658F4)
                                .withValues(alpha: .22),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 7),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  style: TextStyle(
                    color: widget.selected
                        ? const Color(0xFF7658F4)
                        : const Color(0xFF938B9F),
                    fontSize: widget.selected ? 12.5 : 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                  child: Text('${widget.number}'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiquidLayer extends StatelessWidget {
  final Color color;
  final bool isTop;
  final Animation<double> wave;
  final int layerIndex;

  const _LiquidLayer({
    super.key,
    required this.color,
    required this.isTop,
    required this.wave,
    required this.layerIndex,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: wave,
      builder: (_, __) {
        final phase = wave.value * math.pi * 2 + layerIndex;
        return CustomPaint(
          painter: _LiquidPainter(
            color: color,
            isTop: isTop,
            phase: phase,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _LiquidPainter extends CustomPainter {
  final Color color;
  final bool isTop;
  final double phase;

  const _LiquidPainter({
    required this.color,
    required this.isTop,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(color, Colors.white, .18)!,
          color,
          Color.lerp(color, Colors.black, .10)!,
        ],
        stops: const [0, .48, 1],
      ).createShader(rect);

    if (!isTop) {
      canvas.drawRect(rect, basePaint);
    } else {
      final path = Path();
      final waveY = 4.5;
      path.moveTo(0, waveY);
      const segments = 18;
      for (int i = 0; i <= segments; i++) {
        final x = size.width * i / segments;
        final y = waveY + math.sin((i / segments) * math.pi * 2 + phase) * 1.8;
        path.lineTo(x, y);
      }
      path
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(path, basePaint);

      final rim = Paint()
        ..color = Colors.white.withValues(alpha: .38)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      final rimPath = Path();
      for (int i = 0; i <= segments; i++) {
        final x = size.width * i / segments;
        final y = waveY + math.sin((i / segments) * math.pi * 2 + phase) * 1.8;
        if (i == 0) {
          rimPath.moveTo(x, y);
        } else {
          rimPath.lineTo(x, y);
        }
      }
      canvas.drawPath(rimPath, rim);
    }

    final shine = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: .32),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(5, 0, size.width * .24, size.height));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(5, 2, size.width * .18, size.height - 4),
        const Radius.circular(10),
      ),
      shine,
    );

    if (isTop) {
      final bubblePaint = Paint()
        ..color = Colors.white.withValues(alpha: .28);
      canvas.drawCircle(
        Offset(size.width * .72, size.height * .42),
        2.2,
        bubblePaint,
      );
      canvas.drawCircle(
        Offset(size.width * .30, size.height * .68),
        1.5,
        bubblePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LiquidPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isTop != isTop ||
        oldDelegate.phase != phase;
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
  late final AnimationController _controller;
  late final Animation<double> _pop;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _pop = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, .42, curve: Curves.elasticOut),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, .22, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) => CustomPaint(
                  painter: _ConfettiPainter(progress: _controller.value),
                ),
              ),
            ),
          ),
          FadeTransition(
            opacity: _fade,
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFFFF7FD),
                    Color(0xFFF2EEFF),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: .92),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7658F4).withValues(alpha: .22),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _pop,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD75E), Color(0xFFFF9E2F)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB12B)
                                .withValues(alpha: .35),
                            blurRadius: 20,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'LEVEL COMPLETE!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .5,
                      color: Color(0xFF251D38),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final earned = index < widget.stars;
                      final begin = .12 + index * .10;
                      final end = math.min(1.0, begin + .38);
                      final starAnimation = CurvedAnimation(
                        parent: _controller,
                        curve: Interval(
                          begin,
                          end,
                          curve: Curves.elasticOut,
                        ),
                      );
                      return ScaleTransition(
                        scale: starAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.star_rounded,
                            size: 42,
                            color: earned
                                ? const Color(0xFFFFBE2E)
                                : const Color(0xFFDCD6E5),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .72),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.moves} moves',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF3C334B),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 9),
                          child: Text(
                            '•',
                            style: TextStyle(color: Color(0xFFAAA2B4)),
                          ),
                        ),
                        Text(
                          'Par ${widget.par}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF786F86),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.alreadyRewarded
                        ? 'Reward already collected'
                        : '+${widget.reward} coins',
                    style: const TextStyle(
                      color: Color(0xFF7658F4),
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 17),
                  FilledButton.icon(
                    onPressed: widget.onContinue,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: const Color(0xFF7658F4),
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
                        letterSpacing: .5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;

  const _ConfettiPainter({required this.progress});

  static const colors = [
    Color(0xFFFF5C72),
    Color(0xFF38C88A),
    Color(0xFF7658F4),
    Color(0xFFFFA52F),
    Color(0xFF2DC8C4),
    Color(0xFFFF67B0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(72);
    final paint = Paint();

    for (int i = 0; i < 48; i++) {
      final startX = random.nextDouble() * size.width;
      final speed = .55 + random.nextDouble() * .75;
      final drift = (random.nextDouble() - .5) * 70;
      final y = -20 + progress * (size.height + 70) * speed;
      final x = startX + math.sin(progress * math.pi * 3 + i) * drift * .18;
      final rotation = progress * math.pi * (2 + random.nextDouble() * 4);
      final w = 5.0 + random.nextDouble() * 6;
      final h = 3.0 + random.nextDouble() * 5;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      paint.color = colors[i % colors.length].withValues(
        alpha: (1 - math.max(0, progress - .82) / .18).clamp(0, 1),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
