
import 'dart:async';

import 'package:flutter/material.dart';

import '../../shared/game_animations.dart';
import '../../shared/game_theme.dart';
import '../../shared/game_widgets.dart';
import 'pattern_logic_questions.dart';

class PatternLogicPage extends StatefulWidget {
  const PatternLogicPage({super.key});

  @override
  State<PatternLogicPage> createState() =>
      _PatternLogicPageState();
}

class _PatternLogicPageState extends State<PatternLogicPage> {
  static const int maxQuestions = 10;

  late PatternLogicQuestion _question;

  int _score = 0;
  int _round = 1;

  bool _answerLocked = false;
  String? _selectedAnswer;
  Timer? _advanceTimer;

  @override
  void initState() {
    super.initState();
    _question = PatternLogicQuestion.generate();
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  void _select(String answer) {
    if (_answerLocked) return;

    final correct = answer == _question.answer;

    setState(() {
      _answerLocked = true;
      _selectedAnswer = answer;

      if (correct) _score++;
    });

    _advanceTimer?.cancel();

    _advanceTimer = Timer(
      const Duration(milliseconds: 650),
      () {
        if (!mounted) return;

        if (_round >= maxQuestions) {
          _showResults();
          return;
        }

        _next();
      },
    );
  }

  void _next() {
    setState(() {
      _question = PatternLogicQuestion.generate();
      _round++;
      _selectedAnswer = null;
      _answerLocked = false;
    });
  }

  void _restart() {
    Navigator.of(context).pop();

    _advanceTimer?.cancel();

    setState(() {
      _score = 0;
      _round = 1;
      _selectedAnswer = null;
      _answerLocked = false;
      _question = PatternLogicQuestion.generate();
    });
  }

  void _showResults() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return GameResultsDialog(
          title: 'Pattern Logic',
          score: _score,
          total: maxQuestions,
          onReplay: _restart,
          onExit: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Widget _sequence() {
    final tokens = _question.sequence
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 9,
      children: tokens.map((value) {
        final missing = value == '?';

        return Container(
          width: 53,
          height: 57,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: missing
                ? GameTheme.gold.withOpacity(0.17)
                : GameTheme.panelLight,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: missing
                  ? GameTheme.gold
                  : GameTheme.border,
              width: missing ? 2 : 1,
            ),
            boxShadow: [
              if (missing)
                BoxShadow(
                  color: GameTheme.gold.withOpacity(0.24),
                  blurRadius: 16,
                ),
            ],
          ),
          child: Text(
            value,
            style: TextStyle(
              color: missing ? GameTheme.gold : Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 21,
            ),
          ),
        );
      }).toList(),
    );
  }

  bool? _answerState(String option) {
    if (!_answerLocked) return null;

    if (option == _question.answer) return true;
    if (option == _selectedAnswer) return false;

    return null;
  }

  Widget _answers() {
    return Column(
      children: _question.options.map((option) {
        final highlighted = _answerLocked &&
            (option == _selectedAnswer ||
                option == _question.answer);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GameAnswerButton(
            text: option,
            selected: highlighted,
            correct: _answerState(option),
            onPressed:
                _answerLocked ? null : () => _select(option),
            accent: GameTheme.purple,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameScreen(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 28),
        children: [
          GameHeader(
            title: 'Pattern Logic',
            icon: Icons.auto_awesome_mosaic_rounded,
            onBack: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 22),
          GameRoundProgress(
            current: _round,
            total: maxQuestions,
          ),
          const SizedBox(height: 22),
          GameQuestionReveal(
            questionNumber: _round,
            child: GamePanel(
              title: 'Find the Pattern',
              instruction:
                  'Study the sequence and choose what comes next.',
              icon: Icons.extension_rounded,
              child: _sequence(),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(bottom: 11),
            child: Text(
              'CHOOSE YOUR ANSWER',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: GameTheme.muted,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
          GameAnswerFeedback(
            correct: _selectedAnswer == null
                ? null
                : _selectedAnswer == _question.answer,
            child: _answers(),
          ),
          const SizedBox(height: 10),
          GameScoreChip(
            score: _score,
            total: maxQuestions,
          ),
        ],
      ),
    );
  }
}
