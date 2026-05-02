import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'order_recall_questions.dart';

class OrderRecallPage extends StatefulWidget {
  const OrderRecallPage({super.key});

  @override
  State<OrderRecallPage> createState() => _OrderRecallPageState();
}

class _OrderRecallPageState extends State<OrderRecallPage> {
  final Random _random = Random();

  late OrderRecallQuestion _question;

  int score = 0;
  int questionNumber = 1;
  final int maxQuestions = 10;

  bool showingNumbers = true;

  List<int> answerInput = <int>[];
  List<int> selectableNumbers = <int>[];

  Timer? _hideNumbersTimer;

  @override
  void initState() {
    super.initState();
    _loadQuestion(resetGame: true);
  }

  @override
  void dispose() {
    _hideNumbersTimer?.cancel();
    super.dispose();
  }

  void _loadQuestion({bool resetGame = false}) {
    _hideNumbersTimer?.cancel();

    if (resetGame) {
      score = 0;
      questionNumber = 1;
    }

    _question = OrderRecallQuestions
        .all[_random.nextInt(OrderRecallQuestions.all.length)];

    showingNumbers = true;
    answerInput = <int>[];
    selectableNumbers = List<int>.from(_question.shown)..shuffle(_random);

    setState(() {});

    _hideNumbersTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;

      setState(() {
        showingNumbers = false;
      });
    });
  }

  void _selectNumber(int number) {
    if (showingNumbers) return;
    if (answerInput.contains(number)) return;
    if (answerInput.length >= _question.answer.length) return;

    setState(() {
      answerInput.add(number);
    });

    if (answerInput.length == _question.answer.length) {
      _checkAnswer();
    }
  }

  void _undo() {
    if (showingNumbers) return;
    if (answerInput.isEmpty) return;

    setState(() {
      answerInput.removeLast();
    });
  }

  void _clear() {
    if (showingNumbers) return;

    setState(() {
      answerInput.clear();
    });
  }

  void _checkAnswer() {
    bool correct = true;

    for (int i = 0; i < _question.answer.length; i++) {
      if (answerInput[i] != _question.answer[i]) {
        correct = false;
        break;
      }
    }

    if (correct) {
      score++;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(correct ? '✅ Correct' : '❌ Wrong'),
          duration: const Duration(milliseconds: 550),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              correct ? const Color(0xFF26B957) : const Color(0xFFE94D5F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      if (questionNumber >= maxQuestions) {
        _showFinishedDialog();
      } else {
        questionNumber++;
        _loadQuestion();
      }
    });
  }

  Future<void> _showFinishedDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Order Recall Complete'),
          content: Text('Score: $score / $maxQuestions'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _loadQuestion(resetGame: true);
              },
              child: const Text('Play Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Widget _progressBar() {
    return Row(
      children: List<Widget>.generate(maxQuestions, (index) {
        final bool active = index < questionNumber;

        return Expanded(
          child: Container(
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFF19C2F5)
                  : Colors.white.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }

  Widget _numberOption(int number) {
    final bool used = answerInput.contains(number);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: SizedBox(
          height: 62,
          child: ElevatedButton(
            onPressed: used ? null : () => _selectNumber(number),
            style: ElevatedButton.styleFrom(
              elevation: used ? 0 : 4,
              backgroundColor:
                  used ? Colors.white.withValues(alpha: 0.35) : Colors.white,
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.35),
              disabledForegroundColor: Colors.black.withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String displayText = showingNumbers
        ? _question.shown.join('   ')
        : answerInput.isEmpty
            ? '_   _   _   _   _'
            : answerInput.map((number) => '$number').join('   ');

    return Scaffold(
      backgroundColor: const Color(0xFF6157EA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Order Recall'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            children: [
              _progressBar(),
              const SizedBox(height: 34),
              Text(
                'Question $questionNumber of $maxQuestions',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                showingNumbers
                    ? 'Remember the order'
                    : 'Tap the numbers in the same order',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  displayText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 34),
              if (!showingNumbers) ...[
                Row(
                  children: selectableNumbers
                      .map((number) => _numberOption(number))
                      .toList(),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _actionButton(
                      text: 'UNDO',
                      onPressed: _undo,
                    ),
                    _actionButton(
                      text: 'CLEAR',
                      onPressed: _clear,
                    ),
                  ],
                ),
              ],
              const Spacer(),
              Text(
                'Score: $score',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}