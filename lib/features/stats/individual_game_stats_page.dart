
import 'package:flutter/material.dart';

import '../../core/constants/game_ids.dart';
import '../../core/services/stats_service.dart';
import '../../core/widgets/app_banner_ad.dart';
import '../games/shared/game_theme.dart';
import 'game_detail_stats_page.dart';

class IndividualGameStatsPage extends StatefulWidget {
  const IndividualGameStatsPage({super.key});

  @override
  State<IndividualGameStatsPage> createState() =>
      _IndividualGameStatsPageState();
}

class _IndividualGameStatsPageState
    extends State<IndividualGameStatsPage> {
  Map<String, Map<String, dynamic>> _summaries = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final summaries = <String, Map<String, dynamic>>{};

      for (final id in GameIds.all) {
        summaries[id] = await StatsService.getGameSummary(id);
      }

      if (!mounted) return;

      setState(() {
        _summaries = summaries;
        _loading = false;
      });
    } catch (error) {
      debugPrint('Game stats error: $error');

      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  IconData _icon(String id) {
    switch (id) {
      case GameIds.memoryGrid:
        return Icons.grid_view_rounded;
      case GameIds.orderRecall:
        return Icons.format_list_numbered_rounded;
      case GameIds.patternLogic:
        return Icons.auto_awesome_mosaic_rounded;
      case GameIds.symbolMatch:
        return Icons.interests_rounded;
      case GameIds.focusCount:
        return Icons.center_focus_strong_rounded;
      case GameIds.reactionSwitch:
        return Icons.bolt_rounded;
      case GameIds.stroopShift:
        return Icons.palette_rounded;
      case GameIds.quickMath:
        return Icons.calculate_rounded;
      case GameIds.timeDifference:
        return Icons.timer_rounded;
      case GameIds.sudoku:
        return Icons.grid_on_rounded;
      case GameIds.biologyQuiz:
        return Icons.biotech_rounded;
      case GameIds.scienceQuiz:
        return Icons.science_rounded;
      case GameIds.antonyms:
        return Icons.compare_arrows_rounded;
      case GameIds.wordSnap:
        return Icons.category_rounded;
      case GameIds.wordScramble:
        return Icons.shuffle_rounded;
      default:
        return Icons.psychology_rounded;
    }
  }

  Color _colour(int index) {
    const colours = [
      Color(0xFFAF83FF),
      Color(0xFF4DDDD1),
      Color(0xFFFFC75D),
      Color(0xFFFF81BE),
      Color(0xFF62BDFE),
      Color(0xFF70E29C),
    ];

    return colours[index % colours.length];
  }

  Widget _heading(
    String title,
    String subtitle,
    IconData icon,
    Color colour,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(1, 15, 1, 12),
      child: Row(
        children: [
          Container(
            width: 41,
            height: 41,
            decoration: BoxDecoration(
              color: colour.withOpacity(0.16),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: colour.withOpacity(0.6),
              ),
            ),
            child: Icon(icon, color: colour),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: GameTheme.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openGame(String id) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameDetailStatsPage(gameId: id),
      ),
    );

    if (mounted) await _refresh();
  }

  Widget _gameTile(String id, int index) {
    final data = _summaries[id];
    final plays = (data?['plays'] as int?) ?? 0;
    final best = (data?['bestScore'] as int?) ?? 0;
    final accuracy =
        (data?['averageAccuracy'] as num?)?.toDouble() ?? 0;

    final colour = _colour(index);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openGame(id),
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.lerp(GameTheme.panel, colour, 0.13)!,
                  GameTheme.panel,
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colour.withOpacity(0.65),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 51,
                  height: 51,
                  decoration: BoxDecoration(
                    color: colour.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _icon(id),
                    color: colour,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        GameIds.label(id),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        plays == 0
                            ? 'No completed rounds yet'
                            : '$plays plays  •  Best $best',
                        style: const TextStyle(
                          color: GameTheme.muted,
                          fontSize: 11,
                        ),
                      ),
                      if (plays > 0) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: accuracy.clamp(0.0, 1.0),
                            minHeight: 5,
                            backgroundColor:
                                GameTheme.border.withOpacity(0.35),
                            color: colour,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (plays > 0)
                  Text(
                    '${(accuracy * 100).round()}%',
                    style: TextStyle(
                      color: colour,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: GameTheme.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(List<String> ids, int offset) {
    return Column(
      children: List.generate(
        ids.length,
        (index) => _gameTile(
          ids[index],
          index + offset,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPlays = _summaries.values.fold<int>(
      0,
      (sum, item) => sum + ((item['plays'] as int?) ?? 0),
    );

    final playedGames = _summaries.values.where(
      (item) => ((item['plays'] as int?) ?? 0) > 0,
    ).length;

    return Scaffold(
      backgroundColor: GameTheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: GameTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  color: GameTheme.purple,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      15, 9, 15, 26,
                    ),
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () =>
                                Navigator.pop(context),
                            style: IconButton.styleFrom(
                              backgroundColor: GameTheme.panel,
                            ),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 9),
                          const Expanded(
                            child: Text(
                              'Game Statistics',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: GameTheme.card(
                          accent: GameTheme.gold,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.emoji_events_rounded,
                              color: GameTheme.gold,
                              size: 48,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'YOUR GAME PROGRESS',
                                    style: TextStyle(
                                      color: GameTheme.gold,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$totalPlays completed rounds',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$playedGames of 15 games played',
                                    style: const TextStyle(
                                      color: GameTheme.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.all(30),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: GameTheme.purple,
                            ),
                          ),
                        )
                      else ...[
                        _heading(
                          'Brain Training',
                          'Memory, focus, logic and speed',
                          Icons.psychology_rounded,
                          GameTheme.purple,
                        ),
                        _section(GameIds.brainTraining, 0),
                        _heading(
                          'Knowledge Arcade',
                          'Knowledge and language challenges',
                          Icons.auto_stories_rounded,
                          GameTheme.gold,
                        ),
                        _section(GameIds.coinArcade, 10),
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
