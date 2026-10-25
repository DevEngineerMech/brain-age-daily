
import 'package:flutter/material.dart';

import '../../core/services/achievements_service.dart';
import '../../core/services/daily_hearts_service.dart';
import '../../core/services/daily_missions_service.dart';

import '../mystery_bonus/mystery_bonus_page.dart';
import '../rewards/seven_day_reward_page.dart';
import '../shop/brain_shop_page.dart';

import 'home_animations.dart';
import '../social/home_social_cards.dart';

class HomeStyle extends StatelessWidget {
  final int brainAge;
  final int userAge;
  final int totalChecks;
  final int currentStreak;
  final int hearts;

  final bool notificationsEnabled;
  final bool notificationBusy;
  final AchievementUpdate? achievements;

  final VoidCallback onEditAge;
  final ValueChanged<bool> onNotificationsChanged;
  final VoidCallback onStartDaily;
  final VoidCallback onWatchAdForHeart;
  final VoidCallback onDailyResults;
  final VoidCallback onFreePlay;
  final VoidCallback onProgress;
  final VoidCallback onAchievements;
  final VoidCallback onDailyMissions;
  final ValueChanged<String> onComingSoon;

  const HomeStyle({
    super.key,
    required this.brainAge,
    required this.userAge,
    required this.totalChecks,
    required this.currentStreak,
    required this.hearts,
    required this.notificationsEnabled,
    required this.notificationBusy,
    required this.achievements,
    required this.onEditAge,
    required this.onNotificationsChanged,
    required this.onStartDaily,
    required this.onWatchAdForHeart,
    required this.onDailyResults,
    required this.onFreePlay,
    required this.onProgress,
    required this.onAchievements,
    required this.onDailyMissions,
    required this.onComingSoon,
  });

  static const Color bg = Color(0xFF0C0929);
  static const Color panel = Color(0xFF1A1646);
  static const Color gold = Color(0xFFFFC75D);
  static const Color muted = Color(0xFFBDB3DB);
  static const Color cyan = Color(0xFF42D9D0);

