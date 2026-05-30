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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    _question = QuickMathQuestions.all[_random.nextInt(QuickMathQuestions.all.length)];
    _controller.clear();
    setState(() {});
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();

    final int? value = int.tryParse(_controller.text.trim());
    if (value == _question.answer) score++;

    _next();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text('Quick Math')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Text('Score: $score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _question.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: 'Answer',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check_circle),
                      onPressed: _submit,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}