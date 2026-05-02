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

    _next();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Scramble'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Spacer(),

            const Text(
              'Unscramble the word',
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            Text(
              _question.scrambled,
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