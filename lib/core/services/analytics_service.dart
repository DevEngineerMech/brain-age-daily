
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'player_insights_service.dart';
import 'stats_service.dart';

class AnalyticsService {
  AnalyticsService._();

  static FirebaseAnalytics get analytics =>
      FirebaseAnalytics.instance;

  static DateTime? _foregroundStartedAt;
  static DateTime? _appSessionStartedAt;

  static bool _initialized = false;

  // Remembers the starting point of Free Play sessions.
  // No game-page modifications are required.
  static final Map<String, DateTime> _freePlayStarts = {};

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await analytics.setAnalyticsCollectionEnabled(true);

      _foregroundStartedAt = DateTime.now();
      _appSessionStartedAt = DateTime.now();

      await _log(
        'app_session_started',
        {
          'source': 'app_launch',
          'platform_type': kIsWeb
              ? 'web'
              : defaultTargetPlatform.name,
        },
      );

      _initialized = true;

      debugPrint(
        'Firebase Analytics initialized successfully.',
      );
    } catch (error) {
      debugPrint(
        'Firebase Analytics initialization error: $error',
      );
    }
  }

  static Future<void> _log(
    String name, [
    Map<String, Object>? parameters,
  ]) async {
    try {
      await analytics.logEvent(
        name: name,
        parameters: parameters,
      );

      if (kDebugMode) {
        debugPrint(
          '[Analytics] $name'
          '${parameters == null ? '' : ' $parameters'}',
        );
      }
    } catch (error) {
      debugPrint(
        '[Analytics] Error sending $name: $error',
      );
    }
  }

  // =====================================================
  // TEST / DEBUGGING
  // =====================================================

  static Future<void> logTestEvent(
    String name, [
    Map<String, Object>? parameters,
  ]) {
    return _log(name, parameters);
  }

  // =====================================================
  // SCREEN TRACKING
  // =====================================================

  static Future<void> screen(
    String screenName,
  ) async {
    try {
      await analytics.logScreenView(
        screenName: screenName,
        screenClass: screenName,
      );

      if (kDebugMode) {
        debugPrint('[Analytics] Screen: $screenName');
      }
    } catch (error) {
      debugPrint(
        '[Analytics] Screen error: $error',
      );
    }

    // Capture useful gameplay and wallet metrics when
    // the existing home screen is opened.
    //
    // Snapshot is internally restricted to once per day
    // and does not alter saved game data.
    if (screenName == 'home') {
      await PlayerInsightsService.captureDailySnapshot();
    }
  }

  // =====================================================
  // APP / SESSION TRACKING
  // =====================================================

  static Future<void> appForegrounded() async {
    _foregroundStartedAt = DateTime.now();

    await _log(
      'app_foregrounded',
      {
        'platform_type': kIsWeb
            ? 'web'
            : defaultTargetPlatform.name,
      },
    );
  }

  static Future<void> appBackgrounded() async {
    final now = DateTime.now();

    final foregroundStart = _foregroundStartedAt;

    if (foregroundStart != null) {
      final seconds =
          now.difference(foregroundStart).inSeconds;

      if (seconds > 0) {
        await _log(
          'foreground_session',
          {
            'duration_seconds': seconds,
          },
        );
      }
    }

    final sessionStart = _appSessionStartedAt;

    if (sessionStart != null) {
      final seconds =
          now.difference(sessionStart).inSeconds;

      if (seconds > 0) {
        await _log(
          'app_session_duration',
          {
            'duration_seconds': seconds,
          },
        );
      }
    }

    _foregroundStartedAt = null;
  }

  // =====================================================
  // DAILY BRAIN CHECK
  // =====================================================

  static Future<void> dailyChallengeStarted({
    required int games,
    required int heartsRemaining,
  }) {
    return _log(
      'daily_challenge_started',
      {
        'games': games,
        'hearts_remaining': heartsRemaining,
      },
    );
  }

  static Future<void> dailyGameStarted({
    required String gameId,
    required int position,
  }) {
    return _log(
      'daily_game_started',
      {
        'game_id': gameId,
        'position': position,
      },
    );
  }

  static Future<void> dailyGameCompleted({
    required String gameId,
    required int position,
    required int score,
    required int correct,
    required int attempts,
    required int durationSeconds,
  }) {
    final accuracy = attempts == 0
        ? 0
        : ((correct / attempts) * 100)
            .round()
            .clamp(0, 100);

    return _log(
      'daily_game_completed',
      {
        'game_id': gameId,
        'position': position,
        'score': score,
        'correct': correct,
        'attempts': attempts,
        'accuracy': attempts == 0
            ? 0.0
            : correct / attempts,
        'accuracy_pct': accuracy,
        'duration_seconds': durationSeconds,
      },
    );
  }

  static Future<void> dailyChallengeAbandoned({
    required int gamesCompleted,
    required int currentGame,
    required int secondsPlayed,
  }) {
    return _log(
      'daily_challenge_abandoned',
      {
        'games_completed': gamesCompleted,
        'current_game': currentGame,
        'seconds_played': secondsPlayed,
      },
    );
  }

  static Future<void> dailyChallengeCompleted({
    required int brainAge,
    required int chronologicalAge,
    required int score,
    required int correct,
    required int attempts,
    required int durationSeconds,
  }) {
    return _log(
      'daily_challenge_completed',
      {
        'brain_age': brainAge,
        'chronological_age': chronologicalAge,
        'brain_age_difference':
            brainAge - chronologicalAge,
        'score': score,
        'correct': correct,
        'attempts': attempts,
        'duration_seconds': durationSeconds,
        'accuracy_pct': attempts == 0
            ? 0
            : ((correct / attempts) * 100)
                .round()
                .clamp(0, 100),
      },
    );
  }

  static Future<void> brainAgeCalculated({
    required int brainAge,
    required int chronologicalAge,
  }) {
    return _log(
      'brain_age_calculated',
      {
        'brain_age': brainAge,
        'chronological_age': chronologicalAge,
        'difference': brainAge - chronologicalAge,
      },
    );
  }

  // =====================================================
  // FREE PLAY
  // =====================================================

  static Future<void> freePlayOpened() {
    return _log('free_play_opened');
  }

  static Future<void> freePlayGameOpened({
    required String gameId,
  }) async {
    _freePlayStarts[gameId] = DateTime.now();

    await _log(
      'free_play_game_opened',
      {
        'game_id': gameId,
      },
    );
  }

  /// Called by your existing Free Play navigation after
  /// a game screen closes.
  ///
  /// Checks StatsService for a saved completed round.
  /// Opening and immediately leaving a game is tracked
  /// as an exit, not a completed round.
  static Future<void> freePlayGameExited({
    required String gameId,
    required int secondsPlayed,
  }) async {
    await _log(
      'free_play_game_exited',
      {
        'game_id': gameId,
        'duration_seconds': secondsPlayed,
      },
    );

    final started = _freePlayStarts.remove(gameId);

    try {
      if (started == null) return;

      final results =
          await StatsService.getFreePlayResults();

      final newResults = results.where((result) {
        return result.gameId == gameId &&
            result.attempts > 0 &&
            !result.playedAt.isBefore(
              started.subtract(
                const Duration(seconds: 2),
              ),
            );
      }).toList();

      if (newResults.isEmpty) {
        await _log(
          'free_play_game_abandoned',
          {
            'game_id': gameId,
            'duration_seconds': secondsPlayed,
          },
        );

        return;
      }

      // Normally only one result is saved per game.
      // Track any completed records from this session.
      for (final result in newResults) {
        await _log(
          'free_play_game_completed',
          {
            'game_id': gameId,
            'score': result.score,
            'attempts': result.attempts,
            'correct': result.correct,
            'accuracy_pct':
                (result.accuracy * 100)
                    .round()
                    .clamp(0, 100),
            'duration_seconds': secondsPlayed,
          },
        );
      }
    } catch (error) {
      debugPrint(
        '[Analytics] Free Play completion '
        'detection error: $error',
      );
    }
  }

  // =====================================================
  // DAILY MISSIONS
  // =====================================================

  /// Call after a mission reward has been successfully
  /// saved by DailyMissionsService.
  static Future<void> missionClaimed({
    required String missionId,
    required int coinsEarned,
  }) {
    return _log(
      'mission_reward_claimed',
      {
        'mission_id': missionId,
        'coins_earned': coinsEarned,
      },
    );
  }

  static Future<void> missionBonusClaimed({
    required int coinsEarned,
  }) {
    return _log(
      'mission_bonus_claimed',
      {
        'coins_earned': coinsEarned,
      },
    );
  }

  // =====================================================
  // SEVEN-DAY REWARDS
  // =====================================================

  /// Call only after the wallet confirms a claim.
  static Future<void> calendarRewardClaimed({
    required int day,
    required int coinsEarned,
  }) {
    return _log(
      'calendar_reward_claimed',
      {
        'reward_day': day,
        'coins_earned': coinsEarned,
      },
    );
  }

  // =====================================================
  // BRAIN SHOP
  // =====================================================

  /// Call when a purchase succeeds, not when the
  /// player merely opens a product.
  static Future<void> shopPurchase({
    required String itemId,
    required String category,
    required int coinsSpent,
  }) {
    return _log(
      'brain_shop_purchase',
      {
        'item_id': itemId,
        'item_category': category,
        'coins_spent': coinsSpent,
      },
    );
  }

  static Future<void> arcadeEntry({
    required String gameId,
    required String paymentType,
  }) {
    return _log(
      'arcade_game_entry',
      {
        'game_id': gameId,
        'payment_type': paymentType,
      },
    );
  }

  // =====================================================
  // MYSTERY BONUS
  // =====================================================

  static Future<void> mysteryStarted({
    required String gameId,
  }) {
    return _log(
      'mystery_game_started',
      {
        'game_id': gameId,
      },
    );
  }

  static Future<void> mysteryCompleted({
    required String gameId,
    required int performance,
    required int coinsEarned,
  }) {
    return _log(
      'mystery_game_completed',
      {
        'game_id': gameId,
        'performance_pct': performance,
        'coins_earned': coinsEarned,
      },
    );
  }

  // =====================================================
  // HEARTS
  // =====================================================

  static Future<void> heartUsed({
    required int heartsRemaining,
  }) {
    return _log(
      'heart_used',
      {
        'hearts_remaining': heartsRemaining,
      },
    );
  }

  static Future<void> heartUnavailable() {
    return _log('heart_unavailable');
  }

  static Future<void> heartRewardedAdStarted() {
    return _log('heart_rewarded_ad_started');
  }

  static Future<void> heartRewardedAdCompleted() {
    return _log('heart_rewarded_ad_completed');
  }

  static Future<void> heartRewardFailed() {
    return _log('heart_reward_failed');
  }

  // =====================================================
  // STREAKS
  // =====================================================

  static Future<void> streakViewed({
    required int streak,
  }) {
    return _log(
      'streak_viewed',
      {'streak': streak},
    );
  }

  // =====================================================
  // NOTIFICATIONS
  // =====================================================

  static Future<void> notificationScheduled({
    required String slot,
    required String type,
    required String variant,
  }) {
    return _log(
      'notification_scheduled',
      {
        'slot': slot,
        'notification_type': type,
        'variant': variant,
      },
    );
  }

  static Future<void> notificationOpened({
    required String slot,
    required String type,
    required String variant,
  }) {
    return _log(
      'notification_opened',
      {
        'slot': slot,
        'notification_type': type,
        'variant': variant,
      },
    );
  }

  // =====================================================
  // ADVERTISING
  // =====================================================

  static Future<void> adEvent({
    required String action,
    required String format,
    required String placement,
    String? error,
  }) {
    final parameters = <String, Object>{
      'action': action,
      'ad_format': format,
      'placement': placement,
    };

    if (error != null) {
      parameters['error'] = error;
    }

    return _log(
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
  }) {
    return _log(
      'ad_revenue',
      {
        'ad_format': format,
        'placement': placement,
        'value_micros': valueMicros,
        'currency': currencyCode,
        'precision': precision,
      },
    );
  }
}
