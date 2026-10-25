
import 'dart:math';

import '../constants/game_ids.dart';
import '../models/daily_session_result.dart';
import 'daily_missions_bank.dart';

class MissionPlan {
  final String id;
  final String title;
  final String description;
  final String metric;
  final int target;
  final int reward;
  final int threshold;
  final String? gameId;

  const MissionPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.metric,
    required this.target,
    required this.reward,
    this.threshold = 0,
    this.gameId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'metric': metric,
        'target': target,
        'reward': reward,
        'threshold': threshold,
        'gameId': gameId,
      };

  factory MissionPlan.fromJson(Map<String, dynamic> json) {
    return MissionPlan(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      metric: json['metric']?.toString() ?? '',
      target: (json['target'] as num?)?.toInt() ?? 1,
      reward: (json['reward'] as num?)?.toInt() ?? 30,
      threshold: (json['threshold'] as num?)?.toInt() ?? 0,
      gameId: json['gameId']?.toString(),
    );
  }
}

class DailyMissionsGenerator {
  DailyMissionsGenerator._();

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day;

  static MissionPlan? _prepare(
    MissionDefinition definition,
    List<DailySessionResult> history,
    DateTime today,
  ) {
    final metric = definition.metric;

    final previous = history
        .where((s) => !_sameDay(s.completedAt, today))
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    final recent = previous.take(14).toList();

    int threshold = 0;
    String? gameId = definition.gameId;
    String description = definition.description;

    if (metric == 'improve_score' ||
        metric == 'improve_accuracy' ||
        metric == 'improve_speed' ||
        metric == 'improve_age' ||
        metric == 'recent_score' ||
        metric == 'recent_accuracy') {
      if (recent.isEmpty) return null;

      final last = recent.first;

      switch (metric) {
        case 'improve_score':
          threshold = last.totalScore + 1;
          description =
              'Score at least $threshold in a daily check.';
          break;

        case 'improve_accuracy':
          threshold =
              ((last.averageAccuracy * 100).floor() + 1)
                  .clamp(1, 100);
          if (threshold > 95) return null;
          description =
              'Reach at least $threshold% accuracy in '
              'a daily check.';
          break;

        case 'improve_speed':
          if (last.averageResponseTime <= 0) return null;
          threshold =
              (last.averageResponseTime * 0.95).round();
          if (threshold < 350) return null;
          description =
              'Average under ${(threshold / 1000).toStringAsFixed(2)} '
              'seconds in a daily check.';
          break;

        case 'improve_age':
          if (last.brainAge <= 18) return null;
          threshold = last.brainAge - 1;
          description =
              'Reach a brain age of $threshold or lower.';
          break;

        case 'recent_score':
          final average = recent
                  .map((s) => s.totalScore)
                  .reduce((a, b) => a + b) /
              recent.length;
          threshold = max(1, (average * 0.90).ceil());
          description =
              'Score at least $threshold in a daily check.';
          break;

        case 'recent_accuracy':
          final average = recent
                  .map((s) => s.averageAccuracy)
                  .reduce((a, b) => a + b) /
              recent.length;
          threshold = (average * 100).round().clamp(40, 95);
          description =
              'Reach at least $threshold% accuracy in '
              'a daily check.';
          break;
      }
    }

    if (metric == 'weak_visits' ||
        metric == 'strong_visits') {
      final results = recent.expand((s) => s.gameResults);
      final perGame = <String, List<double>>{};

      for (final result in results) {
        if (result.attempts < 1) continue;
        perGame.putIfAbsent(result.gameId, () => []);
        perGame[result.gameId]!.add(result.accuracy);
      }

      // Require at least two observations for comparison.
      final reliable = <String, double>{};

      for (final entry in perGame.entries) {
        if (entry.value.length >= 2 &&
            GameIds.all.contains(entry.key)) {
          reliable[entry.key] =
              entry.value.reduce((a, b) => a + b) /
                  entry.value.length;
        }
      }

      if (reliable.length < 2) return null;

      final sorted = reliable.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      gameId = metric == 'weak_visits'
          ? sorted.first.key
          : sorted.last.key;

      description =
          'Complete ${GameIds.label(gameId)} '
          '${definition.target} '
          '${definition.target == 1 ? 'time' : 'times'} '
          'in Free Play.';
    }

    if (metric == 'streak') {
      final completedDays = history
          .map((s) => DateTime(
                s.completedAt.year,
                s.completedAt.month,
                s.completedAt.day,
              ))
          .toSet();

      final yesterday = DateTime(
        today.year,
        today.month,
        today.day - 1,
      );

      int previousStreak = 0;
      var check = yesterday;

      while (completedDays.contains(check)) {
        previousStreak++;
        check = check.subtract(const Duration(days: 1));
      }

      // The next daily completion must be able to
      // reach the target; don't assign distant streaks.
      if (previousStreak != definition.target - 1) {
        return null;
      }
    }

    // Avoid very demanding result targets for players
    // who have never completed a Daily Brain Check.
    if (recent.isEmpty &&
        definition.tier == MissionTier.challenge &&
        !{
          'visits',
          'unique_visits',
          'game_visits',
        }.contains(metric)) {
      return null;
    }

    return MissionPlan(
      id: definition.id,
      title: definition.title,
      description: description,
      metric: metric,
      target: definition.target,
      reward: definition.reward,
      threshold: threshold,
      gameId: gameId,
    );
  }

