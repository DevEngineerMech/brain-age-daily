import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

enum _GraphTab {
  brainAge,
  responseTime,
}

class _StatsPageState extends State<StatsPage> {
  static const Color background = Color(0xFF0C0929);
  static const Color panel = Color(0xFF1A1646);
  static const Color gold = Color(0xFFFFC75D);
  static const Color cyan = Color(0xFF42D9D0);
  static const Color purple = Color(0xFF9C70FF);
  static const Color muted = Color(0xFFC5B9DF);
  static const Color pink = Color(0xFFE277FF);

  final ScrollController _scrollController =
      ScrollController();
  final GlobalKey _latestResultsKey = GlobalKey();

  int userAge = 25;
  int latestBrainAge = 40;
  int totalChecks = 0;
  int currentStreak = 0;
  int longestStreak = 0;

  List<int> brainAgeHistory = [];
  List<double> responseTimeHistory = [];
  List<DailySessionResult> dailySessions = [];

  DailySessionResult? latestSession;
  DailySessionResult? todaySession;

  bool loading = true;
  _GraphTab selectedGraph = _GraphTab.brainAge;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final sessions = await StatsService.getDailySessions();
      final streak = await StatsService.getCurrentStreak();
      final longest = await StatsService.getLongestStreak();
      final latest = await StatsService.getLatestSession();
      final today = await StatsService.getTodaySession();

      sessions.sort(
        (a, b) => b.completedAt.compareTo(a.completedAt),
      );

      if (!mounted) return;

