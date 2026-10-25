
import 'package:flutter/material.dart';

import '../../core/services/daily_missions_service.dart';
import '../games/shared/game_theme.dart';

import 'mystery_games.dart';

class MysteryBonusPage extends StatefulWidget {
  const MysteryBonusPage({super.key});

  @override
  State<MysteryBonusPage> createState() =>
      _MysteryBonusPageState();
}

class _MysteryBonusPageState extends State<MysteryBonusPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _revealController;

  Map<String, dynamic>? _state;

  bool _loading = true;
  bool _busy = false;
  bool _playing = false;
  bool _showResult = false;

  int _performance = 0;
  int _reward = 0;

  String get _gameId =>
      _state?['game']?.toString() ?? 'shuffle';

  String get _status =>
      _state?['status']?.toString() ?? 'ready';

  int get _balance =>
      (_state?['coins'] as num?)?.toInt() ?? 0;

  bool get _available => _status == 'ready';

  String _gameName(String id) {
    switch (id) {
      case 'shuffle':
        return 'Brain Shuffle';
      case 'rush':
        return 'Golden Rush';
      case 'missing':
        return 'What’s Missing?';
      default:
        return 'Mystery Bonus';
    }
  }

  IconData _gameIcon(String id) {
    switch (id) {
      case 'shuffle':
        return Icons.psychology_rounded;
      case 'rush':
        return Icons.bolt_rounded;
      case 'missing':
        return Icons.visibility_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  Color _gameColour(String id) {
    switch (id) {
      case 'shuffle':
        return GameTheme.cyan;
      case 'rush':
        return GameTheme.gold;
      case 'missing':
        return const Color(0xFFFF81BE);
      default:
        return GameTheme.purple;
    }
  }

  @override
  void initState() {
    super.initState();

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    );

    _load();
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final value =
          await DailyMissionsService.getMysteryBonusState();

      if (!mounted) return;

      setState(() {
        _state = value;
        _loading = false;
      });
    } catch (error) {
      debugPrint('Mystery Bonus load error: $error');

      if (mounted) {
        setState(() => _loading = false);
        _notice('Unable to load today’s mystery.');
      }
    }
  }

  void _notice(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: GameTheme.panel,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _start() async {
    if (_busy || !_available || _playing) return;

    setState(() => _busy = true);

    try {
      // Mark the attempt as used BEFORE revealing
      // the game. It cannot be rerolled by restarting.
      final success =
          await DailyMissionsService.startMysteryBonus();

      await _load();

      if (!mounted) return;

      if (!success) {
        _notice('Today’s attempt is no longer available.');
        return;
      }

      await _revealController.forward(from: 0);

      if (!mounted) return;

      setState(() {
        _playing = true;
        _showResult = false;
      });
    } catch (error) {
      debugPrint('Mystery start error: $error');
      _notice('Could not start the challenge.');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _finish(int performance) async {
    if (_busy || _showResult) return;

    setState(() => _busy = true);

    final safePerformance = performance.clamp(0, 100);

    try {
      final earned =
          await DailyMissionsService.finishMysteryBonus(
        safePerformance,
      );

      await _load();

      if (!mounted) return;

      setState(() {
        _performance = safePerformance;
        _reward = earned;
        _playing = false;
        _showResult = true;
      });
    } catch (error) {
      debugPrint('Mystery reward error: $error');
      _notice('Could not save the result. Please reopen this page.');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Widget _selectedGame() {
    switch (_gameId) {
      case 'rush':
        return GoldenRushGame(onFinished: _finish);
      case 'missing':
        return WhatsMissingGame(onFinished: _finish);
      default:
        return BrainShuffleGame(onFinished: _finish);
    }
  }

  Widget _header() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: GameTheme.panel,
            side: const BorderSide(
              color: GameTheme.border,
            ),
          ),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 9),
        const Expanded(
          child: Text(
            'Mystery Bonus',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 23,
            ),
          ),
        ),
        const Icon(
          Icons.monetization_on_rounded,
          color: GameTheme.gold,
        ),
        const SizedBox(width: 5),
        Text(
          '$_balance',
          style: const TextStyle(
            color: GameTheme.gold,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _readyView() {
    final accent = _gameColour(_gameId);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: GameTheme.card(
        accent: GameTheme.gold,
        radius: 25,
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          AnimatedBuilder(
            animation: _revealController,
            builder: (context, child) {
              final value = _revealController.value;

              return Transform.scale(
                scale: 1 + value * 0.3,
                child: Transform.rotate(
                  angle: value * 6.28318530718,
                  child: Container(
                    width: 132,
                    height: 132,
                    decoration: BoxDecoration(
                      color: GameTheme.purple.withOpacity(0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: GameTheme.gold,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: GameTheme.gold.withOpacity(
                            0.15 + value * 0.45,
                          ),
                          blurRadius: 20 + 40 * value,
                        ),
                      ],
                    ),
                    child: Icon(
                      value < 0.55
                          ? Icons.help_rounded
                          : _gameIcon(_gameId),
                      color: value < 0.55
                          ? GameTheme.gold
                          : accent,
                      size: 75,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 23),
          const Text(
            'TODAY’S SURPRISE',
            style: TextStyle(
              color: GameTheme.gold,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'What will you get?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'One mystery game every day.\n'
            'Play once and win up to 60 Brain Coins!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: GameTheme.muted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 23),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _busy ? null : _start,
              icon: const Icon(
                Icons.auto_awesome_rounded,
              ),
              label: Text(
                _busy
                    ? 'Revealing...'
                    : 'REVEAL MY MYSTERY',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: GameTheme.gold,
                foregroundColor: GameTheme.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultView() {
    final earned = _reward;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: GameTheme.card(
        accent: GameTheme.gold,
        radius: 23,
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.elasticOut,
            builder: (_, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: const Icon(
              Icons.emoji_events_rounded,
              color: GameTheme.gold,
              size: 87,
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'MYSTERY COMPLETE!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 13),
          Text(
            '$_performance% performance',
            style: const TextStyle(
              color: GameTheme.cyan,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 15),
          const Icon(
            Icons.monetization_on_rounded,
            color: GameTheme.gold,
            size: 61,
          ),
          Text(
            '+$earned',
            style: const TextStyle(
              color: GameTheme.gold,
              fontSize: 49,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            'BRAIN COINS',
            style: TextStyle(
              color: GameTheme.gold,
              letterSpacing: 2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Your reward has been saved.\n'
            'Come back tomorrow for another mystery!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: GameTheme.muted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 19),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: GameTheme.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('COLLECT & RETURN HOME'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _alreadyUsedView() {
    final completed = _status == 'completed';

    final lastReward =
        (_state?['reward'] as num?)?.toInt() ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: GameTheme.card(
        accent: completed
            ? GameTheme.green
            : GameTheme.purple,
      ),
      child: Column(
        children: [
          Icon(
            completed
                ? Icons.check_circle_rounded
                : Icons.hourglass_bottom_rounded,
            color: completed
                ? GameTheme.green
                : GameTheme.purple,
            size: 67,
          ),
          const SizedBox(height: 13),
          Text(
            completed
                ? 'TODAY’S MYSTERY COMPLETE'
                : 'TODAY’S ATTEMPT USED',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 21,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            completed
                ? 'You earned $lastReward Brain Coins '
                    'from ${_gameName(_gameId)}.'
                : 'You started ${_gameName(_gameId)} '
                    'but did not finish it. '
                    'Another challenge will be available tomorrow.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: GameTheme.muted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BACK TO HOME'),
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
              : ListView(
                  padding: const EdgeInsets.fromLTRB(
                    15, 10, 15, 30,
                  ),
                  children: [
                    _header(),
                    const SizedBox(height: 19),
                    if (_showResult)
                      _resultView()
                    else if (_playing)
                      _selectedGame()
                    else if (_available)
                      _readyView()
                    else
                      _alreadyUsedView(),
                  ],
                ),
        ),
      ),
    );
  }
}
