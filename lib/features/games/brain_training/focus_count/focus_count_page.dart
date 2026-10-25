
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../shared/game_animations.dart';
import '../../shared/game_theme.dart';
import '../../shared/game_widgets.dart';
import 'focus_count_questions.dart';

class FocusCountPage extends StatefulWidget {
  final String? gameId;
  final String title;

  const FocusCountPage({
    super.key,
    this.gameId,
    this.title = 'Focus Count',
  });

  @override
  State<FocusCountPage> createState() => _FocusCountPageState();
}

class _FocusCountPageState extends State<FocusCountPage> {
  static const int maxQuestions = 10;

  static const List<Color> _symbolColors = [
    GameTheme.cyan,
    GameTheme.gold,
    GameTheme.purple,
    Color(0xFFFF80C7),
    GameTheme.green,
    Color(0xFFFF9569),
  ];

  static const List<String> _symbols = [
    '▲',
    '■',
    '●',
    '★',
    '◆',
    '⬟',
  ];

  final Random _random = Random();

  late FocusCountQuestion _question;
  late List<int> _options;

  int _score = 0;
  int _round = 1;

  int? _selected;
  bool _answerLocked = false;

  Timer? _advanceTimer;

  @override
  void initState() {
    super.initState();
    _prepareQuestion();
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  Color _colorFor(String symbol) {
    final index = _symbols.indexOf(symbol);

    if (index == -1) return GameTheme.purple;

    return _symbolColors[index % _symbolColors.length];
  }

  void _prepareQuestion({bool restart = false}) {
    _advanceTimer?.cancel();

    if (restart) {
      _score = 0;
      _round = 1;
    }

    _question = FocusCountQuestions.random(_random);
    _options = FocusCountQuestions.optionsFor(
      _question,
      _random,
    );

    _selected = null;
    _answerLocked = false;

    if (mounted) setState(() {});
  }

  void _answer(int value) {
    if (_answerLocked) return;

    final correct = value == _question.answer;

    setState(() {
      _selected = value;
      _answerLocked = true;

      if (correct) _score++;
    });

    _advanceTimer = Timer(
      const Duration(milliseconds: 850),
      () {
        if (!mounted) return;

        if (_round >= maxQuestions) {
          _showResults();
        } else {
          _round++;
          _prepareQuestion();
        }
      },
    );
  }

  void _showResults() {
    _advanceTimer?.cancel();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return GameResultsDialog(
          title: widget.title,
          score: _score,
          total: maxQuestions,
          onReplay: () {
            Navigator.of(dialogContext).pop();
            _prepareQuestion(restart: true);
          },
          onExit: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Widget _targetDisplay() {
    final color = _colorFor(_question.target);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 13,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: color.withOpacity(0.7),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _question.target,
            style: TextStyle(
              color: color,
              fontSize: 42,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'COUNT THIS SHAPE',
                  style: TextStyle(
                    color: GameTheme.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'How many are there?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _symbolGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 6;
        const spacing = 5.0;

        final availableWidth = constraints.maxWidth;
        final cellSize = min(
          51.0,
          (availableWidth - (columns - 1) * spacing) /
              columns,
        );

        final gridWidth =
            cellSize * columns + spacing * (columns - 1);

        return Center(
          child: SizedBox(
            width: gridWidth,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: _question.grid.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final symbol = _question.grid[index];
                final color = _colorFor(symbol);
                final isTarget = symbol == _question.target;

                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: GameTheme.panelLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isTarget
                          ? color.withOpacity(0.48)
                          : GameTheme.border.withOpacity(0.7),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      symbol,
                      style: TextStyle(
                        fontSize: cellSize * 0.58,
                        color: color,
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

  Widget _answerButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;

        final width = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _options.map((number) {
            final selected = number == _selected;
            final isCorrect = number == _question.answer;

            final highlighted = _answerLocked &&
                (selected || isCorrect);

            final Color color = _answerLocked && isCorrect
                ? GameTheme.green
                : _answerLocked && selected
                    ? GameTheme.red
                    : GameTheme.purple;

            return SizedBox(
              width: width,
              height: 65,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                decoration: BoxDecoration(
                  color: highlighted
                      ? color.withOpacity(0.26)
                      : GameTheme.panelLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: highlighted
                        ? color
                        : GameTheme.border,
                    width: highlighted ? 2.0 : 1.0,
                  ),
                  boxShadow: highlighted
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.23),
                            blurRadius: 14,
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _answerLocked
                        ? null
                        : () => _answer(number),
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '$number',
                          style: TextStyle(
                            color: highlighted
                                ? color
                                : Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (highlighted)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Icon(
                              isCorrect
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: color,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _feedback() {
    if (_selected == null) {
      return const Text(
        'Look carefully before choosing.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: GameTheme.muted,
          fontSize: 12,
        ),
      );
    }

    final correct = _selected == _question.answer;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          correct
              ? Icons.check_circle_rounded
              : Icons.cancel_rounded,
          color: correct ? GameTheme.green : GameTheme.red,
          size: 21,
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            correct
                ? 'Brilliant counting!'
                : 'There were ${_question.answer} '
                    '${_question.target} symbols.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: correct
                  ? GameTheme.green
                  : GameTheme.red,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameScreen(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 28),
        children: [
          GameHeader(
            title: widget.title,
            icon: Icons.center_focus_strong_rounded,
            accent: GameTheme.cyan,
            onBack: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 19),
          GameRoundProgress(
            current: _round,
            total: maxQuestions,
            accent: GameTheme.gold,
          ),
          const SizedBox(height: 17),
          GameQuestionReveal(
            questionNumber: _round,
            child: GamePanel(
              title: 'Focus Count',
              instruction:
                  'Find and count the matching shapes.',
              icon: Icons.visibility_rounded,
              accent: GameTheme.cyan,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _targetDisplay(),
                  const SizedBox(height: 16),
                  GameAnswerFeedback(
                    correct: _selected == null
                        ? null
                        : _selected == _question.answer,
                    child: _symbolGrid(),
                  ),
                  const SizedBox(height: 17),
                  _answerButtons(),
                  const SizedBox(height: 12),
                  _feedback(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 17),
          GameScoreChip(
            score: _score,
            total: maxQuestions,
          ),
        ],
      ),
    );
  }
}
