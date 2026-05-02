import 'dart:math';
import 'package:flutter/material.dart';

import 'time_difference_questions.dart';

class TimeDifferencePage extends StatefulWidget {
  const TimeDifferencePage({super.key});

  @override
  State<TimeDifferencePage> createState() => _TimeDifferencePageState();
}

class _TimeDifferencePageState extends State<TimeDifferencePage> {
  final Random _random = Random();

  late TimeDifferenceQuestion _question;

  int score = 0;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    _question = TimeDifferenceQuestions
        .all[_random.nextInt(TimeDifferenceQuestions.all.length)];

    setState(() {});
  }

  void _tap(int minutes) {
    if (minutes == _question.minutes) {
      score++;
    }

    _next();
  }

  @override
  Widget build(BuildContext context) {
    final List<int> options = [
      _question.minutes,
      _question.minutes + 5,
      _question.minutes - 5,
      _question.minutes + 10,
    ]..shuffle();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Difference'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Spacer(),

            Text(
              '${_question.from} → ${_question.to}',
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            ...options.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _tap(e),
                    child: Text('$e mins'),
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