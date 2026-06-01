import 'dart:math';
import 'package:flutter/material.dart';

import 'word_scramble_questions.dart';

class WordScramblePage extends StatefulWidget {
  const WordScramblePage({super.key});

  @override
  State<WordScramblePage> createState() => _WordScramblePageState();
}

class _WordScramblePageState extends State<WordScramblePage> {
  final Random _random = Random();

  late WordScrambleQuestion _question;

  int score = 0;
  int questionNumber = 1;
  static const int maxQuestions = 10;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    _question = WordScrambleQuestions
        .all[_random.nextInt(WordScrambleQuestions.all.length)];

    setState(() {});
  }

  void _tap(String word) {
    if (word == _question.answer) {
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
          title: const Text('Round Complete'),
          content: Text('You scored $score out of $maxQuestions.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
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
    return Row(
      children: [
        Material(
          color: Colors.white.withOpacity(0.10),
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
            'Word Scramble',
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

  Widget _progress() {
    return Row(
      children: List.generate(maxQuestions, (index) {
        final bool active = index + 1 == questionNumber;
        final bool done = index + 1 < questionNumber;

        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            decoration: BoxDecoration(
              color: active || done
                  ? const Color(0xFFFFD247)
                  : Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }

  Widget _questionCard(bool compact) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: compact ? 300 : 370,
          ),
          margin: const EdgeInsets.only(top: 34),
          padding: EdgeInsets.fromLTRB(
            24,
            compact ? 52 : 62,
            24,
            compact ? 28 : 34,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 26,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Word Scramble',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF55178A),
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Unscramble the word',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF55178A).withOpacity(0.76),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
              SizedBox(height: compact ? 38 : 64),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _question.scrambled,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    color: const Color(0xFF4C1179),
                    fontSize: compact ? 46 : 58,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
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
                color: Colors.black.withOpacity(0.22),
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

  Widget _answerButton(String word) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: () => _tap(word),
        style: ElevatedButton.styleFrom(
          elevation: 7,
          shadowColor: const Color(0xFFFFC93A).withOpacity(0.45),
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
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            word,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _scoreCard() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.11),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.22),
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
    final List<String> options = List<String>.from(_question.options)
      ..shuffle(_random);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxHeight < 760;

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
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  18,
                  compact ? 10 : 16,
                  18,
                  20,
                ),
                child: Column(
                  children: [
                    _header(),
                    SizedBox(height: compact ? 18 : 24),
                    _progress(),
                    SizedBox(height: compact ? 28 : 38),
                    _questionCard(compact),
                    SizedBox(height: compact ? 22 : 30),
                    ...options.map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _answerButton(option),
                      ),
                    ),
                    SizedBox(height: compact ? 10 : 18),
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