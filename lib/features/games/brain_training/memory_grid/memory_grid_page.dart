
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/game_animations.dart';
import '../../shared/game_theme.dart';
import '../../shared/game_widgets.dart';
import 'memory_grid_questions.dart';

class MemoryGridPage extends StatefulWidget {
  const MemoryGridPage({super.key});

  @override
  State<MemoryGridPage> createState() => _MemoryGridPageState();
}

class _MemoryGridPageState extends State<MemoryGridPage> {
  static const int maxQuestions = 10;
  static const int baseShowMilliseconds = 1500;

  final Random _random = Random();
  final Set<int> _selected = <int>{};

  MemoryGridQuestion? _question;
  Timer? _hideTimer;
  Timer? _advanceTimer;

  int _score = 0;
  int _round = 1;
  int _userAge = 25;

  bool _showPattern = true;
  bool _answerLocked = false;
  bool? _lastCorrect;

  @override
  void initState() {
    super.initState();
    _loadAge();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _advanceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAge() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    _userAge = prefs.getInt('user_age') ?? 25;
    _startRound();
  }

  int get _showMilliseconds {
    int bonus = 0;

    if (_userAge >= 25 && _userAge < 45) {
      bonus = 2000;
    } else if (_userAge >= 45 && _userAge < 65) {
      bonus = 4000;
    } else if (_userAge >= 65) {
      bonus = 6000;
    }

    return baseShowMilliseconds + bonus;
  }

  String get _timeLabel =>
      '${(_showMilliseconds / 1000).toStringAsFixed(1)}s';

  void _startRound() {
    _hideTimer?.cancel();
    _advanceTimer?.cancel();

    final questions = MemoryGridQuestions.all;

    if (questions.isEmpty) return;

    setState(() {
      _question = questions[_random.nextInt(questions.length)];
      _selected.clear();
      _showPattern = true;
      _answerLocked = false;
      _lastCorrect = null;
    });

    _hideTimer = Timer(
      Duration(milliseconds: _showMilliseconds),
      () {
        if (!mounted) return;
        setState(() => _showPattern = false);
      },
    );
  }

  void _hidePattern() {
    _hideTimer?.cancel();

    if (!mounted || _answerLocked) return;

    setState(() => _showPattern = false);
  }

  void _tap(int index) {
    final question = _question;

    if (question == null || _showPattern || _answerLocked) {
      return;
    }

    if (_selected.contains(index)) return;

    final correctTile = question.pattern.contains(index);

    setState(() {
      _selected.add(index);
    });

    if (!correctTile) {
      _finishAnswer(false);
      return;
    }

    final complete = question.pattern.every(_selected.contains);

    if (complete) {
      _finishAnswer(true);
    }
  }

  void _finishAnswer(bool correct) {
    if (_answerLocked) return;

    setState(() {
      _answerLocked = true;
      _lastCorrect = correct;
      if (correct) _score++;
    });

    _advanceTimer?.cancel();
    _advanceTimer = Timer(
      const Duration(milliseconds: 650),
      () {
        if (!mounted) return;

        if (_round >= maxQuestions) {
          _showResults();
        } else {
          setState(() => _round++);
          _startRound();
        }
      },
    );
  }

  void _restart() {
    Navigator.of(context).pop();

    setState(() {
      _score = 0;
      _round = 1;
    });

    _startRound();
  }

  void _showResults() {
    _hideTimer?.cancel();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return GameResultsDialog(
          title: 'Memory Grid',
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

  Color _tileColour(int index) {
    final question = _question!;

    if (_showPattern && question.pattern.contains(index)) {
      return GameTheme.gold;
    }

    if (_selected.contains(index)) {
      return question.pattern.contains(index)
          ? GameTheme.green
          : GameTheme.red;
    }

    return GameTheme.panelLight;
  }

  Widget _tileGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, 340.0);

        return Center(
          child: SizedBox(
            width: size,
            height: size,
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
                final active = _showPattern &&
                    _question!.pattern.contains(index);

                final picked = _selected.contains(index);

                final colour = _tileColour(index);

                return GestureDetector(
                  onTap: () => _tap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: colour,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: active || picked
                            ? colour
                            : GameTheme.border,
                        width: 1.5,
                      ),
                      boxShadow: [
                        if (active || picked)
                          BoxShadow(
                            color: colour.withOpacity(0.42),
                            blurRadius: 13,
                          ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        picked
                            ? _question!.pattern.contains(index)
                                ? Icons.check_rounded
                                : Icons.close_rounded
                            : active
                                ? Icons.auto_awesome_rounded
                                : Icons.circle_outlined,
                        color: active
                            ? GameTheme.background
                            : picked
                                ? Colors.white
                                : GameTheme.border,
                        size: 23,
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

  Widget _memoryContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GameAnswerFeedback(
          correct: _lastCorrect,
          child: _tileGrid(),
        ),
        const SizedBox(height: 17),
        if (_showPattern)
          TextButton.icon(
            onPressed: _hidePattern,
            icon: const Icon(Icons.fast_forward_rounded),
            label: const Text('Ready to Answer'),
            style: TextButton.styleFrom(
              foregroundColor: GameTheme.gold,
            ),
          )
        else
          Text(
            _answerLocked
                ? (_lastCorrect == true
                    ? 'Perfect recall!'
                    : 'Not quite — keep practising!')
                : 'Tap all the squares you remember',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _lastCorrect == null
                  ? GameTheme.muted
                  : _lastCorrect!
                      ? GameTheme.green
                      : GameTheme.red,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_question == null) {
      return const GameScreen(
        child: Center(
          child: CircularProgressIndicator(
            color: GameTheme.purple,
          ),
        ),
      );
    }

    return GameScreen(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 28),
        children: [
          GameHeader(
            title: 'Memory Grid',
            icon: Icons.grid_view_rounded,
            accent: GameTheme.purple,
            onBack: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 22),
          GameRoundProgress(
            current: _round,
            total: maxQuestions,
          ),
          const SizedBox(height: 21),
          GameQuestionReveal(
            questionNumber: _round,
            child: GamePanel(
              title: 'Memory Grid',
              instruction: _showPattern
                  ? 'Remember the glowing pattern '
                      'for $_timeLabel.'
                  : 'Select the squares that were glowing.',
              icon: Icons.psychology_rounded,
              child: _memoryContent(),
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
