
class GameIds {
  GameIds._();

  // ==========================================
  // BRAIN TRAINING GAMES
  // Available in Daily Brain Check and Free Play
  // ==========================================

  static const String memoryGrid = 'memory_grid';
  static const String orderRecall = 'order_recall';
  static const String patternLogic = 'pattern_logic';
  static const String symbolMatch = 'symbol_match';
  static const String focusCount = 'focus_count';
  static const String reactionSwitch = 'reaction_switch';
  static const String stroopShift = 'stroop_shift';
  static const String quickMath = 'quick_math';
  static const String timeDifference = 'time_difference';
  static const String sudoku = 'sudoku';

  // ==========================================
  // KNOWLEDGE / FUTURE COIN ARCADE GAMES
  // ==========================================

  static const String biologyQuiz = 'biology_quiz';
  static const String scienceQuiz = 'science_quiz';
  static const String antonyms = 'antonyms';
  static const String wordSnap = 'word_snap';
  static const String wordScramble = 'word_scramble';

  // ==========================================
  // DAILY BRAIN CHECK ELIGIBILITY
  // ==========================================

  static const List<String> brainTraining = [
    memoryGrid,
    orderRecall,
    patternLogic,
    symbolMatch,
    focusCount,
    reactionSwitch,
    stroopShift,
    quickMath,
    timeDifference,
    sudoku,
  ];

  // Future shop inventory.
  // These games remain accessible through the current
  // Free Play system until purchasing is implemented.
  static const List<String> coinArcade = [
    biologyQuiz,
    scienceQuiz,
    antonyms,
    wordSnap,
    wordScramble,
  ];

  // Keep this for historical stats, achievements,
  // mission definitions and existing Free Play links.
  static const List<String> all = [
    ...brainTraining,
    ...coinArcade,
  ];

  static bool isBrainTraining(String id) {
    return brainTraining.contains(id);
  }

  static bool isCoinArcade(String id) {
    return coinArcade.contains(id);
  }

  static bool isKnown(String id) {
    return all.contains(id);
  }

  static String label(String id) {
    switch (id) {
      case memoryGrid:
        return 'Memory Grid';

      case orderRecall:
        return 'Order Recall';

      case patternLogic:
        return 'Pattern Logic';

      case symbolMatch:
        return 'Symbol Match';

      case focusCount:
        return 'Focus Count';

      case reactionSwitch:
        return 'Reaction Switch';

      case stroopShift:
        return 'Stroop Shift';

      case quickMath:
        return 'Quick Math';

      case timeDifference:
        return 'Time Difference';

      case sudoku:
        return 'Sudoku';

      case biologyQuiz:
        return 'Biology Quiz';

      case scienceQuiz:
        return 'Science Quiz';

      case antonyms:
        return 'Antonyms';

      case wordSnap:
        return 'Word Snap';

      case wordScramble:
        return 'Word Scramble';

      default:
        return id;
    }
  }
}
