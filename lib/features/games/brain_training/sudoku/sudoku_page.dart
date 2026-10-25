
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../shared/game_animations.dart';
import '../../shared/game_theme.dart';
import '../../shared/game_widgets.dart';
import 'sudoku_questions.dart';

class SudokuPage extends StatefulWidget {
  const SudokuPage({super.key});

  @override
  State<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> {
  static const int maxQuestions = 10;

  final Random _random = Random();

  late SudokuQuestion _question;
  late List<String> _options;

  Timer? _advanceTimer;

  int _round = 1;
  int _score = 0;

  String? _selected;
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _newQuestion();
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  void _newQuestion({bool restart = false}) {
    _advanceTimer?.cancel();

    if (restart) {
      _round = 1;
      _score = 0;
    }

    final bank = SudokuQuestions.all;
    _question = bank[_random.nextInt(bank.length)];

    final choices = <String>{_question.answer};
    choices.addAll(_question.options);

    // Ensure four unique answers even when the
    // original question generator contains duplicates.
    var offset = 1;

    while (choices.length < 4) {
      choices.add(
        '${int.parse(_question.answer) + offset}',
      );
      offset++;
    }

    _options = choices.take(4).toList()
      ..shuffle(_random);

    _selected = null;
    _locked = false;

    if (mounted) setState(() {});
  }

  void _answer(String value) {
    if (_locked) return;

    final correct = value == _question.answer;

    setState(() {
      _selected = value;
      _locked = true;

      if (correct) _score++;
    });

    _advanceTimer = Timer(
      const Duration(milliseconds: 950),
      () {
        if (!mounted) return;

        if (_round >= maxQuestions) {
          _showResults();
        } else {
          _round++;
          _newQuestion();
        }
      },
    );
  }

  void _showResults() {
    _advanceTimer?.cancel();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => GameResultsDialog(
        title: 'Sudoku',
        score: _score,
        total: maxQuestions,
        onReplay: () {
          Navigator.of(dialogContext).pop();
          _newQuestion(restart: true);
        },
        onExit: () {
          Navigator.of(dialogContext).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _sequence() {
    final values = _question.row
        .trim()
        .split(RegExp(r'\s+'))
        .where((value) => value.isNotEmpty)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;

        final width = min(
          75.0,
          (constraints.maxWidth - gap * 3) / 4,
        );

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(values.length, (index) {
            final value = values[index];
            final missing = value == '?';

            return Padding(
              padding: EdgeInsets.only(
                right: index == values.length - 1
                    ? 0
                    : gap,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: width,
                height: 76,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      missing
                          ? GameTheme.gold.withOpacity(0.24)
                          : GameTheme.purple.withOpacity(0.22),
                      GameTheme.panel,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: missing
                        ? GameTheme.gold
                        : GameTheme.border,
                    width: missing ? 2 : 1,
                  ),
                  boxShadow: missing
                      ? [
                          BoxShadow(
                            color: GameTheme.gold.withOpacity(0.3),
                            blurRadius: 19,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  missing && _locked
                      ? _question.answer
                      : value,
                  style: TextStyle(
                    color: missing
                        ? GameTheme.gold
                        : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 25,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _option(String value) {
    final selected = value == _selected;
    final isCorrect = value == _question.answer;
    final highlighted = _locked &&
        (selected || isCorrect);

    final color = _locked && isCorrect
        ? GameTheme.green
        : _locked && selected
            ? GameTheme.red
            : GameTheme.purple;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: 72,
      decoration: BoxDecoration(
        color: highlighted
            ? color.withOpacity(0.26)
            : GameTheme.panelLight,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: highlighted ? color : GameTheme.border,
          width: highlighted ? 2 : 1,
        ),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: color.withOpacity(0.24),
                  blurRadius: 16,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _locked ? null : () => _answer(value),
          borderRadius: BorderRadius.circular(17),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (highlighted)
                Positioned(
                  right: 7,
                  top: 7,
                  child: Icon(
                    isCorrect
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: color,
                    size: 19,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _answers() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;

        final width =
            (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: _options.map((value) {
            return SizedBox(
              width: width,
              child: _option(value),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _feedback() {
    if (_selected == null) {
      return const Text(
        'Look for the missing number.',
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
          color: correct
              ? GameTheme.green
              : GameTheme.red,
          size: 21,
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            correct
                ? 'Correct sequence!'
                : 'The missing number was '
                    '${_question.answer}.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: correct
                  ? GameTheme.green
                  : GameTheme.red,
              fontSize: 12,
              fontWeight: FontWeight.w900,
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
        padding: const EdgeInsets.fromLTRB(
          15, 10, 15, 28,
        ),
        children: [
          GameHeader(
            title: 'Sudoku',
            icon: Icons.grid_on_rounded,
            accent: GameTheme.purple,
            onBack: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 21),
          GameRoundProgress(
            current: _round,
            total: maxQuestions,
          ),
          const SizedBox(height: 20),
          GameQuestionReveal(
            questionNumber: _round,
            child: GamePanel(
              title: 'Find the Missing Number',
              instruction:
                  'Study the number pattern and '
                  'complete the sequence.',
              icon: Icons.extension_rounded,
              accent: GameTheme.purple,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GameAnswerFeedback(
                    correct: _selected == null
                        ? null
                        : _selected == _question.answer,
                    child: _sequence(),
                  ),
                  const SizedBox(height: 23),
                  const Text(
                    'CHOOSE THE MISSING NUMBER',
                    style: TextStyle(
                      color: GameTheme.muted,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _answers(),
                  const SizedBox(height: 14),
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
