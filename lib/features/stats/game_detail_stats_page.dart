import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/stats_service.dart';
import '../../core/widgets/app_banner_ad.dart';
import '../../core/widgets/stat_card.dart';

class GameDetailStatsPage extends StatefulWidget {
  final String gameId;

  const GameDetailStatsPage({
    super.key,
    required this.gameId,
  });

  @override
  State<GameDetailStatsPage> createState() => _GameDetailStatsPageState();
}

class _GameDetailStatsPageState extends State<GameDetailStatsPage> {
  Map<String, dynamic>? summary;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final Map<String, dynamic> data =
        await StatsService.getGameSummary(widget.gameId);

    if (mounted) {
      setState(() {
        summary = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? data = summary;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: data == null
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView(
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
                              Expanded(
                                child: Text(
                                  data['label'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  title: 'Plays',
                                  value: '${data['plays']}',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  title: 'Best Score',
                                  value: '${data['bestScore']}',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  title: 'Accuracy',
                                  value:
                                      '${(((data['averageAccuracy'] as double) * 100)).toStringAsFixed(1)}%',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  title: 'Avg Response',
                                  value:
                                      '${(data['averageResponseTime'] as double).toStringAsFixed(0)}ms',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          StatCard(
                            title: 'Estimated Brain Age',
                            value: '${data['estimatedBrainAge']}',
                          ),
                        ],
                      ),
              ),
              const SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 4),
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