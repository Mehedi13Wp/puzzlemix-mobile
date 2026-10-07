import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'arrow_escape.dart';
import 'color_crew.dart';
import 'color_sort_fx.dart';
import 'sound_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SoundManager.instance.initialize();
  runApp(const PuzzleMixApp());
}

class PuzzleMixApp extends StatelessWidget {
  const PuzzleMixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PuzzleMix',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'sans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7A5CFA),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8FC),
      ),
      home: const HomeScreen(),
    );
  }
}

class PuzzleLevel {
  final int id;
  final int par;
  final List<List<int>> tubes;

  const PuzzleLevel({
    required this.id,
    required this.par,
    required this.tubes,
  });
}

const int tubeCapacity = 4;

const gameColors = <Color>[
  Color(0xFFFF5C72),
  Color(0xFF38C88A),
  Color(0xFF7A5CFA),
  Color(0xFFFFA52F),
  Color(0xFF2DC8C4),
  Color(0xFFFF67B0),
  Color(0xFF8BD63D),
  Color(0xFF3FA9F5),
];

final levels = <PuzzleLevel>[
  const PuzzleLevel(
    id: 1,
    par: 8,
    tubes: [
      [0, 1, 0, 1],
      [1, 0, 1, 0],
      [2, 2, 2, 2],
      [],
      [],
    ],
  ),
  const PuzzleLevel(
    id: 2,
    par: 12,
    tubes: [
      [0, 1, 2, 0],
      [1, 2, 0, 1],
      [2, 0, 1, 2],
      [],
      [],
    ],
  ),
  const PuzzleLevel(
    id: 3,
    par: 18,
    tubes: [
      [0, 1, 2, 3],
      [1, 2, 3, 0],
      [2, 3, 0, 1],
      [3, 0, 1, 2],
      [],
      [],
    ],
  ),
  const PuzzleLevel(
    id: 4,
    par: 20,
    tubes: [
      [4, 0, 1, 2],
      [2, 4, 0, 1],
      [1, 2, 4, 0],
      [0, 1, 2, 4],
      [],
      [],
    ],
  ),
  const PuzzleLevel(
    id: 5,
    par: 24,
    tubes: [
      [0, 1, 2, 3],
      [4, 0, 1, 2],
      [3, 4, 0, 1],
      [2, 3, 4, 0],
      [1, 2, 3, 4],
      [],
      [],
    ],
  ),
  const PuzzleLevel(
    id: 6,
    par: 28,
    tubes: [
      [0, 5, 2, 3],
      [4, 0, 5, 2],
      [3, 4, 0, 5],
      [2, 3, 4, 0],
      [5, 2, 3, 4],
      [],
      [],
    ],
  ),
];

