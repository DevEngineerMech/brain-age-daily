
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/game_ids.dart';
import '../../core/models/daily_session_result.dart';
import '../../core/models/game_result.dart';
import '../../core/services/stats_service.dart';
import '../../core/widgets/app_banner_ad.dart';

class DailyResultsPage extends StatefulWidget {
  const DailyResultsPage({super.key});

  @override
  State<DailyResultsPage> createState() =>
      _DailyResultsPageState();
}

class _DailyResultsPageState extends State<DailyResultsPage> {
  static const Color bg = Color(0xFF0C0929);
  static const Color panel = Color(0xFF1A1646);
  static const Color purple = Color(0xFF803CFA);
  static const Color cyan = Color(0xFF42D9D0);
  static const Color gold = Color(0xFFFFC75D);
  static const Color muted = Color(0xFFBDB3DB);

  bool _loading = true;
  int _userAge = 25;
  int _currentStreak = 0;
  int _longestStreak = 0;

  DailySessionResult? _todaySession;
  DailySessionResult? _latestSession;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final today = await StatsService.getTodaySession();
      final latest = await StatsService.getLatestSession();
      final streak = await StatsService.getCurrentStreak();
      final longest = await StatsService.getLongestStreak();

      if (!mounted) return;

      setState(() {
        _userAge = prefs.getInt('user_age') ?? 25;
        _todaySession = today;
        _latestSession = latest;
        _currentStreak = streak;
        _longestStreak = longest;
        _loading = false;
      });
    } catch (error) {
      debugPrint('Results load failed: $error');

      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  BoxDecoration _decoration({
    Color? color,
    Color? border,
  }) {
    return BoxDecoration(
      color: color ?? panel,
      borderRadius: BorderRadius.circular(19),
      border: Border.all(
        color: border ?? const Color(0xFF51418C),
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x44000000),
          blurRadius: 12,
          offset: Offset(0, 5),
        ),
      ],
    );
  }

  Widget _panel({
    required Widget child,
    Color? color,
    Color? border,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _decoration(color: color, border: border),
      child: child,
    );
  }

  String _comparison(int brainAge) {
    final difference = _userAge - brainAge;

    if (difference >= 3) {
      return 'Your result is $difference years below your actual age';
    }

    if (difference <= -3) {
      return 'Your result is ${difference.abs()} years above your actual age';
    }

    return 'Your result is close to your actual age';
  }

  String _date(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  Widget _statTile({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 13,
        ),
        decoration: _decoration(),
        child: Column(
          children: [
            Icon(icon, color: accent, size: 23),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
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

  Widget _emptyResults() {
    return _panel(
      child: Column(
        children: [
          const Icon(
            Icons.psychology_rounded,
            color: cyan,
            size: 55,
          ),
          const SizedBox(height: 14),
          const Text(
            "Today's brain check awaits!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontSize: 21,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Complete your Daily Brain Check to unlock '
            'your score, brain age and performance report.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: muted,
              height: 1.5,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 15),
          const Icon(
            Icons.lock_open_rounded,
            color: gold,
            size: 25,
          ),
        ],
      ),
    );
  }

  Widget _brainAgeHero(
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
          const Icon(
            Icons.auto_awesome_rounded,
            color: gold,
            size: 25,
          ),
          const SizedBox(height: 10),
          Text(
            isToday
                ? "TODAY'S BRAIN AGE"
                : 'LATEST BRAIN AGE',
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
            duration: const Duration(milliseconds: 1100),
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
            'Your training performance estimate',
            style: TextStyle(
              color: muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _performanceStats(DailySessionResult session) {
    return Row(
      children: [
        _statTile(
          icon: Icons.emoji_events_rounded,
          label: 'Score',
          value: '${session.totalScore}',
          accent: gold,
        ),
        const SizedBox(width: 8),
        _statTile(
          icon: Icons.check_circle_rounded,
          label: 'Accuracy',
          value:
              '${(session.averageAccuracy * 100).round()}%',
          accent: cyan,
        ),
        const SizedBox(width: 8),
        _statTile(
          icon: Icons.timer_rounded,
          label: 'Avg time',
          value:
              '${(session.averageResponseTime / 1000).toStringAsFixed(1)}s',
          accent: const Color(0xFFDA7BFF),
        ),
      ],
    );
  }

  Widget _gameBreakdown(GameResult game) {
    final accuracy = (game.accuracy * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _decoration(),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: const ExpansionTileThemeData(
            iconColor: gold,
            collapsedIconColor: muted,
            textColor: Colors.white,
            collapsedTextColor: Colors.white,
          ),
        ),
        child: ExpansionTile(
          leading: const Icon(
            Icons.psychology_rounded,
            color: cyan,
          ),
          title: Text(
            GameIds.label(game.gameId),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Text(
            'Score ${game.score}  •  $accuracy% accuracy',
            style: const TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
          children: [
            const Divider(color: Color(0xFF51418C)),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                14,
                4,
                14,
                12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(
                    icon: Icons.check_rounded,
                    title: 'Correct answers',
                    value: '${game.correct}/${game.attempts}',
                  ),
                  _infoRow(
                    icon: Icons.timer_outlined,
                    title: 'Average response',
                    value:
                        '${(game.averageResponseTimeMs / 1000).toStringAsFixed(2)}s',
                  ),
                  if (game.questionResults.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'No individual question history available.',
                        style: TextStyle(
                          color: muted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ...game.questionResults.asMap().entries.map(
                    (entry) {
                      final item = entry.value;
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2056),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  item.isCorrect
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded,
                                  color: item.isCorrect
                                      ? cyan
                                      : const Color(0xFFFF7189),
                                  size: 18,
                                ),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: Text(
                                    'Question ${entry.key + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            Text(
                              item.question,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Your answer: ${item.userAnswer}',
                              style: const TextStyle(
                                color: muted,
                                fontSize: 11,
                              ),
                            ),
                            if (!item.isCorrect)
                              Text(
                                'Correct: ${item.correctAnswer}',
                                style: const TextStyle(
                                  color: cyan,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sessionReport(
    DailySessionResult session,
    bool isToday,
  ) {
    GameResult? strongest;
    GameResult? weakest;

    if (session.gameResults.isNotEmpty) {
      strongest = session.gameResults.reduce(
        (a, b) => a.score >= b.score ? a : b,
      );
      weakest = session.gameResults.reduce(
        (a, b) => a.score <= b.score ? a : b,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _brainAgeHero(session, isToday),
        const SizedBox(height: 13),
        _performanceStats(session),
        const SizedBox(height: 13),
        _panel(
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    color: gold,
                    size: 23,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Your Streaks',
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
                value: '$_currentStreak days',
                accent: gold,
              ),
              _infoRow(
                icon: Icons.emoji_events_rounded,
                title: 'Longest streak',
                value: '$_longestStreak days',
                accent: gold,
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
        ),
        const SizedBox(height: 17),
        const Row(
          children: [
            Icon(
              Icons.bar_chart_rounded,
              color: cyan,
              size: 23,
            ),
            SizedBox(width: 8),
            Text(
              'Game Breakdown',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        ...session.gameResults.map(_gameBreakdown),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final display = _todaySession ?? _latestSession;

    return Scaffold(
      backgroundColor: bg,
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
                child: RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      14,
                      10,
                      14,
                      24,
                    ),
                    children: [
                      Row(
                        children: [
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: panel,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 7),
                          const Expanded(
                            child: Text(
                              'Daily Results',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: gold,
                          ),
                        ],
                      ),
                      const SizedBox(height: 17),
                      if (_loading)
                        const SizedBox(
                          height: 240,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: cyan,
                            ),
                          ),
                        )
                      else ...[
                        if (_todaySession == null) ...[
                          _emptyResults(),
                          const SizedBox(height: 14),
                        ],
                        if (_todaySession == null &&
                            display != null) ...[
                          const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              'Previous Result',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                        if (display != null)
                          _sessionReport(
                            display,
                            _todaySession != null,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              const AppBannerAd(),
            ],
          ),
        ),
      ),
    );
  }
}
