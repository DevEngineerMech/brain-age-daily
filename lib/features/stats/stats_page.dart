
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/game_ids.dart';
import '../../core/models/daily_session_result.dart';
import '../../core/models/game_result.dart';
import '../../core/services/stats_service.dart';
import '../../core/widgets/app_banner_ad.dart';

import 'individual_game_stats_page.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  static const Color background = Color(0xFF0C0929);
  static const Color panel = Color(0xFF1A1646);
  static const Color gold = Color(0xFFFFC75D);
  static const Color cyan = Color(0xFF42D9D0);
  static const Color purple = Color(0xFF9C70FF);
  static const Color muted = Color(0xFFC5B9DF);

  int latestBrainAge = 40;
  int totalChecks = 0;
  int currentStreak = 0;
  int longestStreak = 0;

  List<int> brainAgeHistory = [];
  List<double> responseTimeHistory = [];
  List<DailySessionResult> dailySessions = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final sessions = await StatsService.getDailySessions();
      final streak = await StatsService.getCurrentStreak();
      final longest = await StatsService.getLongestStreak();

      sessions.sort(
        (a, b) => b.completedAt.compareTo(a.completedAt),
      );

      if (!mounted) return;

      setState(() {
        dailySessions = sessions;
        totalChecks = sessions.length;
        currentStreak = streak;
        longestStreak = longest;
        latestBrainAge =
            sessions.isEmpty ? 40 : sessions.first.brainAge;

        final chronological = sessions.reversed.toList();

        brainAgeHistory = chronological
            .map((session) => session.brainAge)
            .toList();

        responseTimeHistory = chronological
            .map((session) =>
                session.averageResponseTime / 1000)
            .toList();

        loading = false;
      });
    } catch (error) {
      debugPrint('Progress loading error: $error');
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  String _date(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  DateTime _dayOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  bool _completedOn(DateTime date) {
    return dailySessions.any(
      (session) =>
          _dayOnly(session.completedAt) == _dayOnly(date),
    );
  }

  int get _bestBrainAge {
    if (dailySessions.isEmpty) return 0;
    return dailySessions
        .map((session) => session.brainAge)
        .reduce(math.min);
  }

  int get _bestDailyScore {
    if (dailySessions.isEmpty) return 0;
    return dailySessions
        .map((session) => session.totalScore)
        .reduce(math.max);
  }

  GameResult? _bestGame(DailySessionResult session) {
    if (session.gameResults.isEmpty) return null;
    return session.gameResults.reduce(
      (a, b) => a.score >= b.score ? a : b,
    );
  }

  GameResult? _weakestGame(DailySessionResult session) {
    if (session.gameResults.isEmpty) return null;
    return session.gameResults.reduce(
      (a, b) => a.score <= b.score ? a : b,
    );
  }

  BoxDecoration _decoration({Color? border}) {
    return BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(19),
      border: Border.all(
        color: border ?? const Color(0xFF53438A),
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 12,
          offset: Offset(0, 6),
        ),
      ],
    );
  }

  Widget _heading(String title, IconData icon,
      {Color color = gold}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 21),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _metric({
    required String label,
    required String value,
    required IconData icon,
    required Color accent,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 14,
        ),
        decoration: _decoration(
          border: accent.withOpacity(0.45),
        ),
        child: Column(
          children: [
            Icon(icon, color: accent, size: 23),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: muted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3D1B82),
            Color(0xFF22205B),
            Color(0xFF14204D),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF9A71EA),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x554D1EAC),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR BRAIN AGE',
                  style: TextStyle(
                    color: muted,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0,
                    end: latestBrainAge.toDouble(),
                  ),
                  duration: const Duration(milliseconds: 850),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return Text(
                      value.round().toString(),
                      style: const TextStyle(
                        color: gold,
                        fontSize: 71,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        shadows: [
                          Shadow(
                            color: Color(0x88FFB54B),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 9),
                Text(
                  totalChecks == 0
                      ? 'Complete a Daily Brain Check to begin'
                      : 'Keep training to build your history',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.psychology_rounded,
            size: 105,
            color: Color(0xFFC09BFF),
          ),
        ],
      ),
    );
  }

  Widget _graphCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required List<double> values,
    required String unit,
  }) {
    final recent = values.length <= 30
        ? values
        : values.sublist(values.length - 30);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _decoration(
        border: accent.withOpacity(0.55),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(title, icon, color: accent),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 16),
          if (recent.length < 2)
            SizedBox(
              height: 145,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.show_chart_rounded,
                      color: accent.withOpacity(0.6),
                      size: 33,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Complete at least 2 daily checks',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 165,
              width: double.infinity,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, animation, _) {
                  return CustomPaint(
                    painter: _ProgressLinePainter(
                      values: recent,
                      color: accent,
                      reveal: animation,
                    ),
                  );
                },
              ),
            ),
          if (recent.isNotEmpty) ...[
            const SizedBox(height: 11),
            Row(
              children: [
                Text(
                  'First: ${recent.first.toStringAsFixed(1)}$unit',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                Text(
                  'Latest: ${recent.last.toStringAsFixed(1)}$unit',
                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _activityCalendar() {
    final today = _dayOnly(DateTime.now());
    final start = today.subtract(const Duration(days: 6));

    const weekdays = [
      'M', 'T', 'W', 'T', 'F', 'S', 'S'
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _decoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(
            'Last 7 Days',
            Icons.calendar_month_rounded,
            color: purple,
          ),
          const SizedBox(height: 8),
          const Text(
            'Your completed Daily Brain Checks',
            style: TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: List.generate(7, (index) {
              final date = start.add(Duration(days: index));
              final done = _completedOn(date);
              final isToday = _dayOnly(date) == today;

              return Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    children: [
                      Text(
                        weekdays[date.weekday - 1],
                        style: const TextStyle(
                          color: muted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 7),
                      AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 250),
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: done
                              ? const Color(0xFF177E79)
                              : const Color(0xFF30255F),
                          border: Border.all(
                            color: isToday
                                ? gold
                                : done
                                    ? cyan
                                    : const Color(0xFF544385),
                          ),
                        ),
                        child: Center(
                          child: done
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 21,
                                )
                              : Text(
                                  '${date.day}',
                                  style: const TextStyle(
                                    color: muted,
                                    fontSize: 12,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(DailySessionResult session) {
    final best = _bestGame(session);
    final weakest = _weakestGame(session);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _decoration(),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          iconColor: gold,
          collapsedIconColor: muted,
          leading: Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF423079),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              '${session.brainAge}',
              style: const TextStyle(
                color: gold,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          title: Text(
            _date(session.completedAt),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            '${session.totalScore} pts • '
            '${(session.averageAccuracy * 100).round()}% accuracy',
            style: const TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
          children: [
            const Divider(color: Color(0xFF554386)),
            if (best != null)
              _historyLine(
                'Highest scoring',
                GameIds.label(best.gameId),
                cyan,
              ),
            if (weakest != null)
              _historyLine(
                'Lowest scoring',
                GameIds.label(weakest.gameId),
                gold,
              ),
            _historyLine(
              'Average response',
              '${(session.averageResponseTime / 1000).toStringAsFixed(2)}s',
              purple,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _historyLine(
      String label, String value, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 6,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _individualGameButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFB448F4),
            Color(0xFF633BF1),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x665F27D0),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    const IndividualGameStatsPage(),
              ),
            );
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insights_rounded,
                color: Colors.white,
              ),
              SizedBox(width: 9),
              Text(
                'Individual Game Stats',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(width: 9),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E104A),
              Color(0xFF080D2A),
              Color(0xFF100A2F),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: cyan,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: purple,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(
                            14, 10, 14, 25),
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  style: IconButton.styleFrom(
                                    backgroundColor: panel,
                                  ),
                                  icon: const Icon(
                                    Icons.arrow_back_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 9),
                                const Expanded(
                                  child: Text(
                                    'Your Progress',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.auto_graph_rounded,
                                  color: gold,
                                  size: 27,
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            _hero(),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _metric(
                                  label: 'Current streak',
                                  value: '$currentStreak',
                                  icon: Icons.local_fire_department,
                                  accent: gold,
                                ),
                                const SizedBox(width: 8),
                                _metric(
                                  label: 'Daily checks',
                                  value: '$totalChecks',
                                  icon: Icons.check_circle_rounded,
                                  accent: cyan,
                                ),
                                const SizedBox(width: 8),
                                _metric(
                                  label: 'Longest streak',
                                  value: '$longestStreak',
                                  icon: Icons.emoji_events_rounded,
                                  accent: purple,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _metric(
                                  label: 'Best brain age',
                                  value: totalChecks == 0
                                      ? '—'
                                      : '$_bestBrainAge',
                                  icon: Icons.psychology_rounded,
                                  accent: cyan,
                                ),
                                const SizedBox(width: 8),
                                _metric(
                                  label: 'Best daily score',
                                  value: totalChecks == 0
                                      ? '—'
                                      : '$_bestDailyScore',
                                  icon: Icons.workspace_premium_rounded,
                                  accent: gold,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _graphCard(
                              title: 'Brain Age History',
                              subtitle: 'Last 30 completed checks',
                              icon: Icons.show_chart_rounded,
                              accent: purple,
                              values: brainAgeHistory
                                  .map((e) => e.toDouble())
                                  .toList(),
                              unit: '',
                            ),
                            const SizedBox(height: 13),
                            _graphCard(
                              title: 'Response Times',
                              subtitle:
                                  'Average seconds per response',
                              icon: Icons.speed_rounded,
                              accent: cyan,
                              values: responseTimeHistory,
                              unit: 's',
                            ),
                            const SizedBox(height: 13),
                            _activityCalendar(),
                            const SizedBox(height: 18),
                            _heading(
                              'Recent Daily Checks',
                              Icons.history_rounded,
                            ),
                            const SizedBox(height: 12),
                            if (dailySessions.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(25),
                                decoration: _decoration(),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.psychology_rounded,
                                      color: purple,
                                      size: 43,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Your results will appear here',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Complete a Daily Brain Check '
                                      'to begin tracking your progress.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: muted),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ...dailySessions
                                  .take(10)
                                  .map(_historyCard),
                            const SizedBox(height: 17),
                            _individualGameButton(),
                          ],
                        ),
                      ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, 5),
                child: AppBannerAd(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressLinePainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final double reveal;

  const _ProgressLinePainter({
    required this.values,
    required this.color,
    required this.reveal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 ||
        size.width <= 0 ||
        size.height <= 0) {
      return;
    }

    final validValues = values
        .where((value) => value.isFinite)
        .toList();

    if (validValues.length < 2) return;

    final minValue = validValues.reduce(math.min);
    final maxValue = validValues.reduce(math.max);

    final range = math.max(1.0, maxValue - minValue);
    final low = minValue - range * 0.15;
    final high = maxValue + range * 0.15;

    final chartWidth = size.width - 16;
    final chartHeight = size.height - 24;

    final gridPaint = Paint()
      ..color = const Color(0xFF65558C).withOpacity(0.3)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = 9 + chartHeight * i / 4;
      canvas.drawLine(
        Offset(8, y),
        Offset(8 + chartWidth, y),
        gridPaint,
      );
    }

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < validValues.length; i++) {
      final x = 8 +
          chartWidth * i / (validValues.length - 1);

      final fraction =
          (validValues[i] - low) / (high - low);

      final y = 9 + chartHeight * (1 - fraction);
      points.add(Offset(x, y));
    }

    final lastVisible =
        ((points.length - 1) * reveal)
            .clamp(0.0, (points.length - 1).toDouble());

    final fullSegments = lastVisible.floor();

    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i <= fullSegments; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    if (fullSegments < points.length - 1) {
      final fraction = lastVisible - fullSegments;
      final a = points[fullSegments];
      final b = points[fullSegments + 1];

      path.lineTo(
        a.dx + (b.dx - a.dx) * fraction,
        a.dy + (b.dy - a.dy) * fraction,
      );
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, linePaint);

    if (reveal > 0.98) {
      final dotPaint = Paint()..color = color;
      canvas.drawCircle(points.last, 5, dotPaint);

      canvas.drawCircle(
        points.last,
        9,
        Paint()
          ..color = color.withOpacity(0.16),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressLinePainter oldDelegate) {
    return oldDelegate.reveal != reveal ||
        oldDelegate.values != values ||
        oldDelegate.color != color;
  }
}
