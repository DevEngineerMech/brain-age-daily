
import 'package:flutter/material.dart';

import '../../core/services/social_leaderboard_service.dart';

import 'create_username_page.dart';
import 'weekly_leaderboard_page.dart';

class HomeLeaderboardCard extends StatefulWidget {
  const HomeLeaderboardCard({super.key});

  @override
  State<HomeLeaderboardCard> createState() =>
      _HomeLeaderboardCardState();
}

class _HomeLeaderboardCardState
    extends State<HomeLeaderboardCard> {
  bool _opening = false;

  Future<void> _open() async {
    if (_opening) return;

    setState(() => _opening = true);

    try {
      final profile =
          await SocialLeaderboardService.getMyProfile();

      if (!mounted) return;

      if (profile == null) {
        final created = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => const CreateUsernamePage(),
          ),
        );

        if (!mounted || created != true) return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const WeeklyLeaderboardPage(),
        ),
      );
    } catch (error) {
      SocialLeaderboardService.logError(
        'open leaderboard',
        error,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to connect to the leaderboard. '
            'Check your Firebase setup.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _opening ? null : _open,
        borderRadius: BorderRadius.circular(17),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1646),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: const Color(0xFF66529A),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFFFC75D),
                    size: 17,
                  ),
                  const SizedBox(width: 5),
                  const Expanded(
                    child: Text(
                      'Weekly Leaderboard',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFBDB3DB),
                    size: 17,
                  ),
                ],
              ),
              const Spacer(),
              if (_opening)
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFFC75D),
                    strokeWidth: 2,
                  ),
                )
              else
                const Icon(
                  Icons.leaderboard_rounded,
                  color: Color(0xFFB58AFF),
                  size: 36,
                ),
              const SizedBox(height: 7),
              const Text(
                'Compete each week',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'View global rankings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFBDB3DB),
                  fontSize: 11,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeChallengeFriendCard extends StatelessWidget {
  const HomeChallengeFriendCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF432350),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE073C0),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.groups_rounded,
            color: Color(0xFFF073C0),
            size: 25,
          ),
          const SizedBox(width: 7),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Challenge a Friend',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Coming Soon',
                  style: TextStyle(
                    color: Color(0xFFFFA9D8),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.lock_clock_rounded,
            color: Color(0xFFFFA9D8),
            size: 19,
          ),
        ],
      ),
    );
  }
}
