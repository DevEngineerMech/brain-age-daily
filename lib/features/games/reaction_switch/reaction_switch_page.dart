import 'dart:math';
import 'package:flutter/material.dart';

import 'reaction_switch_questions.dart';

class ReactionSwitchPage extends StatefulWidget {
  const ReactionSwitchPage({super.key});

  @override
  State<ReactionSwitchPage> createState() => _ReactionSwitchPageState();
}

class _ReactionSwitchPageState extends State<ReactionSwitchPage> {
  final Random _random = Random();

  late ReactionSwitchQuestion _question;

  int score = 0;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    _question = ReactionSwitchQuestions
        .all[_random.nextInt(ReactionSwitchQuestions.all.length)];

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
        title: const Text('Reaction Switch'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Spacer(),

            Text(
              _question.prompt,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              _question.display,
              style: const TextStyle(
                fontSize: 54,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _tap('YES'),
                    child: const Text('YES'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _tap('NO'),
                    child: const Text('NO'),
                  ),
                ),
              ],
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