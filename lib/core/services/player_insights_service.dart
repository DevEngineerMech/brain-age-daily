
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'daily_missions_service.dart';
import 'stats_service.dart';

/// Collects one anonymous player-level analytics snapshot
/// per local calendar day.
///
/// Uses existing saved gameplay and wallet data.
/// Does not upload usernames or individual gameplay history.
///
/// The snapshot is sent to Google Analytics, not Firestore.
class PlayerInsightsService {
  PlayerInsightsService._();

  static const String _lastSnapshotKey =
      'insights_last_snapshot_day_v1';

  static Future<void>? _running;

  static String _dateKey(DateTime value) {
    return '${value.year}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  static DateTime _localDay(DateTime value) {
    final local = value.toLocal();

    return DateTime(
      local.year,
      local.month,
      local.day,
    );
  }

  /// Called from the existing AnalyticsService
  /// when the user visits the home page.
  ///
  /// Records no more than one snapshot per local day
  /// unless a previous attempt failed.
  static Future<void> captureDailySnapshot() {
    return _running ??= _capture().whenComplete(() {
      _running = null;
    });
  }

  static Future<void> _capture() async {
    try {
      final now = DateTime.now();
      final today = _dateKey(now);

      final prefs = await SharedPreferences.getInstance();

      if (prefs.getString(_lastSnapshotKey) == today) {
        return;
      }

      final sessions =
          await StatsService.getDailySessions();

      final freePlay =
          await StatsService.getFreePlayResults();

      final wallet =
          await DailyMissionsService.getShopState();

      // Rolling seven-day window, including today.
      final cutoff = DateTime(
        now.year,
        now.month,
        now.day - 6,
      );

      final checks = sessions.where((session) {
        return !_localDay(
          session.completedAt,
        ).isBefore(cutoff);
      }).toList();

      final rounds = freePlay.where((round) {
        return round.attempts > 0 &&
            !_localDay(
              round.playedAt,
            ).isBefore(cutoff);
      }).toList();

      final activeCheckDays = checks
          .map((session) => _dateKey(
                session.completedAt.toLocal(),
              ))
          .toSet()
          .length;

      final activeFreePlayDays = rounds
          .map((round) => _dateKey(
                round.playedAt.toLocal(),
              ))
          .toSet()
          .length;

      final totalAttempts = checks.fold<int>(
        0,
        (sum, session) => sum + session.totalAttempts,
      );

      final totalCorrect = checks.fold<int>(
        0,
        (sum, session) => sum + session.totalCorrect,
      );

      final accuracy = totalAttempts == 0
          ? 0
          : ((totalCorrect / totalAttempts) * 100)
              .round()
              .clamp(0, 100);

      final uniqueFreeGames =
          rounds.map((r) => r.gameId).toSet().length;

      final coins =
          (wallet['coins'] as num?)?.toInt() ?? 0;

      final passes =
          (wallet['passes'] as num?)?.toInt() ?? 0;

      final boosts =
          (wallet['boosts'] as num?)?.toInt() ?? 0;

      final unlocks = wallet['unlocks'] is List
          ? (wallet['unlocks'] as List).length
          : 0;

      final badges = wallet['badges'] is List
          ? (wallet['badges'] as List).length
          : 0;

      // One event per active player-day.
      //
      // Register these numeric parameters as custom
      // metrics in GA4 to calculate population averages.
      await FirebaseAnalytics.instance.logEvent(
        name: 'player_insights_snapshot',
        parameters: <String, Object>{
          'daily_checks_7d': checks.length,
          'check_days_7d': activeCheckDays,
          'free_rounds_7d': rounds.length,
          'free_days_7d': activeFreePlayDays,
          'free_games_7d': uniqueFreeGames,
          'check_accuracy_pct': accuracy,
          'coins_balance': coins,
          'arcade_passes': passes,
          'mission_doublers': boosts,
          'arcade_unlocks': unlocks,
          'owned_badges': badges,
          'platform_type': kIsWeb
              ? 'web'
              : defaultTargetPlatform.name,
        },
      );

      // Record the date only after successful submission
      // to the Analytics SDK.
      await prefs.setString(
        _lastSnapshotKey,
        today,
      );

      if (kDebugMode) {
        debugPrint(
          '[PlayerInsights] Snapshot submitted: '
          '${checks.length} checks, '
          '${rounds.length} Free Play rounds, '
          '$coins coins.',
        );
      }
    } catch (error) {
      // Analytics must never crash the app or prevent
      // players from accessing their games.
      debugPrint(
        '[PlayerInsights] Snapshot failed: $error',
      );
    }
  }
}
