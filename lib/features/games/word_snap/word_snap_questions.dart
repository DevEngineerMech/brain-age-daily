class WordSnapQuestion {
  final String word;
  final List<String> options;
  final String answer;

  const WordSnapQuestion({
    required this.word,
    required this.options,
    required this.answer,
  });
}

class WordSnapQuestions {
  static final List<WordSnapQuestion> all = _buildAll();

  static List<WordSnapQuestion> _buildAll() {
    final Map<String, List<String>> categories = <String, List<String>>{
      'Animal': <String>[
        'Tiger', 'Dog', 'Whale', 'Rabbit', 'Fox', 'Panda', 'Horse', 'Otter'
      ],
      'Fruit': <String>[
        'Apple', 'Banana', 'Orange', 'Pear', 'Peach', 'Lemon', 'Mango', 'Grape'
      ],
      'Country': <String>[
        'Italy', 'Japan', 'Brazil', 'Spain', 'India', 'Canada', 'France', 'Egypt'
      ],
      'Colour': <String>[
        'Red', 'Blue', 'Green', 'Purple', 'Yellow', 'Black', 'White', 'Orange'
      ],
      'Sport': <String>[
        'Football', 'Tennis', 'Golf', 'Cricket', 'Rugby', 'Boxing', 'Hockey', 'Rowing'
      ],
      'Vehicle': <String>[
        'Car', 'Train', 'Boat', 'Plane', 'Truck', 'Scooter', 'Bus', 'Bike'
      ],
    };

    final List<String> categoryNames = categories.keys.toList();
    final List<WordSnapQuestion> questions = <WordSnapQuestion>[];

    for (int variant = 0; variant < 4; variant++) {
      for (final String category in categoryNames) {
        for (final String word in categories[category]!) {
          final List<String> options = <String>[category];

          for (final String other in categoryNames) {
            if (other != category && options.length < 4) {
              options.add(other);
            }
          }

          final List<String> arranged = _rotate(options, variant);

          questions.add(
            WordSnapQuestion(
              word: _variantWord(word, variant),
              options: arranged,
              answer: category,
            ),
          );
        }
      }
    }

    return questions;
  }

  static String _variantWord(String word, int variant) {
    switch (variant) {
      case 0:
        return word;
      case 1:
        return 'Category: $word';
      case 2:
        return 'Where does $word belong?';
      case 3:
        return 'Pick the group for $word';
      default:
        return word;
    }
  }

  static List<String> _rotate(List<String> items, int shift) {
    return List<String>.generate(
      items.length,
      (int i) => items[(i + shift) % items.length],
    );
  }
}