      setState(() {
        userAge = prefs.getInt('user_age') ?? 25;
        dailySessions = sessions;
        totalChecks = sessions.length;
        currentStreak = streak;
        longestStreak = longest;
        latestSession = latest;
        todaySession = today;
        latestBrainAge =
            latest == null ? 40 : latest.brainAge;

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

  String _comparison(int brainAge) {
    final difference = userAge - brainAge;

    if (difference >= 3) {
      return 'Your result is $difference years below your actual age';
    }

    if (difference <= -3) {
      return 'Your result is ${difference.abs()} years above your actual age';
    }

    return 'Your result is close to your actual age';
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

  Widget _heading(
    String title,
    IconData icon, {
    Color color = gold,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
        ],
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                  duration: const Duration(
                    milliseconds: 850,
                  ),
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
                      : _comparison(latestBrainAge),
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
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.92, end: 1.0),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: const Icon(
              Icons.psychology_rounded,
              size: 105,
              color: Color(0xFFC09BFF),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _jumpToLatestResults() async {
    final context = _latestResultsKey.currentContext;
    if (context == null) return;

    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
      alignment: 0.05,
    );
  }

  Widget _latestResultButton() {
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
          onTap: _jumpToLatestResults,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart_rounded,
                color: Colors.white,
              ),
              SizedBox(width: 9),
              Text(
                'View Latest Daily Result',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(width: 9),
              Icon(
                Icons.arrow_downward_rounded,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _graphTabButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    required Color accent,
  }) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 42,
        decoration: BoxDecoration(
          color: selected
              ? accent.withOpacity(0.18)
              : const Color(0xFF261E54),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? accent
                : const Color(0xFF554386),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(icon, color: accent, size: 18),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: selected
                        ? FontWeight.w900
                        : FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _combinedGraphCard() {
    final isBrainAge =
        selectedGraph == _GraphTab.brainAge;

    final accent = isBrainAge ? purple : cyan;
    final values = isBrainAge
        ? brainAgeHistory
              .map((e) => e.toDouble())
              .toList()
        : responseTimeHistory;
    final title = isBrainAge
        ? 'Brain Age History'
        : 'Response Time History';
    final subtitle = isBrainAge
        ? 'Track your last 30 completed checks'
        : 'Average seconds per response';
    final unit = isBrainAge ? '' : 's';

    final recent = values.length <= 30
        ? values
        : values.sublist(values.length - 30);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _decoration(
        border: accent.withOpacity(0.5),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _heading(
            'Performance Trends',
            Icons.auto_graph_rounded,
            color: accent,
            subtitle:
                'Switch between Brain Age and Response Times',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _graphTabButton(
                label: 'Brain Age',
                icon: Icons.psychology_rounded,
                selected: isBrainAge,
                accent: purple,
                onTap: () {
                  setState(() {
                    selectedGraph = _GraphTab.brainAge;
                  });
                },
              ),
              const SizedBox(width: 8),
              _graphTabButton(
                label: 'Response',
                icon: Icons.speed_rounded,
                selected: !isBrainAge,
                accent: cyan,
                onTap: () {
                  setState(() {
                    selectedGraph =
                        _GraphTab.responseTime;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: Column(
              key: ValueKey(selectedGraph),
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
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
                    height: 170,
                    child: Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.show_chart_rounded,
                            color:
                                accent.withOpacity(0.65),
                            size: 36,
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
                  Column(
                    children: [
                      SizedBox(
                        height: 175,
                        width: double.infinity,
                        child: TweenAnimationBuilder<
                            double>(
                          tween: Tween(
                            begin: 0,
                            end: 1,
                          ),
                          duration: const Duration(
                            milliseconds: 900,
                          ),
                          curve: Curves.easeOutCubic,
                          builder:
                              (context, animation, _) {
                            return CustomPaint(
                              painter:
                                  _ProgressLinePainter(
                                values: recent,
                                color: accent,
                                reveal: animation,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _miniTrendStat(
                              label: 'First',
                              value:
                                  '${recent.first.toStringAsFixed(isBrainAge ? 0 : 1)}$unit',
                              accent: muted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _miniTrendStat(
                              label: 'Latest',
                              value:
                                  '${recent.last.toStringAsFixed(isBrainAge ? 0 : 1)}$unit',
                              accent: accent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniTrendStat({
    required String label,
    required String value,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF251F52),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: muted,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityCalendar() {
    final today = _dayOnly(DateTime.now());
    final start = today.subtract(const Duration(days: 6));

    const weekdays = [
      'M',
      'T',
      'W',
      'T',
      'F',
      'S',
      'S',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _decoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _heading(
            'Last 7 Days',
            Icons.calendar_month_rounded,
            color: purple,
            subtitle:
                'Your completed Daily Brain Checks',
          ),
          const SizedBox(height: 18),
          Row(
            children: List.generate(7, (index) {
              final date =
                  start.add(Duration(days: index));
              final done = _completedOn(date);
              final isToday =
                  _dayOnly(date) == today;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                  ),
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
                            const Duration(
                          milliseconds: 250,
                        ),
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(12),
                          color: done
                              ? const Color(0xFF177E79)
                              : const Color(0xFF30255F),
                          border: Border.all(
                            color: isToday
                                ? gold
                                : done
                                    ? cyan
                                    : const Color(
                                        0xFF544385),
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
                                  style:
                                      const TextStyle(
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

  Widget _latestEmptyCard() {
    return Container(
      key: _latestResultsKey,
      padding: const EdgeInsets.all(22),
      decoration: _decoration(
        border: cyan.withOpacity(0.45),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.psychology_rounded,
            color: cyan,
            size: 52,
          ),
          const SizedBox(height: 12),
          const Text(
            'No Daily Brain Check yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete your first Daily Brain Check to unlock your latest result summary here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: muted,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF251F52),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'This replaces the old separate Daily Results section.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: gold,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _latestResultHero(
    DailySessionResult session,
    bool isToday,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF32156E),
            Color(0xFF191044),
            Color(0xFF11183D),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF9657E8),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x665F20CE),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isToday
                ? Icons.today_rounded
                : Icons.history_rounded,
            color: gold,
            size: 25,
          ),
          const SizedBox(height: 10),
          Text(
            isToday
                ? "TODAY'S RESULT"
                : 'LATEST DAILY RESULT',
            style: const TextStyle(
              color: muted,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            key: ValueKey(
              '${session.brainAge}-${session.completedAt}',
            ),
            tween: Tween(
              begin: 0,
              end: session.brainAge.toDouble(),
            ),
            duration: const Duration(
              milliseconds: 1100,
            ),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                value.round().toString(),
                style: const TextStyle(
                  color: gold,
                  fontSize: 86,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  shadows: [
                    Shadow(
                      color: Color(0x99F8A83D),
                      blurRadius: 18,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            _comparison(session.brainAge),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _date(session.completedAt),
            style: const TextStyle(
              color: cyan,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your latest Daily Brain Check summary',
            style: TextStyle(
              color: muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _latestPerformanceStats(
      DailySessionResult session) {
    return Row(
      children: [
        _metric(
          icon: Icons.emoji_events_rounded,
          label: 'Score',
          value: '${session.totalScore}',
          accent: gold,
        ),
        const SizedBox(width: 8),
        _metric(
          icon: Icons.check_circle_rounded,
          label: 'Accuracy',
          value:
              '${(session.averageAccuracy * 100).round()}%',
          accent: cyan,
        ),
        const SizedBox(width: 8),
        _metric(
          icon: Icons.timer_rounded,
          label: 'Avg time',
          value:
              '${(session.averageResponseTime / 1000).toStringAsFixed(1)}s',
          accent: pink,
        ),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    Color accent = cyan,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: muted,
                fontSize: 13,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _latestSummaryCard(DailySessionResult session) {
    final strongest = _bestGame(session);
    final weakest = _weakestGame(session);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _decoration(
        border: gold.withOpacity(0.45),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.insights_rounded,
                color: gold,
                size: 23,
              ),
              SizedBox(width: 8),
              Text(
                'Latest Check Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _infoRow(
            icon: Icons.local_fire_department_rounded,
            title: 'Current streak',
            value: '$currentStreak days',
            accent: gold,
          ),
          _infoRow(
            icon: Icons.emoji_events_rounded,
            title: 'Longest streak',
            value: '$longestStreak days',
            accent: gold,
          ),
          _infoRow(
            icon: Icons.workspace_premium_rounded,
            title: 'Daily score',
            value: '${session.totalScore}',
            accent: cyan,
          ),
          if (strongest != null)
            _infoRow(
              icon: Icons.trending_up_rounded,
              title: 'Highest scoring game',
              value: GameIds.label(strongest.gameId),
            ),
          if (weakest != null)
            _infoRow(
              icon: Icons.track_changes_rounded,
              title: 'Lowest scoring game',
              value: GameIds.label(weakest.gameId),
            ),
        ],
      ),
    );
  }

  Widget _gameResultTile(
    GameResult game,
    int index,
  ) {
    final accuracy = (game.accuracy * 100).round();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(
        milliseconds: 320 + (index * 90),
      ),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF241E54),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cyan.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.psychology_rounded,
                  color: cyan,
                  size: 21,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    GameIds.label(game.gameId),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: gold.withOpacity(0.14),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${game.score} pts',
                    style: const TextStyle(
                      color: gold,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _miniGameStat(
                    'Accuracy',
                    '$accuracy%',
                    cyan,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _miniGameStat(
                    'Correct',
                    '${game.correct}/${game.attempts}',
                    gold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _miniGameStat(
                    'Avg time',
                    '${(game.averageResponseTimeMs / 1000).toStringAsFixed(2)}s',
                    pink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniGameStat(
    String label,
    String value,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1646),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent.withOpacity(0.28),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: muted,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                color: accent,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _latestResultsSection() {
    final session = todaySession ?? latestSession;

    if (session == null) {
      return _latestEmptyCard();
    }

    final isToday = todaySession != null;

    return Container(
      key: _latestResultsKey,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          _heading(
            'Latest Daily Result',
            Icons.bar_chart_rounded,
            color: cyan,
            subtitle:
                'This now replaces the old separate Daily Results view',
          ),
          const SizedBox(height: 12),
          _latestResultHero(session, isToday),
          const SizedBox(height: 12),
          _latestPerformanceStats(session),
          const SizedBox(height: 12),
          _latestSummaryCard(session),
          const SizedBox(height: 16),
          const Text(
            'Game Breakdown',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...session.gameResults
              .asMap()
              .entries
              .map(
                (entry) => _gameResultTile(
                  entry.value,
                  entry.key,
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
            mainAxisAlignment:
                MainAxisAlignment.center,
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
                        child:
                            CircularProgressIndicator(
                          color: cyan,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: purple,
                        child: ListView(
                          controller: _scrollController,
                          padding:
                              const EdgeInsets.fromLTRB(
                            14,
                            10,
                            14,
                            25,
                          ),
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      Navigator.pop(
                                          context),
                                  style:
                                      IconButton.styleFrom(
                                    backgroundColor:
                                        panel,
                                  ),
                                  icon: const Icon(
                                    Icons
                                        .arrow_back_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 9),
                                const Expanded(
                                  child: Text(
                                    'Your Progress',
                                    style: TextStyle(
                                      color:
                                          Colors.white,
                                      fontSize: 25,
                                      fontWeight:
                                          FontWeight
                                              .w900,
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
                                  label:
                                      'Current streak',
                                  value:
                                      '$currentStreak',
                                  icon: Icons
                                      .local_fire_department,
                                  accent: gold,
                                ),
                                const SizedBox(
                                    width: 8),
                                _metric(
                                  label:
                                      'Daily checks',
                                  value:
                                      '$totalChecks',
                                  icon: Icons
                                      .check_circle_rounded,
                                  accent: cyan,
                                ),
                                const SizedBox(
                                    width: 8),
                                _metric(
                                  label:
                                      'Longest streak',
                                  value:
                                      '$longestStreak',
                                  icon: Icons
                                      .emoji_events_rounded,
                                  accent: purple,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _metric(
                                  label:
                                      'Best brain age',
                                  value:
                                      totalChecks == 0
                                          ? '—'
                                          : '$_bestBrainAge',
                                  icon: Icons
                                      .psychology_rounded,
                                  accent: cyan,
                                ),
                                const SizedBox(
                                    width: 8),
                                _metric(
                                  label:
                                      'Best daily score',
                                  value:
                                      totalChecks == 0
                                          ? '—'
                                          : '$_bestDailyScore',
                                  icon: Icons
                                      .workspace_premium_rounded,
                                  accent: gold,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _latestResultButton(),
                            const SizedBox(height: 16),
                            _combinedGraphCard(),
                            const SizedBox(height: 13),
                            _activityCalendar(),
                            const SizedBox(height: 18),
                            _latestResultsSection(),
                            const SizedBox(height: 18),
                            _individualGameButton(),
                          ],
                        ),
                      ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  12,
                  0,
                  12,
                  5,
                ),
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
      ..color =
          const Color(0xFF65558C).withOpacity(0.3)
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
    final fillPath = Path();
    final points = <Offset>[];

    for (int i = 0; i < validValues.length; i++) {
      final x =
          8 + chartWidth * i / (validValues.length - 1);

      final fraction =
          (validValues[i] - low) / (high - low);

      final y = 9 + chartHeight * (1 - fraction);
      points.add(Offset(x, y));
    }

    final lastVisible =
        ((points.length - 1) * reveal).clamp(
      0.0,
      (points.length - 1).toDouble(),
    );

    final fullSegments = lastVisible.floor();

    path.moveTo(points.first.dx, points.first.dy);
    fillPath.moveTo(points.first.dx, size.height - 8);
    fillPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 1; i <= fullSegments; i++) {
      path.lineTo(points[i].dx, points[i].dy);
      fillPath.lineTo(points[i].dx, points[i].dy);
    }

    if (fullSegments < points.length - 1) {
      final fraction = lastVisible - fullSegments;
      final a = points[fullSegments];
      final b = points[fullSegments + 1];

      final partial = Offset(
        a.dx + (b.dx - a.dx) * fraction,
        a.dy + (b.dy - a.dy) * fraction,
      );

      path.lineTo(partial.dx, partial.dy);
      fillPath.lineTo(partial.dx, partial.dy);
      fillPath.lineTo(partial.dx, size.height - 8);
    } else {
      fillPath.lineTo(
        points.last.dx,
        size.height - 8,
      );
    }

    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.22),
          color.withOpacity(0.02),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(fillPath, fillPaint);
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
  bool shouldRepaint(
      covariant _ProgressLinePainter oldDelegate) {
    return oldDelegate.reveal != reveal ||
        oldDelegate.values != values ||
        oldDelegate.color != color;
  }
}