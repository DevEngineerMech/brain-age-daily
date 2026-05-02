class SymbolMatchQuestion {
  final String target;
  final List<String> options;
  final String answer;

  const SymbolMatchQuestion({
    required this.target,
    required this.options,
    required this.answer,
  });
}

class SymbolMatchQuestions {
  static final List<SymbolMatchQuestion> all = _buildAll();

  static List<SymbolMatchQuestion> _buildAll() {
    const List<String> symbols = <String>[
      '▲',
      '■',
      '●',
      '◆',
      '★',
      '♥',
      '⬟',
      '⬢',
    ];

    final List<SymbolMatchQuestion> questions = <SymbolMatchQuestion>[];

    for (int variant = 0; variant < 16; variant++) {
      for (int i = 0; i < symbols.length; i++) {
        final String target = symbols[i];

        final List<String> options = <String>[
          target,
          symbols[(i + 1 + variant) % symbols.length],
          symbols[(i + 2 + variant) % symbols.length],
          symbols[(i + 3 + variant) % symbols.length],
        ];

        questions.add(
          SymbolMatchQuestion(
            target: target,
            options: options,
            answer: target,
          ),
        );
      }
    }

    return questions;
  }
}