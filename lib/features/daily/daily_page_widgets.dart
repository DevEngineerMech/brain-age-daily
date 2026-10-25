
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../games/shared/game_theme.dart';

// ======================================================
// SHARED DAILY THEME
// ======================================================

class BrainGameTheme {
  static const Color background = GameTheme.background;
  static const Color panel = GameTheme.panel;
  static const Color purple = GameTheme.purple;
  static const Color cyan = GameTheme.cyan;
  static const Color gold = GameTheme.gold;
  static const Color muted = GameTheme.muted;
  static const Color green = GameTheme.green;
  static const Color red = GameTheme.red;
}

class GameVisual {
  final IconData icon;
  final Color color;
  final String label;

  const GameVisual(this.icon, this.color, this.label);

  static GameVisual forTitle(String title) {
    final t = title.toLowerCase();

    if (t.contains('memory grid')) {
      return const GameVisual(
        Icons.grid_view_rounded,
        GameTheme.purple,
        'VISUAL MEMORY',
      );
    }
    if (t.contains('order recall')) {
      return const GameVisual(
        Icons.format_list_numbered_rounded,
        GameTheme.cyan,
        'SEQUENCE MEMORY',
      );
    }
    if (t.contains('pattern')) {
      return const GameVisual(
        Icons.auto_awesome_mosaic_rounded,
        GameTheme.purple,
        'PATTERN RECOGNITION',
      );
    }
    if (t.contains('symbol')) {
      return const GameVisual(
        Icons.interests_rounded,
        GameTheme.cyan,
        'VISUAL MATCHING',
      );
    }
    if (t.contains('focus')) {
      return const GameVisual(
        Icons.center_focus_strong_rounded,
        GameTheme.cyan,
        'VISUAL ATTENTION',
      );
    }
    if (t.contains('reaction')) {
      return const GameVisual(
        Icons.bolt_rounded,
        GameTheme.gold,
        'REACTION SPEED',
      );
    }
    if (t.contains('stroop')) {
      return const GameVisual(
        Icons.palette_rounded,
        GameTheme.purple,
        'COLOUR FOCUS',
      );
    }
    if (t.contains('quick math')) {
      return const GameVisual(
        Icons.calculate_rounded,
        GameTheme.gold,
        'MENTAL MATHS',
      );
    }
    if (t.contains('time')) {
      return const GameVisual(
        Icons.access_time_rounded,
        GameTheme.cyan,
        'TIME CHALLENGE',
      );
    }
    if (t.contains('sudoku')) {
      return const GameVisual(
        Icons.grid_on_rounded,
        GameTheme.purple,
        'NUMBER LOGIC',
      );
    }
    if (t.contains('biology')) {
      return const GameVisual(
        Icons.biotech_rounded,
        GameTheme.green,
        'BIOLOGY',
      );
    }
    if (t.contains('science')) {
      return const GameVisual(
        Icons.science_rounded,
        GameTheme.cyan,
        'SCIENCE',
      );
    }
    if (t.contains('word') || t.contains('antonym')) {
      return const GameVisual(
        Icons.menu_book_rounded,
        GameTheme.gold,
        'LANGUAGE',
      );
    }

    return const GameVisual(
      Icons.psychology_rounded,
      GameTheme.purple,
      'BRAIN TRAINING',
    );
  }
}

// ======================================================
// HEADER
// ======================================================

class DailyHeader extends StatelessWidget {
  final VoidCallback onBack;
  final int heartsLeft;
  final VoidCallback? onWatchAdForHeart;

