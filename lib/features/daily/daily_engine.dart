import 'dart:math';

import '../../core/constants/game_ids.dart';

class DailyEngine {
  static const int gamesPerSession = 5;

  List<String> getTodayGames() {
    final List<String> games = List<String>.from(GameIds.all);

    final DateTime now = DateTime.now();
    final int seed = now.year * 10000 + now.month * 100 + now.day;

    games.shuffle(Random(seed));

    return games.take(gamesPerSession).toList();
  }
}