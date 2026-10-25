
import 'package:flutter/material.dart';

import '../../core/services/achievements_service.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() =>
      _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  static const Color bg = Color(0xFF0C0929);
  static const Color panel = Color(0xFF1A1646);
  static const Color gold = Color(0xFFFFC75D);
  static const Color muted = Color(0xFFC5B9DF);

  AchievementUpdate? _data;
  bool _loading = true;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await AchievementsService.refresh();

      if (!mounted) return;

      setState(() {
        _data = result;
        _loading = false;
      });

      if (result.newlyUnlocked.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showUnlock(result.newlyUnlocked);
          }
        });
      }
    } catch (error) {
      debugPrint('Achievement loading error: $error');
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showUnlock(List<BadgeProgress> badges) {
    if (badges.isEmpty) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF251451),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: gold, width: 1.5),
          ),
          title: const Text(
            '🏆 Achievement Unlocked!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: gold,
              fontWeight: FontWeight.w900,
              fontSize: 19,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                badges.first.badge.icon,
                color: badges.first.badge.color,
                size: 65,
              ),
              const SizedBox(height: 12),
              Text(
                badges.length == 1
                    ? badges.first.badge.title
                    : '${badges.length} New Badges',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                badges.length == 1
                    ? badges.first.badge.description
                    : badges.map((b) => b.badge.title).join(' • '),
                textAlign: TextAlign.center,
                style: const TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Collect!',
                style: TextStyle(color: gold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDetails(BadgeProgress item) {
    final badge = item.badge;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF21184B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: badge.color),
          ),
          title: Column(
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badge.color.withOpacity(0.2),
                  border: Border.all(color: badge.color),
                ),
                child: Icon(
                  badge.icon,
                  size: 46,
                  color: badge.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                badge.title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                badge.description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: muted),
              ),
              const SizedBox(height: 15),
              if (item.unlocked)
                Text(
                  'Unlocked ${_formatDate(item.unlockedAt!)}',
                  style: const TextStyle(
                    color: gold,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else ...[
                Text(
                  item.progressText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: item.fraction,
                    minHeight: 8,
                    color: badge.color,
                    backgroundColor: const Color(0xFF50416F),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Close',
                style: TextStyle(color: gold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _header() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: panel,
          ),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 9),
        const Expanded(
          child: Text(
            'Achievements',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const Icon(
          Icons.workspace_premium_rounded,
          color: gold,
          size: 29,
        ),
      ],
    );
  }

  Widget _summary(AchievementUpdate data) {
    final unlocked = data.unlockedCount;
    final total = AchievementsService.all.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5325A0),
            Color(0xFF251559),
            Color(0xFF17265A),
          ],
        ),
        border: Border.all(color: const Color(0xFFAC80FF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 67,
                height: 67,
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.17),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: gold.withOpacity(0.7),
                  ),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: gold,
                  size: 40,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR COLLECTION',
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$unlocked / $total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 31,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'Badges earned',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: TweenAnimationBuilder<double>(
              tween: Tween(
                begin: 0,
                end: total == 0 ? 0 : unlocked / total,
              ),
              duration: const Duration(milliseconds: 850),
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 9,
                  color: gold,
                  backgroundColor: const Color(0xFF554485),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgeCard(BadgeProgress item) {
    final badge = item.badge;
    final unlocked = item.unlocked;
    final accent = badge.color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showDetails(item),
        borderRadius: BorderRadius.circular(17),
        child: Ink(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(panel, accent, unlocked ? 0.29 : 0.17)!,
                const Color(0xFF17143B),
              ],
            ),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: accent.withOpacity(unlocked ? 0.95 : 0.60),
              width: unlocked ? 1.5 : 1,
            ),
            boxShadow: unlocked
                ? [
                    BoxShadow(
                      color: accent.withOpacity(0.22),
                      blurRadius: 15,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(
                        unlocked ? 0.28 : 0.17,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: accent.withOpacity(0.85),
                      ),
                    ),
                    child: Icon(
                      badge.icon,
                      color: accent.withOpacity(
                        unlocked ? 1 : 0.80,
                      ),
                      size: 31,
                    ),
                  ),
                  Positioned(
                    right: -5,
                    bottom: -5,
                    child: Container(
                      width: 19,
                      height: 19,
                      decoration: BoxDecoration(
                        color: unlocked
                            ? const Color(0xFF1D9D78)
                            : const Color(0xFF41345F),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF17143B),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        unlocked
                            ? Icons.check_rounded
                            : Icons.lock_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                badge.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 7),
              if (unlocked)
                const Text(
                  'UNLOCKED',
                  style: TextStyle(
                    color: gold,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                )
              else
                Text(
                  item.progressText,
                  style: TextStyle(
                    color: accent.withOpacity(0.90),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: item.fraction,
                  minHeight: 4,
                  backgroundColor: accent.withOpacity(0.13),
                  color: accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filters() {
    return Row(
      children: ['All', 'Unlocked', 'Locked'].map((filter) {
        final selected = filter == _filter;

        return Padding(
          padding: const EdgeInsets.only(right: 7),
          child: ChoiceChip(
            label: Text(filter),
            selected: selected,
            onSelected: (_) => setState(() => _filter = filter),
            selectedColor: const Color(0xFF8246F2),
            backgroundColor: panel,
            side: BorderSide(
              color: selected
                  ? const Color(0xFFAE8AFF)
                  : const Color(0xFF66538F),
            ),
            labelStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final badges = _data?.badges ?? <BadgeProgress>[];

    final filtered = badges.where((item) {
      if (_filter == 'Unlocked') return item.unlocked;
      if (_filter == 'Locked') return !item.unlocked;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      body: Container(
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
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: gold,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          12, 10, 12, 8,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _header(),
                            const SizedBox(height: 15),
                            if (_data != null) _summary(_data!),
                            const SizedBox(height: 12),
                            _filters(),
                            const SizedBox(height: 9),
                          ]),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          12, 0, 12, 24,
                        ),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                _badgeCard(filtered[index]),
                            childCount: filtered.length,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisExtent: 165,
                            crossAxisSpacing: 9,
                            mainAxisSpacing: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
