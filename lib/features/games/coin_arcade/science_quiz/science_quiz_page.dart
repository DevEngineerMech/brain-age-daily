
import 'package:flutter/material.dart';

import '../../shared/arcade_quiz_page.dart';
import '../../shared/game_theme.dart';
import 'science_quiz_questions.dart';

class ScienceQuizPage extends StatelessWidget {
  const ScienceQuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ArcadeQuizPage(
      title: 'Science Quiz',
      instruction:
          'Test your knowledge of space, physics, '
          'chemistry and the world.',
      icon: Icons.science_rounded,
      accent: GameTheme.cyan,
      style: ArcadeQuizStyle.science,
      questions: ScienceQuizQuestions.all
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
