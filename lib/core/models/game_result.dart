class QuestionResult {
  final String gameId;
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;

  const QuestionResult({
    required this.gameId,
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'question': question,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
    };
  }

  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      gameId: json['gameId'] as String? ?? '',
      question: json['question'] as String? ?? '',
      userAnswer: json['userAnswer'] as String? ?? '',
      correctAnswer: json['correctAnswer'] as String? ?? '',
      isCorrect: json['isCorrect'] as bool? ?? false,
    );
  }
}

class GameResult {
  final String gameId;
  final int score;
  final int correct;
  final int attempts;
  final double averageResponseTimeMs;
  final DateTime playedAt;
  final List<QuestionResult> questionResults;

  const GameResult({
    required this.gameId,
    required this.score,
    required this.correct,
    required this.attempts,
    required this.averageResponseTimeMs,
    required this.playedAt,
    this.questionResults = const <QuestionResult>[],
  });

  double get accuracy {
    if (attempts <= 0) return 0;
    return correct / attempts;
  }

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'score': score,
      'correct': correct,
      'attempts': attempts,
      'averageResponseTimeMs': averageResponseTimeMs,
      'playedAt': playedAt.toIso8601String(),
      'questionResults':
          questionResults.map((result) => result.toJson()).toList(),
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
      questionResults: (json['questionResults'] as List<dynamic>? ?? [])
          .map((item) => QuestionResult.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
    );
  }
}