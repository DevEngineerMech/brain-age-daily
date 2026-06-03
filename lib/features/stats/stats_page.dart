import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/game_ids.dart';
import '../../core/models/daily_session_result.dart';
import '../../core/models/game_result.dart';
import '../../core/services/stats_service.dart';
import '../../core/widgets/app_banner_ad.dart';
import '../../core/widgets/line_chart_placeholder.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/stat_card.dart';
import 'individual_game_stats_page.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int latestBrainAge = 40;
  int totalChecks = 0;
  int currentStreak = 0;
  List<int> brainAgeHistory = <int>[];
  List<double> responseTimeHistory = <double>[];
  List<DailySessionResult> dailySessions = <DailySessionResult>[];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final int loadedLatestBrainAge = await StatsService.getLatestBrainAge();
    final int loadedTotalChecks = await StatsService.getTotalChecks();
    final int loadedCurrentStreak = await StatsService.getCurrentStreak();
    final List<int> loadedBrainAgeHistory = await StatsService.getBrainAgeHistory();
    final List<double> loadedResponseTimeHistory =
        await StatsService.getResponseTimeHistory();
    final List<DailySessionResult> loadedDailySessions =
        await StatsService.getDailySessions();

    loadedDailySessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    if (!mounted) return;

    setState(() {
      latestBrainAge = loadedLatestBrainAge;
      totalChecks = loadedTotalChecks;
      currentStreak = loadedCurrentStreak;
      brainAgeHistory = loadedBrainAgeHistory;
      responseTimeHistory = loadedResponseTimeHistory;
      dailySessions = loadedDailySessions;
      loading = false;
    });
  }

  String _formatDate(DateTime date) {
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

  Widget _emptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Icon(icon, size: 46, color: const Color(0xFF625BEA)),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF202024),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dailySessionCard(DailySessionResult session) {
    final GameResult? bestGame = _bestGame(session);
    final GameResult? weakestGame = _weakestGame(session);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F2FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    '${session.brainAge}',
                    style: const TextStyle(
                      color: Color(0xFF625BEA),
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(session.completedAt),
                      style: const TextStyle(
                        color: Color(0xFF202024),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${session.totalScore} pts • ${(session.averageAccuracy * 100).round()}% accuracy • ${(session.averageResponseTime / 1000).toStringAsFixed(1)}s avg',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (bestGame != null)
            _MiniResultLine(
              label: 'Best game',
              value: GameIds.label(bestGame.gameId),
            ),
          if (weakestGame != null)
            _MiniResultLine(
              label: 'Needs work',
              value: GameIds.label(weakestGame.gameId),
            ),
        ],
      ),
    );
  }

  Widget _historyList() {
    if (dailySessions.isEmpty) {
      return _emptyCard(
        icon: Icons.analytics_rounded,
        title: 'No Daily Results Yet',
        subtitle: 'Complete a Daily Brain Check to start building your history.',
      );
    }

    return Column(
      children: dailySessions.take(10).map(_dailySessionCard).toList(),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<double> brainAgeValues =
        brainAgeHistory.map((e) => e.toDouble()).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: loading
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
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Your Progress',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    title: 'Current Brain Age',
                                    value: '$latestBrainAge',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: StatCard(
                                    title: 'Day Streak',
                                    value: '$currentStreak',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: StatCard(
                                    title: 'Total Checks',
                                    value: '$totalChecks',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _sectionTitle('Brain Age History'),
                            if (brainAgeValues.length < 2)
                              _emptyCard(
                                icon: Icons.show_chart_rounded,
                                title: 'Your graph will appear here',
                                subtitle:
                                    'Complete at least two Daily Brain Checks to see your Brain Age trend.',
                              )
                            else
                              LineChartPlaceholder(
                                values: brainAgeValues,
                                title: 'Brain Age History',
                              ),
                            const SizedBox(height: 18),
                            _sectionTitle('Response Times'),
                            if (responseTimeHistory.length < 2)
                              _emptyCard(
                                icon: Icons.speed_rounded,
                                title: 'No response trend yet',
                                subtitle:
                                    'Your average response time graph will build as you complete more Daily Brain Checks.',
                              )
                            else
                              LineChartPlaceholder(
                                values: responseTimeHistory,
                                title: 'Response Times',
                              ),
                            const SizedBox(height: 18),
                            _sectionTitle('Daily Brain Checks'),
                            _historyList(),
                            const SizedBox(height: 18),
                            PrimaryButton(
                              text: 'Individual Game Stats',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const IndividualGameStatsPage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
              ),
              const SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: AppBannerAd(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniResultLine extends StatelessWidget {
  final String label;
  final String value;

  const _MiniResultLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
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
              color: Color(0xFF202024),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}