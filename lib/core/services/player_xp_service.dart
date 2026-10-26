
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerXpSnapshot {
  final int totalXp;
  final int level;
  final int currentLevelXp;
  final int requiredLevelXp;
  final int pendingCoins;
  final int lifetimeCoinsAwarded;

  const PlayerXpSnapshot({
    required this.totalXp,
    required this.level,
    required this.currentLevelXp,
    required this.requiredLevelXp,
    required this.pendingCoins,
    required this.lifetimeCoinsAwarded,
  });

  double get progress =>
      requiredLevelXp <= 0
          ? 0
          : (currentLevelXp / requiredLevelXp)
              .clamp(0.0, 1.0);

  int get xpRemaining =>
      requiredLevelXp - currentLevelXp;

  String get title {
    if (level >= 50) return 'Brain Legend';
    if (level >= 30) return 'Brain Master';
    if (level >= 20) return 'Mind Champion';
    if (level >= 10) return 'Brain Expert';
    if (level >= 5) return 'Brain Explorer';
    return 'Brain Rookie';
  }
}

class PlayerXpAward {
  final bool awarded;
  final int xpEarned;
  final int previousLevel;
  final PlayerXpSnapshot snapshot;

  const PlayerXpAward({
    required this.awarded,
    required this.xpEarned,
    required this.previousLevel,
    required this.snapshot,
  });

  bool get levelledUp =>
      snapshot.level > previousLevel;
}

class PlayerXpService {
  PlayerXpService._();

  static const String _storageKey =
      'brain_age_player_xp_v1';

  static const int dailyCheckXp = 100;
  static const int freePlayXp = 20;
  static const int perfectGameBonusXp = 15;
  static const int missionXp = 25;
  static const int achievementXp = 50;

  static Future<void> _queue = Future<void>.value();

  static Future<T> _locked<T>(
    Future<T> Function() action,
  ) async {
    final previous = _queue;
    final done = Completer<void>();

    _queue = done.future;
    await previous;

    try {
      return await action();
    } finally {
      done.complete();
    }
  }

  static int xpForNextLevel(int level) {
    return 100 + ((level - 1) * 50);
  }

  static int coinsForLevel(int level) {
    if (level <= 1) return 0;
    if (level % 10 == 0) return 150;
    if (level % 5 == 0) return 50;
    return 0;
  }

  static Map<String, dynamic> _emptyData() {
    return {
      'totalXp': 0,
      'pendingCoins': 0,
      'lifetimeCoinsAwarded': 0,
      'events': <String>[],
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  static Future<Map<String, dynamic>> _read(
    SharedPreferences prefs,
  ) async {
    final raw = prefs.getString(_storageKey);

    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);

        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (error) {
        debugPrint('XP data read error: $error');

        // Do not overwrite damaged existing data.
        rethrow;
      }
    }

    final data = _emptyData();

    final saved = await prefs.setString(
      _storageKey,
      jsonEncode(data),
    );

    if (!saved) {
      throw StateError('XP data could not be created.');
    }

    return data;
  }

  static int _number(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];
    return value is num ? value.toInt() : 0;
  }

  static PlayerXpSnapshot _snapshot(
    Map<String, dynamic> data,
  ) {
    final totalXp = _number(data, 'totalXp');

    var level = 1;
    var remaining = totalXp;

    while (remaining >= xpForNextLevel(level)) {
      remaining -= xpForNextLevel(level);
      level++;
    }

    return PlayerXpSnapshot(
      totalXp: totalXp,
      level: level,
      currentLevelXp: remaining,
      requiredLevelXp: xpForNextLevel(level),
      pendingCoins: _number(data, 'pendingCoins'),
      lifetimeCoinsAwarded:
          _number(data, 'lifetimeCoinsAwarded'),
    );
  }

  static Future<PlayerXpSnapshot> getSnapshot() async {
    return _locked(() async {
      final prefs =
          await SharedPreferences.getInstance();

      final data = await _read(prefs);
      return _snapshot(data);
    });
  }

  // Every award requires a unique event ID.
  //
  // Example:
  // daily:2026-10-26
  // freeplay:unique-session-id
  // mission:2026-10-26:mission-id
  //
  // Repeated calls with the same ID cannot grant
  // XP again.
  static Future<PlayerXpAward> award({
    required String eventId,
    required int xp,
  }) async {
    if (eventId.trim().isEmpty) {
      throw ArgumentError('XP event ID is required.');
    }

    if (xp <= 0) {
      throw ArgumentError('XP must be positive.');
    }

    return _locked(() async {
      final prefs =
          await SharedPreferences.getInstance();

      final data = await _read(prefs);

      final events = List<String>.from(
        data['events'] as List? ?? [],
      );

      final before = _snapshot(data);

      if (events.contains(eventId)) {
        return PlayerXpAward(
          awarded: false,
          xpEarned: 0,
          previousLevel: before.level,
          snapshot: before,
        );
      }

      data['totalXp'] =
          _number(data, 'totalXp') + xp;

      events.add(eventId);
      data['events'] = events;

      final after = _snapshot(data);

      var earnedCoins = 0;

      for (
        var level = before.level + 1;
        level <= after.level;
        level++
      ) {
        earnedCoins += coinsForLevel(level);
      }

      data['pendingCoins'] =
          _number(data, 'pendingCoins') +
          earnedCoins;

      final saved = await prefs.setString(
        _storageKey,
        jsonEncode(data),
      );

      if (!saved) {
        throw StateError('XP award could not be saved.');
      }

      return PlayerXpAward(
        awarded: true,
        xpEarned: xp,
        previousLevel: before.level,
        snapshot: _snapshot(data),
      );
    });
  }

  // This only records the coins awaiting delivery.
  // Actual wallet crediting will be connected to
  // DailyMissionsService in the integration step.
  //
  // Do not clear pending coins without successfully
  // crediting the user's wallet.
  static Future<int> getPendingCoins() async {
    final snapshot = await getSnapshot();
    return snapshot.pendingCoins;
  }
}
