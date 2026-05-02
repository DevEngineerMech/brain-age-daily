import 'package:flutter/material.dart';
import 'pattern_logic_questions.dart';

class PatternLogicPage extends StatefulWidget {
  const PatternLogicPage({super.key});

  @override
  State<PatternLogicPage> createState() => _PatternLogicPageState();
}

class _PatternLogicPageState extends State<PatternLogicPage> {
  late PatternLogicQuestion _question;

  @override
  void initState() {
    super.initState();
    _question = PatternLogicQuestion.generate();
  }

  void _next() {
    setState(() {
      _question = PatternLogicQuestion.generate();
    });
  }

  void _select(String value) {
    _next();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _question.sequence,
          style: const TextStyle(fontSize: 40),
        ),
        const SizedBox(height: 20),
        ..._question.options.map(
          (e) => Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () => _select(e),
              child: Text(e),
            ),
          ),
        )
      ],
    );
  }
}