
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../shared/game_animations.dart';
import '../../shared/game_theme.dart';
import '../../shared/game_widgets.dart';
import 'time_difference_questions.dart';

class TimeDifferencePage extends StatefulWidget {
  const TimeDifferencePage({super.key});

  @override
  State<TimeDifferencePage> createState() =>
      _TimeDifferencePageState();
}

class _TimeDifferencePageState extends State<TimeDifferencePage> {
  static const int maxQuestions = 10;

  final Random _random = Random();

  late TimeDifferenceQuestion _question;
  late List<int> _options;

  Timer? _advanceTimer;

  int _round = 1;
  int _score = 0;
  int? _selected;
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

  List<int> _makeOptions(int answer) {
    final choices = <int>{answer};
    final offsets = <int>[
      -30, -20, -15, -10, -5,
      5, 10, 15, 20, 30,
    ]..shuffle(_random);

    for (final difference in offsets) {
      final value = answer + difference;

      if (value > 0) choices.add(value);
      if (choices.length >= 4) break;
    }

    while (choices.length < 4) {
      choices.add(5 + _random.nextInt(25) * 5);
    }

    return choices.toList()..shuffle(_random);
  }

  void _newQuestion({bool restart = false}) {
    _advanceTimer?.cancel();

    if (restart) {
      _round = 1;
      _score = 0;
    }

    final bank = TimeDifferenceQuestions.all;

    _question = bank[_random.nextInt(bank.length)];
    _options = _makeOptions(_question.minutes);

    _selected = null;
    _locked = false;

    if (mounted) setState(() {});
  }

  void _answer(int minutes) {
    if (_locked) return;

    final correct = minutes == _question.minutes;

    setState(() {
      _selected = minutes;
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
        title: 'Time Difference',
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

  Widget _clock(
    String time,
    String label,
    Color accent,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 17,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accent.withOpacity(0.23),
              GameTheme.panel,
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: accent.withOpacity(0.8),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.12),
              blurRadius: 15,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: accent, size: 22),
            const SizedBox(height: 9),
            Text(
              label,
              style: const TextStyle(
                color: GameTheme.muted,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 9),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                time,
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeVisual() {
    return Column(
      children: [
        Row(
          children: [
            _clock(
              _question.from,
              'START',
              GameTheme.cyan,
              Icons.schedule_rounded,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 7),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: GameTheme.gold,
                size: 20,
              ),
            ),
            _clock(
              _question.to,
              'FINISH',
              GameTheme.purple,
              Icons.flag_rounded,
            ),
          ],
        ),
        const SizedBox(height: 19),
        Row(
          children: [
            Container(
              width: 13,
              height: 13,
              decoration: const BoxDecoration(
                color: GameTheme.cyan,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Container(
                height: 5,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GameTheme.cyan,
                      GameTheme.purple,
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: 13,
              height: 13,
              decoration: const BoxDecoration(
                color: GameTheme.purple,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Text(
          _locked
              ? '${_question.minutes} minutes elapsed'
              : 'How many minutes passed?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _locked
                ? GameTheme.gold
                : GameTheme.muted,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _choice(int minutes) {
    final selected = _selected == minutes;
    final isCorrect = minutes == _question.minutes;
    final highlighted =
        _locked && (selected || isCorrect);

    final color = _locked && isCorrect
        ? GameTheme.green
        : _locked && selected
            ? GameTheme.red
            : GameTheme.purple;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: 69,
      decoration: BoxDecoration(
        color: highlighted
            ? color.withOpacity(0.25)
            : GameTheme.panelLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? color : GameTheme.border,
          width: highlighted ? 2 : 1,
        ),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 15,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _locked ? null : () => _answer(minutes),
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '$minutes min',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
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
        final width = (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: _options.map((minutes) {
            return SizedBox(
              width: width,
              child: _choice(minutes),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _feedback() {
    if (_selected == null) {
      return const Text(
        'Compare the two clocks carefully.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: GameTheme.muted,
          fontSize: 12,
        ),
      );
    }

    final correct = _selected == _question.minutes;

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
                ? 'Exactly right!'
                : 'Correct answer: ${_question.minutes} minutes.',
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
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 28),
        children: [
          GameHeader(
            title: 'Time Difference',
            icon: Icons.access_time_filled_rounded,
            accent: GameTheme.cyan,
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
              title: 'Time Challenge',
              instruction:
                  'Work out the elapsed time between '
                  'these two digital clocks.',
              icon: Icons.timer_rounded,
              accent: GameTheme.cyan,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GameAnswerFeedback(
                    correct: _selected == null
                        ? null
                        : _selected == _question.minutes,
                    child: _timeVisual(),
                  ),
                  const SizedBox(height: 22),
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
