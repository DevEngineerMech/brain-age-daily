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
    _question = BiologyQuizQuestions.all[_random.nextInt(BiologyQuizQuestions.all.length)];
    setState(() {});
  }

  void _tap(String value) {
    if (value == _question.answer) score++;
    _next();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biology Quiz')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Text('Score: $score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                flex: 3,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 36,
                      child: Text(
                        _question.question,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
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