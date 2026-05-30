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
    _question = AntonymQuestions.all[_random.nextInt(AntonymQuestions.all.length)];
    setState(() {});
  }

  void _tap(String value) {
    if (value == _question.answer) score++;
    _next();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Antonyms')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Text('Score: $score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Choose the opposite word', style: TextStyle(fontSize: 17)),
              const SizedBox(height: 10),
              Expanded(
                flex: 3,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _question.word,
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