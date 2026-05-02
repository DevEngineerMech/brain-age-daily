class QuickMathQuestion {
  final String text;
  final int answer;

  const QuickMathQuestion({
    required this.text,
    required this.answer,
  });
}

class QuickMathQuestions {
  static final List<QuickMathQuestion> all = _buildAll();

  static List<QuickMathQuestion> _buildAll() {
    final List<QuickMathQuestion> questions = <QuickMathQuestion>[];

    for (int a = 6; a <= 20; a++) {
      for (int b = 3; b <= 10; b++) {
        questions.add(
          QuickMathQuestion(
            text: '$a + $b',
            answer: a + b,
          ),
        );
      }
    }

    for (int a = 18; a <= 40; a++) {
      for (int b = 2; b <= 9; b++) {
        if (a - b >= 0) {
          questions.add(
            QuickMathQuestion(
              text: '$a - $b',
              answer: a - b,
            ),
          );
        }
      }
    }

    for (int a = 2; a <= 12; a++) {
      for (int b = 2; b <= 12; b++) {
        questions.add(
          QuickMathQuestion(
            text: '$a × $b',
            answer: a * b,
          ),
        );
      }
    }

    for (int b = 2; b <= 12; b++) {
      for (int answer = 2; answer <= 12; answer++) {
        final int dividend = b * answer;
        questions.add(
          QuickMathQuestion(
            text: '$dividend ÷ $b',
            answer: answer,
          ),
        );
      }
    }

    return questions;
  }
}