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
  State<DailyResultsPage> createState() => _DailyResultsPageState();
}

class _DailyResultsPageState extends State<DailyResultsPage> {
  static const String _ageKey = 'user_age';

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
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final DailySessionResult? todaySession =
        await StatsService.getTodaySession();

    final DailySessionResult? latestSession =
        await StatsService.getLatestSession();

    final int currentStreak = await StatsService.getCurrentStreak();
    final int longestStreak = await StatsService.getLongestStreak();

    if (!mounted) return;

    setState(() {
      _userAge = prefs.getInt(_ageKey) ?? 25;
      _todaySession = todaySession;
      _latestSession = latestSession;
      _currentStreak = currentStreak;
      _longestStreak = longestStreak;
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

    return 'Your result is close to your real age.';
  }

  String _dateText(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  GameResult? _bestGame(DailySessionResult session) {
    if (session.gameResults.isEmpty) return null;
    return session.gameResults.reduce((a, b) => a.score >= b.score ? a : b);
  }

  GameResult? _weakestGame(DailySessionResult session) {
    if (session.gameResults.isEmpty) return null;
    return session.gameResults.reduce((a, b) => a.score <= b.score ? a : b);
  }

  Widget _blankTodayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.psychology_alt_rounded,
            color: Color(0xFF625BEA),
            size: 58,
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
            'Complete today’s Daily Brain Check to unlock your Brain Age, score, accuracy, response time and game breakdown.',
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

  Widget _summaryBox({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7FB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF625BEA),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF202024),
                fontSize: 20,
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

  Widget _infoPill({
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F2FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF625BEA),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _questionResultCard(QuestionResult result) {
    final Color backgroundColor = result.isCorrect
        ? const Color(0xFFE8F8EF)
        : const Color(0xFFFFECEC);

    final Color borderColor = result.isCorrect
        ? const Color(0xFF2EAD68)
        : const Color(0xFFE54848);

    final Color titleColor = result.isCorrect
        ? const Color(0xFF157A43)
        : const Color(0xFFB32626);

    final IconData icon =
        result.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor.withOpacity(0.6),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: titleColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                result.isCorrect ? 'Correct' : 'Wrong',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Question',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            result.question.isEmpty ? 'Question unavailable' : result.question,
            style: const TextStyle(
              color: Color(0xFF202024),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your answer',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            result.userAnswer.isEmpty ? 'No answer recorded' : result.userAnswer,
            style: TextStyle(
              color: result.isCorrect
                  ? const Color(0xFF157A43)
                  : const Color(0xFFB32626),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Correct answer',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            result.correctAnswer.isEmpty
                ? 'Correct answer unavailable'
                : result.correctAnswer,
            style: const TextStyle(
              color: Color(0xFF157A43),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

 Widget _gameExpansionCard(GameResult result) {
  final bool hasQuestionResults = result.questionResults.isNotEmpty;

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F7FB),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        iconColor: const Color(0xFF625BEA),
        collapsedIconColor: const Color(0xFF625BEA),
        leading: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF625BEA),
        ),
        title: Text(
          GameIds.label(result.gameId),
          style: const TextStyle(
            color: Color(0xFF202024),
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${result.score} pts • ${result.correct}/${result.attempts} correct • tap to view questions',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        children: [
          if (!hasQuestionResults)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'No question details were saved for this game yet. Complete a new Daily Brain Check to record detailed question results.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (hasQuestionResults)
            ...result.questionResults.map(_questionResultCard),
        ],
      ),
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
          const SizedBox(height: 6),
          Text(
            _dateText(session.completedAt),
            style: const TextStyle(
              color: Color(0xFF625BEA),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _summaryBox(
                title: 'Score',
                value: '${session.totalScore}',
                icon: Icons.emoji_events_rounded,
              ),
              const SizedBox(width: 10),
              _summaryBox(
                title: 'Accuracy',
                value: '${(session.averageAccuracy * 100).round()}%',
                icon: Icons.check_circle_rounded,
              ),
              const SizedBox(width: 10),
              _summaryBox(
                title: 'Avg time',
                value:
                    '${(session.averageResponseTime / 1000).toStringAsFixed(1)}s',
                icon: Icons.speed_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _infoPill(
            label: 'Current streak',
            value: '🔥 $_currentStreak days',
          ),
          const SizedBox(height: 10),
          _infoPill(
            label: 'Longest streak',
            value: '🏆 $_longestStreak days',
          ),
          if (bestGame != null) const SizedBox(height: 10),
          if (bestGame != null)
            _infoPill(
              label: 'Best game',
              value: GameIds.label(bestGame.gameId),
            ),
          if (weakestGame != null) const SizedBox(height: 10),
          if (weakestGame != null)
            _infoPill(
              label: 'Needs work',
              value: GameIds.label(weakestGame.gameId),
            ),
          const SizedBox(height: 22),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Game breakdown',
              style: TextStyle(
                color: Color(0xFF202024),
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...session.gameResults.map(_gameExpansionCard),
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
        color: const Color(0xFF625BEA),
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