import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/game_ids.dart';
import '../models/daily_session_result.dart';
import '../models/game_result.dart';
import '../models/stored_stats.dart';

class StatsService {
  static const String _latestBrainAgeKey = 'latest_brain_age';
  static const String _totalChecksKey = 'total_checks';
  static const String _currentStreakKey = 'current_streak';
  static const String _brainAgeHistoryKey = 'brain_age_history';
  static const String _responseHistoryKey = 'response_history';
  static const String _dailySessionsKey = 'daily_sessions';

  static String _gameStatsKey(String gameId) => 'game_stats_$gameId';

  static Future<int> getLatestBrainAge() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_latestBrainAgeKey) ?? 40;
  }

  static Future<int> getTotalChecks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalChecksKey) ?? 0;
  }

  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentStreakKey) ?? 0;
  }

  static Future<List<int>> getBrainAgeHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_brainAgeHistoryKey) ?? <String>[];
    return raw.map((e) => int.tryParse(e) ?? 40).toList();
  }

  static Future<List<double>> getResponseTimeHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_responseHistoryKey) ?? <String>[];
    return raw.map((e) => double.tryParse(e) ?? 0).toList();
  }

  static Future<List<DailySessionResult>> getDailySessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_dailySessionsKey) ?? <String>[];
    return raw
        .map((e) => DailySessionResult.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveDailySession(DailySessionResult session) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_latestBrainAgeKey, session.brainAge);

    final checks = (prefs.getInt(_totalChecksKey) ?? 0) + 1;
    await prefs.setInt(_totalChecksKey, checks);

    final streak = (prefs.getInt(_currentStreakKey) ?? 0) + 1;
    await prefs.setInt(_currentStreakKey, streak);

    final brainHistory = prefs.getStringList(_brainAgeHistoryKey) ?? <String>[];
    brainHistory.add(session.brainAge.toString());
    await prefs.setStringList(_brainAgeHistoryKey, brainHistory);

    final responseHistory = prefs.getStringList(_responseHistoryKey) ?? <String>[];
    responseHistory.add(session.averageResponseTime.toString());
    await prefs.setStringList(_responseHistoryKey, responseHistory);

    final dailySessions = prefs.getStringList(_dailySessionsKey) ?? <String>[];
    dailySessions.add(jsonEncode(session.toJson()));
    await prefs.setStringList(_dailySessionsKey, dailySessions);

    for (final result in session.gameResults) {
      await saveGameResult(result);
    }
  }

  static Future<void> saveGameResult(GameResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _gameStatsKey(result.gameId);
    final raw = prefs.getStringList(key) ?? <String>[];
    raw.add(jsonEncode(result.toJson()));
    await prefs.setStringList(key, raw);
  }

  static Future<List<GameResult>> getGameResults(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_gameStatsKey(gameId)) ?? <String>[];
    return raw
        .map((e) => GameResult.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  static Future<Map<String, dynamic>> getGameSummary(String gameId) async {
    final results = await getGameResults(gameId);

    if (results.isEmpty) {
      return {
        'gameId': gameId,
        'label': GameIds.label(gameId),
        'plays': 0,
        'averageAccuracy': 0.0,
        'averageResponseTime': 0.0,
        'bestScore': 0,
        'estimatedBrainAge': 40,
      };
    }

    final plays = results.length;
    final averageAccuracy =
        results.map((e) => e.accuracy).fold<double>(0, (a, b) => a + b) / plays;
    final averageResponseTime = results
            .map((e) => e.averageResponseTimeMs)
            .fold<double>(0, (a, b) => a + b) /
        plays;
    final bestScore =
        results.map((e) => e.score).reduce((a, b) => a > b ? a : b);

    int estimatedBrainAge = 40;
    if (averageAccuracy >= 0.9) estimatedBrainAge -= 6;
    if (averageResponseTime <= 1500) estimatedBrainAge -= 5;
    if (bestScore >= 50) estimatedBrainAge -= 4;
    if (estimatedBrainAge < 18) estimatedBrainAge = 18;

    return {
      'gameId': gameId,
      'label': GameIds.label(gameId),
      'plays': plays,
      'averageAccuracy': averageAccuracy,
      'averageResponseTime': averageResponseTime,
      'bestScore': bestScore,
      'estimatedBrainAge': estimatedBrainAge,
    };
  }

  static Future<StoredStats> getStoredStats() async {
    final latestBrainAge = await getLatestBrainAge();
    final totalChecks = await getTotalChecks();
    final currentStreak = await getCurrentStreak();
    final brainAgeHistory = await getBrainAgeHistory();
    final responseTimeHistory = await getResponseTimeHistory();

    return StoredStats(
      latestBrainAge: latestBrainAge,
      totalChecks: totalChecks,
      currentStreak: currentStreak,
      brainAgeHistory: brainAgeHistory,
      responseTimeHistory: responseTimeHistory,
    );
  }
}