
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/game_animations.dart';
import '../../shared/game_theme.dart';
import '../../shared/game_widgets.dart';
import 'quick_math_questions.dart';

class QuickMathPage extends StatefulWidget {
  const QuickMathPage({super.key});

  @override
  State<QuickMathPage> createState() => _QuickMathPageState();
}

class _QuickMathPageState extends State<QuickMathPage> {
  static const int maxQuestions = 10;

  final Random _random = Random();
  final TextEditingController _answerController =
      TextEditingController();
  final FocusNode _answerFocus = FocusNode();

  late QuickMathQuestion _question;

  Timer? _advanceTimer;

  int _round = 1;
  int _score = 0;

  bool _locked = false;
  bool? _correct;
  int? _submittedAnswer;

  @override
  void initState() {
    super.initState();
    _newQuestion();
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _answerController.dispose();
    _answerFocus.dispose();
    super.dispose();
  }

  void _newQuestion({bool restart = false}) {
    _advanceTimer?.cancel();

    if (restart) {
      _round = 1;
      _score = 0;
    }

    final bank = QuickMathQuestions.all;
    _question = bank[_random.nextInt(bank.length)];

    _answerController.clear();
    _locked = false;
    _correct = null;
    _submittedAnswer = null;

    if (mounted) setState(() {});
  }

  void _submit() {
    if (_locked) return;

    final value = int.tryParse(_answerController.text.trim());

    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a number first.'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    _answerFocus.unfocus();

    final correct = value == _question.answer;

    setState(() {
      _submittedAnswer = value;
      _correct = correct;
      _locked = true;

      if (correct) _score++;
    });

    _advanceTimer = Timer(
      const Duration(milliseconds: 1050),
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
    _answerFocus.unfocus();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => GameResultsDialog(
        title: 'Quick Math',
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

  Color get _operationColor {
    if (_question.text.contains('×')) {
      return GameTheme.cyan;
    }
    if (_question.text.contains('÷')) {
      return GameTheme.gold;
    }
    if (_question.text.contains('-')) {
      return const Color(0xFFFF91C8);
    }
    return GameTheme.purple;
  }

  String get _operationName {
    if (_question.text.contains('×')) return 'MULTIPLICATION';
    if (_question.text.contains('÷')) return 'DIVISION';
    if (_question.text.contains('-')) return 'SUBTRACTION';
    return 'ADDITION';
  }

  Widget _equation() {
    final accent = _operationColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 28,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withOpacity(0.23),
            GameTheme.panel,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withOpacity(0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.16),
            blurRadius: 22,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _operationName,
            style: TextStyle(
              color: accent,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 15),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${_question.text} = ?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 49,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _answerField() {
    return Container(
      decoration: BoxDecoration(
        color: GameTheme.panelLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _correct == null
              ? GameTheme.border
              : _correct!
                  ? GameTheme.green
                  : GameTheme.red,
          width: _correct == null ? 1.2 : 2,
        ),
      ),
      child: TextField(
        controller: _answerController,
        focusNode: _answerFocus,
        enabled: !_locked,
        keyboardType: const TextInputType.numberWithOptions(
          signed: true,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(r'^-?\d*'),
          ),
        ],
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 31,
          fontWeight: FontWeight.w900,
        ),
        decoration: const InputDecoration(
          hintText: 'Your answer',
          hintStyle: TextStyle(
            color: GameTheme.muted,
            fontSize: 19,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 15,
          ),
          border: InputBorder.none,
          counterText: '',
        ),
      ),
    );
  }

  Widget _feedback() {
    if (_correct == null) {
      return const Text(
        'Work it out, then submit your answer.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: GameTheme.muted,
          fontSize: 12,
        ),
      );
    }

    final correct = _correct!;

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
                ? 'Correct! Great thinking.'
                : 'You answered $_submittedAnswer. '
                    'Correct answer: ${_question.answer}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: correct ? GameTheme.green : GameTheme.red,
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
        keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 28),
        children: [
          GameHeader(
            title: 'Quick Math',
            icon: Icons.calculate_rounded,
            accent: GameTheme.gold,
            onBack: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 22),
          GameRoundProgress(
            current: _round,
            total: maxQuestions,
          ),
          const SizedBox(height: 20),
          GameQuestionReveal(
            questionNumber: _round,
            child: GamePanel(
              title: 'Mental Maths',
              instruction:
                  'Solve the equation as accurately '
                  'and quickly as you can.',
              icon: Icons.functions_rounded,
              accent: _operationColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GameAnswerFeedback(
                    correct: _correct,
                    child: _equation(),
                  ),
                  const SizedBox(height: 20),
                  _answerField(),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 51,
                    child: ElevatedButton.icon(
                      onPressed: _locked ? null : _submit,
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                      ),
                      label: Text(
                        _locked
                            ? 'Answer Submitted'
                            : 'Submit Answer',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GameTheme.purple,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            GameTheme.panelLight,
                        disabledForegroundColor:
                            GameTheme.muted,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
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
