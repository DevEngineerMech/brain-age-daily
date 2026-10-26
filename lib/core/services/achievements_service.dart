
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/game_ids.dart';
import '../models/daily_session_result.dart';
import '../models/game_result.dart';
import 'stats_service.dart';
import 'player_xp_service.dart';

class BrainBadge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int target;
  final String metric;

  const BrainBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.target,
    required this.metric,
  });
}

class BadgeProgress {
  final BrainBadge badge;
  final int value;
  final DateTime? unlockedAt;

  const BadgeProgress({
    required this.badge,
    required this.value,
    this.unlockedAt,
  });

  bool get unlocked => unlockedAt != null;

  double get fraction =>
      (value / badge.target).clamp(0.0, 1.0);

  String get progressText =>
      '$value / ${badge.target}';
}

class AchievementUpdate {
  final List<BadgeProgress> badges;
  final List<BadgeProgress> newlyUnlocked;

  const AchievementUpdate({
    required this.badges,
    required this.newlyUnlocked,
  });

  int get unlockedCount =>
      badges.where((b) => b.unlocked).length;
}

class AchievementsService {
  // Version 2 starts achievement tracking from a
  // clean baseline, without deleting gameplay history.
  //
  // Do not change these keys in ordinary app updates.
  static const String _storageKey =
      'brain_age_badges_unlocked_v2';

  static const String _baselineKey =
      'brain_age_achievements_baseline_v2';

  // Old unlocks were calculated from lifetime history.
  // They must not be migrated into the new system.
  static const String _legacyStorageKey =
      'brain_age_badges_unlocked_v1';

  static const Color purple = Color(0xFFB78AFF);
  static const Color gold = Color(0xFFFFC75D);
  static const Color cyan = Color(0xFF42D9D0);
  static const Color green = Color(0xFF4BE09D);
  static const Color pink = Color(0xFFFF84BC);

  static const List<BrainBadge> all = [
    BrainBadge(
      id: 'first_check',
      title: 'First Check',
      description: 'Complete your first Daily Brain Check.',
      icon: Icons.psychology_rounded,
      color: purple,
      target: 1,
      metric: 'checks',
    ),
    BrainBadge(
      id: 'streak_3',
      title: 'On Fire',
      description: 'Reach a 3-day Daily Brain Check streak.',
      icon: Icons.local_fire_department_rounded,
      color: gold,
      target: 3,
      metric: 'streak',
    ),
    BrainBadge(
      id: 'streak_7',
      title: 'Week Warrior',
      description: 'Reach a 7-day streak.',
      icon: Icons.emoji_events_rounded,
      color: gold,
      target: 7,
      metric: 'streak',
    ),
    BrainBadge(
      id: 'streak_30',
      title: 'Streak Legend',
      description: 'Reach a 30-day streak.',
      icon: Icons.workspace_premium_rounded,
      color: gold,
      target: 30,
      metric: 'streak',
    ),
    BrainBadge(
      id: 'checks_10',
      title: 'Brain Regular',
      description: 'Complete 10 daily checks.',
      icon: Icons.star_rounded,
      color: purple,
      target: 10,
      metric: 'checks',
    ),
    BrainBadge(
      id: 'checks_50',
      title: 'Dedicated Mind',
      description: 'Complete 50 daily checks.',
      icon: Icons.diamond_rounded,
      color: cyan,
      target: 50,
      metric: 'checks',
    ),
    BrainBadge(
      id: 'checks_100',
      title: 'Century Club',
      description: 'Complete 100 daily checks.',
      icon: Icons.military_tech_rounded,
      color: gold,
      target: 100,
      metric: 'checks',
    ),
    BrainBadge(
      id: 'perfect_game',
      title: 'Perfect Game',
      description: 'Finish a mini-game with at least '
          '5 correct answers and 100% accuracy.',
      icon: Icons.track_changes_rounded,
      color: green,
      target: 1,
      metric: 'perfect',
    ),
    BrainBadge(
      id: 'speed_star',
      title: 'Speed Star',
      description: 'Complete a mini-game with at least '
          '5 correct answers and an average response '
          'time below 2 seconds.',
      icon: Icons.bolt_rounded,
      color: gold,
      target: 1,
      metric: 'speed',
    ),
    BrainBadge(
      id: 'puzzle_pro',
      title: 'Puzzle Pro',
      description: 'Score 10 or more in Pattern Logic '
          'or Sudoku in a daily check.',
      icon: Icons.extension_rounded,
      color: purple,
      target: 10,
      metric: 'puzzle',
    ),
    BrainBadge(
      id: 'word_master',
      title: 'Word Master',
      description: 'Score 10 or more in any word game.',
      icon: Icons.menu_book_rounded,
      color: pink,
      target: 10,
      metric: 'words',
    ),
    BrainBadge(
      id: 'maths_master',
      title: 'Maths Master',
      description: 'Score 10 or more in Quick Math.',
      icon: Icons.calculate_rounded,
      color: gold,
      target: 10,
      metric: 'maths',
    ),
    BrainBadge(
      id: 'biology_buff',
      title: 'Biology Buff',
      description: 'Score 10 or more in Biology Quiz.',
      icon: Icons.eco_rounded,
      color: green,
      target: 10,
      metric: 'biology',
    ),
    BrainBadge(
      id: 'science_star',
      title: 'Science Star',
      description: 'Score 10 or more in Science Quiz.',
      icon: Icons.science_rounded,
      color: cyan,
      target: 10,
      metric: 'science',
    ),
    BrainBadge(
      id: 'memory_master',
      title: 'Memory Master',
      description: 'Score 5 or more in Memory Grid '
          'or Order Recall.',
      icon: Icons.grid_view_rounded,
      color: purple,
      target: 5,
      metric: 'memory',
    ),
    BrainBadge(
      id: 'new_best',
      title: 'New Personal Best',
      description: 'Beat your previous highest daily score.',
      icon: Icons.trending_up_rounded,
      color: green,
      target: 1,
      metric: 'improvement',
    ),
    BrainBadge(
      id: 'all_rounder',
      title: 'All-Rounder',
      description: 'Complete 10 different game types '
          'across your daily checks.',
      icon: Icons.auto_awesome_rounded,
      color: cyan,
      target: 10,
      metric: 'unique_games',
    ),
    BrainBadge(
      id: 'comeback',
      title: 'Comeback Kid',
      description: 'Return and complete a daily check '
          'after a break of at least 7 days.',
      icon: Icons.restart_alt_rounded,
      color: pink,
      target: 1,
      metric: 'comeback',
    ),
    BrainBadge(
      id: 'five_days',
      title: 'Getting Consistent',
      description: 'Complete checks on 5 different days.',
      icon: Icons.calendar_month_rounded,
      color: green,
      target: 5,
      metric: 'unique_days',
    ),
    BrainBadge(
      id: 'champion',
      title: 'Brain Champion',
      description: 'Earn a total of 75 correct answers '
          'across daily challenges.',
      icon: Icons.emoji_events_rounded,
      color: gold,
      target: 75,
      metric: 'correct',
    ),
  ];

