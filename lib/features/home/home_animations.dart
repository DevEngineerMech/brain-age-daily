
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/services/achievements_service.dart';
import '../../core/services/daily_hearts_service.dart';
import '../../core/services/daily_missions_service.dart';

// ======================================================
// FLOATING BRAIN
// ======================================================

class HomeFloatingBrain extends StatefulWidget {
  const HomeFloatingBrain({super.key});

  @override
  State<HomeFloatingBrain> createState() =>
      _HomeFloatingBrainState();
}

class _HomeFloatingBrainState extends State<HomeFloatingBrain>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final phase = _controller.value * math.pi;

        return Transform.translate(
          offset: Offset(0, math.sin(phase) * -7),
          child: Transform.rotate(
            angle: math.sin(phase) * 0.065,
            child: child,
          ),
        );
      },
      child: SizedBox(
        width: 135,
        height: 104,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: -0.22,
              child: Container(
                width: 116,
                height: 67,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xCCFFA94D),
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(90),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x77FFA94D),
                      blurRadius: 15,
                    ),
                  ],
                ),
              ),
            ),
            const Text(
              '🧠',
              style: TextStyle(fontSize: 72),
            ),
            const Positioned(
              right: 5,
              top: 1,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFFFC75D),
                size: 19,
              ),
            ),
            const Positioned(
              left: 7,
              bottom: 5,
              child: Icon(
                Icons.star_rounded,
                color: Color(0xFFE469F4),
                size: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// PULSING HEARTS
// ======================================================

class HomePulsingHearts extends StatefulWidget {
  final int hearts;

  const HomePulsingHearts({
    super.key,
    required this.hearts,
  });

  @override
  State<HomePulsingHearts> createState() =>
      _HomePulsingHeartsState();
}

class _HomePulsingHeartsState extends State<HomePulsingHearts>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            DailyHeartsService.maxHearts,
            (index) {
              final available = index < widget.hearts;

              final phase =
                  (_controller.value - index * 0.19) *
                      math.pi *
                      2;

              final pulse = math.pow(
                math.max(0, math.sin(phase)),
                8,
              ).toDouble();

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 2,
                ),
                child: Transform.scale(
                  scale: available ? 1 + 0.16 * pulse : 1,
                  child: Text(
                    available ? '❤️' : '🩶',
                    style: const TextStyle(fontSize: 23),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ======================================================
// ROTATING MYSTERY BONUS BORDER
// ======================================================

class HomeAnimatedMysteryBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  final double borderWidth;

  const HomeAnimatedMysteryBorder({
    super.key,
    required this.child,
    this.radius = 19,
    this.borderWidth = 2.5,
  });

  @override
  State<HomeAnimatedMysteryBorder> createState() =>
      _HomeAnimatedMysteryBorderState();
}

class _HomeAnimatedMysteryBorderState
    extends State<HomeAnimatedMysteryBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final glow =
            (math.sin(_controller.value * math.pi * 2) + 1) /
                2;

        return Container(
          padding: EdgeInsets.all(widget.borderWidth),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: SweepGradient(
              transform: GradientRotation(
                _controller.value * math.pi * 2,
              ),
              colors: const [
                Color(0xFFFFD36C),
                Color(0xFFFF7E36),
                Color(0xFF7239EF),
                Color(0xFF30215E),
                Color(0xFFFFD36C),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color.lerp(
                  const Color(0x44FFA842),
                  const Color(0x77FFC75D),
                  glow,
                )!,
                blurRadius: 13,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}

// ======================================================
// ANIMATED DAILY MISSIONS HOME CARD
// ======================================================

class HomeAnimatedMissionsCard extends StatefulWidget {
  final VoidCallback onOpen;

  const HomeAnimatedMissionsCard({
    super.key,
    required this.onOpen,
  });

  @override
  State<HomeAnimatedMissionsCard> createState() =>
      _HomeAnimatedMissionsCardState();
}

class _HomeAnimatedMissionsCardState
    extends State<HomeAnimatedMissionsCard>
    with TickerProviderStateMixin {
  static const Color panel = Color(0xFF1A1646);
  static const Color gold = Color(0xFFFFC75D);
  static const Color muted = Color(0xFFBDB3DB);
  static const Color purple = Color(0xFFA87CFF);
  static const Color cyan = Color(0xFF42D9D0);
  static const Color green = Color(0xFF4BE09D);

  late final AnimationController _enterController;
  late final AnimationController _exitController;

  DailyMissionsSnapshot? _snapshot;

  bool _expanded = false;
  bool _opening = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    );

    _refresh();
  }

  @override
  void dispose() {
    _enterController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final snapshot = await DailyMissionsService.getSnapshot();
      if (!mounted) return;

      setState(() => _snapshot = snapshot);
    } catch (error) {
      debugPrint('Home missions preview error: $error');
    }
  }

  Color _accent(int index) {
    if (index == 0) return purple;
    if (index == 1) return cyan;
    return green;
  }

  IconData _icon(int index) {
    if (index == 0) return Icons.psychology_rounded;
    if (index == 1) return Icons.sports_esports_rounded;
    return Icons.bolt_rounded;
  }

  Future<void> _onTap() async {
    if (_opening || _loading) return;

    if (!_expanded) {
      setState(() {
        _expanded = true;
        _loading = true;
      });

      // Update progress from the real mission service.
      await _refresh();

      if (!mounted) return;

      _loading = false;
      await _enterController.forward();
      return;
    }

    // Do not interrupt the staggered entrance.
    if (!_enterController.isCompleted) return;

    _opening = true;

    try {
      await _exitController.forward();

      if (!mounted) return;

      // The navigation callback opens the real missions page.
      widget.onOpen();

      // Wait for the home screen to be covered by the route.
      // The preview will reset for the next visit.
      if (mounted) {
        _enterController.reset();
        _exitController.reset();

        setState(() {
          _expanded = false;
          _opening = false;
        });
      }
    } catch (error) {
      debugPrint('Mission opening animation error: $error');

      if (mounted) {
        _exitController.reset();
        setState(() => _opening = false);
      }
    }
  }

  Widget _missionRow(DailyMission mission, int index) {
    final color = _accent(index);
    final completed = mission.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.48),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              completed ? Icons.check_rounded : _icon(index),
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: mission.fraction,
                    minHeight: 5,
                    backgroundColor: const Color(0xFF3E335D),
                    color: color,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${mission.progress} / ${mission.target}',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          Column(
            children: [
              const Icon(
                Icons.monetization_on_rounded,
                color: gold,
                size: 19,
              ),
              Text(
                '+${mission.reward}',
                style: const TextStyle(
                  color: gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _animatedMission(DailyMission mission, int index) {
    // Entrance intervals are staggered across 2 seconds.
    final start = index * 0.28;
    final end = start + 0.44;

    final enter = CurvedAnimation(
      parent: _enterController,
      curve: Interval(
        start,
        end,
        curve: Curves.easeOutCubic,
      ),
    );

    // Exit runs backwards: bottom row leaves first.
    final exitIndex = 2 - index;
    final exit = CurvedAnimation(
      parent: _exitController,
      curve: Interval(
        exitIndex * 0.19,
        exitIndex * 0.19 + 0.43,
        curve: Curves.easeInCubic,
      ),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([
        _enterController,
        _exitController,
      ]),
      child: _missionRow(mission, index),
      builder: (context, child) {
        final x = -1.18 * (1 - enter.value) +
            1.65 * exit.value;

        final opacity =
            (enter.value * (1 - exit.value))
                .clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: FractionalTranslation(
            translation: Offset(x, 0),
            child: child,
          ),
        );
      },
    );
  }

  Widget _openingIcon() {
    return AnimatedBuilder(
      animation: _exitController,
      builder: (context, child) {
        final progress = Curves.easeInCubic.transform(
          ((_exitController.value - 0.48) / 0.52)
              .clamp(0.0, 1.0),
        );

        return SizedBox(
          height: 29 + progress * 65,
          child: Center(
            child: Transform.scale(
              scale: 1 + progress * 3.3,
              child: Opacity(
                opacity: (1 - progress * 0.32)
                    .clamp(0.0, 1.0),
                child: Icon(
                  Icons.ads_click_rounded,
                  color: Color.lerp(
                    gold,
                    Colors.white,
                    progress,
                  ),
                  size: 25,
                  shadows: [
                    Shadow(
                      color: gold.withOpacity(progress),
                      blurRadius: 8 + progress * 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final missions = _snapshot?.missions ?? <DailyMission>[];
    final completed = _snapshot?.completedCount ?? 0;

    return AnimatedBuilder(
      animation: _exitController,
      builder: (context, _) {
        final glow = _exitController.value;

        return AnimatedSize(
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _onTap,
              borderRadius: BorderRadius.circular(19),
              child: Ink(
                decoration: BoxDecoration(
                  color: Color.lerp(
                    panel,
                    const Color(0xFF493092),
                    glow * 0.55,
                  ),
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(
                    color: Color.lerp(
                      const Color(0xFF6550A0),
                      gold,
                      glow,
                    )!,
                    width: 1 + glow * 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withOpacity(glow * 0.35),
                      blurRadius: 8 + glow * 24,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          if (!_opening)
                            const Icon(
                              Icons.ads_click_rounded,
                              color: gold,
                              size: 19,
                            ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Daily Missions',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            _expanded
                                ? '$completed / 3'
                                : 'Earn Brain Coins',
                            style: const TextStyle(
                              color: muted,
                              fontSize: 10,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: muted,
                            size: 17,
                          ),
                        ],
                      ),

                      if (!_expanded) ...[
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Icon(
                              Icons.monetization_on_rounded,
                              color: gold,
                              size: 22,
                            ),
                            SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'Complete 3 daily challenges '
                                'to earn up to 150 Brain Coins!',
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: gold,
                            ),
                          ],
                        ),
                      ],

                      if (_expanded) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: completed / 3,
                            minHeight: 6,
                            backgroundColor:
                                const Color(0xFF463763),
                            color: gold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        ClipRect(
                          child: Column(
                            children: [
                              for (var i = 0;
                                  i < missions.length;
                                  i++)
                                _animatedMission(
                                  missions[i],
                                  i,
                                ),
                            ],
                          ),
                        ),

                        if (!_opening) ...[
                          const SizedBox(height: 3),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.touch_app_rounded,
                                size: 16,
                                color: gold,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _enterController.isCompleted
                                    ? 'Tap again to open missions'
                                    : 'Revealing your missions...',
                                style: const TextStyle(
                                  color: gold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],

                        if (_opening)
                          _openingIcon(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ======================================================
// DAILY CHECK CINEMATIC TRANSITION
// ======================================================

typedef HomeLaunchBuilder = Widget Function(
  VoidCallback startDaily,
);

class HomeDailyLaunchTransition extends StatefulWidget {
  final HomeLaunchBuilder builder;
  final Future<void> Function() onLaunch;
  final int brainAge;
  final int hearts;

  const HomeDailyLaunchTransition({
    super.key,
    required this.builder,
    required this.onLaunch,
    required this.brainAge,
    required this.hearts,
  });

  @override
  State<HomeDailyLaunchTransition> createState() =>
      _HomeDailyLaunchTransitionState();
}

class _HomeDailyLaunchTransitionState
    extends State<HomeDailyLaunchTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _launching = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1950),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _phase(double value, double start, double end) {
    return ((value - start) / (end - start)).clamp(0.0, 1.0);
  }

  Future<void> _start() async {
    if (_launching) return;

    if (widget.hearts <= 0) {
      await widget.onLaunch();
      return;
    }

    _launching = true;

    try {
      await _controller.forward();

      if (!mounted) return;
      await widget.onLaunch();
    } finally {
      if (mounted) _controller.reset();
      _launching = false;
    }
  }

  Widget _fallingLetters(double t) {
    const text = 'Start Daily Brain Check';
    final characters = text.split('');

    final scatter = Curves.easeInCubic.transform(
      _phase(t, 0.13, 0.57),
    );

    return Wrap(
      alignment: WrapAlignment.center,
      children: List.generate(characters.length, (i) {
        final char = characters[i];
        final seed = math.sin(i * 13.19 + 4.7);

        return Transform.translate(
          offset: Offset(
            seed * (35 + (i % 4) * 12) * scatter,
            (100 + (i % 6) * 24.0) * scatter,
          ),
          child: Transform.rotate(
            angle: seed * 1.7 * scatter,
            child: Opacity(
              opacity: (1 - scatter).clamp(0.0, 1.0),
              child: Text(
                char == ' ' ? '\u00A0' : char,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _cinematicOverlay(double t, Size size) {
    if (t <= 0) return const SizedBox.shrink();

    final centre = Curves.easeOutCubic.transform(
      _phase(t, 0.12, 0.52),
    );
    final lens = Curves.easeInOutCubic.transform(
      _phase(t, 0.43, 0.78),
    );
    final zoom = Curves.easeInCubic.transform(
      _phase(t, 0.68, 1),
    );
    final press = Curves.easeOutCubic.transform(
      _phase(t, 0, 0.14),
    );

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.hardEdge,
          children: [
            Opacity(
              opacity: _phase(t, 0.05, 0.29) * 0.95,
              child: const ColoredBox(
                color: Color(0xFF0D082D),
                child: SizedBox.expand(),
              ),
            ),
            Transform.translate(
              offset: Offset(
                0,
                -size.height * 0.21 * (1 - centre),
              ),
              child: Opacity(
                opacity: (1 - zoom).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.85 + centre * 0.15,
                  child: Container(
                    width: math.min(size.width - 34, 380),
                    height: 185,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF422185),
                          Color(0xFF18123F),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFFB17AFF),
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x88693AEF),
                          blurRadius: 35,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'YOUR BRAIN AGE',
                                style: TextStyle(
                                  color: Color(0xFFFFD48B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                '${widget.brainAge}',
                                style: const TextStyle(
                                  color: Color(0xFFFFD48B),
                                  fontSize: 59,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          '🧠',
                          style: TextStyle(fontSize: 74),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 26,
              right: 26,
              bottom: size.height * 0.16,
              child: Opacity(
                opacity: (1 - _phase(t, 0.35, 0.68))
                    .clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 1 - press * 0.10,
                  child: Container(
                    height: 55,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(29),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE14CF8),
                          Color(0xFF6540FC),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFFFFB8FA),
                        width: 1.5,
                      ),
                    ),
                    child: _fallingLetters(t),
                  ),
                ),
              ),
            ),
            Opacity(
              opacity: (lens * (1 - zoom)).clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(
                  0,
                  size.height * 0.18 * (1 - lens),
                ),
                child: Transform.scale(
                  scale: 0.25 + lens * 2 + zoom * 2.5,
                  child: const Icon(
                    Icons.search_rounded,
                    size: 117,
                    color: Color(0xFFFFD47E),
                    shadows: [
                      Shadow(
                        color: Color(0xFFFFBD49),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (t > 0.65)
              Opacity(
                opacity: _phase(t, 0.65, 0.87) *
                    (1 - _phase(t, 0.94, 1)),
                child: Transform.scale(
                  scale: 0.7 + zoom * 12,
                  child: const Text(
                    '🧠',
                    style: TextStyle(fontSize: 115),
                  ),
                ),
              ),
            Opacity(
              opacity: _phase(t, 0.86, 1),
              child: const ColoredBox(
                color: Color(0xFF4C21A6),
                child: SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final fall = Curves.easeInCubic.transform(
              _phase(t, 0.08, 0.51),
            );

            return Stack(
              fit: StackFit.expand,
              children: [
                IgnorePointer(
                  ignoring: _launching,
                  child: Opacity(
                    opacity: (1 - fall).clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        fall * size.height * 0.65,
                      ),
                      child: widget.builder(_start),
                    ),
                  ),
                ),
                _cinematicOverlay(t, size),
              ],
            );
          },
        );
      },
    );
  }
}

// ======================================================
// ACHIEVEMENT CELEBRATION
// ======================================================

class HomeAchievementCelebration {
  const HomeAchievementCelebration._();

  static Future<void> show(
    BuildContext context,
    List<BadgeProgress> badges,
  ) async {
    if (badges.isEmpty || !context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF43207F),
                  Color(0xFF18123D),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFFFC75D),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66FFC75D),
                  blurRadius: 22,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFFFFC75D),
                    size: 32,
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    'NEW ACHIEVEMENT!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFC75D),
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.5, end: 1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Icon(
                      badges.first.badge.icon,
                      color: badges.first.badge.color,
                      size: 65,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Text(
                    badges.length == 1
                        ? badges.first.badge.title
                        : '${badges.length} badges unlocked!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    badges.length == 1
                        ? badges.first.badge.description
                        : badges
                            .map((b) => b.badge.title)
                            .join(' • '),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFBDB3DB),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8541EA),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Collect Badge!',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
