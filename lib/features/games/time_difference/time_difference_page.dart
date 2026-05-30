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
  late List<int> _options;

  int score = 0;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    _question = TimeDifferenceQuestions.all[_random.nextInt(TimeDifferenceQuestions.all.length)];

    _options = <int>[
      _question.minutes,
      _question.minutes + 5,
      _question.minutes - 5,
      _question.minutes + 10,
    ]..shuffle(_random);

    setState(() {});
  }

  void _tap(int minutes) {
    if (minutes == _question.minutes) score++;
    _next();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time Difference')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Text('Score: $score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Work out the time gap', style: TextStyle(fontSize: 17)),
              const SizedBox(height: 10),
              Expanded(
                flex: 3,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${_question.from} → ${_question.to}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _options.map((option) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _tap(option),
                          child: Text('$option mins'),
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