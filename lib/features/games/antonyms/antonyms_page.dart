import 'dart:math';
import 'package:flutter/material.dart';

import 'antonyms_questions.dart';

class AntonymsPage extends StatefulWidget {
  const AntonymsPage({super.key});

  @override
  State<AntonymsPage> createState() => _AntonymsPageState();
}

class _AntonymsPageState extends State<AntonymsPage> {
  final Random _random = Random();

  late AntonymQuestion _question;
  int score = 0;
  int questionNumber = 1;

  static const int maxQuestions = 10;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    _question = AntonymQuestions.all[_random.nextInt(AntonymQuestions.all.length)];
    setState(() {});
  }

  void _tap(String value) {
    if (value == _question.answer) score++;

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
      builder: (context) {
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

  @override
  Widget build(BuildContext context) {
    final List<String> options = List<String>.from(_question.options);

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
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              _Header(
                title: 'Antonyms',
                onBack: () => Navigator.pop(context),
              ),
              const SizedBox(height: 22),
              _Progress(
                current: questionNumber,
                total: maxQuestions,
              ),
              const SizedBox(height: 34),
              _QuestionCard(
                word: _question.word,
              ),
              const SizedBox(height: 28),
              ...options.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AnswerButton(
                    text: option,
                    onPressed: () => _tap(option),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _StatCard(
                icon: '🏆',
                label: 'Score',
                value: '$score',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _Header({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onBack,
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
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  final int current;
  final int total;

  const _Progress({
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        final bool active = index + 1 == current;
        final bool done = index + 1 < current;

        return Expanded(
          child: Container(
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
}

class _QuestionCard extends StatelessWidget {
  final String word;

  const _QuestionCard({
    required this.word,
  });

  @override
  Widget build(BuildContext context) {
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
                color: Colors.black.withOpacity(0.22),
                blurRadius: 26,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Choose the opposite word',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF55178A),
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 36),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  word,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF4C1179),
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
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
}

class _AnswerButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _AnswerButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 7,
          backgroundColor: const Color(0xFFFFD247),
          foregroundColor: const Color(0xFF35125A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.11),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            value,
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
}