class TimeDifferenceQuestion {
  final String from;
  final String to;
  final int minutes;

  const TimeDifferenceQuestion({
    required this.from,
    required this.to,
    required this.minutes,
  });
}

class TimeDifferenceQuestions {
  static final List<TimeDifferenceQuestion> all = _buildAll();

  static List<TimeDifferenceQuestion> _buildAll() {
    final List<TimeDifferenceQuestion> questions = <TimeDifferenceQuestion>[];
    final List<int> durations = <int>[
      15,
      20,
      25,
      30,
      35,
      40,
      45,
      50,
      55,
      60,
      75,
      90,
    ];

    for (int hour = 6; hour <= 20; hour++) {
      for (final int startMinute in <int>[0, 5, 10, 15, 20, 25, 30, 35]) {
        for (final int duration in durations) {
          final int startTotal = hour * 60 + startMinute;
          final int endTotal = startTotal + duration;

          if (endTotal >= 24 * 60) {
            continue;
          }

          questions.add(
            TimeDifferenceQuestion(
              from: _formatMinutes(startTotal),
              to: _formatMinutes(endTotal),
              minutes: duration,
            ),
          );

          if (questions.length >= 180) {
            return questions;
          }
        }
      }
    }

    return questions;
  }

  static String _formatMinutes(int totalMinutes) {
    final int hour = totalMinutes ~/ 60;
    final int minute = totalMinutes % 60;

    final String hh = hour.toString().padLeft(2, '0');
    final String mm = minute.toString().padLeft(2, '0');

    return '$hh:$mm';
  }
}