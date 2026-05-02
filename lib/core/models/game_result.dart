class GameResult {
  final String gameId;
  final int score;
  final int correct;
  final int attempts;
  final double averageResponseTimeMs;
  final DateTime playedAt;

  const GameResult({
    required this.gameId,
    required this.score,
    required this.correct,
    required this.attempts,
    required this.averageResponseTimeMs,
    required this.playedAt,
  });

  double get accuracy => attempts == 0 ? 0 : correct / attempts;

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'score': score,
      'correct': correct,
      'attempts': attempts,
      'averageResponseTimeMs': averageResponseTimeMs,
      'playedAt': playedAt.toIso8601String(),
    };
  }

  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      gameId: json['gameId'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      correct: json['correct'] as int? ?? 0,
      attempts: json['attempts'] as int? ?? 0,
      averageResponseTimeMs:
          (json['averageResponseTimeMs'] as num?)?.toDouble() ?? 0,
      playedAt: DateTime.tryParse(json['playedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}