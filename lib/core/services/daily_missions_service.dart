
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/game_ids.dart';
import '../models/daily_session_result.dart';
import '../models/game_result.dart';

import '../../features/shop/brain_shop_catalog.dart';

import 'daily_missions_generator.dart';
import 'stats_service.dart';

class DailyMission {
  final String id;
  final String title;
  final String description;
  final int target;
  final int progress;
  final int reward;
  final bool claimed;

  const DailyMission({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    required this.progress,
    required this.reward,
    required this.claimed,
  });

  bool get completed => progress >= target;

  double get fraction =>
      target <= 0 ? 0 : (progress / target).clamp(0.0, 1.0);
}

class DailyMissionsSnapshot {
  final String dayKey;
  final int coins;
  final List<DailyMission> missions;
  final bool bonusClaimed;

  const DailyMissionsSnapshot({
    required this.dayKey,
    required this.coins,
    required this.missions,
    required this.bonusClaimed,
  });

  int get completedCount =>
      missions.where((item) => item.completed).length;

  int get claimedCount =>
      missions.where((item) => item.claimed).length;

  bool get allClaimed =>
      missions.length == 3 &&
      missions.every((item) => item.claimed);

  bool get canClaimBonus => allClaimed && !bonusClaimed;
}

class DailyMissionsService {
  DailyMissionsService._();

  static const String _storageKey =
      'brain_daily_missions_wallet_v1';

  static const int bonusReward = 50;

  static const List<int> calendarRewards = [
    20, 30, 40, 50, 60, 80, 150,
  ];

  static const List<String> _mysteryGames = [
    'shuffle',
    'rush',
    'missing',
  ];

  static Future<void> _queue = Future<void>.value();

  // All wallet transactions share one queue.
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

  static String _dateKey(DateTime value) {
    return '${value.year}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static DateTime nextRefreshAt() {
    final now = DateTime.now();

    return DateTime(
      now.year,
      now.month,
      now.day + 1,
    );
  }

  static Duration untilNextRefresh() {
    final remaining =
        nextRefreshAt().difference(DateTime.now());

    return remaining.isNegative
        ? Duration.zero
        : remaining;
  }

  static List<String> _strings(dynamic raw) {
    if (raw is! List) return <String>[];

    return raw.map((item) => item.toString()).toList();
  }

  static Map<String, dynamic> _newWallet() {
    return {
      'day': _dateKey(DateTime.now()),
      'coins': 0,
      'claimed': <String>[],
      'bonusClaimed': false,
      'freePlayOpens': <String>[],
      'plan': <Map<String, dynamic>>[],
      'recentPlans': <Map<String, dynamic>>[],

      // BRAIN SHOP
      'shopUnlocks': <String>[],
      'shopBadges': <String>[],
      'shopEquipped': '',
      'shopPasses': 0,
      'shopBoosts': 0,

      // SEVEN-DAY REWARDS
      'calendarLastClaimDate': '',
      'calendarStep': 0,

      // MYSTERY BONUS
      'mysteryGame': '',
      'mysteryStatus': 'ready',
      'mysteryReward': 0,
      'mysteryPerformance': 0,
    };
  }

