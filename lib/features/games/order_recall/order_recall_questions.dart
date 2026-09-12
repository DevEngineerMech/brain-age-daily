class OrderRecallQuestion {
  final List<int> shown;
  final List<int> answer;

  const OrderRecallQuestion({
    required this.shown,
    required this.answer,
  });
}

class OrderRecallQuestions {
  static final List<OrderRecallQuestion> all = _buildAll();

  static List<OrderRecallQuestion> _buildAll() {
    final List<OrderRecallQuestion> questions = <OrderRecallQuestion>[];

    final List<List<int>> sets = <List<int>>[
      <int>[1, 3, 11, 14, 21],
      <int>[4, 8, 13, 19, 25],
      <int>[2, 7, 12, 18, 24],
      <int>[5, 9, 16, 22, 28],
      <int>[6, 10, 15, 23, 30],
      <int>[3, 8, 17, 20, 27],
      <int>[7, 11, 14, 26, 31],
      <int>[9, 13, 18, 21, 29],
      <int>[4, 12, 16, 25, 33],
      <int>[6, 15, 19, 24, 32],
      <int>[10, 14, 21, 28, 35],
      <int>[8, 16, 22, 27, 36],
      <int>[11, 18, 23, 31, 39],
      <int>[12, 20, 26, 34, 41],
      <int>[13, 17, 29, 37, 42],
      <int>[15, 24, 30, 38, 45],
      <int>[16, 25, 33, 40, 48],
      <int>[18, 27, 35, 43, 50],
      <int>[19, 28, 36, 44, 52],
      <int>[21, 30, 39, 47, 55],
      <int>[22, 31, 41, 49, 58],
      <int>[24, 33, 42, 51, 60],
      <int>[25, 35, 44, 53, 62],
      <int>[27, 37, 46, 56, 65],
      <int>[29, 38, 48, 57, 67],
      <int>[31, 40, 50, 59, 69],
      <int>[33, 43, 52, 61, 72],
      <int>[35, 45, 55, 64, 75],
      <int>[37, 47, 58, 66, 78],
      <int>[39, 49, 60, 70, 81],
    ];

    for (final List<int> set in sets) {
      questions.add(
        OrderRecallQuestion(
          shown: List<int>.from(set),
          answer: List<int>.from(set),
        ),
      );
    }

    return questions;
  }
}