import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  AnalyticsService._();

  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static bool _enabled = false;

  static Future<void> initialize() async {
    if (kIsWeb) return;
    await analytics.setAnalyticsCollectionEnabled(true);
    _enabled = true;
  }

  static Future<void> event(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    if (!_enabled || kIsWeb) return;
    await analytics.logEvent(name: name, parameters: parameters);
  }

  static Future<void> screen(String name) async {
    if (!_enabled || kIsWeb) return;
    await analytics.logScreenView(screenName: name);
  }

  static Future<void> dailyStarted({required int gameCount}) => event(
        'daily_challenge_started',
        parameters: {'game_count': gameCount},
      );

  static Future<void> dailyGameStarted(String gameId, int position) => event(
        'daily_game_started',
        parameters: {'game_id': gameId, 'position': position},
      );

  static Future<void> dailyGameCompleted({
    required String gameId,
    required int position,
    required int score,
    required int correct,
    required int attempts,
    required int durationSeconds,
  }) =>
      event(
        'daily_game_completed',
        parameters: {
          'game_id': gameId,
          'position': position,
          'score': score,
          'correct': correct,
          'attempts': attempts,
          'duration_seconds': durationSeconds,
        },
      );

  static Future<void> dailyCompleted({
    required int brainAge,
    required int chronologicalAge,
    required int score,
    required int correct,
    required int attempts,
  }) =>
      event(
        'daily_challenge_completed',
        parameters: {
          'brain_age': brainAge,
          'chronological_age': chronologicalAge,
          'score': score,
          'correct': correct,
          'attempts': attempts,
        },
      );

  static Future<void> freePlayOpened() => event('free_play_opened');

  static Future<void> freePlayGameOpened(String gameId) => event(
        'free_play_game_opened',
        parameters: {'game_id': gameId},
      );

  static Future<void> adEvent({
    required String action,
    required String format,
    required String placement,
    String? error,
  }) =>
      event(
        'ad_event',
        parameters: {
          'action': action,
          'ad_format': format,
          'placement': placement,
          if (error != null) 'error': error.length > 90 ? error.substring(0, 90) : error,
        },
      );

  static Future<void> adRevenue({
    required String format,
    required String placement,
    required int valueMicros,
    required String currencyCode,
    required String precision,
  }) =>
      event(
        'ad_revenue',
        parameters: {
          'ad_format': format,
          'placement': placement,
          'value_micros': valueMicros,
          'currency': currencyCode,
          'precision': precision,
        },
      );
}
