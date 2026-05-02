import 'dart:math';
import 'package:flutter/material.dart';

import 'stroop_shift_questions.dart';

class StroopShiftPage extends StatefulWidget {
  const StroopShiftPage({super.key});

  @override
  State<StroopShiftPage> createState() => _StroopShiftPageState();
}

class _StroopShiftPageState extends State<StroopShiftPage> {
  final Random _random = Random();

  late StroopShiftQuestion _question;

  int score = 0;

  final Map<String, Color> _colourMap = const {
    'Red': Colors.red,
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Yellow': Colors.orange,
    'Purple': Colors.purple,
    'Orange': Colors.deepOrange,
  };

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    _question = StroopShiftQuestions
        .all[_random.nextInt(StroopShiftQuestions.all.length)];

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
    final Color ink = _colourMap[_question.inkColour] ?? Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stroop Shift'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Spacer(),

            const Text(
              'Tap the INK colour, not the word',
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 24),

            Text(
              _question.word,
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: ink,
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