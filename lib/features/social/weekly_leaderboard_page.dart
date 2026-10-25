
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/services/social_leaderboard_service.dart';
import 'player_account_page.dart';

class WeeklyLeaderboardPage extends StatefulWidget {
  const WeeklyLeaderboardPage({super.key});

  @override
  State<WeeklyLeaderboardPage> createState() =>
      _WeeklyLeaderboardPageState();
}

class _WeeklyLeaderboardPageState
    extends State<WeeklyLeaderboardPage> {
  static const Color bg = Color(0xFF100C2F);
  static const Color panel = Color(0xFF211947);
  static const Color gold = Color(0xFFFFC75D);
  static const Color cyan = Color(0xFF42D9D0);
  static const Color muted = Color(0xFFB9AACC);

  WeeklyLeaderboardData? _data;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data =
          await SocialLeaderboardService.getLeaderboard();

      if (!mounted) return;

      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (error) {
      SocialLeaderboardService.logError(
        'load leaderboard',
        error,
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Could not load rankings. '
            'Please check your connection.';
      });
    }
  }

  Future<void> _openSettings() async {
    final deleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const PlayerAccountPage(),
      ),
    );

    if (!mounted) return;

    if (deleted == true) {
      Navigator.of(context).pop();
    } else {
      await _refresh();
    }
  }

  String _date(DateTime value) {
    final utc = value.toUtc();

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${utc.day} ${months[utc.month - 1]}';
  }

  Widget _metric(
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.55),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: muted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    final data = _data;
    final mine = data?.currentPlayer;

    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF54278D),
            Color(0xFF241650),
            Color(0xFF15204A),
          ],
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: const Color(0xFFAD77F8),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: gold,
            size: 61,
          ),
          const SizedBox(height: 9),
          const Text(
            'WEEKLY CHAMPIONS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            data == null
                ? 'Monday – Sunday'
                : '${_date(data.weekStart)} – '
                    '${_date(data.weekEnd.subtract(
                      const Duration(days: 1),
                    ))}',
            style: const TextStyle(
              color: muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: _metric(
                  'YOUR POINTS',
                  '${mine?.points ?? 0}',
                  gold,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metric(
                  'DAYS PLAYED',
                  '${mine?.daysPlayed ?? 0} / 7',
                  cyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Text(
            'Your best Daily Brain Check accuracy each '
            'day earns up to 1,000 points.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: muted,
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _rankColour(int rank) {
    switch (rank) {
      case 1:
        return gold;
      case 2:
        return const Color(0xFFC9D5E5);
      case 3:
        return const Color(0xFFDE9865);
      default:
        return const Color(0xFFAD95D6);
    }
  }

  Widget _playerRow(
    WeeklyPlayerScore player,
    int? rank,
  ) {
    final mine = player.uid ==
        FirebaseAuth.instance.currentUser?.uid;

    final colour = rank == null
        ? cyan
        : _rankColour(rank);

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: mine
            ? const Color(0xFF413076)
            : panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: mine
              ? const Color(0xFFBA91FF)
              : const Color(0xFF51417C),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 39,
            child: rank != null && rank <= 3
                ? Icon(
                    Icons.workspace_premium_rounded,
                    color: colour,
                    size: 28,
                  )
                : Text(
                    rank?.toString() ?? '—',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colour,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: colour.withOpacity(0.17),
            child: Icon(
              Icons.person_rounded,
              color: colour,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  mine
                      ? 'YOU'
                      : '${player.daysPlayed} daily checks',
                  style: TextStyle(
                    color: mine
                        ? const Color(0xFFCDAAFF)
                        : muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.star_rounded,
            color: gold,
            size: 17,
          ),
          const SizedBox(width: 4),
          Text(
            '${player.points}',
            style: const TextStyle(
              color: gold,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              14, 10, 14, 27,
            ),
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
                      'Weekly Leaderboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Player Settings',
                    onPressed: _openSettings,
                    icon: const Icon(
                      Icons.settings_rounded,
                      color: gold,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh Rankings',
                    onPressed: _refresh,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: cyan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(45),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: cyan,
                    ),
                  ),
                )
              else if (_error != null) ...[
                const SizedBox(height: 35),
                const Icon(
                  Icons.wifi_off_rounded,
                  color: gold,
                  size: 50,
                ),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: muted,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _refresh,
                  child: const Text('Try Again'),
                ),
              ] else ...[
                _hero(),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Icon(
                      Icons.public_rounded,
                      color: cyan,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'GLOBAL TOP 50',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (data == null || data.players.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(23),
                    decoration: BoxDecoration(
                      color: panel,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'No scores yet. Complete a Daily Brain '
                      'Check to join this week’s rankings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted),
                    ),
                  )
                else
                  ...data.players.asMap().entries.map(
                    (entry) => _playerRow(
                      entry.value,
                      entry.key + 1,
                    ),
                  ),
                if (data?.currentPlayer != null &&
                    !data!.players.any(
                      (p) =>
                          p.uid == data.currentPlayer!.uid,
                    )) ...[
                  const SizedBox(height: 13),
                  const Text(
                    'YOUR POSITION — OUTSIDE TOP 50',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _playerRow(data.currentPlayer!, null),
                ],
                const SizedBox(height: 18),
                const Text(
                  'Rankings start fresh every Monday at '
                  '00:00 UTC. Only the best completed '
                  'Daily Brain Check per day contributes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
