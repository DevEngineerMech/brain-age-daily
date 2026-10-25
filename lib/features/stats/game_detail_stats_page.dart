
import 'package:flutter/material.dart';

import '../../core/constants/game_ids.dart';
import '../../core/models/game_result.dart';
import '../../core/services/stats_service.dart';
import '../../core/widgets/app_banner_ad.dart';
import '../games/shared/game_theme.dart';

class GameDetailStatsPage extends StatefulWidget {
  final String gameId;

  const GameDetailStatsPage({
    super.key,
    required this.gameId,
  });

  @override
  State<GameDetailStatsPage> createState() =>
      _GameDetailStatsPageState();
}

class _GameDetailStatsPageState
    extends State<GameDetailStatsPage> {
  Map<String, dynamic>? _summary;
  List<GameResult> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await StatsService.getGameSummary(
        widget.gameId,
      );

      final history = await StatsService.getGameHistory(
        widget.gameId,
      );

      if (!mounted) return;

      setState(() {
        _summary = data;
        _history = history;
        _loading = false;
      });
    } catch (error) {
      debugPrint('Game detail stats error: $error');

      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _stat({
    required String label,
    required String value,
    required IconData icon,
    required Color colour,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: GameTheme.card(
        accent: colour,
        radius: 18,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: colour, size: 25),
          const SizedBox(height: 9),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colour,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: GameTheme.muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year}  $hour:$minute';
  }

  Widget _historyTile(GameResult result) {
    final accuracy = result.accuracy;
    final colour =
        accuracy >= 0.8 ? GameTheme.green : GameTheme.purple;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: GameTheme.card(
        accent: colour,
        radius: 16,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colour.withOpacity(0.18),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              color: colour,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${result.score} / ${result.attempts} points',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _formatDate(result.playedAt),
                  style: const TextStyle(
                    color: GameTheme.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(accuracy * 100).round()}%',
            style: TextStyle(
              color: colour,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _summary;
    final plays = (data?['plays'] as int?) ?? 0;
    final best = (data?['bestScore'] as int?) ?? 0;

    final accuracy =
        (data?['averageAccuracy'] as num?)?.toDouble() ?? 0;

    final response =
        (data?['averageResponseTime'] as num?)?.toDouble() ?? 0;

    final hasResponse = data?['hasResponseTime'] == true;
    final brainAge = data?['estimatedBrainAge'];

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
                  onRefresh: _load,
                  color: GameTheme.purple,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      15, 10, 15, 28,
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
                          Expanded(
                            child: Text(
                              GameIds.label(widget.gameId),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 17),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: GameTheme.card(
                          accent: GameTheme.gold,
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.insights_rounded,
                              color: GameTheme.gold,
                              size: 43,
                            ),
                            const SizedBox(height: 9),
                            const Text(
                              'YOUR PERFORMANCE',
                              style: TextStyle(
                                color: GameTheme.gold,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              plays == 0
                                  ? 'No completed games yet'
                                  : '$plays completed rounds',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 7),
                            const Text(
                              'Includes Daily Brain Check and Free Play',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: GameTheme.muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 17),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 1.35,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        children: [
                          _stat(
                            label: 'Total Plays',
                            value: '$plays',
                            icon: Icons.play_circle_rounded,
                            colour: GameTheme.purple,
                          ),
                          _stat(
                            label: 'Best Score',
                            value: plays == 0 ? '—' : '$best',
                            icon: Icons.emoji_events_rounded,
                            colour: GameTheme.gold,
                          ),
                          _stat(
                            label: 'Accuracy',
                            value: plays == 0
                                ? '—'
                                : '${(accuracy * 100).toStringAsFixed(1)}%',
                            icon: Icons.track_changes_rounded,
                            colour: GameTheme.green,
                          ),
                          _stat(
                            label: 'Average Response',
                            value: hasResponse
                                ? '${(response / 1000).toStringAsFixed(2)}s'
                                : '—',
                            icon: Icons.timer_rounded,
                            colour: GameTheme.cyan,
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: GameTheme.card(
                          accent: GameTheme.purple,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.psychology_rounded,
                              color: GameTheme.gold,
                              size: 35,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Latest Daily Brain Age',
                                    style: TextStyle(
                                      color: GameTheme.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    brainAge == null
                                        ? 'Not measured'
                                        : '$brainAge',
                                    style: const TextStyle(
                                      color: GameTheme.gold,
                                      fontSize: 23,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: GameTheme.card(
                          accent: GameTheme.cyan,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.sports_esports_rounded,
                                  color: GameTheme.cyan,
                                ),
                                const SizedBox(width: 9),
                                const Expanded(
                                  child: Text(
                                    'Free Play rounds',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${data?['freePlayCount'] ?? 0}',
                                  style: const TextStyle(
                                    color: GameTheme.cyan,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 13),
                            Row(
                              children: [
                                const Icon(
                                  Icons.psychology_rounded,
                                  color: GameTheme.purple,
                                ),
                                const SizedBox(width: 9),
                                const Expanded(
                                  child: Text(
                                    'Daily Check appearances',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${data?['dailyCheckCount'] ?? 0}',
                                  style: const TextStyle(
                                    color: GameTheme.purple,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'RECENT RESULTS',
                        style: TextStyle(
                          color: GameTheme.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_loading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: GameTheme.purple,
                          ),
                        )
                      else if (_history.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: GameTheme.card(),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.hourglass_empty_rounded,
                                color: GameTheme.muted,
                                size: 35,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'No completed rounds yet',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Finish a game in Free Play or '
                                'Daily Brain Check to see results.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: GameTheme.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._history
                            .take(15)
                            .map(_historyTile),
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
