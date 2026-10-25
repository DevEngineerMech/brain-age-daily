
import 'dart:math';

import '../../core/constants/game_ids.dart';

class DailyEngine {
  static const int gamesPerSession = 5;

  static const List<String> _memoryGames = [
    GameIds.memoryGrid,
    GameIds.orderRecall,
  ];

  static const List<String> _logicGames = [
    GameIds.patternLogic,
    GameIds.symbolMatch,
    GameIds.sudoku,
  ];

  static const List<String> _attentionGames = [
    GameIds.focusCount,
    GameIds.stroopShift,
  ];

  static const List<String> _speedGames = [
    GameIds.reactionSwitch,
  ];

  static const List<String> _numericalGames = [
    GameIds.quickMath,
    GameIds.timeDifference,
  ];

  List<String> getTodayGames() {
    final now = DateTime.now();

    // Same selection for a given date.
    final seed =
        now.year * 10000 + now.month * 100 + now.day;

    final random = Random(seed);

    String choose(List<String> games) {
      return games[random.nextInt(games.length)];
    }

    final selected = <String>[
      choose(_memoryGames),
      choose(_logicGames),
      choose(_attentionGames),
      choose(_speedGames),
      choose(_numericalGames),
    ];

    selected.shuffle(random);

    return selected;
  }
}
