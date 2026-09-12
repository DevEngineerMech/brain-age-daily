import 'dart:math';

class PatternLogicQuestion {
  final String sequence;
  final List<String> options;
  final String answer;

  PatternLogicQuestion({
    required this.sequence,
    required this.options,
    required this.answer,
  });

  static final Random _random = Random();

  static PatternLogicQuestion generate() {
    int start = _random.nextInt(20);
    int step = (_random.nextInt(3) + 1) * 2;

    List<int> seq = List.generate(4, (i) => start + (i * step));
    int correct = start + (4 * step);

    List<String> options = [
      correct.toString(),
      (correct + 1).toString(),
      (correct - 1).toString(),
      (correct + 2).toString(),
    ];

    options.shuffle(); // FIX

    return PatternLogicQuestion(
      sequence: '${seq.join('  ')}  ?',
      options: options,
      answer: correct.toString(),
    );
  }
}