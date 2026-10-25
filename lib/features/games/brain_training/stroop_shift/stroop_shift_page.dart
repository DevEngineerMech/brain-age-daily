
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../shared/game_animations.dart';
import '../../shared/game_theme.dart';
import '../../shared/game_widgets.dart';
import 'stroop_shift_questions.dart';

class StroopShiftPage extends StatefulWidget {
  const StroopShiftPage({super.key});

  @override
  State<StroopShiftPage> createState() => _StroopShiftPageState();
}

class _StroopShiftPageState extends State<StroopShiftPage> {
  static const int maxQuestions = 10;

  static const Map<String, Color> _colors = {
    'Red': Color(0xFFFF536C),
    'Blue': Color(0xFF439CFF),
    'Green': Color(0xFF4BE09D),
    'Yellow': Color(0xFFFFDD4D),
    'Purple': Color(0xFFAF7CFF),
    'Orange': Color(0xFFFF984B),
  };

  final Random _random = Random();

  late StroopShiftQuestion _question;
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

  Color _colorOf(String name) {
    return _colors[name] ?? Colors.white;
  }

  void _newQuestion({bool restart = false}) {
    _advanceTimer?.cancel();

    if (restart) {
      _round = 1;
      _score = 0;
    }

    final questions = StroopShiftQuestions.all;

    _question = questions[_random.nextInt(questions.length)];
    _options = List<String>.from(_question.options)
      ..shuffle(_random);

    _selected = null;
    _locked = false;

    if (mounted) setState(() {});
  }

  void _answer(String answer) {
    if (_locked) return;

    final correct = answer == _question.answer;

    setState(() {
      _selected = answer;
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
      builder: (dialogContext) {
        return GameResultsDialog(
          title: 'Stroop Shift',
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
        );
      },
    );
  }

  Widget _wordDisplay() {
    final ink = _colorOf(_question.inkColour);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 29,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: ink.withOpacity(0.10),
        border: Border.all(
          color: ink.withOpacity(0.6),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: ink.withOpacity(0.13),
            blurRadius: 23,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'WHAT COLOUR IS THE TEXT?',
            style: TextStyle(
              color: GameTheme.muted,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _question.word.toUpperCase(),
              style: TextStyle(
                color: ink,
                fontSize: 53,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: ink.withOpacity(0.28),
                    blurRadius: 13,
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorButton(String name) {
    final color = _colorOf(name);
    final selected = _selected == name;
    final correctAnswer = _question.answer == name;

    final showCorrect = _locked && correctAnswer;
    final showWrong = _locked && selected && !correctAnswer;

    final outline = showCorrect
        ? GameTheme.green
        : showWrong
            ? GameTheme.red
            : color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 67,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            outline.withOpacity(
              showCorrect || showWrong ? 0.36 : 0.19,
            ),
            GameTheme.panel,
          ],
        ),
        border: Border.all(
          color: outline,
          width: showCorrect || showWrong ? 2.5 : 1.2,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (showCorrect || showWrong)
            BoxShadow(
              color: outline.withOpacity(0.32),
              blurRadius: 14,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _locked ? null : () => _answer(name),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 17,
                  height: 17,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white54,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (showCorrect || showWrong) ...[
                  const SizedBox(width: 4),
                  Icon(
                    showCorrect
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: outline,
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _answers() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 9.0;
        final cellWidth =
            (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _options.map((name) {
            return SizedBox(
              width: cellWidth,
              child: _colorButton(name),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _feedback() {
    if (_selected == null) {
      return const Text(
        'Choose the ink colour, not the written word.',
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
                ? 'Well spotted!'
                : 'The ink colour was ${_question.answer}.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: correct ? GameTheme.green : GameTheme.red,
              fontWeight: FontWeight.w900,
              fontSize: 13,
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
            title: 'Stroop Shift',
            icon: Icons.palette_rounded,
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
              title: 'Colour Challenge',
              instruction:
                  'Ignore the written word. '
                  'Select the colour it is displayed in.',
              icon: Icons.visibility_rounded,
              accent: GameTheme.purple,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GameAnswerFeedback(
                    correct: _selected == null
                        ? null
                        : _selected == _question.answer,
                    child: _wordDisplay(),
                  ),
                  const SizedBox(height: 19),
                  const Text(
                    'SELECT THE INK COLOUR',
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
