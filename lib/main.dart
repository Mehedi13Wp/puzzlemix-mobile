import 'ads/ad_service.dart';
import 'ads/ad_widgets.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'arrow_escape.dart';
import 'color_crew.dart';
import 'color_sort_fx.dart';
import 'fruit_jar_board.dart';
import 'sound_manager.dart';
import 'privacy_policy.dart';

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
          seedColor: const Color(0xFF197844),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F9EE),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1350), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PremiumFruitBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .82),
                  borderRadius: BorderRadius.circular(34),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF185F39).withValues(alpha: .20),
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: const Center(
                  child: FruitToken(fruitId: 5, size: 78),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'PuzzleMix',
                style: TextStyle(
                  color: Color(0xFF164D2D),
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.8,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Relax. Match. Enjoy.',
                style: TextStyle(
                  color: Color(0xFF5E7B65),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
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
  Color(0xFFFFD43B),
  Color(0xFFFF922B),
  Color(0xFFFFB13B),
  Color(0xFFE94A55),
  Color(0xFF8458C8),
  Color(0xFFF34E64),
  Color(0xFF7CB342),
  Color(0xFFA7C84B),
];

final levels = <PuzzleLevel>[
  const PuzzleLevel(id: 1, par: 6, tubes: [
    [0, 0, 0, 1],
    [1, 1, 0, 1],
    [],
    []
  ]),
  const PuzzleLevel(id: 2, par: 7, tubes: [
    [1, 1, 0, 0],
    [1, 0, 1, 0],
    [],
    []
  ]),
  const PuzzleLevel(id: 3, par: 10, tubes: [
    [0, 1, 0, 2],
    [1, 0, 0, 2],
    [1, 2, 2, 1],
    [],
    []
  ]),
  const PuzzleLevel(id: 4, par: 9, tubes: [
    [0, 2, 2, 1],
    [0, 1, 1, 2],
    [1, 2, 0, 0],
    [],
    []
  ]),
  const PuzzleLevel(id: 5, par: 8, tubes: [
    [2, 0, 0, 0],
    [1, 2, 0, 2],
    [1, 1, 1, 2],
    [],
    []
  ]),
  const PuzzleLevel(id: 6, par: 13, tubes: [
    [3, 2, 2, 0],
    [0, 1, 2, 3],
    [3, 1, 1, 2],
    [3, 1, 0, 0],
    [],
    []
  ]),
  const PuzzleLevel(id: 7, par: 15, tubes: [
    [2, 2, 3, 1],
    [2, 0, 3, 1],
    [3, 0, 2, 0],
    [3, 1, 0, 1],
    [],
    []
  ]),
  const PuzzleLevel(id: 8, par: 12, tubes: [
    [2, 2, 0, 2],
    [3, 3, 0, 1],
    [1, 2, 0, 1],
    [0, 3, 3, 1],
    [],
    []
  ]),
  const PuzzleLevel(id: 9, par: 18, tubes: [
    [1, 0, 3, 2],
    [4, 0, 2, 2],
    [3, 2, 1, 0],
    [0, 4, 1, 4],
    [4, 3, 1, 3],
    [],
    []
  ]),
  const PuzzleLevel(id: 10, par: 18, tubes: [
    [2, 3, 4, 3],
    [0, 0, 4, 1],
    [2, 0, 1, 4],
    [4, 3, 3, 1],
    [2, 1, 0, 2],
    [],
    []
  ]),
  const PuzzleLevel(id: 11, par: 17, tubes: [
    [4, 0, 3, 4],
    [1, 1, 1, 4],
    [3, 4, 0, 1],
    [2, 0, 3, 2],
    [0, 3, 2, 2],
    [],
    []
  ]),
  const PuzzleLevel(id: 12, par: 21, tubes: [
    [0, 4, 2, 4],
    [5, 1, 0, 3],
    [5, 5, 3, 3],
    [1, 0, 2, 2],
    [0, 2, 1, 4],
    [1, 3, 5, 4],
    [],
    []
  ]),
  const PuzzleLevel(id: 13, par: 20, tubes: [
    [2, 5, 3, 3],
    [1, 4, 5, 2],
    [4, 3, 0, 5],
    [2, 3, 4, 4],
    [1, 1, 0, 0],
    [0, 1, 2, 5],
    [],
    []
  ]),
  const PuzzleLevel(id: 14, par: 23, tubes: [
    [0, 3, 4, 1],
    [0, 5, 2, 1],
    [0, 1, 2, 2],
    [3, 4, 1, 5],
    [0, 4, 5, 4],
    [3, 3, 5, 2],
    [],
    []
  ]),
  const PuzzleLevel(id: 15, par: 21, tubes: [
    [5, 4, 2, 0],
    [4, 3, 0, 2],
    [4, 4, 1, 5],
    [1, 2, 1, 1],
    [5, 3, 5, 3],
    [3, 0, 0, 2],
    [],
    []
  ]),
  const PuzzleLevel(id: 16, par: 18, tubes: [
    [4, 1, 4, 2],
    [4, 0, 3, 2],
    [3, 1, 3, 2],
    [1, 3, 4, 0],
    [0, 2, 0, 1],
    [],
    [],
  ]),
  const PuzzleLevel(id: 17, par: 18, tubes: [
    [4, 1, 1, 3],
    [0, 3, 4, 2],
    [3, 0, 2, 0],
    [3, 4, 0, 2],
    [4, 1, 1, 2],
    [],
    [],
  ]),
  const PuzzleLevel(id: 18, par: 26, tubes: [
    [4, 3, 2, 0],
    [3, 3, 2, 1],
    [1, 2, 0, 4],
    [1, 2, 1, 4],
    [0, 4, 0, 3],
    [],
    [],
  ]),
  const PuzzleLevel(id: 19, par: 20, tubes: [
    [2, 2, 1, 4],
    [2, 1, 0, 0],
    [2, 3, 4, 4],
    [0, 3, 1, 0],
    [4, 1, 3, 3],
    [],
    [],
  ]),
  const PuzzleLevel(id: 20, par: 18, tubes: [
    [1, 2, 4, 3],
    [0, 3, 0, 4],
    [2, 3, 1, 4],
    [3, 1, 2, 4],
    [2, 0, 1, 0],
    [],
    [],
  ]),
  const PuzzleLevel(id: 21, par: 26, tubes: [
    [1, 4, 3, 5],
    [0, 4, 1, 2],
    [5, 2, 0, 0],
    [3, 3, 1, 4],
    [2, 1, 5, 3],
    [4, 2, 0, 5],
    [],
    [],
  ]),
  const PuzzleLevel(id: 22, par: 32, tubes: [
    [5, 4, 5, 4],
    [2, 1, 0, 1],
    [0, 1, 4, 5],
    [1, 2, 3, 3],
    [5, 4, 2, 0],
    [0, 3, 3, 2],
    [],
    [],
  ]),
  const PuzzleLevel(id: 23, par: 28, tubes: [
    [2, 0, 3, 0],
    [5, 2, 3, 2],
    [2, 4, 0, 0],
    [4, 3, 5, 5],
    [3, 1, 4, 4],
    [5, 1, 1, 1],
    [],
    [],
  ]),
  const PuzzleLevel(id: 24, par: 26, tubes: [
    [5, 4, 1, 5],
    [1, 5, 4, 0],
    [2, 4, 1, 1],
    [2, 0, 0, 2],
    [3, 0, 3, 5],
    [2, 3, 3, 4],
    [],
    [],
  ]),
  const PuzzleLevel(id: 25, par: 23, tubes: [
    [4, 5, 0, 4],
    [3, 2, 3, 3],
    [1, 0, 5, 2],
    [3, 0, 1, 1],
    [4, 5, 4, 5],
    [1, 2, 2, 0],
    [],
    [],
  ]),
  const PuzzleLevel(id: 26, par: 37, tubes: [
    [3, 4, 1, 5],
    [2, 4, 1, 5],
    [0, 6, 2, 4],
    [5, 0, 3, 5],
    [2, 6, 6, 3],
    [3, 2, 1, 0],
    [4, 1, 0, 6],
    [],
    [],
  ]),
  const PuzzleLevel(id: 27, par: 23, tubes: [
    [1, 5, 2, 1],
    [3, 3, 3, 2],
    [2, 2, 0, 1],
    [6, 3, 5, 4],
    [0, 0, 4, 4],
    [0, 6, 6, 5],
    [1, 4, 6, 5],
    [],
    [],
  ]),
  const PuzzleLevel(id: 28, par: 24, tubes: [
    [1, 0, 5, 5],
    [2, 3, 6, 6],
    [2, 5, 4, 1],
    [1, 4, 0, 5],
    [4, 3, 2, 0],
    [2, 1, 6, 0],
    [6, 3, 4, 3],
    [],
    [],
  ]),
  const PuzzleLevel(id: 29, par: 37, tubes: [
    [4, 3, 2, 0],
    [5, 2, 1, 3],
    [1, 5, 4, 5],
    [5, 6, 0, 1],
    [6, 4, 3, 2],
    [2, 6, 0, 3],
    [0, 4, 6, 1],
    [],
    [],
  ]),
  const PuzzleLevel(id: 30, par: 41, tubes: [
    [1, 4, 2, 0],
    [0, 3, 5, 0],
    [1, 6, 5, 0],
    [4, 3, 3, 6],
    [2, 5, 1, 5],
    [6, 4, 6, 2],
    [1, 3, 2, 4],
    [],
    [],
  ]),
];

int highestUnlockedFruitLevel(SharedPreferences prefs) {
  var highest = (prefs.getInt('highest_level') ?? 1).clamp(1, levels.length);
  while (
      highest < levels.length && prefs.getBool('level_done_$highest') == true) {
    highest++;
  }
  return highest;
}

const dailyLevel = PuzzleLevel(
  id: 1000,
  par: 24,
  tubes: [
    [2, 4, 6, 5],
    [0, 2, 1, 2],
    [0, 1, 6, 4],
    [2, 3, 3, 0],
    [5, 4, 3, 6],
    [5, 5, 0, 6],
    [1, 1, 3, 4],
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

  int get playerLevel => 1 + (stars ~/ 12);
  int get xpCurrent => stars % 12;
  int get xpTarget => 12;

  @override
  void initState() {
    super.initState();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SoundManager.instance.startBackground();
      AdService.instance.initialize();
    });
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      coins = prefs.getInt('coins') ?? 200;
      stars = prefs.getInt('stars') ?? 0;
      highestLevel = highestUnlockedFruitLevel(prefs);
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
      bottomNavigationBar: const HomeAdBanner(),
      body: ColoredBox(
        color: const Color(0xFF101E1B),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFFFD25F),
                                            Color(0xFFFFA62E),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFFB83E)
                                                .withValues(alpha: .22),
                                            blurRadius: 16,
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: FruitToken(fruitId: 5, size: 29),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'PuzzleMix',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 31,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -.8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'Your cozy puzzle garden',
                                  style: TextStyle(
                                    color: Color(0xFFBFE7C8),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _StatPill(
                            icon: Icons.monetization_on_rounded,
                            value: coins.toString(),
                          ),
                          const SizedBox(width: 6),
                          _StatPill(
                            icon: Icons.star_rounded,
                            value: stars.toString(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _PlayerProgressCard(
                              level: playerLevel,
                              xp: xpCurrent,
                              target: xpTarget,
                              highestLevel: highestLevel,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Column(
                            children: [
                              _RoundIconButton(
                                icon: Icons.privacy_tip_outlined,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const PrivacyPolicyScreen(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              AnimatedBuilder(
                                animation: SoundManager.instance,
                                builder: (_, __) => _RoundIconButton(
                                  icon: SoundManager.instance.enabled
                                      ? Icons.volume_up_rounded
                                      : Icons.volume_off_rounded,
                                  onTap: () => SoundManager.instance.toggle(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _FruitHeroCard(
                        level: highestLevel,
                        onTap: _openLevels,
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 34),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const _SectionTitle(
                      title: 'Daily Harvest',
                      subtitle: 'One fresh challenge. One juicy reward.',
                    ),
                    const SizedBox(height: 11),
                    _DailyCard(onTap: _openDaily),
                    const SizedBox(height: 24),
                    const _SectionTitle(
                      title: 'Puzzle Collection',
                      subtitle: 'Pick a mood and jump right in',
                    ),
                    const SizedBox(height: 11),
                    _ModeCard(
                      icon: Icons.spa_rounded,
                      title: 'Fruit Sort Deluxe',
                      subtitle: 'Match premium fruit pieces in glass jars',
                      label: 'PLAY',
                      accent: Color(0xFFFFC34A),
                      onTap: _openLevels,
                    ),
                    const SizedBox(height: 11),
                    _ModeCard(
                      icon: Icons.alt_route_rounded,
                      title: 'Arrow Escape',
                      subtitle: 'Clear every arrow in the right order',
                      label: 'PLAY',
                      accent: Color(0xFF72D8A0),
                      onTap: _openArrow,
                    ),
                    const SizedBox(height: 11),
                    _ModeCard(
                      icon: Icons.grid_view_rounded,
                      title: 'Color Crew',
                      subtitle: 'Match colorful blocks with your crew',
                      label: 'PLAY',
                      accent: Color(0xFF9CC8FF),
                      onTap: _openCrew,
                    ),
                    const SizedBox(height: 28),
                    const Center(
                      child: Text(
                        'PuzzleMix  •  Relax. Match. Enjoy.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF8FC39B),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerProgressCard extends StatelessWidget {
  final int level;
  final int xp;
  final int target;
  final int highestLevel;

  const _PlayerProgressCard({
    required this.level,
    required this.xp,
    required this.target,
    required this.highestLevel,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target == 0 ? 0.0 : (xp / target).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .075),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: .10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFB9F66B),
                  Color(0xFF52D987),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                level.toString(),
                style: const TextStyle(
                  color: Color(0xFF123B25),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'PLAYER LEVEL $level',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .3,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Stage $highestLevel',
                      style: const TextStyle(
                        color: Color(0xFFA9D4B4),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: Colors.white.withValues(alpha: .10),
                    valueColor: const AlwaysStoppedAnimation(
                      Color(0xFFD6FF62),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$xp / $target stars to next level',
                  style: const TextStyle(
                    color: Color(0xFF91C29E),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
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

class _FruitHeroCard extends StatelessWidget {
  final int level;
  final VoidCallback onTap;
  const _FruitHeroCard({required this.level, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF20382E),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: .09)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(
                child: Text('CONTINUE YOUR JOURNEY',
                    style: TextStyle(
                        color: Color(0xFFA5CCB5),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3))),
            const FruitToken(fruitId: 5, size: 36),
          ]),
          const SizedBox(height: 14),
          const Text('Fruit Sort',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.7)),
          const SizedBox(height: 8),
          const Text('A little focus. A satisfying match.',
              style: TextStyle(
                  color: Color(0xFFB4CBBE), fontSize: 13, height: 1.5)),
          const SizedBox(height: 18),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _MiniFeature(
                icon: Icons.layers_outlined, text: '${levels.length} levels'),
            _MiniFeature(icon: Icons.spa_outlined, text: 'At your own pace'),
          ]),
          const SizedBox(height: 20),
          FilledButton.icon(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFC5E5B6),
                  foregroundColor: const Color(0xFF173524),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text('Continue · Level $level',
                  style: const TextStyle(fontWeight: FontWeight.w700))),
        ]),
      );
}

class _MiniFeature extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniFeature({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .085),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: .08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFD8F7DF), size: 14),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFD8F7DF),
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;

  const _StatPill({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF20342D).withValues(alpha: .86),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: .10),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFC34A), size: 19),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF20342D).withValues(alpha: .88),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: const Color(0xFFDDF4E3),
            size: 21,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF8FC39B),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1A2E27),
                Color(0xFF1A2E27),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFFD25F).withValues(alpha: .16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .13),
                blurRadius: 20,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFE27A),
                        Color(0xFFFFA62E),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFB83E).withValues(alpha: .25),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFF21472C),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Daily Harvest',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD25F)
                                  .withValues(alpha: .14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              '+100',
                              style: TextStyle(
                                color: Color(0xFFFFD25F),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        now.day.toString() +
                            ' ' +
                            months[now.month - 1] +
                            '  •  Par 24',
                        style: const TextStyle(
                          color: Color(0xFFB6DCC0),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Complete today\'s special board',
                        style: TextStyle(
                          color: Color(0xFF86B895),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFFD6F3DD),
                    size: 20,
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

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(23),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(23),
        child: Ink(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1A2E27),
                Color(0xFF1A2E27),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(23),
            border: Border.all(
              color: Colors.white.withValues(alpha: .075),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: accent.withValues(alpha: .28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: .08),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Icon(icon, color: accent, size: 28),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF9AC5A6),
                        fontSize: 12.2,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 9),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accent.withValues(alpha: .20),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 10.5,
                    letterSpacing: .4,
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
      highest = highestUnlockedFruitLevel(prefs);
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
      body: PremiumFruitBackground(
        dark: true,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fruit Sort Deluxe',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Choose your next harvest',
                            style: TextStyle(
                              color: Color(0xFF99CBA6),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatPill(
                      icon: Icons.star_rounded,
                      value: stars.toString(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: .84,
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
                          gradient: unlocked
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF155D36),
                                    Color(0xFF0C4729),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: unlocked
                              ? null
                              : const Color(0xFF123521).withValues(alpha: .78),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: unlocked
                                ? const Color(0xFF4FAE69).withValues(alpha: .45)
                                : Colors.white.withValues(alpha: .06),
                          ),
                          boxShadow: unlocked
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: .16),
                                    blurRadius: 14,
                                    offset: const Offset(0, 8),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (unlocked)
                              FruitToken(
                                fruitId: index % fruitNames.length,
                                size: 48,
                              )
                            else
                              const Icon(
                                Icons.lock_rounded,
                                color: Color(0xFF6E8E77),
                                size: 30,
                              ),
                            const SizedBox(height: 8),
                            Text(
                              'LEVEL ' + level.id.toString(),
                              style: TextStyle(
                                color: unlocked
                                    ? Colors.white
                                    : const Color(0xFF76917D),
                                fontWeight: FontWeight.w900,
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              unlocked
                                  ? 'Par ' + level.par.toString()
                                  : 'Locked',
                              style: TextStyle(
                                color: unlocked
                                    ? const Color(0xFFA9D4B4)
                                    : const Color(0xFF617D69),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
  int? celebrationTube;
  int? pouringFruit;
  int pourStep = 0;
  int _boardGeneration = 0;

  @override
  void initState() {
    super.initState();
    _resetBoard();
    _loadCoins();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowTutorial();
    });
  }

  void _resetBoard() {
    _boardGeneration++;
    tubes = widget.level.tubes.map((e) => List<int>.from(e)).toList();
    history.clear();
    moves = 0;
    selected = null;
    finished = false;
    isPouring = false;
    pouringFrom = null;
    pouringTo = null;
    celebrationTube = null;
    pouringFruit = null;
  }

  Future<void> _loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => coins = prefs.getInt('coins') ?? 200);
  }

  Future<void> _maybeShowTutorial() async {
    if (widget.daily || widget.level.id != 1) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('fruit_tutorial_seen') ?? false) return;
    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (!mounted) return;
    await _showTutorial();
    await prefs.setBool('fruit_tutorial_seen', true);
  }

  Future<void> _showTutorial() async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        title: const Text(
          'How to Play 🍓',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF174D2D),
            fontWeight: FontWeight.w900,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TutorialRow(
              fruitId: 3,
              title: '1. Tap a jar',
              text: 'Choose the top fruit you want to move.',
            ),
            SizedBox(height: 13),
            _TutorialRow(
              fruitId: 1,
              title: '2. Tap another jar',
              text: 'Use an empty jar or place it on the same fruit.',
            ),
            SizedBox(height: 13),
            _TutorialRow(
              fruitId: 2,
              title: '3. Complete every jar',
              text: 'Fill each jar with four matching fruits.',
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF197844),
            ),
            child: const Text(
              'GOT IT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
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
        HapticFeedback.selectionClick();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 900),
          content: Text('Only matching fruits can stack 🍊'),
        ),
      );
      return;
    }

    history.add(
      GameSnapshot(
        tubes.map((e) => List<int>.from(e)).toList(),
        moves,
      ),
    );

    final amount = _pourAmount(from, index);
    final generation = _boardGeneration;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    SoundManager.instance.whoosh();
    HapticFeedback.lightImpact();

    setState(() {
      isPouring = true;
      pouringFrom = from;
      pouringTo = index;
      pouringFruit = tubes[from].last;
      pourStep++;
      selected = null;
    });

    for (int i = 0; i < amount; i++) {
      await Future<void>.delayed(
        Duration(milliseconds: reduceMotion ? 30 : 360),
      );
      if (!mounted || generation != _boardGeneration) return;
      setState(() {
        tubes[index].add(tubes[from].removeLast());
        if (i + 1 < amount) {
          pourStep++;
        } else {
          pouringFruit = null;
        }
      });
      SoundManager.instance.pop();
    }
    setState(() {
      moves++;
    });

    final targetSolved = tubes[index].length == tubeCapacity &&
        tubes[index].every((c) => c == tubes[index].first);
    if (targetSolved) {
      SoundManager.instance.match();
      HapticFeedback.mediumImpact();
      setState(() => celebrationTube = index);
    }

    await Future<void>.delayed(
      Duration(milliseconds: reduceMotion ? 30 : (targetSolved ? 950 : 260)),
    );
    if (!mounted || generation != _boardGeneration) return;

    setState(() {
      isPouring = false;
      pouringFrom = null;
      pouringTo = null;
      celebrationTube = null;
      pouringFruit = null;
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
    if (finished || isPouring) return;
    finished = true;

    final prefs = await SharedPreferences.getInstance();
    final stars = moves <= widget.level.par
        ? 3
        : moves <= widget.level.par + 5
            ? 2
            : 1;

    final date = DateTime.now();
    final dailyKey = 'daily_done_${date.year}_${date.month}_${date.day}';
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
    }

    if (!widget.daily) {
      final highest = math.max(highestUnlockedFruitLevel(prefs),
          math.min(widget.level.id + 1, levels.length));
      if (highest != prefs.getInt('highest_level')) {
        await prefs.setInt('highest_level', highest);
      }
    }

    if (!mounted) return;
    await _loadCoins();
    SoundManager.instance.success();
    HapticFeedback.heavyImpact();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => LevelCompleteCelebration(
        stars: stars,
        moves: moves,
        par: widget.level.par,
        reward: reward,
        alreadyRewarded: alreadyRewarded,
        onContinue: () {
          continueAfterCompletion(dialogContext);
        },
      ),
    );
  }

  void _undo() {
    if (history.isEmpty || finished || isPouring) return;
    SoundManager.instance.tap();
    HapticFeedback.selectionClick();
    final last = history.removeLast();
    setState(() {
      tubes = last.tubes.map((e) => List<int>.from(e)).toList();
      moves = last.moves;
      selected = null;
    });
  }

  void _restart() {
    SoundManager.instance.tap();
    HapticFeedback.mediumImpact();
    setState(_resetBoard);
  }

  bool _hintBusy = false;
  Future<void> _hint() async {
    if (_hintBusy) return;
    _hintBusy = true;
    try {
      if (finished || isPouring) return;
      int from = -1;
      int to = -1;

      outer:
      for (int i = 0; i < tubes.length; i++) {
        if (tubes[i].isEmpty) continue;
        for (int j = 0; j < tubes.length; j++) {
          if (_canPour(i, j)) {
            if (tubes[j].isEmpty &&
                tubes[i].every((c) => c == tubes[i].first)) {
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

      final cost = await chooseHintCost(context, coins);
      if (!mounted || cost == null || finished) return;
      final prefs = await SharedPreferences.getInstance();
      final balance = prefs.getInt('coins') ?? 200;
      if (balance < cost) return;
      final newCoins = balance - cost;
      if (cost > 0) await prefs.setInt('coins', newCoins);
      if (!mounted) return;
      setState(() => coins = newCoins);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hint: Jar ${from + 1}  →  Jar ${to + 1}'),
        ),
      );
    } finally {
      _hintBusy = false;
    }
  }

  Future<void> _addVial() async {
    if (finished || isPouring) return;
    if (tubes.length >= widget.level.tubes.length + 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 2 extra jars.')),
      );
      return;
    }
    const cost = 50;
    if (coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need 50 coins for an extra jar.')),
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
    final title = widget.daily ? 'Daily Harvest' : 'Level ${widget.level.id}';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF101E1B),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
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
                color: Color(0xFFBFE8C9),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'How to play',
            onPressed: _showTutorial,
            icon: const Icon(Icons.help_outline_rounded),
          ),
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
      body: ColoredBox(
        color: const Color(0xFF101E1B),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _MoveStatusBanner(
                moves: moves,
                par: widget.level.par,
                selected: selected != null,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: FruitJarBoard(
                children: List.generate(
                    tubes.length,
                    (index) => RealisticTube(
                          number: index + 1,
                          layers: tubes[index],
                          palette: gameColors,
                          selected: selected == index,
                          pouringOut: pouringFrom == index,
                          pouringIn: pouringTo == index,
                          celebrate: celebrationTube == index,
                          incomingFruit:
                              pouringTo == index ? pouringFruit : null,
                          pourStep: pourStep,
                          onTap: () => _tapTube(index),
                        )),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                  14, 10, 14, 10 + MediaQuery.paddingOf(context).bottom),
              decoration: BoxDecoration(
                color: const Color(0xFF101E1B).withValues(alpha: .96),
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
                      icon: Icons.add_box_rounded,
                      label: '+ Jar',
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

class _MoveStatusBanner extends StatelessWidget {
  final int moves;
  final int par;
  final bool selected;

  const _MoveStatusBanner({
    required this.moves,
    required this.par,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = par - moves;
    final onPace = remaining >= 0;
    final accent = selected
        ? const Color(0xFFFFD25F)
        : onPace
            ? const Color(0xFF7AF0A6)
            : const Color(0xFFFF9B7A);

    final message = selected
        ? 'Now choose a matching or empty jar'
        : onPace
            ? (remaining == 0
                ? 'Par move reached — finish strong'
                : '$remaining moves left for a perfect clear')
            : '${moves - par} over par — keep sorting';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E27).withValues(alpha: .88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: .24)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: .07),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              selected
                  ? Icons.touch_app_rounded
                  : onPace
                      ? Icons.local_fire_department_rounded
                      : Icons.flag_rounded,
              color: accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selected ? 'Fruit selected' : 'Move rhythm',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFFAED5B8),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$moves / $par',
              style: TextStyle(
                color: accent,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialRow extends StatelessWidget {
  final int fruitId;
  final String title;
  final String text;

  const _TutorialRow({
    required this.fruitId,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFE9F6E6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: FruitToken(fruitId: fruitId, size: 38),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF174D2D),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF66776A),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
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
      color: const Color(0xFF20342D),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 11,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: .08),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: const Color(0xFFE4F6E7),
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11.5,
                ),
              ),
              SizedBox(
                height: 15,
                child: small.isEmpty
                    ? null
                    : Text(
                        small,
                        style: const TextStyle(
                          color: Color(0xFFFFC34A),
                          fontWeight: FontWeight.w900,
                          fontSize: 10.5,
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
