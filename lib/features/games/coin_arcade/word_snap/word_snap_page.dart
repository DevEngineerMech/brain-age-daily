
import 'package:flutter/material.dart';

import '../../shared/arcade_quiz_page.dart';
import '../../shared/game_theme.dart';
import 'word_snap_questions.dart';

class WordSnapPage extends StatelessWidget {
  const WordSnapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ArcadeQuizPage(
      title: 'Word Snap',
      instruction:
          'Recognise words and match them '
          'to the correct category.',
      icon: Icons.category_rounded,
      accent: GameTheme.purple,
      style: ArcadeQuizStyle.wordSnap,
      questions: WordSnapQuestions.all
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
