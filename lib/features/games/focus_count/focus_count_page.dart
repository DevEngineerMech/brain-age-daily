// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';

import 'focus_count_questions.dart';

class FocusCountPage extends StatefulWidget {
  final String? gameId;
  final String title;

  const FocusCountPage({
    super.key,
    this.gameId,
    this.title = 'Focus Count',
  });

  @override
  State<FocusCountPage> createState() => _FocusCountPageState();
}

class _FocusCountPageState extends State<FocusCountPage> {
  final Random _random = Random();

  late FocusCountQuestion _question;
  List<int> _options = <int>[];

  int score = 0;
  int questionNumber = 1;
  static const int maxQuestions = 10;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    _question = FocusCountQuestions.random(_random);
    _options = FocusCountQuestions.optionsFor(_question, _random);

    if (mounted) {
      setState(() {});
    }
  }

  void _tap(int value) {
    if (value == _question.answer) {
      score++;
    }

    if (questionNumber >= maxQuestions) {
      _showFinishedDialog();
      return;
    }

    setState(() {
      questionNumber++;
    });

    _next();
  }

  void _restart() {
    Navigator.pop(context);

    setState(() {
      score = 0;
      questionNumber = 1;
    });

    _next();
  }

  void _showFinishedDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Round Complete'),
          content: Text(
            'You scored $score out of $maxQuestions.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: _restart,
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF625BEA),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: List.generate(maxQuestions, (index) {
                final bool active = index + 1 == questionNumber;
                final bool completed = index + 1 < questionNumber;

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 10,
                    decoration: BoxDecoration(
                      color: completed
                          ? Colors.green
                          : active
                              ? const Color(0xFF11B5E5)
                              : Colors.white.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 26),
            Text(
              'Question $questionNumber of $maxQuestions',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _question.instruction,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.35),
                ),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: _question.grid.map(
                  (symbol) {
                    final bool isTarget = symbol == _question.target;

                    return Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isTarget
                            ? Colors.white
                            : Colors.white.withOpacity(0.72),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isTarget
                              ? Colors.black.withOpacity(0.18)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        symbol,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            const SizedBox(height: 24),
            ..._options.map(
              (value) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: () => _tap(value),
                    child: Text(
                      '$value',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Score: $score',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}