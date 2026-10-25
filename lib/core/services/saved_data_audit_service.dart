
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'stats_service.dart';

class SavedDataAudit {
  final int coins;
  final int arcadeUnlocks;
  final int arcadePasses;
  final int missionDoublers;
  final int ownedBadges;
  final int dailySessions;
  final int freePlayResults;
  final int claimedMissions;
  final int calendarDay;
  final bool calendarClaimedToday;
  final String mysteryStatus;
  final List<String> problems;

  const SavedDataAudit({
    required this.coins,
    required this.arcadeUnlocks,
    required this.arcadePasses,
    required this.missionDoublers,
    required this.ownedBadges,
    required this.dailySessions,
    required this.freePlayResults,
    required this.claimedMissions,
    required this.calendarDay,
    required this.calendarClaimedToday,
    required this.mysteryStatus,
    required this.problems,
  });

  bool get passed => problems.isEmpty;
}

class SavedDataAuditService {
  SavedDataAuditService._();

  static const String _walletKey =
      'brain_daily_missions_wallet_v1';

  static int _number(Map<String, dynamic> map, String key) {
    final value = map[key];

    return value is num ? value.toInt() : 0;
  }

  static int _listCount(
    Map<String, dynamic> map,
    String key,
  ) {
    final value = map[key];
    return value is List ? value.length : 0;
  }

  static String _today() {
    final now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  static Future<SavedDataAudit> inspect() async {
    final problems = <String>[];

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_walletKey);

    Map<String, dynamic> wallet = {};

    if (raw == null) {
      problems.add(
        'No saved Brain Coin wallet exists yet.',
      );
    } else {
      try {
        final decoded = jsonDecode(raw);

        if (decoded is! Map) {
          throw const FormatException(
            'Wallet is not an object.',
          );
        }

        wallet = Map<String, dynamic>.from(decoded);
      } catch (error) {
        problems.add(
          'The saved Brain Coin wallet could not '
          'be decoded: $error',
        );
      }
    }

    for (final key in [
      'coins',
      'shopPasses',
      'shopBoosts',
      'calendarStep',
      'mysteryReward',
    ]) {
      final value = wallet[key];

      if (value != null && value is! num) {
        problems.add(
          '$key is not stored as a number.',
        );
      } else if (value is num && value < 0) {
        problems.add(
          '$key has an invalid negative value.',
        );
      }
    }

    final coins = _number(wallet, 'coins');
    final passes = _number(wallet, 'shopPasses');
    final boosts = _number(wallet, 'shopBoosts');
    final calendarStep =
        _number(wallet, 'calendarStep');

    if (calendarStep > 7) {
      problems.add(
        'Seven-day reward progress exceeds Day 7.',
      );
    }

    final claimDate =
        wallet['calendarLastClaimDate']?.toString() ?? '';

    if (claimDate.isNotEmpty &&
        DateTime.tryParse(claimDate) == null) {
      problems.add(
        'The saved calendar claim date is invalid.',
      );
    }

    final mysteryStatus =
        wallet['mysteryStatus']?.toString() ?? 'ready';

    if (![
      'ready',
      'started',
      'completed',
    ].contains(mysteryStatus)) {
      problems.add(
        'The saved Mystery Bonus status is invalid.',
      );
    }

    final unlocks = wallet['shopUnlocks'];

    if (unlocks is List &&
        unlocks.toSet().length != unlocks.length) {
      problems.add(
        'Duplicate permanent Arcade unlocks were found.',
      );
    }

    final claimed = wallet['claimed'];

    if (claimed is List &&
        claimed.toSet().length != claimed.length) {
      problems.add(
        'Duplicate claimed mission IDs were found.',
      );
    }

    var dailyCount = 0;
    var freePlayCount = 0;

    try {
      final sessions =
          await StatsService.getDailySessions();

      dailyCount = sessions.length;
    } catch (error) {
      problems.add(
        'Could not read Daily Brain Check history: $error',
      );
    }

    try {
      final results =
          await StatsService.getFreePlayResults();

      freePlayCount = results.length;
    } catch (error) {
      problems.add(
        'Could not read Free Play history: $error',
      );
    }

    debugPrint(
      '[SavedDataAudit] '
      'coins=$coins, '
      'dailySessions=$dailyCount, '
      'freePlay=$freePlayCount, '
      'issues=${problems.length}',
    );

    return SavedDataAudit(
      coins: coins,
      arcadeUnlocks: _listCount(
        wallet,
        'shopUnlocks',
      ),
      arcadePasses: passes,
      missionDoublers: boosts,
      ownedBadges: _listCount(
        wallet,
        'shopBadges',
      ),
      dailySessions: dailyCount,
      freePlayResults: freePlayCount,
      claimedMissions: _listCount(
        wallet,
        'claimed',
      ),
      calendarDay: calendarStep,
      calendarClaimedToday: claimDate == _today(),
      mysteryStatus: mysteryStatus,
      problems: problems,
    );
  }
}
