class WordScrambleQuestion {
  final String scrambled;
  final List<String> options;
  final String answer;

  const WordScrambleQuestion({
    required this.scrambled,
    required this.options,
    required this.answer,
  });
}

class WordScrambleQuestions {
  static final List<WordScrambleQuestion> all = _buildAll();

  static List<WordScrambleQuestion> _buildAll() {
    const List<String> words = <String>[
      'BRAIN',
      'FOCUS',
      'MEMORY',
      'PUZZLE',
      'THINK',
      'SPEED',
      'SMART',
      'ENERGY',
      'VISION',
      'POWER',
      'SKILL',
      'MIND',
      'LOGIC',
      'RECALL',
      'SHARP',
      'LEARN',
      'BOOST',
      'ALERT',
      'SOLVE',
      'TRAIN',
      'QUICK',
      'CALM',
      'STREAK',
      'TARGET',
      'WINNER',
      'MASTER',
      'LEVEL',
      'GAMER',
      'HUMAN',
      'PLAYER',
    ];

    final List<WordScrambleQuestion> questions = <WordScrambleQuestion>[];

    for (int variant = 0; variant < 4; variant++) {
      for (int i = 0; i < words.length; i++) {
        final String word = words[i];
        final String scrambled = _scramble(word, variant);

        final List<String> options = <String>[word];

        for (int j = 1; j < words.length && options.length < 4; j++) {
          final String candidate = words[(i + j + variant) % words.length];
          if (!options.contains(candidate) && candidate.length == word.length) {
            options.add(candidate);
          }
        }

        questions.add(
          WordScrambleQuestion(
            scrambled: scrambled,
            options: _rotate(options, variant),
            answer: word,
          ),
        );
      }
    }

    return questions;
  }

  static String _scramble(String word, int variant) {
    final List<String> letters = word.split('');

    if (letters.length > 2) {
      final int index = variant % (letters.length - 1);
      final String temp = letters[index];
      letters[index] = letters[index + 1];
      letters[index + 1] = temp;
    }

    return letters.join();
  }

  static List<String> _rotate(List<String> items, int shift) {
    return List<String>.generate(
      items.length,
      (int i) => items[(i + shift) % items.length],
    );
  }
}