
import '../../features/daily/daily_engine.dart';

class DailyBrainCheckService {
  DailyBrainCheckService._();

  static List<String> dailyGames() {
    return DailyEngine().getTodayGames();
  }
}
