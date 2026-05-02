import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    latestBrainAge = await StatsService.getLatestBrainAge();
    totalChecks = await StatsService.getTotalChecks();
    currentStreak = await StatsService.getCurrentStreak();
    brainAgeHistory = await StatsService.getBrainAgeHistory();
    responseTimeHistory = await StatsService.getResponseTimeHistory();

    if (mounted) {
      setState(() {});
    }
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
                child: RefreshIndicator(
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
                      LineChartPlaceholder(
                        values: brainAgeValues,
                        title: 'Brain Age History',
                      ),
                      const SizedBox(height: 18),
                      LineChartPlaceholder(
                        values: responseTimeHistory,
                        title: 'Response Times',
                      ),
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