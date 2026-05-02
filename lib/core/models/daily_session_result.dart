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

  double get averageResponseTime {
    if (gameResults.isEmpty) return 0;
    final total = gameResults
        .map((e) => e.averageResponseTimeMs)
        .fold<double>(0, (a, b) => a + b);
    return total / gameResults.length;
  }

  double get averageAccuracy {
    if (gameResults.isEmpty) return 0;
    final total =
        gameResults.map((e) => e.accuracy).fold<double>(0, (a, b) => a + b);
    return total / gameResults.length;
  }

  int get totalScore =>
      gameResults.map((e) => e.score).fold<int>(0, (a, b) => a + b);

  Map<String, dynamic> toJson() {
    return {
      'gameResults': gameResults.map((e) => e.toJson()).toList(),
      'brainAge': brainAge,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory DailySessionResult.fromJson(Map<String, dynamic> json) {
    final rawResults = (json['gameResults'] as List?) ?? const [];
    return DailySessionResult(
      gameResults: rawResults
          .map((e) => GameResult.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      brainAge: json['brainAge'] as int? ?? 40,
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}