  BoxDecoration _decoration({
    Color? color,
    Color? border,
  }) {
    return BoxDecoration(
      color: color ?? panel,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(
        color: border ?? const Color(0xFF51418C),
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 9,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  Widget _card({
    required Widget child,
    required VoidCallback onTap,
    Color? color,
    Color? border,
    EdgeInsetsGeometry padding = const EdgeInsets.all(12),
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Ink(
          padding: padding,
          decoration: _decoration(
            color: color,
            border: border,
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _heading(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: gold, size: 17),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const Icon(
          Icons.chevron_right_rounded,
          color: muted,
          size: 16,
        ),
      ],
    );
  }

  Widget _header() {
    return Row(
      children: [
        const Icon(
          Icons.psychology_rounded,
          color: Color(0xFFC47AFF),
          size: 29,
        ),
        const SizedBox(width: 6),
        const Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Brain Age Daily',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        Container(
          height: 39,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 9),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
              Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: notificationsEnabled,
                  onChanged: notificationBusy
                      ? null
                      : onNotificationsChanged,
                  activeColor: gold,
                  activeTrackColor: Colors.white,
                  inactiveThumbColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Edit your age',
          onPressed: onEditAge,
          icon: const Icon(
            Icons.settings_rounded,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _brainAgeDescription() {
    if (totalChecks == 0) {
      return 'Complete your first Daily Brain Check';
    }

    final difference = userAge - brainAge;

    if (difference >= 3) {
      return 'You perform like someone '
          '$difference years younger.';
    }

    if (difference <= -3) {
      return 'Your result is '
          '${difference.abs()} years above your age.';
    }

    return 'Your result is close to your age range.';
  }

  Widget _brainAgeCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 16, 13, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF9250E5),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF32156E),
            Color(0xFF211052),
            Color(0xFF111541),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.workspace_premium_rounded,
                          color: gold,
                          size: 18,
                        ),
                        SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'YOUR BRAIN AGE',
                            maxLines: 1,
                            style: TextStyle(
                              color: Color(0xFFFFDC99),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: 0,
                        end: brainAge.toDouble(),
                      ),
                      duration: const Duration(
                        milliseconds: 900,
                      ),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Text(
                          value.round().toString(),
                          style: const TextStyle(
                            color: Color(0xFFFFDB95),
                            fontSize: 75,
                            height: 1.15,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(
                                color: Color(0xAAF89240),
                                blurRadius: 13,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Text(
                      _brainAgeDescription(),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const HomeFloatingBrain(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF392071),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFF9259D3),
                        ),
                      ),
                      child: FittedBox(
                        child: Text(
                          '🔥 $currentStreak day streak',
                          style: const TextStyle(
                            color: gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    HomePulsingHearts(hearts: hearts),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 57,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFE64CFF),
                  Color(0xFF8538F9),
                  Color(0xFF593EF5),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFFFFBBFF),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x886E38FF),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onStartDaily,
                borderRadius: BorderRadius.circular(30),
                child: const Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'Start Daily Brain Check',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(width: 7),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onDailyResults,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(
                  color: Color(0xFFB19BFF),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              icon: const Icon(Icons.bar_chart_rounded),
              label: const Text(
                'View Daily Results',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          if (hearts < DailyHeartsService.maxHearts) ...[
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: onWatchAdForHeart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD247),
                foregroundColor: const Color(0xFF35125A),
              ),
              icon: const Icon(
                Icons.play_circle_fill_rounded,
              ),
              label: const Text(
                'Watch Ad for +1 Heart',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _quickTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _card(
      onTap: onTap,
      color: Color.lerp(panel, color, 0.24),
      border: color.withOpacity(0.7),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.white70,
            size: 17,
          ),
        ],
      ),
    );
  }

  Widget _leaderboard() {
    return _card(
      onTap: () => onComingSoon('Weekly Leaderboard'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _heading(
            Icons.emoji_events_rounded,
            'Weekly Leaderboard',
          ),
          const Spacer(),
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
            'Coming soon',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _achievements() {
    final count = achievements?.unlockedCount ?? 0;
    final total = AchievementsService.all.length;

    final earned = achievements?.badges
            .where((item) => item.unlocked)
            .toList() ??
        <BadgeProgress>[];

    final locked = achievements?.badges
            .where((item) => !item.unlocked)
            .toList() ??
        <BadgeProgress>[];

    final preview = <BadgeProgress>[
      ...earned.reversed,
      ...locked,
    ].take(3).toList();

    return _card(
      onTap: onAchievements,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _heading(
            Icons.military_tech_rounded,
            'Achievements',
          ),
          const SizedBox(height: 8),
          Text(
            '$count / $total unlocked',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: gold,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: preview.isEmpty
                ? const Center(
                    child: Text(
                      'Loading badges...',
                      style: TextStyle(
                        color: muted,
                        fontSize: 10,
                      ),
                    ),
                  )
                : Row(
                    children: preview.map((item) {
                      final unlocked = item.unlocked;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                          ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: item.badge.color.withOpacity(
                                    unlocked ? 0.18 : 0.09,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(11),
                                  border: Border.all(
                                    color: item.badge.color.withOpacity(
                                      unlocked ? 1 : 0.45,
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  item.badge.icon,
                                  color: item.badge.color.withOpacity(
                                    unlocked ? 1 : 0.6,
                                  ),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                item.badge.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : count / total,
              minHeight: 5,
              backgroundColor: const Color(0xFF3B315C),
              color: gold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _missions() {
    return HomeAnimatedMissionsCard(
      onOpen: onDailyMissions,
    );
  }

  Widget _friendCard() {
    return _card(
      onTap: () => onComingSoon('Challenge a Friend'),
      color: const Color(0xFF432350),
      border: const Color(0xFFE073C0),
      child: const Row(
        children: [
          Icon(
            Icons.groups_rounded,
            color: Color(0xFFF073C0),
            size: 25,
          ),
          SizedBox(width: 7),
          Expanded(
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
                const SizedBox(height: 3),
                const Text(
                  'Share a brain challenge',
                  style: TextStyle(
                    color: muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.white70,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E104A),
            Color(0xFF080D2A),
            Color(0xFF100A2F),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            13, 10, 13, 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              const SizedBox(height: 10),
              _brainAgeCard(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _quickTile(
                      title: 'Free Play',
                      subtitle: 'Unlimited training',
                      icon: Icons.sports_esports_rounded,
                      color: const Color(0xFF9C78FF),
                      onTap: onFreePlay,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _quickTile(
                      title: 'Progress',
                      subtitle: 'Graphs & stats',
                      icon: Icons.bar_chart_rounded,
                      color: cyan,
                      onTap: onProgress,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              SizedBox(
  height: 169,
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Expanded(
        child: HomeLeaderboardCard(),
      ),
      const SizedBox(width: 9),
      Expanded(
        child: _achievements(),
      ),
    ],
  ),
),
              const SizedBox(height: 11),
              _missions(),
              const SizedBox(height: 11),
              const _HomeBrainShopCard(),
              const SizedBox(height: 11),
              
SizedBox(
  height: 87,
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Expanded(
        child: HomeChallengeFriendCard(),
      ),
      const SizedBox(width: 9),
      const Expanded(
        child: _HomeMysteryBonusCard(),
      ),
    ],
  ),
),

              const SizedBox(height: 11),
              const _HomeSevenDayRewardCard(),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: onEditAge,
                icon: const Icon(
                  Icons.person_outline_rounded,
                  size: 17,
                ),
                label: Text(
                  'Your Age: $userAge  ·  Edit',
                  style: const TextStyle(
                    color: Color(0xFFCCB8FF),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// BRAIN SHOP HOME CARD
// =====================================================

class _HomeBrainShopCard extends StatefulWidget {
  const _HomeBrainShopCard();

  @override
  State<_HomeBrainShopCard> createState() =>
      _HomeBrainShopCardState();
}

class _HomeBrainShopCardState
    extends State<_HomeBrainShopCard> {
  late Future<Map<String, dynamic>> _wallet;

  @override
  void initState() {
    super.initState();
    _wallet = DailyMissionsService.getShopState();
  }

  Future<void> _openShop() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const BrainShopPage(),
      ),
    );

    if (mounted) {
      setState(() {
        _wallet = DailyMissionsService.getShopState();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openShop,
        borderRadius: BorderRadius.circular(17),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF271B4A),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: const Color(0xFFFFC75D),
            ),
          ),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _wallet,
            builder: (context, snapshot) {
              final coins =
                  (snapshot.data?['coins'] as num?)?.toInt() ?? 0;

              return Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0x33FFC75D),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Color(0xFFFFC75D),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Brain Shop',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Arcade • Power-ups • Customisation',
                          style: TextStyle(
                            color: Color(0xFFBDB3DB),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.monetization_on_rounded,
                        color: Color(0xFFFFC75D),
                        size: 22,
                      ),
                      Text(
                        snapshot.hasError ? '—' : '$coins',
                        style: const TextStyle(
                          color: Color(0xFFFFC75D),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFFFC75D),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// =====================================================
// LIVE MYSTERY BONUS HOME CARD
// =====================================================

class _HomeMysteryBonusCard extends StatefulWidget {
  const _HomeMysteryBonusCard();

  @override
  State<_HomeMysteryBonusCard> createState() =>
      _HomeMysteryBonusCardState();
}

class _HomeMysteryBonusCardState
    extends State<_HomeMysteryBonusCard> {
  Future<Map<String, dynamic>>? _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _future = DailyMissionsService.getMysteryBonusState();
  }

  Future<void> _open() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MysteryBonusPage(),
      ),
    );

    if (mounted) {
      setState(_refresh);
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomeAnimatedMysteryBorder(
      child: Material(
        color: const Color(0xFF372443),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _open,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: FutureBuilder<Map<String, dynamic>>(
              future: _future,
              builder: (context, snapshot) {
                final status =
                    snapshot.data?['status']?.toString() ??
                    'ready';

                final completed = status == 'completed';
                final used =
                    status == 'started' || completed;

                return Row(
                  children: [
                    Icon(
                      completed
                          ? Icons.check_circle_rounded
                          : Icons.help_center_rounded,
                      color: completed
                          ? const Color(0xFF4BE09D)
                          : const Color(0xFFFFC75D),
                      size: 27,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mystery Bonus',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            used
                                ? completed
                                    ? 'Collected today!'
                                    : 'Attempt used today'
                                : 'Reveal today’s surprise!',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFBDB3DB),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFFFC75D),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// LIVE SEVEN-DAY REWARD HOME CARD
// =====================================================

class _HomeSevenDayRewardCard extends StatefulWidget {
  const _HomeSevenDayRewardCard();

  @override
  State<_HomeSevenDayRewardCard> createState() =>
      _HomeSevenDayRewardCardState();
}

class _HomeSevenDayRewardCardState
    extends State<_HomeSevenDayRewardCard>
    with WidgetsBindingObserver {
  static const Color gold = Color(0xFFFFC75D);
  static const Color cyan = Color(0xFF42D9D0);
  static const Color green = Color(0xFF4BE09D);
  static const Color muted = Color(0xFFBDB3DB);

  Map<String, dynamic>? _calendar;
  bool _loading = true;
  bool _opening = false;

  int get _day {
    final value =
        (_calendar?['step'] as num?)?.toInt() ?? 1;

    return value.clamp(1, 7);
  }

  bool get _claimedToday =>
      _calendar?['claimedToday'] == true;

  bool get _eligible =>
      _calendar?['eligible'] == true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCalendar();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadCalendar();
    }
  }

  Future<void> _loadCalendar() async {
    try {
      final result =
          await DailyMissionsService.getCalendarState();

      if (!mounted) return;

      setState(() {
        _calendar = result;
        _loading = false;
      });
    } catch (error) {
      debugPrint('Home calendar error: $error');

      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openCalendar() async {
    if (_opening) return;

    setState(() => _opening = true);

    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const SevenDayRewardPage(),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _opening = false);
        await _loadCalendar();
      }
    }
  }

  Widget _dayTile(int day) {
    final current = day == _day;

    final collected =
        day < _day || (current && _claimedToday);

    final ready =
        current && _eligible && !_claimedToday;

    final accent = collected
        ? green
        : ready
            ? gold
            : current
                ? cyan
                : const Color(0xFF8E7ABB);

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: current
              ? accent.withOpacity(0.2)
              : const Color(0xFF26204F),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: current
                ? accent
                : collected
                    ? green.withOpacity(0.65)
                    : const Color(0xFF54477F),
            width: current ? 1.8 : 1,
          ),
          boxShadow: [
            if (ready)
              BoxShadow(
                color: gold.withOpacity(0.24),
                blurRadius: 11,
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$day',
              style: TextStyle(
                color: current ? accent : Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Icon(
              collected
                  ? Icons.check_circle_rounded
                  : day == 7
                      ? Icons.inventory_2_rounded
                      : Icons.card_giftcard_rounded,
              color: accent,
              size: 19,
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 10,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  collected
                      ? '✓'
                      : current
                          ? 'TODAY'
                          : '',
                  style: TextStyle(
                    color: accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _status {
    if (_loading) {
      return 'Loading your reward progress...';
    }

    if (_calendar == null) {
      return 'Unable to load reward progress';
    }

    if (_claimedToday) {
      return 'Day $_day collected! Come back tomorrow.';
    }

    if (_eligible) {
      return 'Day $_day gift ready! Tap to open it.';
    }

    return 'Day $_day — complete your Daily Brain Check.';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _claimedToday
        ? green
        : _eligible
            ? gold
            : muted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _opening ? null : _openCalendar,
        borderRadius: BorderRadius.circular(17),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1646),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: _eligible && !_claimedToday
                  ? gold
                  : const Color(0xFF51418C),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.card_giftcard_rounded,
                    color: gold,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      '7-Day Reward Calendar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (!_loading && _calendar != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: cyan.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: cyan.withOpacity(0.7),
                        ),
                      ),
                      child: Text(
                        'Day $_day / 7',
                        style: const TextStyle(
                          color: cyan,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: muted,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 7),
              const Text(
                'Complete daily checks to open gifts',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(
                  7,
                  (index) => _dayTile(index + 1),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    _claimedToday
                        ? Icons.check_circle_rounded
                        : _eligible
                            ? Icons.redeem_rounded
                            : Icons.monetization_on_rounded,
                    color: statusColor,
                    size: 17,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _status,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: gold,
                    size: 19,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
