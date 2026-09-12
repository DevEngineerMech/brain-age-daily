import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  AnalyticsService._();

  static FirebaseAnalytics get analytics =>
      FirebaseAnalytics.instance;

  static DateTime? _foregroundStartedAt;
  static DateTime? _appSessionStartedAt;

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    _initialized = true;

    await analytics.setAnalyticsCollectionEnabled(true);

    _foregroundStartedAt = DateTime.now();
    _appSessionStartedAt = DateTime.now();

    await _log(
      'app_session_started',
      {
        'source': 'app_launch',
      },
    );
  }

  static Future<void> _log(
    String name, [
    Map<String, Object>? parameters,
  ]) async {
    if (kIsWeb) return;

    try {
      await analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      debugPrint(
        'Analytics error [$name]: $e',
      );
    }
  }

  // ------------------------------------------------------------
  // SCREEN TRACKING
  // ------------------------------------------------------------

  static Future<void> screen(
    String screenName,
  ) async {
    if (kIsWeb) return;

    try {
      await analytics.logScreenView(
        screenName: screenName,
      );
    } catch (e) {
      debugPrint(
        'Screen analytics error: $e',
      );
    }
  }

  // ------------------------------------------------------------
  // APP / SESSION TRACKING
  // ------------------------------------------------------------

  static Future<void> appForegrounded() async {
    _foregroundStartedAt = DateTime.now();

    await _log(
      'app_foregrounded',
    );
  }

  static Future<void> appBackgrounded() async {
    final DateTime now = DateTime.now();

    final DateTime? foregroundStart =
        _foregroundStartedAt;

    if (foregroundStart != null) {
      final int foregroundSeconds =
          now.difference(foregroundStart).inSeconds;

      if (foregroundSeconds > 0) {
        await _log(
          'foreground_session',
          {
            'duration_seconds':
                foregroundSeconds,
          },
        );
      }
    }

    final DateTime? sessionStart =
        _appSessionStartedAt;

    if (sessionStart != null) {
      final int totalSeconds =
          now.difference(sessionStart).inSeconds;

      if (totalSeconds > 0) {
        await _log(
          'app_session_duration',
          {
            'duration_seconds':
                totalSeconds,
          },
        );
      }
    }

    _foregroundStartedAt = null;
  }

  // ------------------------------------------------------------
  // DAILY CHALLENGE
  // ------------------------------------------------------------

  static Future<void>
      dailyChallengeStarted({
    required int games,
    required int heartsRemaining,
  }) async {
    await _log(
      'daily_challenge_started',
      {
        'games': games,
        'hearts_remaining':
            heartsRemaining,
      },
    );
  }

  static Future<void> dailyGameStarted({
    required String gameId,
    required int position,
  }) async {
    await _log(
      'daily_game_started',
      {
        'game_id': gameId,
        'position': position,
      },
    );
  }

  static Future<void>
      dailyGameCompleted({
    required String gameId,
    required int position,
    required int score,
    required int correct,
    required int attempts,
    required int durationSeconds,
  }) async {
    final double accuracy =
        attempts == 0
            ? 0
            : correct / attempts;

    await _log(
      'daily_game_completed',
      {
        'game_id': gameId,
        'position': position,
        'score': score,
        'correct': correct,
        'attempts': attempts,
        'accuracy': accuracy,
        'duration_seconds':
            durationSeconds,
      },
    );
  }

  static Future<void>
      dailyChallengeAbandoned({
    required int gamesCompleted,
    required int currentGame,
    required int secondsPlayed,
  }) async {
    await _log(
      'daily_challenge_abandoned',
      {
        'games_completed':
            gamesCompleted,
        'current_game':
            currentGame,
        'seconds_played':
            secondsPlayed,
      },
    );
  }

  static Future<void>
      dailyChallengeCompleted({
    required int brainAge,
    required int chronologicalAge,
    required int score,
    required int correct,
    required int attempts,
    required int durationSeconds,
  }) async {
    await _log(
      'daily_challenge_completed',
      {
        'brain_age': brainAge,
        'chronological_age':
            chronologicalAge,
        'brain_age_difference':
            brainAge -
                chronologicalAge,
        'score': score,
        'correct': correct,
        'attempts': attempts,
        'duration_seconds':
            durationSeconds,
      },
    );
  }

  static Future<void>
      brainAgeCalculated({
    required int brainAge,
    required int chronologicalAge,
  }) async {
    await _log(
      'brain_age_calculated',
      {
        'brain_age': brainAge,
        'chronological_age':
            chronologicalAge,
        'difference':
            brainAge -
                chronologicalAge,
      },
    );
  }

  // ------------------------------------------------------------
  // FREE PLAY
  // ------------------------------------------------------------

  static Future<void>
      freePlayOpened() async {
    await _log(
      'free_play_opened',
    );
  }

  static Future<void>
      freePlayGameOpened({
    required String gameId,
  }) async {
    await _log(
      'free_play_game_opened',
      {
        'game_id': gameId,
      },
    );
  }

  static Future<void>
      freePlayGameExited({
    required String gameId,
    required int secondsPlayed,
  }) async {
    await _log(
      'free_play_game_exited',
      {
        'game_id': gameId,
        'duration_seconds':
            secondsPlayed,
      },
    );
  }

  // ------------------------------------------------------------
  // HEARTS
  // ------------------------------------------------------------

  static Future<void> heartUsed({
    required int heartsRemaining,
  }) async {
    await _log(
      'heart_used',
      {
        'hearts_remaining':
            heartsRemaining,
      },
    );
  }

  static Future<void>
      heartUnavailable() async {
    await _log(
      'heart_unavailable',
    );
  }

  static Future<void>
      heartRewardedAdStarted() async {
    await _log(
      'heart_rewarded_ad_started',
    );
  }

  static Future<void>
      heartRewardedAdCompleted() async {
    await _log(
      'heart_rewarded_ad_completed',
    );
  }

  static Future<void>
      heartRewardFailed() async {
    await _log(
      'heart_reward_failed',
    );
  }

  // ------------------------------------------------------------
  // STREAK
  // ------------------------------------------------------------

  static Future<void> streakViewed({
    required int streak,
  }) async {
    await _log(
      'streak_viewed',
      {
        'streak': streak,
      },
    );
  }

  // ------------------------------------------------------------
  // NOTIFICATIONS
  // ------------------------------------------------------------

  static Future<void>
      notificationScheduled({
    required String slot,
    required String type,
    required String variant,
  }) async {
    await _log(
      'notification_scheduled',
      {
        'slot': slot,
        'notification_type': type,
        'variant': variant,
      },
    );
  }

  static Future<void>
      notificationOpened({
    required String slot,
    required String type,
    required String variant,
  }) async {
    await _log(
      'notification_opened',
      {
        'slot': slot,
        'notification_type': type,
        'variant': variant,
      },
    );
  }

  // ------------------------------------------------------------
  // ADS
  // ------------------------------------------------------------

  static Future<void> adEvent({
    required String action,
    required String format,
    required String placement,
    String? error,
  }) async {
    final Map<String, Object>
        parameters = {
      'action': action,
      'ad_format': format,
      'placement': placement,
    };

    if (error != null) {
      parameters['error'] = error;
    }

    await _log(
      'ad_event',
      parameters,
    );
  }

  static Future<void> adRevenue({
    required String format,
    required String placement,
    required int valueMicros,
    required String currencyCode,
    required String precision,
  }) async {
    await _log(
      'ad_revenue',
      {
        'ad_format': format,
        'placement': placement,
        'value_micros':
            valueMicros,
        'currency':
            currencyCode,
        'precision':
            precision,
      },
    );
  }
}