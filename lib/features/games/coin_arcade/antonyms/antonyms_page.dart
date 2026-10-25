
import 'package:flutter/material.dart';

import '../../shared/arcade_quiz_page.dart';
import '../../shared/game_theme.dart';
import 'antonyms_questions.dart';

class AntonymsPage extends StatelessWidget {
  const AntonymsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ArcadeQuizPage(
      title: 'Antonyms',
      instruction:
          'Find the opposite meaning of each word.',
      icon: Icons.compare_arrows_rounded,
      accent: GameTheme.gold,
      style: ArcadeQuizStyle.antonyms,
      questions: AntonymQuestions.all
          .map(
            (q) => ArcadeQuizQuestion(
              prompt: q.word,
              options: q.options,
              answer: q.answer,
            ),
          )
          .toList(),
    );
  }
}
