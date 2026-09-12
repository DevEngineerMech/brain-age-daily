class ReactionSwitchQuestion {
  final String prompt;
  final String display;
  final String answer;

  const ReactionSwitchQuestion({
    required this.prompt,
    required this.display,
    required this.answer,
  });
}

class ReactionSwitchQuestions {
  static final List<ReactionSwitchQuestion> all = _buildAll();

  static List<ReactionSwitchQuestion> _buildAll() {
    final List<ReactionSwitchQuestion> questions = <ReactionSwitchQuestion>[];

    for (int variant = 0; variant < 4; variant++) {
      for (int number = 1; number <= 30; number++) {
        questions.add(
          ReactionSwitchQuestion(
            prompt: 'Tap YES if even',
            display: '$number',
            answer: number.isEven ? 'YES' : 'NO',
          ),
        );

        questions.add(
          ReactionSwitchQuestion(
            prompt: 'Tap YES if above 10',
            display: '$number',
            answer: number > 10 ? 'YES' : 'NO',
          ),
        );

        questions.add(
          ReactionSwitchQuestion(
            prompt: 'Tap YES if divisible by 3',
            display: '$number',
            answer: number % 3 == 0 ? 'YES' : 'NO',
          ),
        );
      }
    }

    return questions;
  }
}