  static List<MissionPlan> generate({
    required List<DailySessionResult> history,
    required DateTime date,
    required Set<String> recentlyUsedIds,
  }) {
    final rng = Random(
      date.year * 10000 + date.month * 100 + date.day,
    );

    final prepared = DailyMissionsBank.all
        .map((d) => (
              definition: d,
              plan: _prepare(d, history, date),
            ))
        .where((item) => item.plan != null)
        .toList();

    final chosen = <MissionPlan>[];

    bool conflicts(MissionPlan item) {
      return chosen.any((c) {
        if (c.id == item.id) return true;

        // Avoid doubling the exact same game visit.
        if (item.gameId != null &&
            c.gameId == item.gameId) {
          return true;
        }

        // Avoid two very similar global targets.
        return item.metric == c.metric;
      });
    }

    MissionPlan? choose(
      MissionTier tier, {
      bool allowRecent = false,
    }) {
      final candidates = prepared
          .where((item) =>
              item.definition.tier == tier &&
              (allowRecent ||
                  !recentlyUsedIds.contains(item.plan!.id)) &&
              !conflicts(item.plan!))
          .map((item) => item.plan!)
          .toList()
        ..shuffle(rng);

      return candidates.isEmpty ? null : candidates.first;
    }

    // Always start with something approachable.
    final easy = choose(MissionTier.easy) ??
        choose(MissionTier.easy, allowRecent: true);

    if (easy != null) chosen.add(easy);

    // Prefer a true adaptive mission where enough
    // historical data is available.
    final personal = choose(MissionTier.personal) ??
        choose(MissionTier.personal, allowRecent: true);

    if (personal != null) chosen.add(personal);

    final challenge = choose(MissionTier.challenge) ??
        choose(MissionTier.challenge, allowRecent: true);

    if (challenge != null) chosen.add(challenge);

    // New players may have too little data for a
    // personalised target. Fill remaining slots with
    // real, trackable missions rather than dummy ones.
    while (chosen.length < 3) {
      final candidates = prepared
          .map((item) => item.plan!)
          .where((plan) =>
              !conflicts(plan) &&
              !recentlyUsedIds.contains(plan.id))
          .toList()
        ..shuffle(rng);

      if (candidates.isEmpty) {
        final fallback = prepared
            .map((item) => item.plan!)
            .where((plan) => !conflicts(plan))
            .toList()
          ..shuffle(rng);

        if (fallback.isEmpty) break;
        chosen.add(fallback.first);
      } else {
        chosen.add(candidates.first);
      }
    }

    return chosen.take(3).toList();
  }
}