  static DateTime _day(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static int _maxScore(
    List<GameResult> games,
    Set<String> ids,
  ) {
    int best = 0;

    for (final game in games) {
      if (ids.contains(game.gameId) &&
          game.score > best) {
        best = game.score;
      }
    }

    return best;
  }

  // Count consecutive days using only sessions
  // completed after the achievement baseline.
  static int _longestEligibleStreak(
    List<DateTime> dates,
  ) {
    if (dates.isEmpty) return 0;

    int longest = 1;
    int current = 1;

    for (int i = 1; i < dates.length; i++) {
      final difference =
          dates[i].difference(dates[i - 1]).inDays;

      if (difference == 1) {
        current++;
      } else {
        current = 1;
      }

      if (current > longest) {
        longest = current;
      }
    }

    return longest;
  }

  static Map<String, int> _metrics(
    List<DailySessionResult> sessions,
    DateTime baseline,
  ) {
    // Only activity after activation is eligible.
    final eligible = sessions
        .where(
          (session) =>
              session.completedAt.isAfter(baseline),
        )
        .toList()
      ..sort(
        (a, b) =>
            a.completedAt.compareTo(b.completedAt),
      );

    final games = eligible
        .expand((session) => session.gameResults)
        .toList();

    final dates = eligible
        .map((session) => _day(session.completedAt))
        .toSet()
        .toList()
      ..sort();

    final streak = _longestEligibleStreak(dates);

    // Comeback requires two eligible daily checks
    // separated by at least seven missed days.
    int comeback = 0;

    for (int i = 1; i < dates.length; i++) {
      final gap =
          dates[i].difference(dates[i - 1]).inDays;

      if (gap >= 8) {
        comeback = 1;
        break;
      }
    }

    // Personal best requires beating a score earned
    // after achievement tracking began.
    int improvement = 0;
    int? previousBest;

    for (final session in eligible) {
      if (previousBest != null &&
          session.totalScore > previousBest) {
        improvement = 1;
      }

      if (previousBest == null ||
          session.totalScore > previousBest) {
        previousBest = session.totalScore;
      }
    }

    final perfect = games.any(
      (game) =>
          game.attempts >= 5 &&
          game.correct == game.attempts,
    );

    final fast = games.any(
      (game) =>
          game.correct >= 5 &&
          game.averageResponseTimeMs > 0 &&
          game.averageResponseTimeMs < 2000,
    );

    final types =
        games.map((game) => game.gameId).toSet();

    return {
      'checks': dates.length,
      'streak': streak,
      'perfect': perfect ? 1 : 0,
      'speed': fast ? 1 : 0,
      'puzzle': _maxScore(games, {
        GameIds.patternLogic,
        GameIds.sudoku,
      }),
      'words': _maxScore(games, {
        GameIds.wordSnap,
        GameIds.wordScramble,
        GameIds.antonyms,
      }),
      'maths': _maxScore(
        games,
        {GameIds.quickMath},
      ),
      'biology': _maxScore(
        games,
        {GameIds.biologyQuiz},
      ),
      'science': _maxScore(
        games,
        {GameIds.scienceQuiz},
      ),
      'memory': _maxScore(games, {
        GameIds.memoryGrid,
        GameIds.orderRecall,
      }),
      'improvement': improvement,
      'unique_games': types.length,
      'comeback': comeback,
      'unique_days': dates.length,
      'correct': eligible.fold<int>(
        0,
        (sum, session) =>
            sum + session.totalCorrect,
      ),
    };
  }

  // Create the baseline once per installation.
  //
  // Future app updates will reuse the same date.
  static Future<DateTime> _getBaseline(
    SharedPreferences prefs,
  ) async {
    final existing = prefs.getString(_baselineKey);

    if (existing != null) {
      final parsed = DateTime.tryParse(existing);

      if (parsed != null) {
        return parsed;
      }
    }

    final now = DateTime.now();

    final saved = await prefs.setString(
      _baselineKey,
      now.toIso8601String(),
    );

    if (!saved) {
      throw StateError(
        'Achievement baseline could not be saved.',
      );
    }

    // Discard incorrectly calculated V1 unlocks.
    // Do not touch any gameplay history.
    await prefs.remove(_legacyStorageKey);

    return now;
  }

  static Future<AchievementUpdate> refresh() async {
    final prefs =
        await SharedPreferences.getInstance();

    // Initialise baseline before reading gameplay
    // history, preventing historical unlocks.
    final baseline = await _getBaseline(prefs);

    final sessions =
        await StatsService.getDailySessions();

    Map<String, dynamic> stored = {};

    try {
      final raw = prefs.getString(_storageKey);

      if (raw != null) {
        final decoded = jsonDecode(raw);

        if (decoded is Map) {
          stored = Map<String, dynamic>.from(decoded);
        }
      }
    } catch (error) {
      debugPrint(
        'Achievement storage read error: $error',
      );
    }

    final metrics = _metrics(sessions, baseline);

    final newIds = <String>[];
    final now = DateTime.now().toIso8601String();

    for (final badge in all) {
      final value = metrics[badge.metric] ?? 0;

      if (value >= badge.target &&
          !stored.containsKey(badge.id)) {
        stored[badge.id] = now;
        newIds.add(badge.id);
      }
    }

    if (newIds.isNotEmpty) {
      final saved = await prefs.setString(
        _storageKey,
        jsonEncode(stored),
      );

      if (!saved) {
        throw StateError(
          'Achievement unlocks could not be saved.',
        );
      }

      // Award XP only for badges newly unlocked on this refresh.
      // Stable event IDs prevent duplicate XP if refresh runs again.
      for (final badgeId in newIds) {
        try {
          await PlayerXpService.award(
            eventId: 'achievement:$badgeId',
            xp: PlayerXpService.achievementXp,
          );
        } catch (error) {
          debugPrint('Achievement XP award failed for $badgeId: $error');
        }
      }
    }

    final badges = all.map((badge) {
      final dateText = stored[badge.id]?.toString();

      final unlockedAt = dateText == null
          ? null
          : DateTime.tryParse(dateText);

      return BadgeProgress(
        badge: badge,
        value: metrics[badge.metric] ?? 0,
        unlockedAt: unlockedAt,
      );
    }).toList();

    final newlyUnlocked = badges
        .where(
          (badge) =>
              newIds.contains(badge.badge.id),
        )
        .toList();

    return AchievementUpdate(
      badges: badges,
      newlyUnlocked: newlyUnlocked,
    );
  }
}
