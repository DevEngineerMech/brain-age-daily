
import 'package:flutter/material.dart';

import '../../shared/arcade_quiz_page.dart';
import '../../shared/game_theme.dart';
import 'biology_quiz_questions.dart';

class BiologyQuizPage extends StatelessWidget {
  const BiologyQuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ArcadeQuizPage(
      title: 'Biology Quiz',
      instruction:
          'Explore the human body, animals, cells '
          'and living things.',
      icon: Icons.biotech_rounded,
      accent: GameTheme.green,
      style: ArcadeQuizStyle.biology,
      questions: BiologyQuizQuestions.all
          .map(
            (q) => ArcadeQuizQuestion(
              prompt: q.question,
              options: q.options,
              answer: q.answer,
            ),
          )
          .toList(),
    );
  }
}
