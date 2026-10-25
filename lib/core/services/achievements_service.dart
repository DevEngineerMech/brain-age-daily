
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/game_ids.dart';
import '../models/daily_session_result.dart';
import '../models/game_result.dart';
import 'stats_service.dart';

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
  static const String _storageKey =
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

  static DateTime _day(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  static int _maxScore(
    List<GameResult> games,
    Set<String> ids,
  ) {
    int best = 0;
    for (final g in games) {
      if (ids.contains(g.gameId) && g.score > best) {
        best = g.score;
      }
    }
    return best;
  }

  static Map<String, int> _metrics(
    List<DailySessionResult> sessions,
    int longestStreak,
  ) {
    final games = sessions
        .expand((s) => s.gameResults)
        .toList();

    final dates = sessions
        .map((s) => _day(s.completedAt))
        .toSet()
        .toList()
      ..sort();

    int comeback = 0;
    for (int i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays >= 8) {
        comeback = 1;
        break;
      }
    }

    int improvement = 0;
    int bestBefore = -1;
    final ordered = sessions.toList()
      ..sort((a, b) =>
          a.completedAt.compareTo(b.completedAt));

    for (final session in ordered) {
      if (bestBefore >= 0 &&
          session.totalScore > bestBefore) {
        improvement = 1;
      }
      if (session.totalScore > bestBefore) {
        bestBefore = session.totalScore;
      }
    }

    final perfect = games.any(
      (g) => g.attempts >= 5 &&
          g.correct == g.attempts,
    );

    final fast = games.any(
      (g) => g.correct >= 5 &&
          g.averageResponseTimeMs > 0 &&
          g.averageResponseTimeMs < 2000,
    );

    final types = games.map((g) => g.gameId).toSet();

    return {
      'checks': dates.length,
      'streak': longestStreak,
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
      'maths': _maxScore(games, {GameIds.quickMath}),
      'biology': _maxScore(games, {GameIds.biologyQuiz}),
      'science': _maxScore(games, {GameIds.scienceQuiz}),
      'memory': _maxScore(games, {
        GameIds.memoryGrid,
        GameIds.orderRecall,
      }),
      'improvement': improvement,
      'unique_games': types.length,
      'comeback': comeback,
      'unique_days': dates.length,
      'correct': sessions.fold<int>(
        0,
        (sum, s) => sum + s.totalCorrect,
      ),
    };
  }

  static Future<AchievementUpdate> refresh() async {
    final prefs = await SharedPreferences.getInstance();

    final sessions = await StatsService.getDailySessions();
    final longestStreak =
        await StatsService.getLongestStreak();

    Map<String, dynamic> stored = {};
    try {
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        stored = Map<String, dynamic>.from(jsonDecode(raw));
      }
    } catch (_) {
      stored = {};
    }

    final metrics = _metrics(sessions, longestStreak);
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
      await prefs.setString(_storageKey, jsonEncode(stored));
    }

    final badges = all.map((badge) {
      final dateText = stored[badge.id]?.toString();
      return BadgeProgress(
        badge: badge,
        value: metrics[badge.metric] ?? 0,
        unlockedAt: dateText == null
            ? null
            : DateTime.tryParse(dateText),
      );
    }).toList();

    return AchievementUpdate(
      badges: badges,
      newlyUnlocked: badges
          .where((b) => newIds.contains(b.badge.id))
          .toList(),
    );
  }
}