  const DailyHeader({
    super.key,
    required this.onBack,
    required this.heartsLeft,
    this.onWatchAdForHeart,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          style: IconButton.styleFrom(
            backgroundColor: GameTheme.panel,
            side: const BorderSide(color: GameTheme.border),
          ),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Daily Brain Check',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Material(
          color: GameTheme.panel,
          borderRadius: BorderRadius.circular(25),
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: onWatchAdForHeart,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: GameTheme.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFFF597D),
                    size: 19,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$heartsLeft',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (onWatchAdForHeart != null) ...[
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.play_circle_fill_rounded,
                      color: GameTheme.gold,
                      size: 18,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ======================================================
// DAILY PROGRESS
// ======================================================

class DailyStepProgress extends StatelessWidget {
  final int gamesCount;
  final int activeIndex;
  final double progress;

  const DailyStepProgress({
    super.key,
    required this.gamesCount,
    required this.activeIndex,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          children: [
            Text(
              'CHALLENGE ${activeIndex + 1} OF $gamesCount',
              style: const TextStyle(
                color: GameTheme.muted,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            Text(
              '${(value * 100).round()}%',
              style: const TextStyle(
                color: GameTheme.gold,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            color: GameTheme.gold,
            backgroundColor: GameTheme.border.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(gamesCount, (index) {
            final active = index == activeIndex;
            final done = index < activeIndex;

            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: 29,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done
                      ? GameTheme.green.withOpacity(0.27)
                      : active
                          ? GameTheme.purple
                          : GameTheme.panel,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: done
                        ? GameTheme.green
                        : active
                            ? const Color(0xFFCBA8FF)
                            : GameTheme.border,
                  ),
                ),
                child: done
                    ? const Icon(
                        Icons.check_rounded,
                        color: GameTheme.green,
                        size: 17,
                      )
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: active
                              ? Colors.white
                              : GameTheme.muted,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ======================================================
// COMMON VISUAL TILE
// ======================================================

class _VisualTile extends StatelessWidget {
  final String text;
  final Color accent;
  final bool highlighted;
  final double height;
  final double? width;

  const _VisualTile({
  super.key,
  required this.text,
  required this.accent,
  this.highlighted = false,
  this.height = 59,
  this.width,
});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 210),
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withOpacity(highlighted ? 0.37 : 0.18),
            GameTheme.panel,
          ],
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: highlighted ? accent : accent.withOpacity(0.7),
          width: highlighted ? 2 : 1.2,
        ),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: accent.withOpacity(0.28),
                  blurRadius: 13,
                ),
              ]
            : null,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: highlighted ? accent : Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// ORDER RECALL — ANIMATED NUMBERS
// ======================================================

class DailyOrderRecallTiles extends StatefulWidget {
  final String question;
  final String inputText;

  const DailyOrderRecallTiles({
    super.key,
    required this.question,
    required this.inputText,
  });

  @override
  State<DailyOrderRecallTiles> createState() =>
      _DailyOrderRecallTilesState();
}

class _DailyOrderRecallTilesState
    extends State<DailyOrderRecallTiles> {
  static const List<Color> colors = [
    GameTheme.purple,
    GameTheme.cyan,
    GameTheme.gold,
    Color(0xFFFF80C7),
    GameTheme.green,
  ];

  Timer? _timer;
  int _revealed = 0;

  List<String> get _numbers => widget.question
      .trim()
      .split(RegExp(r'\s+'))
      .where((e) => e.isNotEmpty)
      .toList();

  @override
  void initState() {
    super.initState();
    _startReveal();
  }

  @override
  void didUpdateWidget(
    covariant DailyOrderRecallTiles oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question != widget.question &&
        widget.question.isNotEmpty) {
      _startReveal();
    }
  }

  void _startReveal() {
    _timer?.cancel();
    _revealed = 0;

    _timer = Timer.periodic(
      const Duration(milliseconds: 390),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          _revealed++;
        });

        if (_revealed >= _numbers.length) {
          timer.cancel();
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showing = widget.question.isNotEmpty;
    final items = showing
        ? _numbers
        : widget.inputText
            .trim()
            .split(RegExp(r'\s+'))
            .where((item) => item.isNotEmpty)
            .toList();

    const count = 5;

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 6.0;
            final tileWidth = math.min(
              65.0,
              (constraints.maxWidth - gap * (count - 1)) /
                  count,
            );

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(count, (index) {
                final visible = showing
                    ? index < _revealed && index < items.length
                    : index < items.length;

                return Padding(
                  padding: EdgeInsets.only(
                    right: index == count - 1 ? 0 : gap,
                  ),
                  child: SizedBox(
                    width: tileWidth,
                    child: AnimatedSwitcher(
                      duration: const Duration(
                        milliseconds: 240,
                      ),
                      child: _VisualTile(
                        key: ValueKey('$index-$visible-'
                            '${visible ? items[index] : "?"}'),
                        text: visible ? items[index] : '?',
                        accent: colors[index],
                        highlighted: visible,
                        height: 64,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
        const SizedBox(height: 14),
        Text(
          showing
              ? 'Memorise the order, then tap OK'
              : 'Tap the numbers in the original order',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: GameTheme.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ======================================================
// PATTERN / SUDOKU NUMBER TILES
// ======================================================

class DailySequenceTiles extends StatelessWidget {
  final String sequence;

  const DailySequenceTiles({
    super.key,
    required this.sequence,
  });

  @override
  Widget build(BuildContext context) {
    final values = sequence
        .trim()
        .split(RegExp(r'\s+'))
        .where((v) => v.isNotEmpty)
        .toList();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 9,
      children: values.map((value) {
        return _VisualTile(
          text: value,
          accent:
              value.contains('?') ? GameTheme.gold : GameTheme.purple,
          highlighted: value.contains('?'),
          width: 58,
          height: 63,
        );
      }).toList(),
    );
  }
}

// ======================================================
// TIME DIFFERENCE — TWO DIGITAL CLOCKS
// ======================================================

class DailyTimeClocks extends StatelessWidget {
  final String question;

  const DailyTimeClocks({
    super.key,
    required this.question,
  });

  Widget _clock(
    String label,
    String time,
    Color accent,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 17,
        ),
        decoration: GameTheme.card(
          accent: accent,
          radius: 17,
        ),
        child: Column(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: accent,
              size: 23,
            ),
            const SizedBox(height: 7),
            Text(
              label,
              style: const TextStyle(
                color: GameTheme.muted,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                time,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parts = question.split('→');

    if (parts.length != 2) {
      return Text(
        question,
        style: const TextStyle(color: Colors.white),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            _clock('START', parts[0].trim(), GameTheme.cyan),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 7),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: GameTheme.gold,
              ),
            ),
            _clock('FINISH', parts[1].trim(), GameTheme.purple),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'How many minutes have passed?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: GameTheme.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ======================================================
// QUICK MATH — GLOWING EQUATION
// ======================================================

class DailyMathDisplay extends StatelessWidget {
  final String equation;

  const DailyMathDisplay({
    super.key,
    required this.equation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 25,
      ),
      decoration: GameTheme.card(
        accent: GameTheme.gold,
        radius: 19,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.functions_rounded,
            color: GameTheme.gold,
            size: 33,
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$equation = ?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// SYMBOL MATCH — LARGE TARGET
// ======================================================

class DailySymbolDisplay extends StatelessWidget {
  final String symbol;

  const DailySymbolDisplay({
    super.key,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 148,
        height: 148,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [
              Color(0xFF503390),
              GameTheme.panel,
            ],
          ),
          border: Border.all(
            color: GameTheme.gold,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: GameTheme.gold.withOpacity(0.25),
              blurRadius: 24,
            ),
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            symbol,
            style: const TextStyle(
              color: GameTheme.gold,
              fontSize: 78,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// REACTION SWITCH — NUMBER AND RULE
// ======================================================

class DailyReactionDisplay extends StatelessWidget {
  final String number;
  final String rule;

  const DailyReactionDisplay({
    super.key,
    required this.number,
    required this.rule,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: GameTheme.card(
            accent: GameTheme.cyan,
            radius: 15,
          ),
          child: Text(
            rule,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: GameTheme.cyan,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 17),
        Container(
          width: 145,
          height: 145,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: GameTheme.gold.withOpacity(0.12),
            border: Border.all(
              color: GameTheme.gold,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: GameTheme.gold.withOpacity(0.18),
                blurRadius: 25,
              ),
            ],
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 65,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

// ======================================================
// STROOP SHIFT — GLOWING COLOURED WORD
// ======================================================

class DailyStroopDisplay extends StatelessWidget {
  final String word;
  final Color colour;

  const DailyStroopDisplay({
    super.key,
    required this.word,
    required this.colour,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 28,
        horizontal: 12,
      ),
      decoration: GameTheme.card(
        accent: colour,
        radius: 19,
      ),
      child: Column(
        children: [
          const Text(
            'WHAT COLOUR IS THE TEXT?',
            style: TextStyle(
              color: GameTheme.muted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              word.toUpperCase(),
              style: TextStyle(
                color: colour,
                fontSize: 51,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    color: colour.withOpacity(0.35),
                    blurRadius: 15,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Ignore what the word says',
            style: TextStyle(
              color: GameTheme.muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// FOCUS COUNT — COLOURED SYMBOL GRID
// ======================================================

class DailyFocusCountGrid extends StatelessWidget {
  final String question;

  const DailyFocusCountGrid({
    super.key,
    required this.question,
  });

  static const List<String> symbols = [
    '▲',
    '■',
    '●',
    '★',
    '◆',
    '⬟',
  ];

  static const List<Color> colors = [
    GameTheme.cyan,
    GameTheme.gold,
    GameTheme.purple,
    Color(0xFFFF80C7),
    GameTheme.green,
    Color(0xFFFF9569),
  ];

  Color _colourFor(String symbol) {
    final index = symbols.indexOf(symbol);
    return index < 0 ? GameTheme.cyan : colors[index];
  }

  @override
  Widget build(BuildContext context) {
    final items = question
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 6;
        const gap = 5.0;

        final cellSize = math.min(
          50.0,
          (constraints.maxWidth - (columns - 1) * gap) /
              columns,
        );

        final width =
            cellSize * columns + gap * (columns - 1);

        return Center(
          child: SizedBox(
            width: width,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: items.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: gap,
                crossAxisSpacing: gap,
              ),
              itemBuilder: (context, index) {
                final symbol = items[index];
                final colour = _colourFor(symbol);

                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: GameTheme.panelLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colour.withOpacity(0.55),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      symbol,
                      style: TextStyle(
                        color: colour,
                        fontSize: cellSize * 0.57,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ======================================================
// MEMORY GRID — GLOWING 4 × 4 BOARD
// ======================================================

class DailyMemoryGridBoard extends StatelessWidget {
  final List<int> pattern;
  final Set<int> selected;
  final bool showingPattern;
  final ValueChanged<int>? onTap;

  const DailyMemoryGridBoard({
    super.key,
    required this.pattern,
    required this.selected,
    required this.showingPattern,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, 315.0);

        return Center(
          child: SizedBox(
            width: side,
            height: side,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: 16,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final lit =
                    showingPattern && pattern.contains(index);
                final picked = selected.contains(index);

                final color = lit
                    ? GameTheme.gold
                    : picked
                        ? GameTheme.green
                        : GameTheme.panelLight;

                return GestureDetector(
                  onTap: showingPattern
                      ? null
                      : () => onTap?.call(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: lit || picked
                            ? color
                            : GameTheme.border,
                        width: 1.5,
                      ),
                      boxShadow: lit || picked
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      lit
                          ? Icons.auto_awesome_rounded
                          : picked
                              ? Icons.check_rounded
                              : Icons.circle_outlined,
                      color: lit
                          ? GameTheme.background
                          : picked
                              ? Colors.white
                              : GameTheme.border,
                      size: 22,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ======================================================
// MAIN DAILY QUESTION CARD
// ======================================================

class DailyQuestionCard extends StatelessWidget {
  final String title;
  final String instruction;
  final String question;
  final Color? questionColor;
  final int timeLeft;
  final bool compact;
  final String inputText;
  final List<int> memoryGridPattern;
  final Set<int> memoryGridSelected;
  final bool memoryGridShowingPattern;
  final ValueChanged<int>? onMemoryGridTap;

  const DailyQuestionCard({
    super.key,
    required this.title,
    required this.instruction,
    required this.question,
    required this.questionColor,
    required this.timeLeft,
    required this.compact,
    required this.inputText,
    required this.memoryGridPattern,
    required this.memoryGridSelected,
    required this.memoryGridShowingPattern,
    required this.onMemoryGridTap,
  });

  Widget _gameDisplay() {
    final lower = title.toLowerCase();

    if (memoryGridPattern.isNotEmpty) {
      return DailyMemoryGridBoard(
        pattern: memoryGridPattern,
        selected: memoryGridSelected,
        showingPattern: memoryGridShowingPattern,
        onTap: onMemoryGridTap,
      );
    }

    if (lower.contains('order recall')) {
      return DailyOrderRecallTiles(
        question: question,
        inputText: inputText,
      );
    }

    if (lower.contains('focus count')) {
      return DailyFocusCountGrid(question: question);
    }

    if (lower.contains('pattern') ||
        lower.contains('sudoku')) {
      return DailySequenceTiles(sequence: question);
    }

    if (lower.contains('symbol match')) {
      return DailySymbolDisplay(symbol: question);
    }

    if (lower.contains('reaction switch')) {
      return DailyReactionDisplay(
        number: question,
        rule: instruction,
      );
    }

    if (lower.contains('stroop')) {
      return DailyStroopDisplay(
        word: question,
        colour: questionColor ?? Colors.white,
      );
    }

    if (lower.contains('quick math')) {
      return DailyMathDisplay(equation: question);
    }

    if (lower.contains('time difference')) {
      return DailyTimeClocks(question: question);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: GameTheme.card(),
      child: Text(
        question.isNotEmpty ? question : inputText,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: questionColor ?? Colors.white,
          fontSize: 23,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visual = GameVisual.forTitle(title);

    final timerColour = timeLeft <= 5
        ? GameTheme.red
        : visual.color;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 13 : 17),
      decoration: GameTheme.card(
        accent: visual.color,
        radius: 23,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: visual.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: visual.color.withOpacity(0.65),
                  ),
                ),
                child: Icon(
                  visual.icon,
                  color: visual.color,
                  size: 25,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      visual.label,
                      style: TextStyle(
                        color: visual.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: timerColour.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: timerColour),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: timerColour,
                      size: 17,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${timeLeft}s',
                      style: TextStyle(
                        color: timerColour,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            instruction,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: GameTheme.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 15),
          _gameDisplay(),
        ],
      ),
    );
  }
}

// ======================================================
// DAILY ANSWER BUTTONS
// ======================================================

class DailyAnswerButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color accent;

  const DailyAnswerButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.accent = GameTheme.purple,
  });

  @override
  State<DailyAnswerButton> createState() =>
      _DailyAnswerButtonState();
}

class _DailyAnswerButtonState extends State<DailyAnswerButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 110),
        scale: _pressed ? 0.96 : 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(15),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(
                      GameTheme.panelLight,
                      widget.accent,
                      0.24,
                    )!,
                    GameTheme.panel,
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: widget.accent.withOpacity(0.8),
                  width: 1.4,
                ),
                boxShadow: [
                  if (_pressed)
                    BoxShadow(
                      color: widget.accent.withOpacity(0.35),
                      blurRadius: 13,
                    ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.text,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// BOTTOM STAT CARD
// ======================================================

class DailyBottomStatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const DailyBottomStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: GameTheme.card(
        accent: GameTheme.cyan,
        radius: 15,
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: GameTheme.gold,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// BACKGROUND SPARKLES
// ======================================================

class DailySparklesBackground extends StatelessWidget {
  const DailySparklesBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 125,
            right: 21,
            child: Icon(
              Icons.auto_awesome,
              size: 11,
              color: Color(0x996EDBF9),
            ),
          ),
          Positioned(
            top: 350,
            left: 15,
            child: Icon(
              Icons.star_rounded,
              size: 10,
              color: Color(0x88C18AFF),
            ),
          ),
          Positioned(
            bottom: 125,
            right: 25,
            child: Icon(
              Icons.auto_awesome,
              size: 10,
              color: Color(0x88FFC75D),
            ),
          ),
        ],
      ),
    );
  }
}
