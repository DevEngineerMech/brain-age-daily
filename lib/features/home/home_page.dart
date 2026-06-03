import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/game_ids.dart';
import '../../core/models/daily_session_result.dart';
import '../../core/models/game_result.dart';
import '../../core/services/daily_hearts_service.dart';
import '../../core/services/stats_service.dart';
import '../../core/widgets/app_banner_ad.dart';
import '../../core/widgets/app_rewarded_ad.dart';
import '../daily/daily_page.dart';
import '../free_play/free_play_page.dart';
import '../stats/stats_page.dart';
import '../daily/daily_results_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _ageKey = 'user_age';

  final TextEditingController _ageController = TextEditingController();

  int _brainAge = 40;
  int _userAge = 25;
  int _totalChecks = 0;
  int _currentStreak = 0;
  int _hearts = DailyHeartsService.maxHearts;

  @override
  void initState() {
    super.initState();
    _loadHome();

    if (!kIsWeb) {
      AppRewardedAd.load();
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadHome() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final int savedAge = prefs.getInt(_ageKey) ?? 25;
    final int hearts = await DailyHeartsService.getHearts();
    final int latestBrainAge = await StatsService.getLatestBrainAge();
    final int totalChecks = await StatsService.getTotalChecks();
    final int currentStreak = await StatsService.getCurrentStreak();

    if (!mounted) return;

    setState(() {
      _ageController.text = '$savedAge';
      _userAge = savedAge;
      _brainAge = latestBrainAge;
      _totalChecks = totalChecks;
      _currentStreak = currentStreak;
      _hearts = hearts;
    });
  }

  Future<void> _saveAge() async {
    final int? age = int.tryParse(_ageController.text.trim());
    if (age == null) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_ageKey, age);

    if (!mounted) return;
    setState(() => _userAge = age);
  }

  Future<void> _startDailyBrainCheck() async {
    final bool canPlay = await DailyHeartsService.consumeHeart();

    if (!mounted) return;

    if (!canPlay) {
      setState(() => _hearts = 0);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hearts left. Watch an ad to get another heart.'),
          duration: Duration(milliseconds: 1400),
        ),
      );
      return;
    }

    final int hearts = await DailyHeartsService.getHearts();

    if (!mounted) return;

    setState(() => _hearts = hearts);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DailyPage(),
      ),
    );

    if (!mounted) return;
    await _loadHome();
  }

  Future<void> _watchAdForHeart() async {
    if (_hearts >= DailyHeartsService.maxHearts) return;

    final bool earnedReward = await AppRewardedAd.show();

    if (!mounted) return;

    if (!earnedReward) {
      AppRewardedAd.load();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad not ready yet. Try again soon.'),
          duration: Duration(milliseconds: 1200),
        ),
      );
      return;
    }

    final int hearts = await DailyHeartsService.addHeart();

    if (!mounted) return;

    setState(() => _hearts = hearts);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❤️ +1 Heart'),
        duration: Duration(milliseconds: 900),
      ),
    );
  }

  String _comparisonText() {
    if (_totalChecks == 0) {
      return 'Complete your first Daily Brain Check';
    }

    final int difference = _userAge - _brainAge;

    if (difference >= 3) {
      return 'You perform like someone $difference years younger.';
    }

    if (difference <= -3) {
      return 'Your result is ${difference.abs()} years above your age today.';
    }

    return 'Your result is close to your age range.';
  }

  Widget _heartIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(DailyHeartsService.maxHearts, (index) {
        final bool filled = index < _hearts;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            filled ? '❤️' : '🩶',
            style: const TextStyle(fontSize: 25),
          ),
        );
      }),
    );
  }

  Widget _watchAdButton() {
    if (_hearts >= DailyHeartsService.maxHearts) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 38,
      child: ElevatedButton.icon(
        onPressed: _watchAdForHeart,
        icon: const Icon(
          Icons.play_circle_fill_rounded,
          size: 18,
        ),
        label: const Text('Watch Ad'),
        style: ElevatedButton.styleFrom(
          elevation: 4,
          backgroundColor: const Color(0xFFFFD247),
          foregroundColor: const Color(0xFF35125A),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }

  Widget _brainAgeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 28, 26, 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
      ),
      child: Column(
        children: [
          const Text(
            'YOUR BRAIN AGE',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '$_brainAge',
            style: const TextStyle(
              color: Color(0xFF202024),
              fontSize: 72,
              fontWeight: FontWeight.w900,
              height: 0.95,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _comparisonText(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F2FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '🔥 $_currentStreak day streak',
              style: const TextStyle(
                color: Color(0xFF625BEA),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _heartIcons(),
              const SizedBox(width: 12),
              _watchAdButton(),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 72,
            child: ElevatedButton(
              onPressed: _startDailyBrainCheck,
              style: ElevatedButton.styleFrom(
                elevation: 4,
                backgroundColor: const Color(0xFF625BEA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Start Daily Brain Check',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DailyResultsPage(),
                  ),
                );
                if (!mounted) return;
                await _loadHome();
              },
              icon: const Icon(Icons.analytics_rounded),
              label: const Text('View Daily Results'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF625BEA),
                side: const BorderSide(color: Color(0xFF625BEA), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Age',
            style: TextStyle(
              color: Color(0xFF202024),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              FocusScope.of(context).unfocus();
              _saveAge();
            },
            onTapOutside: (_) {
              FocusScope.of(context).unfocus();
              _saveAge();
            },
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: () => _ageController.clear(),
                icon: const Icon(Icons.close_rounded),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: Color(0xFF625BEA),
                  width: 2,
                ),
              ),
            ),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          const Padding(
            padding: EdgeInsets.only(left: 14),
            child: Text(
              'Tap away or press done to save',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Container(
            height: 170,
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 34,
                  color: const Color(0xFF202024),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF202024),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _saveAge();
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF625BEA),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Brain Age Daily',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        _brainAgeCard(),
                        const SizedBox(height: 20),
                        _ageCard(),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _menuCard(
                              icon: Icons.sports_esports_rounded,
                              title: 'Free Play',
                              subtitle: 'Unlimited training',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const FreePlayPage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 18),
                            _menuCard(
                              icon: Icons.trending_up_rounded,
                              title: 'Progress',
                              subtitle: 'Graphs & stats',
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const StatsPage(),
                                  ),
                                );
                                if (!mounted) return;
                                await _loadHome();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const AppBannerAd(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyResultsPageState extends State<DailyResultsPage> {
  static const String _ageKey = 'user_age';

  DailySessionResult? _todaySession;
  DailySessionResult? _latestSession;
  int _userAge = 25;
  int _currentStreak = 0;
  int _longestStreak = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _calculateLongestStreak(List<DailySessionResult> sessions) {
    if (sessions.isEmpty) return 0;

    final dates = sessions
        .map((session) => DateTime(
              session.completedAt.year,
              session.completedAt.month,
              session.completedAt.day,
            ))
        .toSet()
        .toList()
      ..sort();

    int best = 1;
    int current = 1;

    for (int i = 1; i < dates.length; i++) {
      final int gap = dates[i].difference(dates[i - 1]).inDays;
      if (gap == 1) {
        current++;
      } else if (gap > 1) {
        current = 1;
      }
      if (current > best) best = current;
    }

    return best;
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<DailySessionResult> sessions = await StatsService.getDailySessions();
    sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    final DateTime now = DateTime.now();
    DailySessionResult? today;
    for (final session in sessions) {
      if (_isSameDay(session.completedAt, now)) {
        today = session;
        break;
      }
    }

    final int currentStreak = await StatsService.getCurrentStreak();

    if (!mounted) return;

    setState(() {
      _userAge = prefs.getInt(_ageKey) ?? 25;
      _todaySession = today;
      _latestSession = sessions.isEmpty ? null : sessions.first;
      _currentStreak = currentStreak;
      _longestStreak = _calculateLongestStreak(sessions);
      _loading = false;
    });
  }

  String _comparisonText(int brainAge) {
    final int difference = _userAge - brainAge;

    if (difference >= 3) {
      return 'You performed like someone $difference years younger.';
    }

    if (difference <= -3) {
      return 'Your result was ${difference.abs()} years above your age today.';
    }

    return 'Your result is close to your age range.';
  }

  GameResult? _bestGame(DailySessionResult session) {
    if (session.gameResults.isEmpty) return null;
    return session.gameResults.reduce((a, b) => a.score >= b.score ? a : b);
  }

  GameResult? _weakestGame(DailySessionResult session) {
    if (session.gameResults.isEmpty) return null;
    return session.gameResults.reduce((a, b) => a.score <= b.score ? a : b);
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF625BEA)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF202024),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blankTodayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: const [
          Icon(
            Icons.psychology_alt_rounded,
            color: Color(0xFF625BEA),
            size: 54,
          ),
          SizedBox(height: 16),
          Text(
            'Today’s result is waiting',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF202024),
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Complete today’s Daily Brain Check to unlock your Brain Age, score, accuracy and game breakdown.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sessionCard(DailySessionResult session, {required bool isToday}) {
    final GameResult? bestGame = _bestGame(session);
    final GameResult? weakestGame = _weakestGame(session);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  isToday ? 'TODAY’S BRAIN AGE' : 'LATEST BRAIN AGE',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${session.brainAge}',
                  style: const TextStyle(
                    color: Color(0xFF202024),
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    height: 0.95,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _comparisonText(session.brainAge),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _summaryCard(
                title: 'Score',
                value: '${session.totalScore}',
                icon: Icons.emoji_events_rounded,
              ),
              const SizedBox(width: 10),
              _summaryCard(
                title: 'Accuracy',
                value: '${(session.averageAccuracy * 100).round()}%',
                icon: Icons.check_circle_rounded,
              ),
              const SizedBox(width: 10),
              _summaryCard(
                title: 'Avg time',
                value: '${(session.averageResponseTime / 1000).toStringAsFixed(1)}s',
                icon: Icons.speed_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _InfoPill(
                  label: 'Current streak',
                  value: '🔥 $_currentStreak days',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoPill(
                  label: 'Longest streak',
                  value: '🏆 $_longestStreak days',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (bestGame != null)
            _InfoPill(
              label: 'Best game',
              value: GameIds.label(bestGame.gameId),
            ),
          if (bestGame != null) const SizedBox(height: 10),
          if (weakestGame != null)
            _InfoPill(
              label: 'Needs work',
              value: GameIds.label(weakestGame.gameId),
            ),
          const SizedBox(height: 18),
          const Text(
            'Game breakdown',
            style: TextStyle(
              color: Color(0xFF202024),
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...session.gameResults.map((result) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7FB),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      GameIds.label(result.gameId),
                      style: const TextStyle(
                        color: Color(0xFF202024),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${result.score} pts • ${(result.accuracy * 100).round()}% • ${(result.averageResponseTimeMs / 1000).toStringAsFixed(1)}s',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DailySessionResult? displaySession = _todaySession ?? _latestSession;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF625BEA),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(
                                    Icons.arrow_back_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Expanded(
                                  child: Text(
                                    'Daily Results',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            if (_todaySession == null) _blankTodayCard(),
                            if (_todaySession == null && displaySession != null)
                              const SizedBox(height: 18),
                            if (_todaySession == null && displaySession != null)
                              const Padding(
                                padding: EdgeInsets.only(left: 4, bottom: 10),
                                child: Text(
                                  'Previous result',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            if (displaySession != null)
                              _sessionCard(
                                displaySession,
                                isToday: _todaySession != null,
                              ),
                            if (displaySession == null && _todaySession == null)
                              const SizedBox(height: 1),
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

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;

  const _InfoPill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F2FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF625BEA),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}