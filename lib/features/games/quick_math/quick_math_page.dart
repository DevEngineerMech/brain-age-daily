// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';

import 'quick_math_questions.dart';

class QuickMathPage extends StatefulWidget {
  const QuickMathPage({super.key});

  @override
  State<QuickMathPage> createState() => _QuickMathPageState();
}

class _QuickMathPageState extends State<QuickMathPage> {
  final Random _random = Random();
  final TextEditingController _controller = TextEditingController();

  late QuickMathQuestion _question;

  int score = 0;
  int questionNumber = 1;

  static const int maxQuestions = 10;

  @override
  void initState() {
    super.initState();
    _next();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    _question =
        QuickMathQuestions.all[_random.nextInt(QuickMathQuestions.all.length)];

    _controller.clear();

    if (mounted) {
      setState(() {});
    }
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();

    final int? value = int.tryParse(
      _controller.text.trim(),
    );

    if (value == _question.answer) {
      score++;
    }

    if (questionNumber >= maxQuestions) {
      _showFinishedDialog();
      return;
    }

    setState(() {
      questionNumber++;
    });

    _next();
  }

  void _restart() {
    Navigator.pop(context);

    setState(() {
      score = 0;
      questionNumber = 1;
    });

    _next();
  }

  void _showFinishedDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
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
              child: const Text('Play Again'),
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
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              borderRadius: BorderRadius.circular(13),
              onTap: () => Navigator.pop(context),
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
              'Quick Math',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
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
              margin: const EdgeInsets.symmetric(
                horizontal: 2,
              ),
              decoration: BoxDecoration(
                color: active || done
                    ? const Color(0xFFFFD247)
                    : Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _questionCard(bool compact) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          margin: const EdgeInsets.only(
            top: 25,
          ),
          padding: EdgeInsets.fromLTRB(
            18,
            compact ? 38 : 42,
            18,
            16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
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
                'Quick Math',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF55178A),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Solve as fast as you can',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF55178A)
                      .withOpacity(0.72),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _question.text,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    color: const Color(0xFF4C1179),
                    fontSize: compact ? 44 : 52,
                    fontWeight: FontWeight.w900,
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
            style: TextStyle(
              fontSize: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _answerArea() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              style: const TextStyle(
                color: Color(0xFF35125A),
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Answer',
                hintStyle: TextStyle(
                  color: const Color(0xFF35125A)
                      .withOpacity(0.40),
                  fontWeight: FontWeight.w700,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          height: 50,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              elevation: 4,
              backgroundColor:
                  const Color(0xFFFFD247),
              foregroundColor:
                  const Color(0xFF35125A),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'Submit',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.11),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.20),
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
    return GestureDetector(
      onTap: () =>
          FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final bool compact =
                constraints.maxHeight < 760;

            return Container(
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
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

                      _answerArea(),

                      const SizedBox(height: 8),

                      _scoreCard(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}