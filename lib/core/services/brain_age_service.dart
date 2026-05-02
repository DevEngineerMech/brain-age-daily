class BrainAgeService {
  static int calculate({
    required double accuracy,
    required double responseTime,
    required int score,
  }) {
    int age = 40;

    if (accuracy >= 0.9) {
      age -= 8;
    } else if (accuracy >= 0.75) {
      age -= 5;
    } else if (accuracy < 0.5) {
      age += 6;
    }

    if (responseTime <= 1500) {
      age -= 6;
    } else if (responseTime <= 2500) {
      age -= 3;
    } else if (responseTime > 4000) {
      age += 5;
    }

    if (score >= 100) {
      age -= 6;
    } else if (score >= 60) {
      age -= 3;
    } else if (score < 20) {
      age += 4;
    }

    if (age < 18) age = 18;
    if (age > 80) age = 80;

    return age;
  }
}