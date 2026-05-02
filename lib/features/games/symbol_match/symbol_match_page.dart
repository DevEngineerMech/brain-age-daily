import 'dart:math';
import 'package:flutter/material.dart';

import 'symbol_match_questions.dart';

class SymbolMatchPage extends StatefulWidget {
  const SymbolMatchPage({super.key});

  @override
  State<SymbolMatchPage> createState() => _SymbolMatchPageState();
}

class _SymbolMatchPageState extends State<SymbolMatchPage> {
  final Random _random = Random();

  late SymbolMatchQuestion _question;

  int score = 0;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    _question = SymbolMatchQuestions
        .all[_random.nextInt(SymbolMatchQuestions.all.length)];

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
        title: const Text('Symbol Match'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Spacer(),

            const Text(
              'Tap the matching symbol',
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            Text(
              _question.target,
              style: const TextStyle(
                fontSize: 54,
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
                    child: Text(
                      option,
                      style: const TextStyle(fontSize: 24),
                    ),
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