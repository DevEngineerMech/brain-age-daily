import 'dart:math';
import 'package:flutter/material.dart';

import 'order_recall_questions.dart';

class OrderRecallPage extends StatefulWidget {
  const OrderRecallPage({super.key});

  @override
  State<OrderRecallPage> createState() =>
      _OrderRecallPageState();
}

class _OrderRecallPageState
    extends State<OrderRecallPage> {
  final Random _random = Random();

  late OrderRecallQuestion _question;

  int score = 0;
  int questionNumber = 1;

  static const int maxQuestions = 10;

  bool showingNumbers = true;

  List<int> answerInput = <int>[];
  List<int> selectableNumbers = <int>[];

  @override
  void initState() {
    super.initState();
    _loadQuestion(
      resetGame: true,
    );
  }

  void _loadQuestion({
    bool resetGame = false,
  }) {
    if (resetGame) {
      score = 0;
      questionNumber = 1;
    }

    _question =
        OrderRecallQuestions.all[
          _random.nextInt(
            OrderRecallQuestions.all.length,
          )
        ];

    showingNumbers = true;
    answerInput = <int>[];

    selectableNumbers =
        List<int>.from(
      _question.shown,
    )..shuffle(_random);

    if (mounted) {
      setState(() {});
    }
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

    if (answerInput.length >=
        _question.answer.length) {
      return;
    }

    setState(() {
      answerInput.add(number);
    });

    if (answerInput.length ==
        _question.answer.length) {
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

    for (
      int i = 0;
      i < _question.answer.length;
      i++
    ) {
      if (answerInput[i] !=
          _question.answer[i]) {
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
          content: Text(
            correct
                ? '✅ Correct'
                : '❌ Wrong',
          ),
          duration: const Duration(
            milliseconds: 450,
          ),
          behavior:
              SnackBarBehavior.floating,
          backgroundColor: correct
              ? const Color(0xFF26B957)
              : const Color(0xFFE94D5F),
        ),
      );

    Future.delayed(
      const Duration(
        milliseconds: 600,
      ),
      () {
        if (!mounted) return;

        if (questionNumber >=
            maxQuestions) {
          _showFinishedDialog();
        } else {
          setState(() {
            questionNumber++;
          });

          _loadQuestion();
        }
      },
    );
  }

  void _restart() {
    Navigator.pop(context);

    _loadQuestion(
      resetGame: true,
    );
  }

  void _showFinishedDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(24),
          ),
          title: const Text(
            'Round Complete',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'You scored $score out of $maxQuestions.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
            ElevatedButton(
              onPressed: _restart,
              child:
                  const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  Widget _header() {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          Material(
            color:
                Colors.white.withOpacity(0.10),
            borderRadius:
                BorderRadius.circular(13),
            child: InkWell(
              borderRadius:
                  BorderRadius.circular(13),
              onTap: () =>
                  Navigator.pop(context),
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Order Recall',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progress() {
    return Row(
      children: List.generate(
        maxQuestions,
        (index) {
          final bool active =
              index + 1 == questionNumber;

          final bool done =
              index + 1 < questionNumber;

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 180,
              ),
              height: 7,
              margin:
                  const EdgeInsets.symmetric(
                horizontal: 2,
              ),
              decoration: BoxDecoration(
                color: active || done
                    ? const Color(0xFFFFD247)
                    : Colors.white
                        .withOpacity(0.18),
                borderRadius:
                    BorderRadius.circular(999),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _questionCard(
    bool compact,
  ) {
    final String displayText =
        showingNumbers
            ? _question.shown
                .join('   ')
            : answerInput.isEmpty
                ? '_   _   _   _   _'
                : answerInput
                    .map(
                      (number) =>
                          '$number',
                    )
                    .join('   ');

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          margin:
              const EdgeInsets.only(top: 25),
          padding: EdgeInsets.fromLTRB(
            18,
            compact ? 38 : 42,
            18,
            14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Text(
                'Order Recall',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF55178A),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),

              Text(
                showingNumbers
                    ? 'Remember the numbers in order'
                    : 'Tap them in the same order',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF55178A)
                      .withOpacity(0.72),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    displayText,
                    maxLines: 1,
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color:
                          const Color(0xFF4C1179),
                      fontSize:
                          compact ? 30 : 36,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),

        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF7B22C9),
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
          ),
          alignment: Alignment.center,
          child: const Text(
            '⭐',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ],
    );
  }

  Widget _numberButton(
    int number,
  ) {
    final bool used =
        answerInput.contains(number);

    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: used
            ? null
            : () =>
                _selectNumber(number),
        style: ElevatedButton.styleFrom(
          elevation: used ? 0 : 4,
          backgroundColor: used
              ? Colors.white
                  .withOpacity(0.30)
              : const Color(0xFFFFD247),
          disabledBackgroundColor:
              Colors.white.withOpacity(0.30),
          foregroundColor:
              const Color(0xFF35125A),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
        child: Text(
          '$number',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _numberGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount:
          selectableNumbers.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: 48,
      ),
      itemBuilder: (
        _,
        index,
      ) {
        return _numberButton(
          selectableNumbers[index],
        );
      },
    );
  }

  Widget _nextButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed:
            _goToAnswerScreen,
        style: ElevatedButton.styleFrom(
          elevation: 4,
          backgroundColor:
              const Color(0xFFFFD247),
          foregroundColor:
              const Color(0xFF35125A),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'NEXT',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 42,
            child: OutlinedButton(
              onPressed: _undo,
              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    Colors.white,
                side: BorderSide(
                  color:
                      Colors.white.withOpacity(
                    0.30,
                  ),
                ),
              ),
              child: const Text(
                'UNDO',
                style: TextStyle(
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 42,
            child: OutlinedButton(
              onPressed: _clear,
              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    Colors.white,
                side: BorderSide(
                  color:
                      Colors.white.withOpacity(
                    0.30,
                  ),
                ),
              ),
              child: const Text(
                'CLEAR',
                style: TextStyle(
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _scoreCard() {
    return Container(
      height: 44,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(0.11),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color:
              Colors.white.withOpacity(0.20),
        ),
      ),
      child: Row(
        children: [
          const Text(
            '🏆',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Score',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            '$score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final bool compact =
              constraints.maxHeight < 760;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration:
                const BoxDecoration(
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
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  12,
                  8,
                  12,
                  8,
                ),
                child: Column(
                  children: [
                    _header(),
                    const SizedBox(height: 8),
                    _progress(),
                    const SizedBox(height: 8),

                    Expanded(
                      child: _questionCard(
                        compact,
                      ),
                    ),

                    const SizedBox(height: 8),

                    if (showingNumbers)
                      _nextButton()
                    else ...[
                      _numberGrid(),
                      const SizedBox(height: 8),
                      _actionButtons(),
                    ],

                    const SizedBox(height: 8),
                    _scoreCard(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}