  static Future<Map<String, dynamic>> _readRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_storageKey);

    if (value == null) {
      return _newWallet();
    }

    try {
      final decoded = jsonDecode(value);

      if (decoded is! Map) {
        throw const FormatException('Invalid wallet');
      }

      return Map<String, dynamic>.from(decoded);
    } catch (error) {
      debugPrint('Wallet read error: $error');

      throw StateError(
        'Saved wallet could not be read. '
        'Existing data has not been overwritten.',
      );
    }
  }

  static Future<void> _saveRaw(
    Map<String, dynamic> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final saved = await prefs.setString(
      _storageKey,
      jsonEncode(data),
    );

    if (!saved) {
      throw StateError('Could not save Brain Coin wallet.');
    }

    if (kDebugMode) {
      debugPrint(
        '[Wallet] day=${data['day']}, '
        'coins=${data['coins']}, '
        'mystery=${data['mysteryStatus']}',
      );
    }
  }

  static List<MissionPlan> _parsePlan(dynamic raw) {
    if (raw is! List) {
      return <MissionPlan>[];
    }

    final plans = <MissionPlan>[];

    for (final entry in raw) {
      if (entry is! Map) continue;

      try {
        final plan = MissionPlan.fromJson(
          Map<String, dynamic>.from(entry),
        );

        if (plan.id.isNotEmpty &&
            plan.target > 0 &&
            plan.reward >= 0) {
          plans.add(plan);
        }
      } catch (error) {
        debugPrint('Mission plan error: $error');
      }
    }

    return plans;
  }

  static List<MissionPlan> _legacyPlan() {
    return const [
      MissionPlan(
        id: 'daily_check',
        title: 'Daily Brain Check',
        description: 'Complete today’s Daily Brain Check.',
        metric: 'checks',
        target: 1,
        reward: 40,
      ),
      MissionPlan(
        id: 'free_play',
        title: 'Free Play Explorer',
        description: 'Complete 3 Free Play rounds today.',
        metric: 'visits',
        target: 3,
        reward: 30,
      ),
      MissionPlan(
        id: 'correct_answers',
        title: 'Sharp Thinker',
        description: 'Answer 20 daily check questions correctly.',
        metric: 'correct',
        target: 20,
        reward: 30,
      ),
    ];
  }

  static Future<Map<String, dynamic>> _ready() async {
    final data = await _readRaw();

    final today = _dateKey(DateTime.now());
    final previousDay =
        data['day']?.toString() ?? today;

    bool changed = false;

    if (previousDay != today) {
      final history = data['recentPlans'] is List
          ? List<dynamic>.from(data['recentPlans'])
          : <dynamic>[];

      final oldPlan = _parsePlan(data['plan']);

      if (oldPlan.isNotEmpty) {
        history.add({
          'day': previousDay,
          'ids': oldPlan.map((e) => e.id).toList(),
        });
      }

      final cutoff = _dateOnly(DateTime.now())
          .subtract(const Duration(days: 7));

      final recent = history.where((entry) {
        if (entry is! Map) return false;

        final date = DateTime.tryParse(
          entry['day']?.toString() ?? '',
        );

        return date != null &&
            !_dateOnly(date).isBefore(cutoff);
      }).toList();

      // Preserve all long-term inventory, coin balance
      // and seven-day streak records.
      final savedCoins =
          (data['coins'] as num?)?.toInt() ?? 0;

      final unlocks = _strings(data['shopUnlocks']);
      final badges = _strings(data['shopBadges']);
      final equipped =
          data['shopEquipped']?.toString() ?? '';

      final passes =
          (data['shopPasses'] as num?)?.toInt() ?? 0;
      final boosts =
          (data['shopBoosts'] as num?)?.toInt() ?? 0;

      final lastCalendarClaim =
          data['calendarLastClaimDate']?.toString() ?? '';

      final calendarStep =
          (data['calendarStep'] as num?)?.toInt() ?? 0;

      data
        ..clear()
        ..addAll(_newWallet())
        ..['coins'] = math.max(0, savedCoins)
        ..['recentPlans'] = recent
        ..['shopUnlocks'] = unlocks
        ..['shopBadges'] = badges
        ..['shopEquipped'] = equipped
        ..['shopPasses'] = passes
        ..['shopBoosts'] = boosts
        ..['calendarLastClaimDate'] = lastCalendarClaim
        ..['calendarStep'] = calendarStep;

      // Today's mystery selection and attempt are
      // deliberately reset here at local midnight.
      changed = true;
    }

    var plan = _parsePlan(data['plan']);

    if (plan.isEmpty) {
      final oldProgress =
          previousDay == today &&
          data['plan'] == null &&
          (_strings(data['claimed']).isNotEmpty ||
              _strings(data['freePlayOpens']).isNotEmpty ||
              data['bonusClaimed'] == true);

      if (oldProgress) {
        plan = _legacyPlan();
      } else {
        final sessions =
            await StatsService.getDailySessions();

        final recentlyUsed = <String>{};
        final recentPlans = data['recentPlans'];

        if (recentPlans is List) {
          for (final item in recentPlans) {
            if (item is Map) {
              recentlyUsed.addAll(_strings(item['ids']));
            }
          }
        }

        plan = DailyMissionsGenerator.generate(
          history: sessions,
          date: DateTime.now(),
          recentlyUsedIds: recentlyUsed,
        );
      }

      if (plan.length != 3) {
        throw StateError(
          'Could not generate three Daily Missions.',
        );
      }

      data['plan'] =
          plan.map((item) => item.toJson()).toList();

      changed = true;
    }

    if (changed) {
      await _saveRaw(data);
    }

    return data;
  }

  // =====================================================
  // DAILY MISSION PROGRESS
  // =====================================================

  static int _streakToday(
    List<DailySessionResult> sessions,
  ) {
    final days = sessions
        .map((s) => _dateOnly(s.completedAt))
        .toSet();

    var check = _dateOnly(DateTime.now());
    var count = 0;

    while (days.contains(check)) {
      count++;
      check = check.subtract(const Duration(days: 1));
    }

    return count;
  }

  static int _progress(
    MissionPlan plan,
    List<DailySessionResult> sessions,
    List<GameResult> freeRounds,
  ) {
    final today = _dateOnly(DateTime.now());

    final todays = sessions
        .where((s) => _dateOnly(s.completedAt) == today)
        .toList();

    final checks = todays.length;

    final correct = todays.fold<int>(
      0,
      (sum, s) => sum + s.totalCorrect,
    );

    final attempts = todays.fold<int>(
      0,
      (sum, s) => sum + s.totalAttempts,
    );

    final totalScore = todays.fold<int>(
      0,
      (sum, s) => sum + s.totalScore,
    );

    final uniqueGames =
        freeRounds.map((r) => r.gameId).toSet().length;

    final accuracy = todays.isEmpty
        ? 0
        : todays
            .map((s) => (s.averageAccuracy * 100).round())
            .reduce(math.max);

    switch (plan.metric) {
      case 'checks':
        return checks;

      case 'correct':
        return correct;

      case 'attempts':
        return attempts;

      case 'score':
        return totalScore;

      case 'accuracy':
        return accuracy;

      case 'visits':
        return freeRounds.length;

      case 'unique_visits':
        return uniqueGames;

      case 'game_visits':
      case 'weak_visits':
      case 'strong_visits':
        return freeRounds
            .where((r) => r.gameId == plan.gameId)
            .length;

      case 'streak':
        return _streakToday(sessions);

      case 'improve_score':
      case 'recent_score':
        return todays.any(
          (s) => s.totalScore >= plan.threshold,
        )
            ? 1
            : 0;

      case 'improve_accuracy':
      case 'recent_accuracy':
        return todays.any(
          (s) =>
              (s.averageAccuracy * 100).round() >=
              plan.threshold,
        )
            ? 1
            : 0;

      case 'improve_speed':
        return todays.any(
          (s) =>
              s.averageResponseTime > 0 &&
              s.averageResponseTime <= plan.threshold,
        )
            ? 1
            : 0;

      case 'improve_age':
        return todays.any(
          (s) => s.brainAge <= plan.threshold,
        )
            ? 1
            : 0;

      case 'combo_two':
        return checks > 0 && freeRounds.length >= 2
            ? 1
            : 0;

      case 'combo_three':
        return checks > 0 && freeRounds.length >= 3
            ? 1
            : 0;

      case 'combo_variety':
        return uniqueGames >= 3 && correct >= 5
            ? 1
            : 0;

      case 'combo_active':
        return uniqueGames >= 2 && attempts >= 10
            ? 1
            : 0;

      default:
        return 0;
    }
  }

  static Future<DailyMissionsSnapshot> _snapshot(
    Map<String, dynamic> wallet,
  ) async {
    final sessions =
        await StatsService.getDailySessions();

    final allFreePlay =
        await StatsService.getFreePlayResults();

    final today = _dateOnly(DateTime.now());

    final completedRounds = allFreePlay.where(
      (round) =>
          _dateOnly(round.playedAt) == today &&
          round.attempts > 0,
    ).toList();

    final claimed = _strings(wallet['claimed']).toSet();

    final missions = _parsePlan(wallet['plan']).map((plan) {
      final progress = _progress(
        plan,
        sessions,
        completedRounds,
      );

      return DailyMission(
        id: plan.id,
        title: plan.title,
        description: plan.description,
        target: plan.target,
        progress: progress.clamp(0, plan.target),
        reward: plan.reward,
        claimed: claimed.contains(plan.id),
      );
    }).toList();

    return DailyMissionsSnapshot(
      dayKey: wallet['day']?.toString() ??
          _dateKey(DateTime.now()),
      coins: (wallet['coins'] as num?)?.toInt() ?? 0,
      missions: missions,
      bonusClaimed: wallet['bonusClaimed'] == true,
    );
  }

  static Future<DailyMissionsSnapshot> getSnapshot() {
    return _locked(() async {
      final wallet = await _ready();
      return _snapshot(wallet);
    });
  }

  static Future<int> getBalance() {
    return _locked(() async {
      final wallet = await _ready();
      return (wallet['coins'] as num?)?.toInt() ?? 0;
    });
  }

  // For compatibility with Free Play navigation.
  // Opening a game alone never counts for missions.
  static Future<void> recordFreePlayOpen(
    String gameId,
  ) async {}

  static Future<bool> claim(String missionId) {
    return _locked(() async {
      final wallet = await _ready();
      final snapshot = await _snapshot(wallet);

      DailyMission? mission;

      for (final candidate in snapshot.missions) {
        if (candidate.id == missionId) {
          mission = candidate;
          break;
        }
      }

      if (mission == null ||
          !mission.completed ||
          mission.claimed) {
        return false;
      }

      final claimed = _strings(wallet['claimed']);

      if (claimed.contains(missionId)) return false;

      claimed.add(missionId);

      final boosts =
          (wallet['shopBoosts'] as num?)?.toInt() ?? 0;

      final reward =
          boosts > 0 ? mission.reward * 2 : mission.reward;

      wallet['claimed'] = claimed;
      wallet['coins'] = snapshot.coins + reward;

      if (boosts > 0) {
        wallet['shopBoosts'] = boosts - 1;
      }

      await _saveRaw(wallet);
      return true;
    });
  }

  static Future<bool> claimBonus() {
    return _locked(() async {
      final wallet = await _ready();
      final snapshot = await _snapshot(wallet);

      if (!snapshot.canClaimBonus) return false;

      wallet['bonusClaimed'] = true;
      wallet['coins'] = snapshot.coins + bonusReward;

      await _saveRaw(wallet);
      return true;
    });
  }

  // =====================================================
  // BRAIN SHOP
  // =====================================================

  static Future<Map<String, dynamic>> getShopState() {
    return _locked(() async {
      final wallet = await _ready();

      return {
        'coins': (wallet['coins'] as num?)?.toInt() ?? 0,
        'unlocks': _strings(wallet['shopUnlocks']),
        'badges': _strings(wallet['shopBadges']),
        'equipped':
            wallet['shopEquipped']?.toString() ?? '',
        'passes':
            (wallet['shopPasses'] as num?)?.toInt() ?? 0,
        'boosts':
            (wallet['shopBoosts'] as num?)?.toInt() ?? 0,
      };
    });
  }

  // 0 insufficient
  // 1 purchased
  // 2 already owned
  static Future<int> buyShopItem(String itemId) {
    return _locked(() async {
      final item = BrainShopCatalog.find(itemId);

      if (item == null) {
        throw ArgumentError.value(itemId, 'itemId');
      }

      final wallet = await _ready();

      final unlocks = _strings(wallet['shopUnlocks']);
      final badges = _strings(wallet['shopBadges']);

      if (item.kind == ShopKind.gameUnlock &&
          unlocks.contains(item.gameId)) {
        return 2;
      }

      if (item.kind == ShopKind.badge &&
          badges.contains(item.id)) {
        return 2;
      }

      final balance =
          (wallet['coins'] as num?)?.toInt() ?? 0;

      if (balance < item.price) return 0;

      switch (item.kind) {
        case ShopKind.gameUnlock:
          if (item.gameId == null ||
              !GameIds.coinArcade.contains(item.gameId)) {
            throw StateError('Invalid Arcade unlock');
          }

          unlocks.add(item.gameId!);
          wallet['shopUnlocks'] = unlocks;
          break;

        case ShopKind.badge:
          badges.add(item.id);
          wallet['shopBadges'] = badges;
          wallet['shopEquipped'] = item.id;
          break;

        case ShopKind.passes:
          wallet['shopPasses'] =
              ((wallet['shopPasses'] as num?)?.toInt() ?? 0) +
              item.quantity;
          break;

        case ShopKind.missionBoost:
          wallet['shopBoosts'] =
              ((wallet['shopBoosts'] as num?)?.toInt() ?? 0) +
              1;
          break;

        case ShopKind.mystery:
          final passes =
              2 + math.Random.secure().nextInt(5);

          wallet['shopPasses'] =
              ((wallet['shopPasses'] as num?)?.toInt() ?? 0) +
              passes;
          break;
      }

      wallet['coins'] = balance - item.price;

      await _saveRaw(wallet);

      return 1;
    });
  }

  static Future<bool> equipShopBadge(String badgeId) {
    return _locked(() async {
      final wallet = await _ready();

      if (badgeId.isNotEmpty &&
          (!_strings(wallet['shopBadges'])
                  .contains(badgeId) ||
              BrainShopCatalog.badge(badgeId) == null)) {
        return false;
      }

      wallet['shopEquipped'] = badgeId;

      await _saveRaw(wallet);
      return true;
    });
  }

  // 0 cannot afford
  // 1 permanent unlock
  // 2 used pass
  // 3 paid coins
  static Future<int> enterArcadeGame(String gameId) {
    return _locked(() async {
      if (!GameIds.coinArcade.contains(gameId)) {
        throw ArgumentError.value(gameId, 'gameId');
      }

      final wallet = await _ready();

      if (_strings(wallet['shopUnlocks']).contains(gameId)) {
        return 1;
      }

      final passes =
          (wallet['shopPasses'] as num?)?.toInt() ?? 0;

      if (passes > 0) {
        wallet['shopPasses'] = passes - 1;
        await _saveRaw(wallet);
        return 2;
      }

      final balance =
          (wallet['coins'] as num?)?.toInt() ?? 0;
      final price =
          BrainShopCatalog.singleArcadeEntryPrice;

      if (balance < price) return 0;

      wallet['coins'] = balance - price;

      await _saveRaw(wallet);
      return 3;
    });
  }

  static Future<void> refundArcadeEntry(int entryType) {
    if (entryType != 2 && entryType != 3) {
      return Future<void>.value();
    }

    return _locked(() async {
      final wallet = await _ready();

      if (entryType == 2) {
        wallet['shopPasses'] =
            ((wallet['shopPasses'] as num?)?.toInt() ?? 0) +
            1;
      } else {
        wallet['coins'] =
            ((wallet['coins'] as num?)?.toInt() ?? 0) +
            BrainShopCatalog.singleArcadeEntryPrice;
      }

      await _saveRaw(wallet);
    });
  }

  // =====================================================
  // SEVEN-DAY REWARDS
  // =====================================================

  static int _calendarStepForToday(
    Map<String, dynamic> wallet,
  ) {
    final now = DateTime.now();

    final today = _dateKey(now);
    final yesterday = _dateKey(
      DateTime(now.year, now.month, now.day - 1),
    );

    final lastClaim =
        wallet['calendarLastClaimDate']?.toString() ?? '';

    final lastStep =
        (wallet['calendarStep'] as num?)?.toInt() ?? 0;

    if (lastClaim == today) {
      return lastStep.clamp(1, 7);
    }

    if (lastClaim == yesterday && lastStep < 7) {
      return lastStep + 1;
    }

    return 1;
  }

  static Future<Map<String, dynamic>> getCalendarState() {
    return _locked(() async {
      final wallet = await _ready();

      final today = _dateKey(DateTime.now());
      final lastClaim =
          wallet['calendarLastClaimDate']?.toString() ?? '';

      final session =
          await StatsService.getTodaySession();

      return {
        'step': _calendarStepForToday(wallet),
        'claimedToday': lastClaim == today,
        'eligible': session != null,
        'coins': (wallet['coins'] as num?)?.toInt() ?? 0,
      };
    });
  }

  static Future<int> claimCalendarGift() {
    return _locked(() async {
      final wallet = await _ready();

      final today = _dateKey(DateTime.now());
      final lastClaim =
          wallet['calendarLastClaimDate']?.toString() ?? '';

      if (lastClaim == today) return 0;

      final session =
          await StatsService.getTodaySession();

      if (session == null) return 0;

      final step = _calendarStepForToday(wallet);
      final reward = calendarRewards[step - 1];

      final balance =
          (wallet['coins'] as num?)?.toInt() ?? 0;

      wallet['coins'] = balance + reward;
      wallet['calendarStep'] = step;
      wallet['calendarLastClaimDate'] = today;

      await _saveRaw(wallet);

      return reward;
    });
  }

  // =====================================================
  // MYSTERY BONUS — ONE ATTEMPT PER DAY
  // =====================================================

  static Future<Map<String, dynamic>> getMysteryBonusState() {
    return _locked(() async {
      final wallet = await _ready();

      var game =
          wallet['mysteryGame']?.toString() ?? '';

      if (!_mysteryGames.contains(game)) {
        // This choice is immediately persisted.
        // Closing the app cannot reroll it.
        game = _mysteryGames[
            math.Random.secure().nextInt(_mysteryGames.length)];

        wallet['mysteryGame'] = game;
        wallet['mysteryStatus'] = 'ready';
        wallet['mysteryReward'] = 0;
        wallet['mysteryPerformance'] = 0;

        await _saveRaw(wallet);
      }

      return {
        'game': game,
        'status':
            wallet['mysteryStatus']?.toString() ?? 'ready',
        'reward':
            (wallet['mysteryReward'] as num?)?.toInt() ?? 0,
        'performance':
            (wallet['mysteryPerformance'] as num?)?.toInt() ?? 0,
        'coins': (wallet['coins'] as num?)?.toInt() ?? 0,
      };
    });
  }

  static Future<bool> startMysteryBonus() {
    return _locked(() async {
      final wallet = await _ready();

      final game =
          wallet['mysteryGame']?.toString() ?? '';

      if (!_mysteryGames.contains(game)) {
        return false;
      }

      final status =
          wallet['mysteryStatus']?.toString() ?? 'ready';

      if (status != 'ready') {
        return false;
      }

      // Starting consumes the day's attempt.
      // Abandoning the page cannot restart it.
      wallet['mysteryStatus'] = 'started';

      await _saveRaw(wallet);
      return true;
    });
  }

  /// [performance] is a score from 0 to 100.
  ///
  /// Returns 0 when already claimed or ineligible.
  /// Otherwise awards 10–60 Brain Coins.
  static Future<int> finishMysteryBonus(
    int performance,
  ) {
    return _locked(() async {
      final wallet = await _ready();

      final game =
          wallet['mysteryGame']?.toString() ?? '';

      final status =
          wallet['mysteryStatus']?.toString() ?? 'ready';

      if (!_mysteryGames.contains(game) ||
          status != 'started') {
        return 0;
      }

      final safePerformance =
          performance.clamp(0, 100);

      final reward = 10 +
          ((safePerformance / 100) * 50).round();

      final balance =
          (wallet['coins'] as num?)?.toInt() ?? 0;

      // Save completed state and coins together.
      wallet['coins'] = balance + reward;
      wallet['mysteryStatus'] = 'completed';
      wallet['mysteryReward'] = reward;
      wallet['mysteryPerformance'] = safePerformance;

      await _saveRaw(wallet);

      debugPrint(
        '[Mystery] $game completed. '
        'Performance $safePerformance, reward $reward.',
      );

      return reward;
    });
  }
}
