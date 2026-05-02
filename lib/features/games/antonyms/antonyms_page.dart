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

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    _question = AntonymQuestions
        .all[_random.nextInt(AntonymQuestions.all.length)];

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
        title: const Text('Antonyms'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Spacer(),

            const Text(
              'Choose the opposite word',
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            Text(
              _question.word,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            ..._question.options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _tap(option),
                    child: Text(option),
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