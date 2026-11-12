import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Fits every jar, including extra jars, inside the available play area.
class FruitJarBoard extends StatelessWidget {
  const FruitJarBoard({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, space) {
        if (children.isEmpty) return const SizedBox.shrink();
        const cellWidth = 112.0;
        // Includes room above the glass for selection and completion animation.
        const cellHeight = 286.0;
        final width = math.max(1.0, space.maxWidth - 24);
        final height = math.max(1.0, space.maxHeight - 16);
        var columns = 1;
        var bestScale = 0.0;
        for (var candidate = 1; candidate <= children.length; candidate++) {
          final rows = (children.length / candidate).ceil();
          final scale = math.min(
              1.0,
              math.min(width / (candidate * cellWidth),
                  height / (rows * cellHeight)));
          if (scale > bestScale) {
            bestScale = scale;
            columns = candidate;
          }
        }
        final rows = (children.length / columns).ceil();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Center(
              child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: columns * cellWidth,
              height: rows * cellHeight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                    rows,
                    (row) => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var col = 0;
                                  col < columns &&
                                      row * columns + col < children.length;
                                  col++)
                                SizedBox(
                                    width: cellWidth,
                                    height: cellHeight,
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 48, bottom: 8),
                                        child: children[row * columns + col])),
                            ])),
              ),
            ),
          )),
        );
      });
}
