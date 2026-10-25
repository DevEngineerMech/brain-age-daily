
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../shared/game_animations.dart';
import '../../shared/game_theme.dart';
import '../../shared/game_widgets.dart';
import 'reaction_switch_questions.dart';

class ReactionSwitchPage extends StatefulWidget {
  const ReactionSwitchPage({super.key});

  @override
  State<ReactionSwitchPage> createState() =>
      _ReactionSwitchPageState();
}

class _ReactionSwitchPageState extends State<ReactionSwitchPage> {
  static const int maxQuestions = 10;

  final Random _random = Random();
  final Stopwatch _stopwatch = Stopwatch();

  late ReactionSwitchQuestion _question;

  Timer? _advanceTimer;

  int _round = 1;
  int _score = 0;

  int _lastResponseMs = 0;
  int _totalResponseMs = 0;

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
    _stopwatch.stop();
    super.dispose();
  }

  void _newQuestion({bool restart = false}) {
    _advanceTimer?.cancel();
    _stopwatch
      ..stop()
      ..reset();

    if (restart) {
      _round = 1;
      _score = 0;
      _totalResponseMs = 0;
    }

    final bank = ReactionSwitchQuestions.all;

    _question = bank[_random.nextInt(bank.length)];

    _selected = null;
    _lastResponseMs = 0;
    _locked = false;

    _stopwatch.start();

    if (mounted) setState(() {});
  }

  void _answer(String value) {
    if (_locked) return;

    _stopwatch.stop();
    final responseMs = _stopwatch.elapsedMilliseconds;

    final correct = value == _question.answer;

    setState(() {
      _selected = value;
      _locked = true;
      _lastResponseMs = responseMs;
      _totalResponseMs += responseMs;

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
          _newQuestion();
        }
      },
    );
  }

  void _showResults() {
    _advanceTimer?.cancel();
    _stopwatch.stop();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return GameResultsDialog(
          title: 'Reaction Switch',
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

  Color _ruleColor() {
    if (_question.prompt.contains('even')) {
      return GameTheme.cyan;
    }

    if (_question.prompt.contains('above')) {
      return GameTheme.gold;
    }

    return GameTheme.purple;
  }

  IconData _ruleIcon() {
    if (_question.prompt.contains('even')) {
      return Icons.calculate_rounded;
    }

    if (_question.prompt.contains('above')) {
      return Icons.arrow_upward_rounded;
    }

    return Icons.functions_rounded;
  }

  String _ruleText() {
    final prompt = _question.prompt;

    if (prompt.contains('even')) {
      return 'Is the number EVEN?';
    }

    if (prompt.contains('above 10')) {
      return 'Is the number ABOVE 10?';
    }

    if (prompt.contains('divisible by 3')) {
      return 'Is it DIVISIBLE BY 3?';
    }

    return prompt;
  }

  Widget _ruleBanner() {
    final color = _ruleColor();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: color.withOpacity(0.8),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _ruleIcon(),
            color: color,
            size: 27,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _ruleText(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberDisplay() {
    final color = _ruleColor();

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 180,
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(0.27),
              GameTheme.panel,
            ],
          ),
          border: Border.all(
            color: color,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.20),
              blurRadius: 30,
            ),
          ],
        ),
        child: Text(
          _question.display,
          style: TextStyle(
            color: Colors.white,
            fontSize: 83,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: color.withOpacity(0.55),
                blurRadius: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _answerButton(String value) {
    final bool yes = value == 'YES';
    final bool selected = _selected == value;
    final bool correctAnswer = value == _question.answer;

    final bool highlighted =
        _locked && (selected || correctAnswer);

    final color = _locked && correctAnswer
        ? GameTheme.green
        : _locked && selected
            ? GameTheme.red
            : yes
                ? GameTheme.cyan
                : const Color(0xFFFF80C7);

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 190),
        height: 82,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(highlighted ? 0.34 : 0.22),
              GameTheme.panel,
            ],
          ),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: color,
            width: highlighted ? 2.5 : 1.4,
          ),
          boxShadow: highlighted
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 18,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _locked ? null : () => _answer(value),
            borderRadius: BorderRadius.circular(19),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  highlighted
                      ? correctAnswer
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded
                      : yes
                          ? Icons.check_rounded
                          : Icons.close_rounded,
                  color: color,
                  size: 26,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: highlighted ? color : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _feedback() {
    if (_selected == null) {
      return const Text(
        'React quickly, but choose carefully.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: GameTheme.muted,
          fontSize: 12,
        ),
      );
    }

    final correct = _selected == _question.answer;

    return Column(
      children: [
        Text(
          correct ? 'Correct reaction!' : 'Not quite!',
          style: TextStyle(
            color: correct
                ? GameTheme.green
                : GameTheme.red,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Response time: '
          '${(_lastResponseMs / 1000).toStringAsFixed(2)}s',
          style: const TextStyle(
            color: GameTheme.muted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _speedStat() {
    final answered = _round - 1 + (_locked ? 1 : 0);

    final average = answered == 0
        ? 0.0
        : _totalResponseMs / answered / 1000;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: GameTheme.card(
        accent: GameTheme.cyan,
        radius: 15,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.timer_rounded,
            color: GameTheme.cyan,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Average Response',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            answered == 0
                ? '—'
                : '${average.toStringAsFixed(2)}s',
            style: const TextStyle(
              color: GameTheme.cyan,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameScreen(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 28),
        children: [
          GameHeader(
            title: 'Reaction Switch',
            icon: Icons.bolt_rounded,
            accent: GameTheme.gold,
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
              title: 'Quick Thinking',
              instruction:
                  'The rule may change each round. '
                  'Read it before choosing.',
              icon: Icons.flash_on_rounded,
              accent: GameTheme.gold,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ruleBanner(),
                  const SizedBox(height: 20),
                  GameAnswerFeedback(
                    correct: _selected == null
                        ? null
                        : _selected == _question.answer,
                    child: _numberDisplay(),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      _answerButton('YES'),
                      const SizedBox(width: 12),
                      _answerButton('NO'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _feedback(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GameScoreChip(
            score: _score,
            total: maxQuestions,
          ),
          const SizedBox(height: 10),
          _speedStat(),
        ],
      ),
    );
  }
}
