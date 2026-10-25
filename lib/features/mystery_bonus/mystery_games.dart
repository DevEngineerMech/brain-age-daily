
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../games/shared/game_theme.dart';

typedef MysteryFinished = void Function(int performance);

class _MysteryCard extends StatelessWidget {
  final Widget child;
  final Color accent;

  const _MysteryCard({
    required this.child,
    this.accent = GameTheme.purple,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: GameTheme.card(
        accent: accent,
        radius: 22,
      ),
      child: child,
    );
  }
}

// ==========================================================
// GAME 1 — BRAIN SHUFFLE
// ==========================================================

class BrainShuffleGame extends StatefulWidget {
  final MysteryFinished onFinished;

  const BrainShuffleGame({
    super.key,
    required this.onFinished,
  });

  @override
  State<BrainShuffleGame> createState() =>
      _BrainShuffleGameState();
}

class _BrainShuffleGameState extends State<BrainShuffleGame> {
  final Random _random = Random();

  final List<int> _positions = [0, 1, 2];

  int _round = 1;
  int _correct = 0;
  int _targetCup = 0;
  int _sequence = 0;

  bool _revealing = true;
  bool _shuffling = false;
  bool _choosing = false;
  bool _answered = false;
  bool _finished = false;

  int? _chosenCup;

  static const int totalRounds = 4;

  @override
  void initState() {
    super.initState();
    _beginRound();
  }

  @override
  void dispose() {
    _sequence++;
    super.dispose();
  }

  Future<void> _beginRound() async {
    final token = ++_sequence;

    _positions
      ..clear()
      ..addAll([0, 1, 2]);

    _targetCup = _random.nextInt(3);

    if (!mounted) return;

    setState(() {
      _revealing = true;
      _shuffling = false;
      _choosing = false;
      _answered = false;
      _chosenCup = null;
    });

    await Future<void>.delayed(
      const Duration(milliseconds: 1600),
    );

    if (!mounted || token != _sequence) return;

    setState(() {
      _revealing = false;
      _shuffling = true;
    });

    // Cup identity remains constant, while its
    // position changes. The hidden brain moves
    // with the correct cup.
    final swaps = 5 + _round * 2;
    final speed = max(245, 480 - _round * 48);

    for (int i = 0; i < swaps; i++) {
      int a = _random.nextInt(3);
      int b = _random.nextInt(3);

      while (a == b) {
        b = _random.nextInt(3);
      }

      final oldPosition = _positions[a];

      setState(() {
        _positions[a] = _positions[b];
        _positions[b] = oldPosition;
      });

      await Future<void>.delayed(
        Duration(milliseconds: speed),
      );

      if (!mounted || token != _sequence) return;
    }

    setState(() {
      _shuffling = false;
      _choosing = true;
    });
  }

  Future<void> _chooseCup(int cup) async {
    if (!_choosing || _answered || _finished) return;

    final isCorrect = cup == _targetCup;

    setState(() {
      _choosing = false;
      _answered = true;
      _chosenCup = cup;

      if (isCorrect) _correct++;
    });

    await Future<void>.delayed(
      const Duration(milliseconds: 1150),
    );

    if (!mounted || _finished) return;

    if (_round >= totalRounds) {
      _finished = true;
      widget.onFinished(_correct * 25);
      return;
    }

    setState(() => _round++);
    _beginRound();
  }

