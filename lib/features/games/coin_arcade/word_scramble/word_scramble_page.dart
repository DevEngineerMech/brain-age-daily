
import 'package:flutter/material.dart';

import '../../shared/arcade_quiz_page.dart';
import '../../shared/game_theme.dart';
import 'word_scramble_questions.dart';

class WordScramblePage extends StatelessWidget {
  const WordScramblePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ArcadeQuizPage(
      title: 'Word Scramble',
      instruction:
          'Rearrange the mixed-up letters '
          'to discover the hidden word.',
      icon: Icons.text_fields_rounded,
      accent: const Color(0xFFFF86C8),
      style: ArcadeQuizStyle.wordScramble,
      questions: WordScrambleQuestions.all
          .map(
            (q) => ArcadeQuizQuestion(
              prompt: q.scrambled,
              options: q.options,
              answer: q.answer,
            ),
          )
          .toList(),
    );
  }
}
