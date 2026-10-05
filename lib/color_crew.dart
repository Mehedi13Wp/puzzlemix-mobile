import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrewLevelSelectScreen extends StatefulWidget {
  const CrewLevelSelectScreen({super.key});

  @override
  State<CrewLevelSelectScreen> createState() => _CrewLevelSelectScreenState();
}

class _CrewLevelSelectScreenState extends State<CrewLevelSelectScreen> {
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
      highest = prefs.getInt('crew_highest') ?? 1;
      stars = prefs.getInt('stars') ?? 0;
    });
  }

  Future<void> _play(int level) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ColorCrewScreen(level: level)),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Color Crew',
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
                      ? const Color(0xFFFFE1CE)
                      : const Color(0xFFE5E1E8),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    unlocked ? Icons.grid_view_rounded : Icons.lock_rounded,
                    color: unlocked
                        ? const Color(0xFFFF8B39)
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
                    unlocked ? 'Bench puzzle' : 'Locked',
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

class CrewSnapshot {
  final List<List<int>> columns;
  final List<int> bench;
  final List<CrewTarget> active;
  final List<int> waiting;
  final int benchCapacity;
  final int moves;

  CrewSnapshot({
    required this.columns,
    required this.bench,
    required this.active,
    required this.waiting,
    required this.benchCapacity,
    required this.moves,
  });
}

class CrewTarget {
  final int color;
  int remaining;

  CrewTarget(this.color, this.remaining);

  CrewTarget copy() => CrewTarget(color, remaining);
}

class ColorCrewScreen extends StatefulWidget {
  final int level;

  const ColorCrewScreen({
    super.key,
    required this.level,
  });

  @override
  State<ColorCrewScreen> createState() => _ColorCrewScreenState();
}

class _ColorCrewScreenState extends State<ColorCrewScreen> {
  static const crewColors = <Color>[
    Color(0xFF45C780),
    Color(0xFFFF9E2F),
    Color(0xFF775CF5),
    Color(0xFFFF5F7A),
    Color(0xFF2EC6C2),
  ];

  late List<List<int>> columns;
  late List<CrewTarget> active;
  late List<int> waiting;
  final List<int> bench = [];
  final List<CrewSnapshot> history = [];

  int benchCapacity = 5;
  int moves = 0;
  int coins = 200;
  bool finished = false;
  int? hintColumn;

  @override
  void initState() {
    super.initState();
    _reset();
    _loadCoins();
  }

  void _reset() {
    final rotation = (widget.level - 1) % 4;
    final baseColumns = <List<int>>[
      [0, 1, 2, 3, 0],
      [1, 2, 3, 0, 1],
      [2, 3, 0, 1, 2],
      [3, 0, 1, 2, 3],
    ];

    columns = baseColumns
        .map(
          (column) => column
              .map((c) => (c + rotation) % 4)
              .toList(),
        )
        .toList();

    if (widget.level >= 4) {
      columns[0].insert(2, (4 + rotation) % 5);
      columns[1].insert(1, (4 + rotation) % 5);
      columns[2].insert(3, (4 + rotation) % 5);
      columns[3].insert(0, (4 + rotation) % 5);
    }

    final counts = <int, int>{};
    for (final column in columns) {
      for (final color in column) {
        counts[color] = (counts[color] ?? 0) + 1;
      }
    }

    final order = counts.keys.toList()..sort();
    if (widget.level.isEven) {
      order.setAll(0, order.reversed.toList());
    }

    active = [];
    waiting = List<int>.from(order);
    for (int i = 0; i < 3 && waiting.isNotEmpty; i++) {
      final color = waiting.removeAt(0);
      active.add(CrewTarget(color, counts[color] ?? 0));
    }

    bench.clear();
    history.clear();
    benchCapacity = 5;
    moves = 0;
    finished = false;
    hintColumn = null;
  }