  Widget _cup(int cup, double slotWidth) {
    final isTarget = cup == _targetCup;
    final showBrain =
        isTarget && (_revealing || _answered);

    final selected = _chosenCup == cup;

    final color = _answered
        ? isTarget
            ? GameTheme.green
            : selected
                ? GameTheme.red
                : GameTheme.purple
        : GameTheme.purple;

    return AnimatedPositioned(
      duration: Duration(
        milliseconds: max(200, 460 - _round * 45),
      ),
      curve: Curves.easeInOutCubic,
      left: slotWidth * _positions[cup] + 3,
      top: _shuffling
          ? (cup.isEven ? 9 : 21)
          : 15,
      width: slotWidth - 6,
      height: 124,
      child: GestureDetector(
        onTap: () => _chooseCup(cup),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: color.withOpacity(0.19),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: color,
              width: _answered ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 18,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🏆',
                style: TextStyle(fontSize: 43),
              ),
              const SizedBox(height: 7),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: showBrain
                    ? const Text(
                        '🧠',
                        key: ValueKey('brain'),
                        style: TextStyle(fontSize: 26),
                      )
                    : const Icon(
                        Icons.help_rounded,
                        key: ValueKey('hidden'),
                        color: Colors.white70,
                        size: 23,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final instruction = _revealing
        ? 'Remember which cup hides the brain!'
        : _shuffling
            ? 'Follow the cup carefully...'
            : _answered
                ? _chosenCup == _targetCup
                    ? 'Perfect tracking!'
                    : 'The glowing green cup had the brain.'
                : 'Which cup hides the brain? Tap it!';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MysteryCard(
          accent: GameTheme.gold,
          child: Column(
            children: [
              const Icon(
                Icons.psychology_rounded,
                color: GameTheme.gold,
                size: 36,
              ),
              const SizedBox(height: 9),
              const Text(
                'BRAIN SHUFFLE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Round $_round / $totalRounds',
                style: const TextStyle(
                  color: GameTheme.gold,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  instruction,
                  key: ValueKey(instruction),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: GameTheme.muted,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final slotWidth = constraints.maxWidth / 3;

                  return SizedBox(
                    height: 155,
                    child: Stack(
                      children: List.generate(
                        3,
                        (index) => _cup(index, slotWidth),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 9),
              Text(
                _choosing ? 'TAP A CUP' : 'WATCH CLOSELY',
                style: TextStyle(
                  color: _choosing
                      ? GameTheme.cyan
                      : GameTheme.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        _MysteryCard(
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: GameTheme.green,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Correct guesses',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$_correct / $totalRounds',
                style: const TextStyle(
                  color: GameTheme.gold,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================================
// GAME 2 — GOLDEN RUSH
// ==========================================================

class GoldenRushGame extends StatefulWidget {
  final MysteryFinished onFinished;

  const GoldenRushGame({
    super.key,
    required this.onFinished,
  });

  @override
  State<GoldenRushGame> createState() =>
      _GoldenRushGameState();
}

class _GoldenRushGameState extends State<GoldenRushGame> {
  final Random _random = Random();

  Timer? _countdown;
  Timer? _targetsTimer;

  int _seconds = 20;
  int _points = 0;
  int _combo = 0;

  int _gold = 0;
  final Set<int> _red = {};

  bool _finished = false;

  @override
  void initState() {
    super.initState();

    _moveTargets();

    _countdown = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted || _finished) return;

        if (_seconds <= 1) {
          _finish();
        } else {
          setState(() => _seconds--);
        }
      },
    );

    _targetsTimer = Timer.periodic(
      const Duration(milliseconds: 680),
      (_) => _moveTargets(),
    );
  }

  @override
  void dispose() {
    _countdown?.cancel();
    _targetsTimer?.cancel();
    super.dispose();
  }

  void _moveTargets() {
    if (!mounted || _finished) return;

    final gold = _random.nextInt(12);
    final reds = <int>{};

    while (reds.length < 2) {
      final value = _random.nextInt(12);

      if (value != gold) reds.add(value);
    }

    setState(() {
      _gold = gold;
      _red
        ..clear()
        ..addAll(reds);
    });
  }

  void _tap(int index) {
    if (_finished || _seconds <= 0) return;

    if (index == _gold) {
      setState(() {
        _combo++;
        _points += 5 + min(10, _combo * 2);
      });
      _moveTargets();
    } else if (_red.contains(index)) {
      setState(() {
        _combo = 0;
        _points = max(0, _points - 8);
      });
      _moveTargets();
    }
  }

  void _finish() {
    if (_finished) return;

    _finished = true;
    _countdown?.cancel();
    _targetsTimer?.cancel();

    setState(() => _seconds = 0);

    // A score of at least 150 gives full performance.
    final performance =
        ((_points / 150) * 100).round().clamp(0, 100);

    widget.onFinished(performance);
  }

  Widget _target(int index) {
    final isGold = index == _gold;
    final isRed = _red.contains(index);

    final accent = isGold
        ? GameTheme.gold
        : isRed
            ? GameTheme.red
            : GameTheme.purple;

    return InkWell(
      onTap: () => _tap(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: accent.withOpacity(isGold ? 0.28 : 0.14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accent.withOpacity(
              isGold || isRed ? 1 : 0.35,
            ),
            width: isGold ? 2.5 : 1,
          ),
          boxShadow: [
            if (isGold)
              BoxShadow(
                color: GameTheme.gold.withOpacity(0.38),
                blurRadius: 17,
              ),
          ],
        ),
        child: Center(
          child: Icon(
            isGold
                ? Icons.stars_rounded
                : isRed
                    ? Icons.close_rounded
                    : Icons.circle_outlined,
            color: accent,
            size: isGold ? 39 : 27,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MysteryCard(
          accent: GameTheme.gold,
          child: Column(
            children: [
              const Icon(
                Icons.bolt_rounded,
                size: 37,
                color: GameTheme.gold,
              ),
              const SizedBox(height: 8),
              const Text(
                'GOLDEN RUSH',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Tap gold. Avoid red. Build combos!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: GameTheme.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _stat(
                      Icons.timer_rounded,
                      '${_seconds}s',
                      GameTheme.cyan,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _stat(
                      Icons.star_rounded,
                      '$_points',
                      GameTheme.gold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _stat(
                      Icons.local_fire_department_rounded,
                      'x$_combo',
                      const Color(0xFFFF81BE),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _seconds / 20,
                  minHeight: 7,
                  color: GameTheme.gold,
                  backgroundColor: GameTheme.border,
                ),
              ),
              const SizedBox(height: 19),
              AspectRatio(
                aspectRatio: 3 / 4,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 12,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 9,
                    crossAxisSpacing: 9,
                  ),
                  itemBuilder: (_, index) => _target(index),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stat(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 9,
        horizontal: 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// GAME 3 — WHAT'S MISSING?
// ==========================================================

class WhatsMissingGame extends StatefulWidget {
  final MysteryFinished onFinished;

  const WhatsMissingGame({
    super.key,
    required this.onFinished,
  });

  @override
  State<WhatsMissingGame> createState() =>
      _WhatsMissingGameState();
}

class _WhatsMissingGameState extends State<WhatsMissingGame> {
  static const int totalRounds = 4;

  static const List<String> objects = [
    '🍎', '🚀', '🎸', '🐶', '🔑',
    '⭐', '🚗', '🎩', '🍉', '⚽',
    '🦋', '🍕', '🎮', '⏰', '👑',
    '🌈', '🐙', '🧲', '💎', '🎯',
    '🌻', '🪁', '🎨', '🛸', '🥑',
    '🧸', '🦖', '🍓', '🎺', '🧩',
  ];

  final Random _random = Random();

  int _round = 1;
  int _correct = 0;
  int _sequence = 0;

  List<String> _objects = [];
  List<String> _options = [];

  late String _missing;

  bool _showing = true;
  bool _answered = false;
  bool _finished = false;
  String? _selected;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  @override
  void dispose() {
    _sequence++;
    super.dispose();
  }

  Future<void> _newRound() async {
    final token = ++_sequence;

    final shuffled = List<String>.from(objects)
      ..shuffle(_random);

    final itemCount = min(9, 5 + _round);

    _objects = shuffled.take(itemCount).toList();
    _missing = _objects[_random.nextInt(_objects.length)];

    // Wrong answers come from objects not on the
    // original board. Every option is plausible.
    _options = [
      _missing,
      ...shuffled.skip(itemCount).take(3),
    ]..shuffle(_random);

    if (!mounted) return;

    setState(() {
      _showing = true;
      _answered = false;
      _selected = null;
    });

    await Future<void>.delayed(
      Duration(milliseconds: 3900 - (_round - 1) * 250),
    );

    if (!mounted || token != _sequence) return;

    setState(() => _showing = false);
  }

  Future<void> _answer(String value) async {
    if (_showing || _answered || _finished) return;

    final correct = value == _missing;

    setState(() {
      _answered = true;
      _selected = value;

      if (correct) _correct++;
    });

    await Future<void>.delayed(
      const Duration(milliseconds: 1000),
    );

    if (!mounted || _finished) return;

    if (_round >= totalRounds) {
      _finished = true;
      widget.onFinished(_correct * 25);
      return;
    }

    setState(() => _round++);
    _newRound();
  }

  Widget _objectTile(String emoji) {
    final hidden = !_showing && emoji == _missing;

    return Container(
      decoration: BoxDecoration(
        color: hidden
            ? GameTheme.gold.withOpacity(0.15)
            : GameTheme.purple.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hidden
              ? GameTheme.gold
              : GameTheme.purple.withOpacity(0.6),
        ),
      ),
      child: Center(
        child: Text(
          hidden ? '?' : emoji,
          style: TextStyle(
            color: GameTheme.gold,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _option(String value) {
    final selected = value == _selected;
    final right = value == _missing;

    final accent = _answered
        ? right
            ? GameTheme.green
            : selected
                ? GameTheme.red
                : GameTheme.purple
        : GameTheme.purple;

    return InkWell(
      onTap: _showing || _answered
          ? null
          : () => _answer(value),
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 68,
        decoration: BoxDecoration(
          color: accent.withOpacity(0.19),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: accent.withOpacity(
              _answered && (selected || right) ? 1 : 0.6,
            ),
            width: _answered && (selected || right) ? 2.5 : 1.2,
          ),
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(fontSize: 34),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MysteryCard(
          accent: const Color(0xFFFF81BE),
          child: Column(
            children: [
              const Icon(
                Icons.visibility_rounded,
                color: Color(0xFFFF81BE),
                size: 37,
              ),
              const SizedBox(height: 8),
              const Text(
                'WHAT’S MISSING?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Round $_round / $totalRounds',
                style: const TextStyle(
                  color: GameTheme.gold,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                _showing
                    ? 'Memorise these objects!'
                    : 'Which object disappeared?',
                style: const TextStyle(
                  color: GameTheme.muted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 17),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _objects.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 9,
                  crossAxisSpacing: 9,
                  mainAxisExtent: 73,
                ),
                itemBuilder: (_, index) {
                  return _objectTile(_objects[index]);
                },
              ),
              const SizedBox(height: 17),
              if (_showing)
                const Column(
                  children: [
                    Icon(
                      Icons.visibility_rounded,
                      color: GameTheme.cyan,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Look carefully...',
                      style: TextStyle(
                        color: GameTheme.cyan,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                )
              else ...[
                GridView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: _options.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 68,
                    mainAxisSpacing: 9,
                    crossAxisSpacing: 9,
                  ),
                  itemBuilder: (_, index) =>
                      _option(_options[index]),
                ),
                if (_answered) ...[
                  const SizedBox(height: 12),
                  Text(
                    _selected == _missing
                        ? 'Correct!'
                        : 'The missing object was $_missing',
                    style: TextStyle(
                      color: _selected == _missing
                          ? GameTheme.green
                          : GameTheme.red,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _MysteryCard(
          child: Row(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: GameTheme.gold,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Correct answers',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$_correct / $totalRounds',
                style: const TextStyle(
                  color: GameTheme.gold,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
