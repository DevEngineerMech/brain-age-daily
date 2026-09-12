class StoredStats {
  final int latestBrainAge;
  final int totalChecks;
  final int currentStreak;
  final List<int> brainAgeHistory;
  final List<double> responseTimeHistory;

  const StoredStats({
    required this.latestBrainAge,
    required this.totalChecks,
    required this.currentStreak,
    required this.brainAgeHistory,
    required this.responseTimeHistory,
  });

  factory StoredStats.empty() {
    return const StoredStats(
      latestBrainAge: 40,
      totalChecks: 0,
      currentStreak: 0,
      brainAgeHistory: [],
      responseTimeHistory: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latestBrainAge': latestBrainAge,
      'totalChecks': totalChecks,
      'currentStreak': currentStreak,
      'brainAgeHistory': brainAgeHistory,
      'responseTimeHistory': responseTimeHistory,
    };
  }

  factory StoredStats.fromJson(Map<String, dynamic> json) {
    return StoredStats(
      latestBrainAge: json['latestBrainAge'] as int? ?? 40,
      totalChecks: json['totalChecks'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      brainAgeHistory:
          ((json['brainAgeHistory'] as List?) ?? const []).cast<int>(),
      responseTimeHistory: ((json['responseTimeHistory'] as List?) ?? const [])
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}