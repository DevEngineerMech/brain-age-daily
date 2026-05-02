import 'dart:math';
import 'package:flutter/material.dart';

import 'quick_math_questions.dart';

class QuickMathPage extends StatefulWidget {
  const QuickMathPage({super.key});

  @override
  State<QuickMathPage> createState() => _QuickMathPageState();
}

class _QuickMathPageState extends State<QuickMathPage> {
  final Random _random = Random();
  final TextEditingController _controller = TextEditingController();

  late QuickMathQuestion _question;

  int score = 0;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    _question = QuickMathQuestions
        .all[_random.nextInt(QuickMathQuestions.all.length)];

    _controller.clear();

    setState(() {});
  }

  void _submit() {
    final int? value = int.tryParse(_controller.text.trim());

    if (value == _question.answer) {
      score++;
    }

    _next();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Math'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Spacer(),

            Text(
              _question.text,
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                hintText: 'Answer',
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit'),
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