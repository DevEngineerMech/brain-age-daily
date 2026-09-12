import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/game_ids.dart';
import '../../core/widgets/app_banner_ad.dart';
import 'game_detail_stats_page.dart';

class IndividualGameStatsPage extends StatelessWidget {
  const IndividualGameStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> gameIds = GameIds.all;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: gameIds.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Individual Game Stats',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    final String gameId = gameIds[index - 1];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: ListTile(
                        title: Text(GameIds.label(gameId)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GameDetailStatsPage(gameId: gameId),
                            ),
                          );
                        },
                      ),
                    );
                  },
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