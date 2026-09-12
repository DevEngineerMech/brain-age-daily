import 'game_result.dart';

class DailySessionResult {
  final List<GameResult> gameResults;
  final int brainAge;
  final DateTime completedAt;

  const DailySessionResult({
    required this.gameResults,
    required this.brainAge,
    required this.completedAt,
  });

  int get totalScore {
    return gameResults.fold<int>(0, (total, result) => total + result.score);
  }

  int get totalCorrect {
    return gameResults.fold<int>(0, (total, result) => total + result.correct);
  }

  int get totalAttempts {
    return gameResults.fold<int>(0, (total, result) => total + result.attempts);
  }

  double get averageAccuracy {
    if (gameResults.isEmpty) return 0;

    return gameResults.fold<double>(
          0,
          (total, result) => total + result.accuracy,
        ) /
        gameResults.length;
  }

  double get averageResponseTime {
    if (gameResults.isEmpty) return 0;

    return gameResults.fold<double>(
          0,
          (total, result) => total + result.averageResponseTimeMs,
        ) /
        gameResults.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'gameResults': gameResults.map((result) => result.toJson()).toList(),
      'brainAge': brainAge,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory DailySessionResult.fromJson(Map<String, dynamic> json) {
    return DailySessionResult(
      gameResults: (json['gameResults'] as List<dynamic>? ?? [])
          .map((item) => GameResult.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      brainAge: json['brainAge'] as int? ?? 40,
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}