import 'dart:math';

class FocusCountQuestion {
  final String target;
  final String instruction;
  final List<String> grid;
  final int answer;

  const FocusCountQuestion({
    required this.target,
    required this.instruction,
    required this.grid,
    required this.answer,
  });
}

class FocusCountQuestions {
  static final List<FocusCountQuestion> all = _buildAll();

  static FocusCountQuestion random(Random random) {
    return all[random.nextInt(all.length)];
  }

  static List<int> optionsFor(FocusCountQuestion question, Random random) {
    final Set<int> options = <int>{question.answer};

    while (options.length < 4) {
      final int offset = random.nextInt(7) - 3;
      final int value = question.answer + offset;

      if (value >= 1 && value <= 24) {
        options.add(value);
      }
    }

    final List<int> shuffled = options.toList();
    shuffled.shuffle(random);
    return shuffled;
  }

  static List<FocusCountQuestion> _buildAll() {
    const List<String> symbols = <String>[
      '▲',
      '■',
      '●',
      '★',
      '◆',
      '⬟',
    ];

    final List<FocusCountQuestion> questions = <FocusCountQuestion>[];

    for (int variant = 0; variant < 12; variant++) {
      for (int targetIndex = 0; targetIndex < symbols.length; targetIndex++) {
        for (int answer = 3; answer <= 12; answer++) {
          final String target = symbols[targetIndex];
          final List<String> grid = <String>[];

          for (int i = 0; i < answer; i++) {
            grid.add(target);
          }

          int filler = 24 - answer;
          int fillerIndex = 1;

          while (filler > 0) {
            final String symbol =
                symbols[(targetIndex + fillerIndex + variant) % symbols.length];

            if (symbol != target) {
              grid.add(symbol);
              filler--;
            }

            fillerIndex++;
          }

          grid.shuffle(Random(variant + answer + targetIndex));

          questions.add(
            FocusCountQuestion(
              target: target,
              instruction: 'How many $target symbols are there?',
              grid: grid,
              answer: answer,
            ),
          );
        }
      }
    }

    return questions;
  }
}