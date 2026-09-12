import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_session_result.dart';

class StatsService {
  static const String _dailySessionsKey = 'daily_sessions_v2';

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static Future<List<DailySessionResult>> getDailySessions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> rawSessions = prefs.getStringList(_dailySessionsKey) ?? [];

    final List<DailySessionResult> sessions = [];

    for (final raw in rawSessions) {
      try {
        final Map<String, dynamic> json =
            Map<String, dynamic>.from(jsonDecode(raw));
        sessions.add(DailySessionResult.fromJson(json));
      } catch (_) {
        continue;
      }
    }

    sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return sessions;
  }

  static Future<void> saveDailySession(DailySessionResult session) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<DailySessionResult> sessions = await getDailySessions();

    sessions.add(session);
    sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    final List<DailySessionResult> trimmedSessions =
        sessions.take(180).toList();

    final List<String> encodedSessions = trimmedSessions
        .map((item) => jsonEncode(item.toJson()))
        .toList();

    await prefs.setStringList(_dailySessionsKey, encodedSessions);
  }

  static Future<int> getLatestBrainAge() async {
    final List<DailySessionResult> sessions = await getDailySessions();

    if (sessions.isEmpty) return 40;

    return sessions.first.brainAge;
  }

  static Future<int> getTotalChecks() async {
    final List<DailySessionResult> sessions = await getDailySessions();
    return sessions.length;
  }

  static Future<List<int>> getBrainAgeHistory() async {
    final List<DailySessionResult> sessions = await getDailySessions();

    final List<DailySessionResult> ordered = sessions.reversed.toList();

    return ordered.map((session) => session.brainAge).toList();
  }

  static Future<List<double>> getResponseTimeHistory() async {
    final List<DailySessionResult> sessions = await getDailySessions();

    final List<DailySessionResult> ordered = sessions.reversed.toList();

    return ordered
        .map((session) => session.averageResponseTime / 1000)
        .toList();
  }

  static Future<int> getCurrentStreak() async {
    final List<DailySessionResult> sessions = await getDailySessions();

    if (sessions.isEmpty) return 0;

    final Set<DateTime> completedDays = sessions
        .map((session) => _dateOnly(session.completedAt))
        .toSet();

    DateTime checkDay = _dateOnly(DateTime.now());

    if (!completedDays.contains(checkDay)) {
      checkDay = checkDay.subtract(const Duration(days: 1));
    }

    int streak = 0;

    while (completedDays.contains(checkDay)) {
      streak++;
      checkDay = checkDay.subtract(const Duration(days: 1));
    }

    return streak;
  }

  static Future<int> getLongestStreak() async {
    final List<DailySessionResult> sessions = await getDailySessions();

    if (sessions.isEmpty) return 0;

    final List<DateTime> dates = sessions
        .map((session) => _dateOnly(session.completedAt))
        .toSet()
        .toList()
      ..sort();

    int longest = 1;
    int current = 1;

    for (int i = 1; i < dates.length; i++) {
      final int gap = dates[i].difference(dates[i - 1]).inDays;

      if (gap == 1) {
        current++;
      } else if (gap > 1) {
        current = 1;
      }

      if (current > longest) {
        longest = current;
      }
    }

    return longest;
  }

  static Future<DailySessionResult?> getTodaySession() async {
    final List<DailySessionResult> sessions = await getDailySessions();
    final DateTime now = DateTime.now();

    for (final session in sessions) {
      if (_isSameDay(session.completedAt, now)) {
        return session;
      }
    }

    return null;
  }

    static Future<DailySessionResult?> getLatestSession() async {
    final List<DailySessionResult> sessions = await getDailySessions();

    if (sessions.isEmpty) return null;

    return sessions.first;
  }

  static Future<Map<String, dynamic>> getGameSummary(String gameId) async {
    final List<DailySessionResult> sessions = await getDailySessions();

    final results = sessions
        .expand((session) => session.gameResults)
        .where((result) => result.gameId == gameId)
        .toList();

    if (results.isEmpty) {
      return {
        'label': gameId,
        'plays': 0,
        'bestScore': 0,
        'averageAccuracy': 0.0,
        'averageResponseTime': 0.0,
        'estimatedBrainAge': 40,
      };
    }

    final int plays = results.length;

    final int bestScore = results
        .map((result) => result.score)
        .reduce((a, b) => a > b ? a : b);

    final double averageAccuracy = results
            .map((result) => result.accuracy)
            .fold<double>(0, (a, b) => a + b) /
        plays;

    final double averageResponseTime = results
            .map((result) => result.averageResponseTimeMs)
            .fold<double>(0, (a, b) => a + b) /
        plays;

    final int estimatedBrainAge = await getLatestBrainAge();

    return {
      'label': gameId,
      'plays': plays,
      'bestScore': bestScore,
      'averageAccuracy': averageAccuracy,
      'averageResponseTime': averageResponseTime,
      'estimatedBrainAge': estimatedBrainAge,
    };
  }

  static Future<void> clearStats() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dailySessionsKey);
  }
}
  