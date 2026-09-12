class MemoryGridQuestion {
  final List<int> pattern;

  const MemoryGridQuestion({
    required this.pattern,
  });
}

class MemoryGridQuestions {
  static final List<MemoryGridQuestion> all = _buildAll();

  static List<MemoryGridQuestion> _buildAll() {
    final List<MemoryGridQuestion> questions = <MemoryGridQuestion>[];

    for (int a = 0; a < 16; a++) {
      for (int b = a + 1; b < 16; b++) {
        for (int c = b + 1; c < 16; c++) {
          questions.add(
            MemoryGridQuestion(
              pattern: <int>[a, b, c],
            ),
          );

          if (questions.length >= 140) {
            return questions;
          }
        }
      }
    }

    return questions;
  }
}