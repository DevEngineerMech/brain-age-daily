import 'package:shared_preferences/shared_preferences.dart';

class DailyProgress {
  final bool started;
  final bool completed;
  final int gamesCompleted;

  const DailyProgress({
    required this.started,
    required this.completed,
    required this.gamesCompleted,
  });
}

class DailyProgressService {
  DailyProgressService._();

  static const String _dateKey =
      'daily_progress_date';

  static const String _startedKey =
      'daily_progress_started';

  static const String _completedKey =
      'daily_progress_completed';

  static const String _gamesCompletedKey =
      'daily_progress_games_completed';

  static String _todayKey() {
    final DateTime now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  static Future<void>
      _ensureToday() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    final String today = _todayKey();

    final String? savedDate =
        prefs.getString(
      _dateKey,
    );

    if (savedDate == today) {
      return;
    }

    await prefs.setString(
      _dateKey,
      today,
    );

    await prefs.setBool(
      _startedKey,
      false,
    );

    await prefs.setBool(
      _completedKey,
      false,
    );

    await prefs.setInt(
      _gamesCompletedKey,
      0,
    );
  }

  static Future<DailyProgress>
      getTodayProgress() async {
    await _ensureToday();

    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    return DailyProgress(
      started:
          prefs.getBool(
                _startedKey,
              ) ??
              false,
      completed:
          prefs.getBool(
                _completedKey,
              ) ??
              false,
      gamesCompleted:
          prefs.getInt(
                _gamesCompletedKey,
              ) ??
              0,
    );
  }

  static Future<void>
      markStarted() async {
    await _ensureToday();

    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      _startedKey,
      true,
    );
  }

  static Future<void>
      setGamesCompleted(
    int count,
  ) async {
    await _ensureToday();

    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      _startedKey,
      true,
    );

    await prefs.setInt(
      _gamesCompletedKey,
      count,
    );
  }

  static Future<void>
      markCompleted() async {
    await _ensureToday();

    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      _startedKey,
      true,
    );

    await prefs.setBool(
      _completedKey,
      true,
    );

    await prefs.setInt(
      _gamesCompletedKey,
      5,
    );
  }
}