
import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/daily_missions_service.dart';

class DailyMissionsPage extends StatefulWidget {
  const DailyMissionsPage({super.key});

  @override
  State<DailyMissionsPage> createState() =>
      _DailyMissionsPageState();
}

class _DailyMissionsPageState extends State<DailyMissionsPage>
    with WidgetsBindingObserver {
  static const Color background = Color(0xFF0C0929);
  static const Color panel = Color(0xFF1A1646);
  static const Color gold = Color(0xFFFFC75D);
  static const Color purple = Color(0xFFA87CFF);
  static const Color cyan = Color(0xFF42D9D0);
  static const Color green = Color(0xFF4BE09D);
  static const Color muted = Color(0xFFC5B9DF);

  DailyMissionsSnapshot? _snapshot;
  Timer? _timer;

  bool _loading = true;
  bool _refreshing = false;
  bool _claiming = false;

  int _previousBalance = 0;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _remaining = DailyMissionsService.untilNextRefresh();

    _refresh();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tick(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      _tick();
      _refresh();
    }
  }

  String _todayKey() {
    final now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  void _tick() {
    if (!mounted) return;

    final remaining = DailyMissionsService.untilNextRefresh();

    setState(() {
      _remaining = remaining;
    });

    // Also catches midnight while the page remains open.
    // The date comparison prevents refreshing every second.
    if (_snapshot != null &&
        _snapshot!.dayKey != _todayKey() &&
        !_refreshing &&
        !_claiming) {
      _refresh();
    }
  }

  String _countdownText() {
    final seconds = _remaining.inSeconds;

    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    String two(int value) => value.toString().padLeft(2, '0');

    return '${two(hours)}:'
        '${two(minutes)}:'
        '${two(remainingSeconds)}';
  }

  Future<void> _refresh() async {
    if (_refreshing) return;

    _refreshing = true;

    try {
      final result = await DailyMissionsService.getSnapshot();

      if (!mounted) return;

      final oldDay = _snapshot?.dayKey;

      setState(() {
        _snapshot = result;
        _remaining = DailyMissionsService.untilNextRefresh();
        _loading = false;

        if (oldDay != null && oldDay != result.dayKey) {
          _previousBalance = result.coins;
        }
      });

      if (oldDay != null && oldDay != result.dayKey) {
        _message('✨ New Daily Missions are available!');
      }
    } catch (error) {
      debugPrint('Daily Missions refresh error: $error');

      if (!mounted) return;

      setState(() => _loading = false);
      _message('Could not load your saved missions.');
    } finally {
      _refreshing = false;
    }
  }

  void _message(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF35226D),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _claim(DailyMission mission) async {
    if (_claiming || !mission.completed || mission.claimed) {
      return;
    }

    setState(() => _claiming = true);

    try {
      _previousBalance = _snapshot?.coins ?? 0;

      final awarded =
          await DailyMissionsService.claim(mission.id);

      await _refresh();

      if (awarded) {
        _message(
          '🪙 +${mission.reward} Brain Coins collected!',
        );
      } else {
        _message('This mission is not ready to claim.');
      }
    } catch (error) {
      debugPrint('Mission claim error: $error');
      _message('Could not save your Brain Coins.');
    } finally {
      if (mounted) setState(() => _claiming = false);
    }
  }

  Future<void> _claimBonus() async {
    if (_claiming) return;

    setState(() => _claiming = true);

    try {
      _previousBalance = _snapshot?.coins ?? 0;

      final awarded =
          await DailyMissionsService.claimBonus();

      await _refresh();

      if (awarded) {
        _message('🎉 +50 bonus Brain Coins!');
      } else {
        _message('Claim all three missions first.');
      }
    } catch (error) {
      debugPrint('Bonus claim error: $error');
      _message('Could not save your bonus.');
    } finally {
      if (mounted) setState(() => _claiming = false);
    }
  }

  Color _missionColor(int index) {
    switch (index) {
      case 0:
        return purple;
      case 1:
        return cyan;
      default:
        return green;
    }
  }

  IconData _missionIcon(int index) {
    switch (index) {
      case 0:
        return Icons.psychology_rounded;
      case 1:
        return Icons.sports_esports_rounded;
      default:
        return Icons.bolt_rounded;
    }
  }

  Widget _balance(DailyMissionsSnapshot data) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF35245E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: gold.withOpacity(0.7),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.monetization_on_rounded,
            color: gold,
            size: 21,
          ),
          const SizedBox(width: 5),
          TweenAnimationBuilder<double>(
            key: ValueKey(
              '${data.dayKey}-${data.coins}',
            ),
            tween: Tween(
              begin: _previousBalance.toDouble(),
              end: data.coins.toDouble(),
            ),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Text(
                value.round().toString(),
                style: const TextStyle(
                  color: gold,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              );
            },
            onEnd: () {
              _previousBalance = data.coins;
            },
          ),
        ],
      ),
    );
  }

  Widget _countdownCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF272052),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFF8C6DCF),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: gold.withOpacity(0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.timer_rounded,
              color: gold,
              size: 26,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Daily Missions',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'New missions every night at midnight',
                  style: TextStyle(
                    color: muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _countdownText(),
            style: const TextStyle(
              color: gold,
              fontWeight: FontWeight.w900,
              fontSize: 19,
              fontFeatures: [
                FontFeature.tabularFigures(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero(DailyMissionsSnapshot data) {
    final completed = data.completedCount;
    final count = data.missions.length;
    final fraction = count == 0 ? 0.0 : completed / count;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: const Color(0xFF9F75F4),
        ),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF51238E),
            Color(0xFF29205F),
            Color(0xFF182251),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR DAILY OBJECTIVES',
            style: TextStyle(
              color: gold,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Train. Earn. Unlock.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Complete personalised missions to earn '
            'Brain Coins for future arcade games, '
            'power-ups and customisations.',
            style: TextStyle(
              color: muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: gold,
                size: 21,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$completed of $count missions completed',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '${(fraction * 100).round()}%',
                style: const TextStyle(
                  color: gold,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 9,
              color: gold,
              backgroundColor: const Color(0xFF584488),
            ),
          ),
        ],
      ),
    );
  }

  Widget _missionCard(DailyMission mission, int index) {
    final accent = _missionColor(index);
    final completed = mission.completed;
    final claimed = mission.claimed;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Color.lerp(panel, accent, 0.19)!,
            panel,
          ],
        ),
        border: Border.all(
          color: accent.withOpacity(completed ? 0.9 : 0.55),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: accent.withOpacity(0.7),
                  ),
                ),
                child: Icon(
                  claimed
                      ? Icons.check_circle_rounded
                      : _missionIcon(index),
                  color: accent,
                  size: 29,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MISSION ${index + 1}',
                      style: TextStyle(
                        color: accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mission.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      mission.description,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (claimed)
                const Icon(
                  Icons.check_circle_rounded,
                  color: green,
                  size: 23,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${mission.progress} / ${mission.target}',
                style: TextStyle(
                  color: completed ? accent : muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on_rounded,
                    color: gold,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+${mission.reward}',
                    style: const TextStyle(
                      color: gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: LinearProgressIndicator(
              value: mission.fraction,
              minHeight: 8,
              color: accent,
              backgroundColor: accent.withOpacity(0.13),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 43,
            child: ElevatedButton.icon(
              onPressed: completed && !claimed && !_claiming
                  ? () => _claim(mission)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: const Color(0xFF160E34),
                disabledBackgroundColor:
                    const Color(0xFF39305D),
                disabledForegroundColor:
                    claimed ? green : muted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              icon: Icon(
                claimed
                    ? Icons.check_rounded
                    : completed
                        ? Icons.card_giftcard_rounded
                        : Icons.lock_outline_rounded,
                size: 19,
              ),
              label: Text(
                claimed
                    ? 'Reward Collected'
                    : completed
                        ? 'Claim ${mission.reward} Coins'
                        : 'Keep Playing',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bonus(DailyMissionsSnapshot data) {
    final ready = data.canClaimBonus;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF493173),
            Color(0xFF29204F),
          ],
        ),
        border: Border.all(
          color: ready ? gold : const Color(0xFF735999),
          width: ready ? 1.6 : 1,
        ),
        boxShadow: ready
            ? const [
                BoxShadow(
                  color: Color(0x55FFC75D),
                  blurRadius: 17,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                data.bonusClaimed
                    ? Icons.verified_rounded
                    : Icons.card_giftcard_rounded,
                color: gold,
                size: 39,
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Completion Bonus',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Claim all three mission rewards to unlock.',
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Column(
                children: [
                  Icon(
                    Icons.monetization_on_rounded,
                    color: gold,
                  ),
                  Text(
                    '+50',
                    style: TextStyle(
                      color: gold,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed:
                  ready && !_claiming ? _claimBonus : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: const Color(0xFF241345),
                disabledBackgroundColor:
                    const Color(0xFF40345D),
                disabledForegroundColor: muted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: Text(
                data.bonusClaimed
                    ? 'Bonus Collected!'
                    : ready
                        ? 'Collect 50 Bonus Coins'
                        : 'Complete & Claim All Missions',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shopPreview() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFF675094),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.storefront_rounded,
            color: gold,
            size: 30,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Brain Arcade & Shop',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Save Brain Coins for upcoming arcade '
                  'games, power-ups and customisations.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.lock_clock_rounded,
            color: purple,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _snapshot;

    return Scaffold(
      backgroundColor: background,
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
                    color: purple,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      14, 10, 14, 28,
                    ),
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () =>
                                Navigator.pop(context),
                            style: IconButton.styleFrom(
                              backgroundColor: panel,
                            ),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Daily Missions',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (data != null) _balance(data),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _countdownCard(),
                      const SizedBox(height: 13),
                      if (data != null) ...[
                        _hero(data),
                        const SizedBox(height: 18),
                        const Text(
                          'TODAY’S MISSIONS',
                          style: TextStyle(
                            color: gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (int i = 0;
                            i < data.missions.length;
                            i++) ...[
                          _missionCard(data.missions[i], i),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 4),
                        _bonus(data),
                        const SizedBox(height: 16),
                        _shopPreview(),
                      ] else
                        Center(
                          child: TextButton(
                            onPressed: _refresh,
                            child: const Text(
                              'Retry loading missions',
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
