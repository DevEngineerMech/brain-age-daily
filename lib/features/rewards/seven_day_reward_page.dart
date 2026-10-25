
import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/daily_missions_service.dart';
import '../games/shared/game_theme.dart';
import 'present_open_animation.dart';

class SevenDayRewardPage extends StatefulWidget {
  const SevenDayRewardPage({super.key});

  @override
  State<SevenDayRewardPage> createState() =>
      _SevenDayRewardPageState();
}

class _SevenDayRewardPageState extends State<SevenDayRewardPage>
    with WidgetsBindingObserver {
  static const rewards = [20, 30, 40, 50, 60, 80, 150];

  Map<String, dynamic> _state = {};
  bool _loading = true;
  bool _claiming = false;
  Timer? _clock;

  Duration _remaining = Duration.zero;

  int get _day => (_state['step'] as num?)?.toInt() ?? 1;
  int get _coins => (_state['coins'] as num?)?.toInt() ?? 0;
  bool get _claimed => _state['claimedToday'] == true;
  bool get _eligible => _state['eligible'] == true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _load();

    _clock = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;

        final now = DateTime.now();
        final next = DateTime(
          now.year,
          now.month,
          now.day + 1,
        );

        final remaining = next.difference(now);

        setState(() => _remaining = remaining);

        if (remaining.inSeconds <= 1) {
          _load();
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clock?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final result =
          await DailyMissionsService.getCalendarState();

      if (!mounted) return;

      setState(() {
        _state = result;
        _loading = false;
      });
    } catch (error) {
      debugPrint('Reward calendar error: $error');

      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openGift() async {
    if (_claiming || !_eligible || _claimed) return;

    setState(() => _claiming = true);

    final day = _day;

    try {
      // Grant and save the reward first.
      // The animation only celebrates a successful grant.
      final reward =
          await DailyMissionsService.claimCalendarGift();

      if (reward <= 0) {
        await _load();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'This gift is not available to claim.',
              ),
            ),
          );
        }
        return;
      }

      await _load();

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PresentOpenAnimation(
          day: day,
          coins: reward,
        ),
      );

      await _load();
    } catch (error) {
      debugPrint('Gift claim error: $error');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to save your reward.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _claiming = false);
    }
  }

  String _clockText() {
    final seconds = _remaining.inSeconds.clamp(0, 86400);
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;

    String two(int n) => n.toString().padLeft(2, '0');

    return '${two(h)}:${two(m)}:${two(s)}';
  }

  Widget _giftCard(int index) {
    final day = index + 1;
    final active = day == _day;
    final completed = day < _day || (active && _claimed);

    final accent = day == 7
        ? GameTheme.gold
        : active
            ? GameTheme.cyan
            : GameTheme.purple;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 14,
      ),
      decoration: GameTheme.card(
        accent: completed ? GameTheme.green : accent,
        radius: 17,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'DAY $day',
            style: TextStyle(
              color: active ? accent : GameTheme.muted,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 11),
          Icon(
            completed
                ? Icons.check_circle_rounded
                : day == 7
                    ? Icons.inventory_2_rounded
                    : Icons.card_giftcard_rounded,
            color: completed ? GameTheme.green : accent,
            size: 37,
          ),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.monetization_on_rounded,
                color: GameTheme.gold,
                size: 17,
              ),
              const SizedBox(width: 3),
              Text(
                '${rewards[index]}',
                style: const TextStyle(
                  color: GameTheme.gold,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            completed
                ? 'COLLECTED'
                : active
                    ? _eligible
                        ? 'READY!'
                        : 'TODAY'
                    : 'LOCKED',
            style: TextStyle(
              color: completed
                  ? GameTheme.green
                  : active
                      ? accent
                      : GameTheme.muted,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    final reward = rewards[(_day - 1).clamp(0, 6)];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: GameTheme.card(accent: GameTheme.gold),
      child: Column(
        children: [
          const Icon(
            Icons.card_giftcard_rounded,
            size: 65,
            color: GameTheme.gold,
          ),
          const SizedBox(height: 12),
          Text(
            'DAY $_day OF 7',
            style: const TextStyle(
              color: GameTheme.gold,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Your Daily Gift',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Complete your Daily Brain Check to unlock '
            'a present. Claim a gift every day to build '
            'your seven-day streak.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: GameTheme.muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            '+$reward Brain Coins',
            style: const TextStyle(
              color: GameTheme.gold,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _eligible &&
                      !_claimed &&
                      !_claiming
                  ? _openGift
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: GameTheme.gold,
                foregroundColor: const Color(0xFF251438),
                disabledBackgroundColor:
                    const Color(0xFF44365F),
                disabledForegroundColor: GameTheme.muted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: Icon(
                _claimed
                    ? Icons.check_circle_rounded
                    : Icons.card_giftcard_rounded,
              ),
              label: Text(
                _claiming
                    ? 'Opening...'
                    : _claimed
                        ? 'Gift Collected!'
                        : _eligible
                            ? 'OPEN TODAY’S PRESENT'
                            : 'Complete Daily Brain Check',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: GameTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: GameTheme.purple,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      14, 9, 14, 30,
                    ),
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () =>
                                Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              '7-Day Rewards',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.monetization_on_rounded,
                            color: GameTheme.gold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$_coins',
                            style: const TextStyle(
                              color: GameTheme.gold,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _hero(),
                      const SizedBox(height: 21),
                      const Text(
                        'YOUR REWARD CALENDAR',
                        style: TextStyle(
                          color: GameTheme.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 11),
                      GridView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount: 7,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisExtent: 158,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) =>
                            _giftCard(index),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration:
                            GameTheme.card(accent: GameTheme.cyan),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.timer_rounded,
                              color: GameTheme.cyan,
                              size: 27,
                            ),
                            const SizedBox(height: 7),
                            const Text(
                              'Next Daily Reset',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _clockText(),
                              style: const TextStyle(
                                color: GameTheme.gold,
                                fontSize: 29,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 7),
                            const Text(
                              'Rewards refresh at local midnight. '
                              'Miss a claim day and the sequence '
                              'starts again at Day 1.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: GameTheme.muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
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