  Future<void> _loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => coins = prefs.getInt('coins') ?? 200);
  }

  CrewSnapshot _snapshot() {
    return CrewSnapshot(
      columns: columns.map((e) => List<int>.from(e)).toList(),
      bench: List<int>.from(bench),
      active: active.map((e) => e.copy()).toList(),
      waiting: List<int>.from(waiting),
      benchCapacity: benchCapacity,
      moves: moves,
    );
  }

  void _restore(CrewSnapshot snap) {
    columns = snap.columns.map((e) => List<int>.from(e)).toList();
    bench
      ..clear()
      ..addAll(snap.bench);
    active = snap.active.map((e) => e.copy()).toList();
    waiting = List<int>.from(snap.waiting);
    benchCapacity = snap.benchCapacity;
    moves = snap.moves;
    hintColumn = null;
    finished = false;
  }

  int _activeIndexForColor(int color) {
    return active.indexWhere(
      (target) => target.color == color && target.remaining > 0,
    );
  }

  void _tapColumn(int columnIndex) {
    if (finished || columns[columnIndex].isEmpty) return;

    final color = columns[columnIndex].last;
    final targetIndex = _activeIndexForColor(color);

    if (targetIndex < 0 && bench.length >= benchCapacity) {
      _showBenchFull();
      return;
    }

    history.add(_snapshot());

    setState(() {
      columns[columnIndex].removeLast();
      moves++;
      hintColumn = null;

      if (targetIndex >= 0) {
        active[targetIndex].remaining--;
      } else {
        bench.add(color);
      }

      _advanceCrews();
    });

    if (_isSolved()) {
      _finish();
    }
  }

  void _advanceCrews() {
    bool changed = true;
    while (changed) {
      changed = false;

      final finishedIndexes = <int>[];
      for (int i = 0; i < active.length; i++) {
        if (active[i].remaining <= 0) {
          finishedIndexes.add(i);
        }
      }

      for (final index in finishedIndexes.reversed) {
        active.removeAt(index);
        changed = true;
      }

      while (active.length < 3 && waiting.isNotEmpty) {
        final color = waiting.removeAt(0);
        int totalRemaining = 0;
        for (final column in columns) {
          totalRemaining += column.where((c) => c == color).length;
        }
        totalRemaining += bench.where((c) => c == color).length;
        active.add(CrewTarget(color, totalRemaining));
        changed = true;
      }

      for (final target in active) {
        int delivered = 0;
        for (int i = bench.length - 1; i >= 0; i--) {
          if (bench[i] == target.color && target.remaining > 0) {
            bench.removeAt(i);
            target.remaining--;
            delivered++;
          }
        }
        if (delivered > 0) changed = true;
      }
    }
  }

  bool _isSolved() {
    return columns.every((column) => column.isEmpty) &&
        bench.isEmpty &&
        active.isEmpty &&
        waiting.isEmpty;
  }

  void _undo() {
    if (history.isEmpty || finished) return;
    final snap = history.removeLast();
    setState(() => _restore(snap));
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
    for (int i = 0; i < columns.length; i++) {
      if (columns[i].isEmpty) continue;
      final top = columns[i].last;
      if (_activeIndexForColor(top) >= 0) {
        candidate = i;
        break;
      }
    }

    candidate ??= columns.indexWhere((column) => column.isNotEmpty);
    if (candidate < 0) return;

    final prefs = await SharedPreferences.getInstance();
    final newCoins = coins - cost;
    await prefs.setInt('coins', newCoins);
    if (!mounted) return;

    setState(() {
      coins = newCoins;
      hintColumn = candidate;
    });
  }

  Future<void> _addSeat() async {
    if (finished || benchCapacity >= 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum bench capacity is 7.')),
      );
      return;
    }

    const cost = 60;
    if (coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need 60 coins for +1 seat.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final newCoins = coins - cost;
    await prefs.setInt('coins', newCoins);
    if (!mounted) return;

    setState(() {
      coins = newCoins;
      benchCapacity++;
    });
  }

  Future<void> _finish() async {
    if (finished) return;
    finished = true;

    final stars = moves <= columns.length * 6
        ? 3
        : moves <= columns.length * 8
            ? 2
            : 1;

    final prefs = await SharedPreferences.getInstance();
    final key = 'crew_done_${widget.level}';
    final alreadyRewarded = prefs.getBool(key) ?? false;
    int reward = 0;

    if (!alreadyRewarded) {
      reward = 30 + stars * 5;
      await prefs.setInt('coins', (prefs.getInt('coins') ?? 200) + reward);
      await prefs.setInt('stars', (prefs.getInt('stars') ?? 0) + stars);
      await prefs.setBool(key, true);

      final highest = prefs.getInt('crew_highest') ?? 1;
      if (widget.level >= highest && widget.level < 6) {
        await prefs.setInt('crew_highest', widget.level + 1);
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
          'Crew Complete! 🎉',
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
              '$moves moves',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              alreadyRewarded ? 'Level already rewarded' : '+$reward coins',
              style: const TextStyle(
                color: Color(0xFFFF8B39),
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

  void _showBenchFull() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        title: const Text(
          'Bench is full',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Choose a block that matches one of the active crew colors, use Undo, or add a seat.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remainingBlocks =
        columns.fold<int>(0, (sum, column) => sum + column.length);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Level ${widget.level}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            Text(
              '$remainingBlocks blocks left',
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
            colors: [Color(0xFFFFFAF3), Color(0xFFFFEEE0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Tap the top block. Matching colors feed the crew; other colors wait on the bench.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF777083),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _CrewRow(
              active: active,
              colors: crewColors,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    columns.length,
                    (columnIndex) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () => _tapColumn(columnIndex),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: hintColumn == columnIndex
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: .5),
                              borderRadius: BorderRadius.circular(20),
                              border: hintColumn == columnIndex
                                  ? Border.all(
                                      color: const Color(0xFFFF8B39),
                                      width: 3,
                                    )
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: columns[columnIndex]
                                  .map(
                                    (color) => Padding(
                                      padding:
                                          const EdgeInsets.only(top: 5),
                                      child: Container(
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: crewColors[
                                              color % crewColors.length],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: .08),
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .92),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Bench ${bench.length}/$benchCapacity',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF383044),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Moves $moves',
                        style: const TextStyle(
                          color: Color(0xFF8B8495),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(
                      benchCapacity,
                      (i) => Expanded(
                        child: Container(
                          height: 44,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: i < bench.length
                                ? crewColors[bench[i] % crewColors.length]
                                : const Color(0xFFF1EDF3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE1DAE5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _CrewAction(
                          icon: Icons.undo_rounded,
                          label: 'Undo',
                          sub: '${history.length}',
                          onTap: _undo,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CrewAction(
                          icon: Icons.event_seat_rounded,
                          label: '+1 Seat',
                          sub: '60',
                          onTap: _addSeat,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CrewAction(
                          icon: Icons.lightbulb_outline_rounded,
                          label: 'Hint',
                          sub: '30',
                          onTap: _hint,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CrewAction(
                          icon: Icons.restart_alt_rounded,
                          label: 'Restart',
                          sub: '',
                          onTap: () => setState(_reset),
                        ),
                      ),
                    ],
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

class _CrewRow extends StatelessWidget {
  final List<CrewTarget> active;
  final List<Color> colors;

  const _CrewRow({
    required this.active,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 94,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: active
            .map(
              (target) => Container(
                width: 86,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: colors[target.color % colors.length],
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .09),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.sentiment_satisfied_alt_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                    Text(
                      '${target.remaining}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CrewAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;

  const _CrewAction({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF5EC),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 3),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF4A3A2E)),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
              SizedBox(
                height: 14,
                child: sub.isEmpty
                    ? null
                    : Text(
                        sub,
                        style: const TextStyle(
                          color: Color(0xFFFF8B39),
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
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
