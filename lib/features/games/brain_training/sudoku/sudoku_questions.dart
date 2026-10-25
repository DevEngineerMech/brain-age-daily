class SudokuQuestion {
  final String row;
  final List<String> options;
  final String answer;

  const SudokuQuestion({
    required this.row,
    required this.options,
    required this.answer,
  });
}

class SudokuQuestions {
  static final List<SudokuQuestion> all = _buildAll();

  static List<SudokuQuestion> _buildAll() {
    final List<SudokuQuestion> questions = <SudokuQuestion>[];

    for (int start = 1; start <= 20; start++) {
      for (int hidden = 0; hidden < 4; hidden++) {
        final List<int> row = <int>[
          start,
          start + 1,
          start + 2,
          start + 3,
        ];

        final int answer = row[hidden];

        final List<String> display = row
            .asMap()
            .entries
            .map((entry) => entry.key == hidden ? '?' : '${entry.value}')
            .toList();

        final Set<String> options = <String>{
          '$answer',
          '${answer + 1}',
          '${answer + 2}',
          '${answer - 1}',
        };

        questions.add(
          SudokuQuestion(
            row: display.join('   '),
            options: options.take(4).toList(),
            answer: '$answer',
          ),
        );
      }
    }

    return questions;
  }
}