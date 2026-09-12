class GameIds {
  static const String memoryGrid = 'memory_grid';
  static const String quickMath = 'quick_math';
  static const String wordScramble = 'word_scramble';
  static const String scienceQuiz = 'science_quiz';
  static const String biologyQuiz = 'biology_quiz';
  static const String antonyms = 'antonyms';
  static const String reactionSwitch = 'reaction_switch';
  static const String sudoku = 'sudoku';
  static const String wordSnap = 'word_snap';
  static const String focusCount = 'focus_count';
  static const String symbolMatch = 'symbol_match';
  static const String timeDifference = 'time_difference';
  static const String patternLogic = 'pattern_logic';
  static const String orderRecall = 'order_recall';
  static const String stroopShift = 'stroop_shift';

  static const List<String> all = [
    memoryGrid,
    quickMath,
    wordScramble,
    scienceQuiz,
    biologyQuiz,
    antonyms,
    reactionSwitch,
    sudoku,
    wordSnap,
    focusCount,
    symbolMatch,
    timeDifference,
    patternLogic,
    orderRecall,
    stroopShift,
  ];

  static String label(String id) {
    switch (id) {
      case memoryGrid:
        return 'Memory Grid';
      case quickMath:
        return 'Quick Math';
      case wordScramble:
        return 'Word Scramble';
      case scienceQuiz:
        return 'Science Quiz';
      case biologyQuiz:
        return 'Biology Quiz';
      case antonyms:
        return 'Antonyms';
      case reactionSwitch:
        return 'Reaction Switch';
      case sudoku:
        return 'Sudoku';
      case wordSnap:
        return 'Word Snap';
      case focusCount:
        return 'Focus Count';
      case symbolMatch:
        return 'Symbol Match';
      case timeDifference:
        return 'Time Difference';
      case patternLogic:
        return 'Pattern Logic';
      case orderRecall:
        return 'Order Recall';
      case stroopShift:
        return 'Stroop Shift';
      default:
        return id;
    }
  }
}