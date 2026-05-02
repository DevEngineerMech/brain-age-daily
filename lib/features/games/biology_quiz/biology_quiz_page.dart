import 'dart:math';
import 'package:flutter/material.dart';

import 'biology_quiz_questions.dart';

class BiologyQuizPage extends StatefulWidget {
  const BiologyQuizPage({super.key});

  @override
  State<BiologyQuizPage> createState() => _BiologyQuizPageState();
}

class _BiologyQuizPageState extends State<BiologyQuizPage> {
  final Random _random = Random();

  late BiologyQuizQuestion _question;

  int score = 0;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    _question = BiologyQuizQuestions
        .all[_random.nextInt(BiologyQuizQuestions.all.length)];

    setState(() {});
  }

  void _tap(String value) {
    if (value == _question.answer) {
      score++;
    }

    _next();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biology Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Spacer(),

            Text(
              _question.question,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            ..._question.options.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _tap(e),
                    child: Text(e),
                  ),
                ),
              ),
            ),

            const Spacer(),

            Text(
              'Score: $score',
              style: const TextStyle(fontSize: 22),
            ),
          ],
        ),
      ),
    );
  }
}