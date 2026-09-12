import 'dart:math';

class BrainAgeService {
  static int calculate({
    required double accuracy,
    required double responseTime,
    required int score,
    int chronologicalAge = 40,
  }) {
    final int realAge = chronologicalAge.clamp(13, 90).toInt();

    int adjustment = 0;

    // Accuracy impact
    if (accuracy >= 0.95) {
      adjustment -= 15;
    } else if (accuracy >= 0.85) {
      adjustment -= 10;
    } else if (accuracy >= 0.75) {
      adjustment -= 5;
    } else if (accuracy >= 0.60) {
      adjustment += 5;
    } else if (accuracy >= 0.40) {
      adjustment += 15;
    } else {
      adjustment += 25;
    }

    // Response time impact
    if (responseTime <= 1200) {
      adjustment -= 8;
    } else if (responseTime <= 2000) {
      adjustment -= 5;
    } else if (responseTime <= 3000) {
      adjustment -= 2;
    } else if (responseTime <= 5000) {
      adjustment += 5;
    } else {
      adjustment += 10;
    }

    // Score impact
    if (score >= 60) {
      adjustment -= 15;
    } else if (score >= 45) {
      adjustment -= 10;
    } else if (score >= 30) {
      adjustment -= 5;
    } else if (score >= 20) {
      adjustment += 5;
    } else if (score >= 10) {
      adjustment += 15;
    } else {
      adjustment += 40;
    }

    return (realAge + adjustment).clamp(18, 100).toInt();
  }

  static String expectedRangeForAge(int chronologicalAge) {
    final int realAge = chronologicalAge.clamp(13, 90).toInt();

    final int low = max(18, realAge - 5);
    final int high = min(90, realAge + 5);

    return '$low-$high';
  }

  static String comparisonText({
    required int chronologicalAge,
    required int brainAge,
  }) {
    final int difference = chronologicalAge - brainAge;

    if (difference >= 3) {
      return 'You performed like someone $difference years younger.';
    }

    if (difference <= -3) {
      return 'Your result was ${difference.abs()} years above your age today.';
    }

    return 'Your result is close to your age range.';
  }
}