class StroopShiftQuestion {
  final String word;
  final String inkColour;
  final List<String> options;
  final String answer;

  const StroopShiftQuestion({
    required this.word,
    required this.inkColour,
    required this.options,
    required this.answer,
  });
}

class StroopShiftQuestions {
  static final List<StroopShiftQuestion> all = _buildAll();

  static List<StroopShiftQuestion> _buildAll() {
    const List<String> colours = <String>[
      'Red',
      'Blue',
      'Green',
      'Yellow',
      'Purple',
      'Orange',
    ];

    final List<StroopShiftQuestion> questions = <StroopShiftQuestion>[];

    for (int shift = 1; shift < colours.length; shift++) {
      for (int i = 0; i < colours.length; i++) {
        final String word = colours[i];
        final String inkColour = colours[(i + shift) % colours.length];

        questions.add(
          StroopShiftQuestion(
            word: word,
            inkColour: inkColour,
            options: List<String>.from(colours)..shuffle(),
            answer: inkColour,
          ),
        );
      }
    }

    final List<StroopShiftQuestion> expanded = <StroopShiftQuestion>[];
    for (int i = 0; i < 4; i++) {
      expanded.addAll(
        questions.map(
          (q) => StroopShiftQuestion(
            word: q.word,
            inkColour: q.inkColour,
            options: List<String>.from(q.options)
              ..sort((a, b) => (a.length + i).compareTo(b.length + i)),
            answer: q.answer,
          ),
        ),
      );
    }

    return expanded;
  }
}