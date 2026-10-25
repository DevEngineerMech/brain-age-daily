
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/game_ids.dart';
import '../models/daily_session_result.dart';
import '../models/game_result.dart';

class StatsService {
  StatsService._();

  static const String _dailySessionsKey = 'daily_sessions_v2';
  static const String _freePlayKey = 'free_play_results_v1';

  static Future<void> _freePlayQueue = Future<void>.value();

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // ===================================================
  // EXISTING DAILY BRAIN CHECK HISTORY
  // ===================================================

  static Future<List<DailySessionResult>> getDailySessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_dailySessionsKey) ?? [];

    final sessions = <DailySessionResult>[];

    for (final item in raw) {
      try {
        sessions.add(
          DailySessionResult.fromJson(
            Map<String, dynamic>.from(jsonDecode(item)),
          ),
        );
      } catch (error) {
        debugPrint('Daily session read error: $error');
      }
    }

    sessions.sort(
      (a, b) => b.completedAt.compareTo(a.completedAt),
    );

    return sessions;
  }

  static Future<void> saveDailySession(
    DailySessionResult session,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final sessions = await getDailySessions();

    sessions.add(session);

    sessions.sort(
      (a, b) => b.completedAt.compareTo(a.completedAt),
    );

    final encoded = sessions
        .take(180)
        .map((session) => jsonEncode(session.toJson()))
        .toList();

    final saved = await prefs.setStringList(
      _dailySessionsKey,
      encoded,
    );

    if (!saved) {
      throw StateError('Daily Brain Check stats were not saved.');
    }
  }

  // ===================================================
  // NEW FREE PLAY HISTORY
  // ===================================================

  static Future<List<GameResult>> getFreePlayResults() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_freePlayKey) ?? [];

    final results = <GameResult>[];

    for (final item in raw) {
      try {
        results.add(
          GameResult.fromJson(
            Map<String, dynamic>.from(jsonDecode(item)),
          ),
        );
      } catch (error) {
        debugPrint('Free Play result read error: $error');
      }
    }

    results.sort(
      (a, b) => b.playedAt.compareTo(a.playedAt),
    );

    return results;
  }

  static Future<void> saveFreePlayResult({
    required String gameId,
    required int score,
    required int attempts,
    double averageResponseTimeMs = 0,
  }) async {
    if (!GameIds.isKnown(gameId)) {
      throw ArgumentError.value(
        gameId,
        'gameId',
        'Unknown Free Play game',
      );
    }

    if (attempts <= 0 || score < 0 || score > attempts) {
      throw ArgumentError('Invalid Free Play score.');
    }

    // Queue writes to avoid losing results when
    // multiple save operations happen close together.
    final previous = _freePlayQueue;
    final done = Completer<void>();
    _freePlayQueue = done.future;

    await previous;

    try {
      final prefs = await SharedPreferences.getInstance();
      final results = await getFreePlayResults();

      results.add(
        GameResult(
          gameId: gameId,
          score: score,
          correct: score,
          attempts: attempts,
          averageResponseTimeMs: averageResponseTimeMs,
          playedAt: DateTime.now(),
        ),
      );

      results.sort(
        (a, b) => b.playedAt.compareTo(a.playedAt),
      );

      // Keep the most recent 1,000 completed rounds.
      final encoded = results
          .take(1000)
          .map((result) => jsonEncode(result.toJson()))
          .toList();

      final saved = await prefs.setStringList(
        _freePlayKey,
        encoded,
      );

      if (!saved) {
        throw StateError('Free Play result could not be saved.');
      }

      if (kDebugMode) {
        debugPrint(
          '[FreePlay] Saved: $gameId, $score/$attempts',
        );
      }
    } finally {
      done.complete();
    }
  }

  // ===================================================
  // COMBINED GAME HISTORY
  // ===================================================

  static Future<List<GameResult>> getAllGameResults() async {
    final sessions = await getDailySessions();
    final freePlay = await getFreePlayResults();

    final combined = <GameResult>[
      ...freePlay,
      ...sessions.expand((session) => session.gameResults),
    ];

    combined.sort(
      (a, b) => b.playedAt.compareTo(a.playedAt),
    );

    return combined;
  }

  static Future<List<GameResult>> getGameHistory(
    String gameId,
  ) async {
    final all = await getAllGameResults();

    return all
        .where((result) => result.gameId == gameId)
        .toList();
  }

  static Future<Map<String, int>> getAllBestScores() async {
    final results = await getAllGameResults();
    final scores = <String, int>{};

    for (final result in results) {
      final previous = scores[result.gameId];

      if (previous == null || result.score > previous) {
        scores[result.gameId] = result.score;
      }
    }

    return scores;
  }

  static Future<Map<String, dynamic>> getGameSummary(
    String gameId,
  ) async {
    final freePlay = await getFreePlayResults();
    final dailySessions = await getDailySessions();

    final freeResults = freePlay
        .where((result) => result.gameId == gameId)
        .toList();

    final dailyResults = dailySessions
        .expand((session) => session.gameResults)
        .where((result) => result.gameId == gameId)
        .toList();

    final combined = <GameResult>[
      ...freeResults,
      ...dailyResults,
    ]..sort((a, b) => b.playedAt.compareTo(a.playedAt));

    if (combined.isEmpty) {
      return {
        'label': GameIds.label(gameId),
        'plays': 0,
        'freePlayCount': 0,
        'dailyCheckCount': 0,
        'bestScore': 0,
        'averageAccuracy': 0.0,
        'averageResponseTime': 0.0,
        'hasResponseTime': false,
        'estimatedBrainAge': null,
        'lastPlayed': null,
        'totalCorrect': 0,
        'totalAttempts': 0,
      };
    }

    final bestScore = combined
        .map((result) => result.score)
        .reduce((a, b) => a > b ? a : b);

    final totalCorrect = combined.fold<int>(
      0,
      (sum, result) => sum + result.correct,
    );

    final totalAttempts = combined.fold<int>(
      0,
      (sum, result) => sum + result.attempts,
    );

    final accuracy = totalAttempts == 0
        ? 0.0
        : totalCorrect / totalAttempts;

    // Only average rounds with a measured response time.
    final timedResults = combined
        .where((result) => result.averageResponseTimeMs > 0)
        .toList();

    final responseTime = timedResults.isEmpty
        ? 0.0
        : timedResults.fold<double>(
              0,
              (sum, result) =>
                  sum + result.averageResponseTimeMs,
            ) /
            timedResults.length;

    // Only show brain age if this game was actually
    // included in a completed Daily Brain Check.
    int? brainAge;

    for (final session in dailySessions) {
      if (session.gameResults.any(
        (result) => result.gameId == gameId,
      )) {
        brainAge = session.brainAge;
        break;
      }
    }

    return {
      'label': GameIds.label(gameId),
      'plays': combined.length,
      'freePlayCount': freeResults.length,
      'dailyCheckCount': dailyResults.length,
      'bestScore': bestScore,
      'averageAccuracy': accuracy,
      'averageResponseTime': responseTime,
      'hasResponseTime': timedResults.isNotEmpty,
      'estimatedBrainAge': brainAge,
      'lastPlayed': combined.first.playedAt,
      'totalCorrect': totalCorrect,
      'totalAttempts': totalAttempts,
    };
  }

  // ===================================================
  // EXISTING GLOBAL PROGRESS METHODS
  // ===================================================

  static Future<int> getLatestBrainAge() async {
    final sessions = await getDailySessions();
    if (sessions.isEmpty) return 40;
    return sessions.first.brainAge;
  }

  static Future<int> getTotalChecks() async {
    final sessions = await getDailySessions();
    return sessions.length;
  }

  static Future<List<int>> getBrainAgeHistory() async {
    final sessions = await getDailySessions();

    return sessions.reversed
        .map((session) => session.brainAge)
        .toList();
  }

  static Future<List<double>> getResponseTimeHistory() async {
    final sessions = await getDailySessions();

    return sessions.reversed
        .map((session) => session.averageResponseTime / 1000)
        .toList();
  }

  static Future<int> getCurrentStreak() async {
    final sessions = await getDailySessions();
    if (sessions.isEmpty) return 0;

    final days = sessions
        .map((session) => _dateOnly(session.completedAt))
        .toSet();

    var check = _dateOnly(DateTime.now());

    if (!days.contains(check)) {
      check = check.subtract(const Duration(days: 1));
    }

    var streak = 0;

    while (days.contains(check)) {
      streak++;
      check = check.subtract(const Duration(days: 1));
    }

    return streak;
  }

  static Future<int> getLongestStreak() async {
    final sessions = await getDailySessions();
    if (sessions.isEmpty) return 0;

    final days = sessions
        .map((session) => _dateOnly(session.completedAt))
        .toSet()
        .toList()
      ..sort();

    var longest = 1;
    var current = 1;

    for (int i = 1; i < days.length; i++) {
      final gap = days[i].difference(days[i - 1]).inDays;

      if (gap == 1) {
        current++;
      } else if (gap > 1) {
        current = 1;
      }

      if (current > longest) longest = current;
    }

    return longest;
  }

  static Future<DailySessionResult?> getTodaySession() async {
    final sessions = await getDailySessions();
    final now = DateTime.now();

    for (final session in sessions) {
      if (_isSameDay(session.completedAt, now)) {
        return session;
      }
    }

    return null;
  }

  static Future<DailySessionResult?> getLatestSession() async {
    final sessions = await getDailySessions();
    return sessions.isEmpty ? null : sessions.first;
  }

  static Future<void> clearStats() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_dailySessionsKey);
    await prefs.remove(_freePlayKey);
  }
}
