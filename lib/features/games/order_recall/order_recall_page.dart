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

  @override
  void initState() {
    super.initState();
    _loadQuestion(resetGame: true);
  }

  void _loadQuestion({bool resetGame = false}) {
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
  }

  void _goToAnswerScreen() {
    if (!showingNumbers) return;

    setState(() {
      showingNumbers = false;
      answerInput.clear();
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
                  ? const Color(0xFFFFD247)
                  : Colors.white.withValues(alpha: 0.18),
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
              elevation: used ? 0 : 7,
              backgroundColor: used
                  ? Colors.white.withValues(alpha: 0.35)
                  : const Color(0xFFFFD247),
              foregroundColor: const Color(0xFF35125A),
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.35),
              disabledForegroundColor:
                  const Color(0xFF35125A).withValues(alpha: 0.35),
              shadowColor: const Color(0xFFFFC93A).withValues(alpha: 0.45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: const BorderSide(
                  color: Color(0xFFFFF0A6),
                  width: 1.4,
                ),
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
              backgroundColor: Colors.white.withValues(alpha: 0.11),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.22),
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

  Widget _nextButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: _goToAnswerScreen,
        style: ElevatedButton.styleFrom(
          elevation: 7,
          shadowColor: const Color(0xFFFFC93A).withValues(alpha: 0.45),
          backgroundColor: const Color(0xFFFFD247),
          foregroundColor: const Color(0xFF35125A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: const BorderSide(
              color: Color(0xFFFFF0A6),
              width: 1.4,
            ),
          ),
        ),
        child: const Text(
          'NEXT',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _topHeader() {
    return Row(
      children: [
        Material(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.pop(context),
            child: const SizedBox(
              width: 46,
              height: 46,
              child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Order Recall',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _questionCard(String displayText) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 34),
          padding: const EdgeInsets.fromLTRB(24, 62, 24, 34),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 26,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Question $questionNumber of $maxQuestions',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF55178A),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                showingNumbers
                    ? 'Remember the numbers in order'
                    : 'Tap the numbers in the same order',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF55178A).withValues(alpha: 0.76),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 34),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFF7B22C9).withValues(alpha: 0.18),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    displayText,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Color(0xFF4C1179),
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF7B22C9),
            border: Border.all(
              color: Colors.white,
              width: 5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '⭐',
              style: TextStyle(fontSize: 34),
            ),
          ),
        ),
      ],
    );
  }

  Widget _scoreCard() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          const Text(
            '🏆',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Score',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            '$score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4B0B8F),
              Color(0xFF6413A8),
              Color(0xFF7C20C8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool compact = constraints.maxHeight < 760;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  18,
                  compact ? 10 : 16,
                  18,
                  20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        30,
                  ),
                  child: Column(
                    children: [
                      _topHeader(),
                      SizedBox(height: compact ? 18 : 24),
                      _progressBar(),
                      SizedBox(height: compact ? 28 : 38),
                      _questionCard(displayText),
                      SizedBox(height: compact ? 22 : 30),
                      if (showingNumbers)
                        _nextButton()
                      else ...[
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
                      SizedBox(height: compact ? 24 : 34),
                      _scoreCard(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}