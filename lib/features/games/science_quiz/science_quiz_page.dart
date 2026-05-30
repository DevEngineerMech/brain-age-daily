import 'dart:math';
import 'package:flutter/material.dart';

import 'science_quiz_questions.dart';

class ScienceQuizPage extends StatefulWidget {
  const ScienceQuizPage({super.key});

  @override
  State<ScienceQuizPage> createState() => _ScienceQuizPageState();
}

class _ScienceQuizPageState extends State<ScienceQuizPage> {
  final Random _random = Random();

  late ScienceQuizQuestion _question;
  int score = 0;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    _question = ScienceQuizQuestions.all[_random.nextInt(ScienceQuizQuestions.all.length)];
    setState(() {});
  }

  void _tap(String value) {
    if (value == _question.answer) score++;
    _next();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Science Quiz')),
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