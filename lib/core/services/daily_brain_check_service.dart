import '../constants/game_ids.dart';

class DailyBrainCheckService {
  static List<String> dailyGames() {
    return const [
      GameIds.memoryGrid,
      GameIds.quickMath,
      GameIds.stroopShift,
      GameIds.focusCount,
      GameIds.wordSnap,
    ];
  }
}