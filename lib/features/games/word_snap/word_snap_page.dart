import 'dart:math';
import 'package:flutter/material.dart';

import 'word_snap_questions.dart';

class WordSnapPage extends StatefulWidget {
  const WordSnapPage({super.key});

  @override
  State<WordSnapPage> createState() => _WordSnapPageState();
}

class _WordSnapPageState extends State<WordSnapPage> {
  final Random _random = Random();

  late WordSnapQuestion _question;

  int score = 0;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    _question = WordSnapQuestions
        .all[_random.nextInt(WordSnapQuestions.all.length)];

    setState(() {});
  }

  void _tap(String category) {
    if (category == _question.answer) {
      score++;
    }

    _next();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Snap'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Spacer(),

            const Text(
              'Choose the correct category',
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            Text(
              _question.word,
              style: const TextStyle(
                fontSize: 38,
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