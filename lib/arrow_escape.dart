import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ArrowDir { up, right, down, left }

class ArrowPiece {
  final int row;
  final int col;
  final ArrowDir dir;

  const ArrowPiece({
    required this.row,
    required this.col,
    required this.dir,
  });
}

class ArrowLevelSelectScreen extends StatefulWidget {
  const ArrowLevelSelectScreen({super.key});

  @override
  State<ArrowLevelSelectScreen> createState() => _ArrowLevelSelectScreenState();
}

class _ArrowLevelSelectScreenState extends State<ArrowLevelSelectScreen> {
  int highest = 1;
  int stars = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      highest = prefs.getInt('arrow_highest') ?? 1;
      stars = prefs.getInt('stars') ?? 0;
    });
  }

  Future<void> _play(int level) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArrowEscapeScreen(level: level),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Arrow Escape',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Center(
              child: Text(
                '⭐ $stars',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: .92,
        ),
        itemCount: 6,
        itemBuilder: (_, index) {
          final level = index + 1;
          final unlocked = level <= highest;
          return InkWell(
            onTap: unlocked ? () => _play(level) : null,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              decoration: BoxDecoration(
                color: unlocked ? Colors.white : const Color(0xFFF0EDF3),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: unlocked
                      ? const Color(0xFFDDE6FF)
                      : const Color(0xFFE5E1E8),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    unlocked ? Icons.alt_route_rounded : Icons.lock_rounded,
                    color: unlocked
                        ? const Color(0xFF3578F6)
                        : const Color(0xFFAAA3B3),
                    size: 30,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Level $level',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    unlocked
                        ? (level < 4 ? '4 × 4' : '5 × 5')
                        : 'Locked',
                    style: const TextStyle(
                      color: Color(0xFF8E8798),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ArrowEscapeScreen extends StatefulWidget {
  final int level;

  const ArrowEscapeScreen({
    super.key,
    required this.level,
  });

  @override
  State<ArrowEscapeScreen> createState() => _ArrowEscapeScreenState();
}

class _ArrowEscapeScreenState extends State<ArrowEscapeScreen> {
  late int size;
  late List<ArrowPiece> pieces;
  late Set<int> alive;
  int hearts = 3;
  int wrongTaps = 0;
  int coins = 200;
  bool finished = false;
  int? hintIndex;

  @override
  void initState() {
    super.initState();
    _reset();
    _loadCoins();
  }

  void _reset() {
    size = widget.level < 4 ? 4 : 5;
    pieces = _generatePieces(size, widget.level);
    alive = Set<int>.from(List.generate(pieces.length, (i) => i));
    hearts = 3;
    wrongTaps = 0;
    finished = false;
    hintIndex = null;
  }

  List<ArrowPiece> _generatePieces(int n, int level) {
    final result = <ArrowPiece>[];
    for (int row = 0; row < n; row++) {
      for (int col = 0; col < n; col++) {
        final distances = <ArrowDir, int>{
          ArrowDir.up: row,
          ArrowDir.right: n - 1 - col,
          ArrowDir.down: n - 1 - row,
          ArrowDir.left: col,
        };
        final minDistance = distances.values.reduce(
          (a, b) => a < b ? a : b,
        );
        final candidates = distances.entries
            .where((e) => e.value == minDistance)
            .map((e) => e.key)
            .toList();
        final pick = (row * 7 + col * 3 + level) % candidates.length;
        result.add(
          ArrowPiece(
            row: row,
            col: col,
            dir: candidates[pick],
          ),
        );
      }
    }
    return result;
  }

  Future<void> _loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => coins = prefs.getInt('coins') ?? 200);
  }

  bool _canEscape(int index) {
    if (!alive.contains(index)) return false;
    final piece = pieces[index];

    for (final otherIndex in alive) {
      if (otherIndex == index) continue;
      final other = pieces[otherIndex];

      switch (piece.dir) {
        case ArrowDir.up:
          if (other.col == piece.col && other.row < piece.row) return false;
          break;
        case ArrowDir.right:
          if (other.row == piece.row && other.col > piece.col) return false;
          break;
        case ArrowDir.down:
          if (other.col == piece.col && other.row > piece.row) return false;
          break;
        case ArrowDir.left:
          if (other.row == piece.row && other.col < piece.col) return false;
          break;
      }
    }
    return true;
  }

  void _tapPiece(int index) {
    if (finished || !alive.contains(index)) return;

    if (_canEscape(index)) {
      setState(() {
        alive.remove(index);
        hintIndex = null;
      });

      if (alive.isEmpty) {
        _finish();
      }
      return;
    }

    setState(() {
      hearts--;
      wrongTaps++;
      hintIndex = null;
    });

    if (hearts <= 0) {
      _showFail();
    }
  }

  Future<void> _hint() async {
    if (finished) return;

    const cost = 30;
    if (coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need 30 coins for a hint.')),
      );
      return;
    }

    int? candidate;
    for (final index in alive) {
      if (_canEscape(index)) {
        candidate = index;
        break;
      }
    }
    if (candidate == null) return;

    final prefs = await SharedPreferences.getInstance();
    final newCoins = coins - cost;
    await prefs.setInt('coins', newCoins);
    if (!mounted) return;

    setState(() {
      coins = newCoins;
      hintIndex = candidate;
    });
  }

  Future<void> _finish() async {
    if (finished) return;
    finished = true;

    final stars = wrongTaps == 0
        ? 3
        : wrongTaps <= 2
            ? 2
            : 1;

    final prefs = await SharedPreferences.getInstance();
    final key = 'arrow_done_${widget.level}';
    final alreadyRewarded = prefs.getBool(key) ?? false;
    int reward = 0;

    if (!alreadyRewarded) {
      reward = 25 + stars * 5;
      await prefs.setInt('coins', (prefs.getInt('coins') ?? 200) + reward);
      await prefs.setInt('stars', (prefs.getInt('stars') ?? 0) + stars);
      await prefs.setBool(key, true);

      final highest = prefs.getInt('arrow_highest') ?? 1;
      if (widget.level >= highest && widget.level < 6) {
        await prefs.setInt('arrow_highest', widget.level + 1);
      }
    }

    if (!mounted) return;
    await _loadCoins();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        title: const Text(
          'Escaped! 🎉',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              List.filled(stars, '⭐').join(),
              style: const TextStyle(fontSize: 34),
            ),
            const SizedBox(height: 10),
            Text(
              'Wrong taps: $wrongTaps',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              alreadyRewarded ? 'Level already rewarded' : '+$reward coins',
              style: const TextStyle(
                color: Color(0xFF3578F6),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true);
            },
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    );
  }

  void _showFail() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        title: const Text(
          'No hearts left',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Restart the level and look for arrows with a clear path to the edge.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(_reset);
            },
            child: const Text('RESTART'),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(ArrowDir dir) {
    switch (dir) {
      case ArrowDir.up:
        return Icons.arrow_upward_rounded;
      case ArrowDir.right:
        return Icons.arrow_forward_rounded;
      case ArrowDir.down:
        return Icons.arrow_downward_rounded;
      case ArrowDir.left:
        return Icons.arrow_back_rounded;
    }
  }

  Color _colorFor(int index) {
    const colors = [
      Color(0xFFFF5C72),
      Color(0xFF38C88A),
      Color(0xFF7A5CFA),
      Color(0xFFFFA52F),
      Color(0xFF2DC8C4),
      Color(0xFFFF67B0),
    ];
    final piece = pieces[index];
    return colors[(piece.row + piece.col + widget.level) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Level ${widget.level}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            Text(
              '${alive.length} left',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF81798E),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Text(
                '🪙 $coins',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6FAFF), Color(0xFFEAF0FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Icon(
                    i < hearts
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: const Color(0xFFFF5C72),
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                'Tap only arrows that have a clear path to the edge.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF777083),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: size,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: pieces.length,
                      itemBuilder: (_, index) {
                        final isAlive = alive.contains(index);
                        final highlighted = hintIndex == index;
                        if (!isAlive) {
                          return const SizedBox.shrink();
                        }
                        return GestureDetector(
                          onTap: () => _tapPiece(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: _colorFor(index),
                              borderRadius: BorderRadius.circular(18),
                              border: highlighted
                                  ? Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    )
                                  : null,
                              boxShadow: highlighted
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF3578F6)
                                            .withValues(alpha: .35),
                                        blurRadius: 16,
                                        spreadRadius: 4,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              _iconFor(pieces[index].dir),
                              color: Colors.white,
                              size: size == 4 ? 38 : 30,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .9),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ArrowAction(
                      icon: Icons.restart_alt_rounded,
                      label: 'Restart',
                      sub: '',
                      onTap: () => setState(_reset),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ArrowAction(
                      icon: Icons.lightbulb_outline_rounded,
                      label: 'Hint',
                      sub: '30',
                      onTap: _hint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrowAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;

  const _ArrowAction({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4F7FF),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF2E3A56)),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              SizedBox(
                height: 15,
                child: sub.isEmpty
                    ? null
                    : Text(
                        sub,
                        style: const TextStyle(
                          color: Color(0xFFFF9C24),
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