const dailyLevel = PuzzleLevel(
  id: 1000,
  par: 21,
  tubes: [
    [0, 1, 2, 3],
    [1, 2, 3, 4],
    [2, 3, 4, 0],
    [3, 4, 0, 1],
    [4, 0, 1, 2],
    [],
    [],
  ],
);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int coins = 200;
  int stars = 0;
  int highestLevel = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      coins = prefs.getInt('coins') ?? 200;
      stars = prefs.getInt('stars') ?? 0;
      highestLevel = prefs.getInt('highest_level') ?? 1;
    });
  }

  Future<void> _openLevels() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
    );
    await _load();
  }

  Future<void> _openDaily() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ColorSortScreen(level: dailyLevel, daily: true),
      ),
    );
    await _load();
  }

  Future<void> _openArrow() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ArrowLevelSelectScreen()),
    );
    await _load();
  }

  Future<void> _openCrew() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CrewLevelSelectScreen()),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFE8F2), Color(0xFFEDE8FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(34),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PuzzleMix',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF241E3A),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Play. Think. Relax.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF756E8B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StatPill(icon: Icons.monetization_on_rounded, value: '$coins'),
                        const SizedBox(width: 6),
                        _StatPill(icon: Icons.star_rounded, value: '$stars'),
                        const SizedBox(width: 4),
                        AnimatedBuilder(
                          animation: SoundManager.instance,
                          builder: (_, __) => IconButton(
                            tooltip: SoundManager.instance.enabled
                                ? 'Sound on'
                                : 'Sound off',
                            onPressed: () => SoundManager.instance.toggle(),
                            icon: Icon(
                              SoundManager.instance.enabled
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_off_rounded,
                              color: const Color(0xFF7658F4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    FilledButton.icon(
                      onPressed: _openLevels,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(58),
                        backgroundColor: const Color(0xFF7658F4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 30),
                      label: Text(
                        'CONTINUE  •  LEVEL $highestLevel',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: .4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const Text(
                    'Daily Challenge',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF241E3A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DailyCard(onTap: _openDaily),
                  const SizedBox(height: 26),
                  const Text(
                    'Puzzle Collection',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF241E3A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ModeCard(
                    icon: Icons.science_rounded,
                    title: 'Color Sort',
                    subtitle: 'Sort every color into its own vial',
                    label: 'PLAY',
                    active: true,
                    onTap: _openLevels,
                  ),
                  const SizedBox(height: 12),
                  _ModeCard(
                    icon: Icons.alt_route_rounded,
                    title: 'Arrow Escape',
                    subtitle: 'Clear arrows in the correct order',
                    label: 'PLAY',
                    active: true,
                    onTap: _openArrow,
                  ),
                  const SizedBox(height: 12),
                  _ModeCard(
                    icon: Icons.grid_view_rounded,
                    title: 'Color Crew',
                    subtitle: 'Match characters with colored blocks',
                    label: 'PLAY',
                    active: true,
                    onTap: _openCrew,
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'Version 0.4 • Premium sound + liquid FX',
                      style: TextStyle(
                        color: Color(0xFF9992AA),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;

  const _StatPill({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .82),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFAF27), size: 22),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _DailyCard extends StatelessWidget {
  final VoidCallback onTap;

  const _DailyCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF739E), Color(0xFFFFA15D)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 31,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Prism',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${now.day} ${months[now.month - 1]}  •  Par 21  •  +100 coins',
                      style: const TextStyle(
                        color: Color(0xFF777085),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.label,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? Colors.white : const Color(0xFFF4F1F7),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: active ? onTap : null,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFEDE8FF)
                      : const Color(0xFFE6E2EA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: active
                      ? const Color(0xFF7658F4)
                      : const Color(0xFFAAA3B3),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: active
                            ? const Color(0xFF241E3A)
                            : const Color(0xFF918A9C),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF8B8497),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: active
                      ? const Color(0xFF7658F4)
                      : const Color(0xFFAAA3B3),
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
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
      highest = prefs.getInt('highest_level') ?? 1;
      stars = prefs.getInt('stars') ?? 0;
    });
  }

  Future<void> _play(PuzzleLevel level) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ColorSortScreen(level: level),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Color Sort',
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
        itemCount: levels.length,
        itemBuilder: (_, index) {
          final level = levels[index];
          final unlocked = level.id <= highest;
          return InkWell(
            onTap: unlocked ? () => _play(level) : null,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              decoration: BoxDecoration(
                color: unlocked ? Colors.white : const Color(0xFFF0EDF3),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: unlocked
                      ? const Color(0xFFE5DFF9)
                      : const Color(0xFFE5E1E8),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    unlocked ? Icons.science_rounded : Icons.lock_rounded,
                    color: unlocked
                        ? const Color(0xFF7658F4)
                        : const Color(0xFFAAA3B3),
                    size: 30,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Level ${level.id}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    unlocked ? 'Par ${level.par}' : 'Locked',
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

class GameSnapshot {
  final List<List<int>> tubes;
  final int moves;

  GameSnapshot(this.tubes, this.moves);
}

class ColorSortScreen extends StatefulWidget {
  final PuzzleLevel level;
  final bool daily;

  const ColorSortScreen({
    super.key,
    required this.level,
    this.daily = false,
  });

  @override
  State<ColorSortScreen> createState() => _ColorSortScreenState();
}

class _ColorSortScreenState extends State<ColorSortScreen> {
  late List<List<int>> tubes;
  final List<GameSnapshot> history = [];
  int moves = 0;
  int? selected;
  int coins = 200;
  bool finished = false;
  bool isPouring = false;
  int? pouringFrom;
  int? pouringTo;

  @override
  void initState() {
    super.initState();
    _resetBoard();
    _loadCoins();
  }

  void _resetBoard() {
    tubes = widget.level.tubes.map((e) => List<int>.from(e)).toList();
    history.clear();
    moves = 0;
    selected = null;
    finished = false;
    isPouring = false;
    pouringFrom = null;
    pouringTo = null;
  }

  Future<void> _loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => coins = prefs.getInt('coins') ?? 200);
  }

  bool _canPour(int from, int to) {
    if (from == to || tubes[from].isEmpty || tubes[to].length >= tubeCapacity) {
      return false;
    }
    if (tubes[to].isEmpty) return true;
    return tubes[from].last == tubes[to].last;
  }

  int _pourAmount(int from, int to) {
    final src = tubes[from];
    final top = src.last;
    int same = 0;
    for (int i = src.length - 1; i >= 0 && src[i] == top; i--) {
      same++;
    }
    return math.min(same, tubeCapacity - tubes[to].length);
  }

  Future<void> _tapTube(int index) async {
    if (finished || isPouring) return;

    if (selected == null) {
      if (tubes[index].isNotEmpty) {
        SoundManager.instance.tap();
        setState(() => selected = index);
      }
      return;
    }

    if (selected == index) {
      SoundManager.instance.tap();
      setState(() => selected = null);
      return;
    }

    final from = selected!;
    if (!_canPour(from, index)) {
      SoundManager.instance.error();
      setState(() {
        selected = tubes[index].isNotEmpty ? index : null;
      });
      return;
    }

    history.add(
      GameSnapshot(
        tubes.map((e) => List<int>.from(e)).toList(),
        moves,
      ),
    );

    final amount = _pourAmount(from, index);

    SoundManager.instance.pour();

    setState(() {
      isPouring = true;
      pouringFrom = from;
      pouringTo = index;
      selected = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;

    setState(() {
      for (int i = 0; i < amount; i++) {
        tubes[index].add(tubes[from].removeLast());
      }
      moves++;
    });

    final targetSolved = tubes[index].length == tubeCapacity &&
        tubes[index].every((c) => c == tubes[index].first);
    if (targetSolved) {
      SoundManager.instance.match();
    }

    await Future<void>.delayed(const Duration(milliseconds: 360));
    if (!mounted) return;

    setState(() {
      isPouring = false;
      pouringFrom = null;
      pouringTo = null;
    });

    if (_isSolved()) {
      await _finishLevel();
    }
  }

  bool _isSolved() {
    for (final tube in tubes) {
      if (tube.isEmpty) continue;
      if (tube.length != tubeCapacity) return false;
      if (tube.any((c) => c != tube.first)) return false;
    }
    return true;
  }

  Future<void> _finishLevel() async {
    if (finished) return;
    finished = true;

    final prefs = await SharedPreferences.getInstance();
    final stars = moves <= widget.level.par
        ? 3
        : moves <= widget.level.par + 5
            ? 2
            : 1;

    final date = DateTime.now();
    final dailyKey =
        'daily_done_${date.year}_${date.month}_${date.day}';
    final completionKey =
        widget.daily ? dailyKey : 'level_done_${widget.level.id}';
    final alreadyRewarded = prefs.getBool(completionKey) ?? false;

    int reward = 0;
    if (!alreadyRewarded) {
      reward = widget.daily ? 100 : 20 + (stars * 5);
      final newCoins = (prefs.getInt('coins') ?? 200) + reward;
      final newStars = (prefs.getInt('stars') ?? 0) + stars;
      await prefs.setInt('coins', newCoins);
      await prefs.setInt('stars', newStars);
      await prefs.setBool(completionKey, true);

      if (!widget.daily) {
        final highest = prefs.getInt('highest_level') ?? 1;
        if (widget.level.id >= highest && widget.level.id < levels.length) {
          await prefs.setInt('highest_level', widget.level.id + 1);
        }
      }
    }

    if (!mounted) return;
    await _loadCoins();
    SoundManager.instance.success();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => LevelCompleteCelebration(
        stars: stars,
        moves: moves,
        par: widget.level.par,
        reward: reward,
        alreadyRewarded: alreadyRewarded,
        onContinue: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop(true);
        },
      ),
    );
  }

  void _undo() {
    if (history.isEmpty || finished) return;
    final last = history.removeLast();
    setState(() {
      tubes = last.tubes.map((e) => List<int>.from(e)).toList();
      moves = last.moves;
      selected = null;
    });
  }

  void _restart() {
    setState(_resetBoard);
  }

  Future<void> _hint() async {
    if (finished) return;
    int from = -1;
    int to = -1;

    outer:
    for (int i = 0; i < tubes.length; i++) {
      if (tubes[i].isEmpty) continue;
      for (int j = 0; j < tubes.length; j++) {
        if (_canPour(i, j)) {
          if (tubes[j].isEmpty && tubes[i].every((c) => c == tubes[i].first)) {
            continue;
          }
          from = i;
          to = j;
          break outer;
        }
      }
    }

    if (from < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No useful move found. Try Undo.')),
      );
      return;
    }

    const cost = 30;
    if (coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need 30 coins for a hint.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final newCoins = coins - cost;
    await prefs.setInt('coins', newCoins);
    if (!mounted) return;
    setState(() => coins = newCoins);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Hint: Tube ${from + 1}  →  Tube ${to + 1}'),
      ),
    );
  }

  Future<void> _addVial() async {
    if (finished) return;
    if (tubes.length >= widget.level.tubes.length + 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 2 extra vials.')),
      );
      return;
    }
    const cost = 50;
    if (coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need 50 coins for an extra vial.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final newCoins = coins - cost;
    await prefs.setInt('coins', newCoins);
    if (!mounted) return;
    setState(() {
      coins = newCoins;
      tubes.add([]);
      selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.daily ? 'Daily Prism' : 'Level ${widget.level.id}';
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            Text(
              'Moves $moves  •  Par ${widget.level.par}',
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
            padding: const EdgeInsets.only(right: 15),
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
            colors: [
              Color(0xFFFFF5FA),
              Color(0xFFF0E9FF),
              Color(0xFFEAF5FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Tap a vial, then tap another vial to pour matching colors.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF777083),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 25,
                    children: List.generate(
                      tubes.length,
                      (index) => RealisticTube(
                        number: index + 1,
                        layers: tubes[index],
                        palette: gameColors,
                        selected: selected == index,
                        pouringOut: pouringFrom == index,
                        pouringIn: pouringTo == index,
                        onTap: () => _tapTube(index),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .86),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _GameAction(
                      icon: Icons.undo_rounded,
                      label: 'Undo',
                      small: '${history.length}',
                      onTap: _undo,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _GameAction(
                      icon: Icons.science_outlined,
                      label: '+ Vial',
                      small: '50',
                      onTap: _addVial,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _GameAction(
                      icon: Icons.lightbulb_outline_rounded,
                      label: 'Hint',
                      small: '30',
                      onTap: _hint,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _GameAction(
                      icon: Icons.restart_alt_rounded,
                      label: 'Restart',
                      small: '',
                      onTap: _restart,
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

class TubeView extends StatelessWidget {
  final int number;
  final List<int> colors;
  final bool selected;
  final VoidCallback onTap;

  const TubeView({
    super.key,
    required this.number,
    required this.colors,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const tubeHeight = 158.0;
    const tubeWidth = 58.0;
    const innerHeight = 142.0;
    const segmentHeight = innerHeight / tubeCapacity;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        transform: Matrix4.translationValues(0, selected ? -10 : 0, 0),
        child: Column(
          children: [
            Container(
              width: tubeWidth,
              height: tubeHeight,
              padding: const EdgeInsets.fromLTRB(5, 8, 5, 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .42),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF7658F4)
                      : const Color(0xFFCBC4D4),
                  width: selected ? 3 : 2,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(26),
                  bottomRight: Radius.circular(26),
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF7658F4).withValues(alpha: .20),
                          blurRadius: 14,
                          spreadRadius: 3,
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: colors.reversed
                      .map(
                        (id) => Container(
                          height: segmentHeight,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: gameColors[id],
                            border: Border(
                              top: BorderSide(
                                color: Colors.white.withValues(alpha: .18),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '$number',
              style: const TextStyle(
                color: Color(0xFF9A93A5),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String small;
  final VoidCallback onTap;

  const _GameAction({
    required this.icon,
    required this.label,
    required this.small,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F3FB),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF332C45)),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              SizedBox(
                height: 15,
                child: small.isEmpty
                    ? null
                    : Text(
                        small,
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
