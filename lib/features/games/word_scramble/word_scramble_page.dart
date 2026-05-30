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
    _question = WordScrambleQuestions.all[_random.nextInt(WordScrambleQuestions.all.length)];
    setState(() {});
  }

  void _tap(String word) {
    if (word == _question.answer) score++;
    _next();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Word Scramble')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Text('Score: $score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Unscramble the word', style: TextStyle(fontSize: 17)),
              const SizedBox(height: 10),
              Expanded(
                flex: 3,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _question.scrambled,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _question.options.map((option) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _tap(option),
                          child: FittedBox(child: Text(option)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}