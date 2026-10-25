class AntonymQuestion {
  final String word;
  final List<String> options;
  final String answer;

  const AntonymQuestion({
    required this.word,
    required this.options,
    required this.answer,
  });
}

class AntonymQuestions {
  static final List<AntonymQuestion> all = _buildAll();

  static List<AntonymQuestion> _buildAll() {
    const List<AntonymQuestion> base = <AntonymQuestion>[
      AntonymQuestion(
        word: 'Ancient',
        options: ['Modern', 'Old', 'Historic', 'Classic'],
        answer: 'Modern',
      ),
      AntonymQuestion(
        word: 'Noisy',
        options: ['Quiet', 'Loud', 'Busy', 'Harsh'],
        answer: 'Quiet',
      ),
      AntonymQuestion(
        word: 'Expand',
        options: ['Contract', 'Stretch', 'Grow', 'Spread'],
        answer: 'Contract',
      ),
      AntonymQuestion(
        word: 'Fragile',
        options: ['Strong', 'Glass', 'Thin', 'Breakable'],
        answer: 'Strong',
      ),
      AntonymQuestion(
        word: 'Victory',
        options: ['Defeat', 'Win', 'Success', 'Triumph'],
        answer: 'Defeat',
      ),
      AntonymQuestion(
        word: 'Generous',
        options: ['Selfish', 'Helpful', 'Kind', 'Warm'],
        answer: 'Selfish',
      ),
      AntonymQuestion(
        word: 'Sharp',
        options: ['Blunt', 'Pointed', 'Fast', 'Smart'],
        answer: 'Blunt',
      ),
      AntonymQuestion(
        word: 'Early',
        options: ['Late', 'Prompt', 'Fast', 'Quick'],
        answer: 'Late',
      ),
      AntonymQuestion(
        word: 'Above',
        options: ['Below', 'Over', 'High', 'Raised'],
        answer: 'Below',
      ),
      AntonymQuestion(
        word: 'Empty',
        options: ['Full', 'Open', 'Blank', 'Clear'],
        answer: 'Full',
      ),
      AntonymQuestion(
        word: 'Accept',
        options: ['Refuse', 'Allow', 'Agree', 'Take'],
        answer: 'Refuse',
      ),
      AntonymQuestion(
        word: 'Arrive',
        options: ['Depart', 'Enter', 'Reach', 'Appear'],
        answer: 'Depart',
      ),
      AntonymQuestion(
        word: 'Bright',
        options: ['Dim', 'Shiny', 'Light', 'Clear'],
        answer: 'Dim',
      ),
      AntonymQuestion(
        word: 'Brave',
        options: ['Cowardly', 'Bold', 'Strong', 'Proud'],
        answer: 'Cowardly',
      ),
      AntonymQuestion(
        word: 'Calm',
        options: ['Agitated', 'Peaceful', 'Still', 'Quiet'],
        answer: 'Agitated',
      ),
      AntonymQuestion(
        word: 'Cheap',
        options: ['Expensive', 'Small', 'Light', 'Simple'],
        answer: 'Expensive',
      ),
      AntonymQuestion(
        word: 'Complex',
        options: ['Simple', 'Long', 'Difficult', 'Twisted'],
        answer: 'Simple',
      ),
      AntonymQuestion(
        word: 'Create',
        options: ['Destroy', 'Build', 'Make', 'Invent'],
        answer: 'Destroy',
      ),
      AntonymQuestion(
        word: 'Dangerous',
        options: ['Safe', 'Risky', 'Wild', 'Sharp'],
        answer: 'Safe',
      ),
      AntonymQuestion(
        word: 'Deep',
        options: ['Shallow', 'Wide', 'Dark', 'Long'],
        answer: 'Shallow',
      ),
      AntonymQuestion(
        word: 'Distant',
        options: ['Near', 'Far', 'Remote', 'Long'],
        answer: 'Near',
      ),
      AntonymQuestion(
        word: 'Friendly',
        options: ['Hostile', 'Kind', 'Warm', 'Happy'],
        answer: 'Hostile',
      ),
      AntonymQuestion(
        word: 'Giant',
        options: ['Tiny', 'Huge', 'Tall', 'Large'],
        answer: 'Tiny',
      ),
      AntonymQuestion(
        word: 'Harsh',
        options: ['Gentle', 'Rough', 'Hard', 'Severe'],
        answer: 'Gentle',
      ),
      AntonymQuestion(
        word: 'Humid',
        options: ['Dry', 'Wet', 'Warm', 'Foggy'],
        answer: 'Dry',
      ),
      AntonymQuestion(
        word: 'Increase',
        options: ['Decrease', 'Grow', 'Rise', 'Expand'],
        answer: 'Decrease',
      ),
      AntonymQuestion(
        word: 'Junior',
        options: ['Senior', 'Young', 'Small', 'New'],
        answer: 'Senior',
      ),
      AntonymQuestion(
        word: 'Kind',
        options: ['Cruel', 'Helpful', 'Gentle', 'Sweet'],
        answer: 'Cruel',
      ),
      AntonymQuestion(
        word: 'Loose',
        options: ['Tight', 'Soft', 'Wide', 'Free'],
        answer: 'Tight',
      ),
      AntonymQuestion(
        word: 'Permanent',
        options: ['Temporary', 'Strong', 'Lasting', 'Fixed'],
        answer: 'Temporary',
      ),
    ];

    final List<AntonymQuestion> all = <AntonymQuestion>[];
    for (int i = 0; i < 4; i++) {
      all.addAll(base.map((q) {
        final List<String> rotated = List<String>.generate(
          q.options.length,
          (index) => q.options[(index + i) % q.options.length],
        );
        return AntonymQuestion(
          word: q.word,
          options: rotated,
          answer: q.answer,
        );
      }));
    }
    return all;
  }
}