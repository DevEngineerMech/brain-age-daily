
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../shared/game_animations.dart';
import '../../shared/game_theme.dart';
import '../../shared/game_widgets.dart';
import 'order_recall_questions.dart';

class OrderRecallPage extends StatefulWidget {
  const OrderRecallPage({super.key});

  @override
  State<OrderRecallPage> createState() => _OrderRecallPageState();
}

class _OrderRecallPageState extends State<OrderRecallPage> {
  static const int maxQuestions = 10;

  final Random _random = Random();

  late OrderRecallQuestion _question;

  int _score = 0;
  int _round = 1;
  int _revealedCount = 0;

  bool _showingNumbers = true;
  bool _answerLocked = false;
  bool? _correct;

  List<int> _answerInput = [];
  List<int> _selectableNumbers = [];

  Timer? _revealTimer;
  Timer? _advanceTimer;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _advanceTimer?.cancel();
    super.dispose();
  }

  void _loadQuestion({bool reset = false}) {
    _revealTimer?.cancel();
    _advanceTimer?.cancel();

    if (reset) {
      _score = 0;
      _round = 1;
    }

    final questions = OrderRecallQuestions.all;

    _question = questions[_random.nextInt(questions.length)];

    _answerInput = [];
    _selectableNumbers = List<int>.from(_question.shown)
      ..shuffle(_random);

    _showingNumbers = true;
    _answerLocked = false;
    _correct = null;
    _revealedCount = 0;

    if (mounted) setState(() {});

    _revealTimer = Timer.periodic(
      const Duration(milliseconds: 430),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          _revealedCount++;
        });

        if (_revealedCount >= _question.shown.length) {
          timer.cancel();
        }
      },
    );
  }

  void _startRecall() {
    if (!_showingNumbers ||
        _revealedCount < _question.shown.length) {
      return;
    }

    _revealTimer?.cancel();

    setState(() {
      _showingNumbers = false;
      _answerInput.clear();
    });
  }

  void _selectNumber(int number) {
    if (_showingNumbers || _answerLocked) return;
    if (_answerInput.contains(number)) return;
    if (_answerInput.length >= _question.answer.length) return;

    setState(() {
      _answerInput.add(number);
    });

    if (_answerInput.length == _question.answer.length) {
      _checkAnswer();
    }
  }

  void _undo() {
    if (_showingNumbers ||
        _answerLocked ||
        _answerInput.isEmpty) {
      return;
    }

    setState(() {
      _answerInput.removeLast();
    });
  }

  void _clear() {
    if (_showingNumbers || _answerLocked) return;

    setState(() {
      _answerInput.clear();
    });
  }

  void _checkAnswer() {
    if (_answerLocked) return;

    bool correct = true;

    for (int i = 0; i < _question.answer.length; i++) {
      if (_answerInput[i] != _question.answer[i]) {
        correct = false;
        break;
      }
    }

    setState(() {
      _answerLocked = true;
      _correct = correct;

      if (correct) _score++;
    });

    _advanceTimer = Timer(
      const Duration(milliseconds: 1000),
      () {
        if (!mounted) return;

        if (_round >= maxQuestions) {
          _showResults();
        } else {
          _round++;
          _loadQuestion();
        }
      },
    );
  }

  void _showResults() {
    _revealTimer?.cancel();
    _advanceTimer?.cancel();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return GameResultsDialog(
          title: 'Order Recall',
          score: _score,
          total: maxQuestions,
          onReplay: () {
            Navigator.of(dialogContext).pop();
            _loadQuestion(reset: true);
          },
          onExit: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Color _numberColor(int index) {
    const colors = [
      GameTheme.purple,
      GameTheme.cyan,
      GameTheme.gold,
      Color(0xFFFF80C7),
      GameTheme.green,
    ];

    return colors[index % colors.length];
  }

  Widget _numberTile({
    required int index,
    required int? number,
    bool selected = false,
    bool glowing = false,
    VoidCallback? onTap,
  }) {
    final color = _numberColor(index);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: number == null
            ? GameTheme.panelLight
            : color.withOpacity(selected ? 0.32 : 0.17),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: number == null
              ? GameTheme.border
              : color,
          width: number == null ? 1 : 1.6,
        ),
        boxShadow: [
          if (glowing && number != null)
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 16,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 230),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: Text(
                number?.toString() ?? '?',
                key: ValueKey(number),
                style: TextStyle(
                  color: number == null
                      ? GameTheme.border
                      : Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sequence() {
    final count = _question.shown.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 7.0;

        final tileWidth = min(
          61.0,
          (constraints.maxWidth - (count - 1) * gap) / count,
        );

        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (index) {
              int? value;

              if (_showingNumbers) {
                if (index < _revealedCount) {
                  value = _question.shown[index];
                }
              } else if (index < _answerInput.length) {
                value = _answerInput[index];
              }

              return Padding(
                padding: EdgeInsets.only(
                  right: index == count - 1 ? 0 : gap,
                ),
                child: SizedBox(
                  width: tileWidth,
                  height: 64,
                  child: _numberTile(
                    index: index,
                    number: value,
                    glowing: _showingNumbers,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _answerOptions() {
    return Column(
      children: [
        const Text(
          'TAP THE NUMBERS IN THE ORIGINAL ORDER',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: GameTheme.muted,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 13),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 9.0;

            final cellWidth =
                (constraints.maxWidth - spacing * 2) / 3;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              alignment: WrapAlignment.center,
              children: List.generate(
                _selectableNumbers.length,
                (index) {
                  final number = _selectableNumbers[index];
                  final used = _answerInput.contains(number);

                  return SizedBox(
                    width: cellWidth,
                    height: 60,
                    child: _numberTile(
                      index: index,
                      number: number,
                      selected: used,
                      glowing: !used,
                      onTap: used || _answerLocked
                          ? null
                          : () => _selectNumber(number),
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _answerInput.isNotEmpty &&
                        !_answerLocked
                    ? _undo
                    : null,
                icon: const Icon(Icons.undo_rounded),
                label: const Text('Undo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: GameTheme.cyan,
                  side: const BorderSide(
                    color: GameTheme.border,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _answerInput.isNotEmpty &&
                        !_answerLocked
                    ? _clear
                    : null,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Clear'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: GameTheme.muted,
                  side: const BorderSide(
                    color: GameTheme.border,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _feedback() {
    if (_correct == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Icon(
            _correct!
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            color: _correct!
                ? GameTheme.green
                : GameTheme.red,
            size: 34,
          ),
          const SizedBox(height: 6),
          Text(
            _correct!
                ? 'Perfect recall!'
                : 'The correct order was '
                    '${_question.answer.join(' → ')}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _correct!
                  ? GameTheme.green
                  : GameTheme.red,
              fontSize: 13,
              fontWeight: FontWeight.w800,
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
            title: 'Order Recall',
            icon: Icons.format_list_numbered_rounded,
            accent: GameTheme.cyan,
            onBack: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 22),
          GameRoundProgress(
            current: _round,
            total: maxQuestions,
            accent: GameTheme.gold,
          ),
          const SizedBox(height: 21),
          GameQuestionReveal(
            questionNumber: _round,
            child: GamePanel(
              title: _showingNumbers
                  ? 'Remember the Order'
                  : 'Rebuild the Sequence',
              instruction: _showingNumbers
                  ? 'Watch the five numbers appear '
                      'from left to right.'
                  : 'Tap the numbers in exactly '
                      'the same order.',
              icon: Icons.psychology_rounded,
              accent: GameTheme.cyan,
              child: GameAnswerFeedback(
                correct: _correct,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _sequence(),
                    const SizedBox(height: 17),
                    if (_showingNumbers)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _revealedCount ==
                                  _question.shown.length
                              ? _startRecall
                              : null,
                          icon: Icon(
                            _revealedCount ==
                                    _question.shown.length
                                ? Icons.visibility_off_rounded
                                : Icons.hourglass_top_rounded,
                          ),
                          label: Text(
                            _revealedCount ==
                                    _question.shown.length
                                ? 'Start Recalling'
                                : 'Remembering... '
                                    '$_revealedCount / '
                                    '${_question.shown.length}',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GameTheme.purple,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                GameTheme.panelLight,
                            disabledForegroundColor:
                                GameTheme.muted,
                            padding: const EdgeInsets.all(15),
                          ),
                        ),
                      )
                    else ...[
                      _answerOptions(),
                      _feedback(),
                    ],
                  ],
                ),
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
