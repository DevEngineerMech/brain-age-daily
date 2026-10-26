
import 'package:flutter/material.dart';

import '../../core/constants/game_ids.dart';
import '../../core/services/daily_missions_service.dart';
import '../games/shared/game_theme.dart';

import '../games/coin_arcade/antonyms/antonyms_page.dart';
import '../games/coin_arcade/biology_quiz/biology_quiz_page.dart';
import '../games/coin_arcade/science_quiz/science_quiz_page.dart';
import '../games/coin_arcade/word_snap/word_snap_page.dart';
import '../games/coin_arcade/word_scramble/word_scramble_page.dart';

import 'brain_shop_catalog.dart';

class CoinArcadeLibraryPage extends StatefulWidget {
  const CoinArcadeLibraryPage({super.key});

  @override
  State<CoinArcadeLibraryPage> createState() =>
      _CoinArcadeLibraryPageState();
}

class _CoinArcadeLibraryPageState
    extends State<CoinArcadeLibraryPage> {
  Map<String, dynamic> _wallet = {};
  bool _loading = true;
  bool _busy = false;

  int get _coins =>
      (_wallet['coins'] as num?)?.toInt() ?? 0;

  int get _passes =>
      (_wallet['passes'] as num?)?.toInt() ?? 0;

  List<String> get _unlocks =>
      List<String>.from(_wallet['unlocks'] ?? []);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final wallet =
          await DailyMissionsService.getShopState();

      if (!mounted) return;

      setState(() {
        _wallet = wallet;
        _loading = false;
      });
    } catch (error) {
      debugPrint('Arcade wallet error: $error');

      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _pageFor(String gameId) {
    switch (gameId) {
      case GameIds.biologyQuiz:
        return const BiologyQuizPage();

      case GameIds.scienceQuiz:
        return const ScienceQuizPage();

      case GameIds.antonyms:
        return const AntonymsPage();

      case GameIds.wordSnap:
        return const WordSnapPage();

      case GameIds.wordScramble:
        return const WordScramblePage();

      default:
        throw ArgumentError.value(
          gameId,
          'gameId',
          'Unknown Arcade game',
        );
    }
  }

  void _notice(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF352161),
        ),
      );
  }

  Future<void> _play(BrainShopItem item) async {
    if (_busy || item.gameId == null) return;

    final gameId = item.gameId!;
    final owned = _unlocks.contains(gameId);

    if (!owned) {
      final hasPass = _passes > 0;
      final cost =
          BrainShopCatalog.singleArcadeEntryPrice;

      final canPay = hasPass || _coins >= cost;

      final allow = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: GameTheme.panel,
          title: Row(
            children: [
              const Icon(
                Icons.lock_rounded,
                color: GameTheme.gold,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            hasPass
                ? 'This game is locked. Use 1 Arcade Pass '
                    'to play once? You have $_passes passes.'
                : canPay
                    ? 'This game is locked. Spend $cost '
                        'Brain Coins for one play? '
                        'You have $_coins coins.'
                    : 'This game is locked. A play costs '
                        '$cost Brain Coins or 1 Arcade Pass. '
                        'You currently have $_coins coins '
                        'and $_passes passes. Earn coins '
                        'from Daily Missions.',
            style: const TextStyle(
              color: GameTheme.muted,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            if (canPay)
              FilledButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, true),
                child: Text(
                  hasPass
                      ? 'Use 1 Pass'
                      : 'Pay $cost Coins',
                ),
              ),
          ],
        ),
      );

      if (allow != true || !mounted) return;
    }

    setState(() => _busy = true);

    int paymentType = 0;
    bool opened = false;

    try {
      final page = _pageFor(gameId);

      paymentType =
          await DailyMissionsService.enterArcadeGame(
        gameId,
      );

      if (paymentType == 0) {
        _notice('Not enough coins or Arcade Passes.');
        return;
      }

      if (!mounted) {
        if (paymentType >= 2) {
          await DailyMissionsService.refundArcadeEntry(
            paymentType,
          );
        }
        return;
      }

      opened = true;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => page,
        ),
      );

      if (mounted) await _load();
    } catch (error) {
      debugPrint(
        'Unable to open Arcade game: $error',
      );

      if (!opened && paymentType >= 2) {
        await DailyMissionsService.refundArcadeEntry(
          paymentType,
        );
      }

      _notice('Unable to open the game.');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Widget _card(
    BrainShopItem item,
    bool compact,
  ) {
    final owned = _unlocks.contains(item.gameId);
    final hasPass = _passes > 0;

    final canAfford = owned ||
        hasPass ||
        _coins >=
            BrainShopCatalog.singleArcadeEntryPrice;

    final subtitle = owned
        ? 'Unlimited plays'
        : hasPass
            ? '1 pass per play'
            : '${BrainShopCatalog.singleArcadeEntryPrice} '
                'coins per play';

    final actionLabel = owned
        ? 'PLAY FREE'
        : hasPass
            ? 'USE PASS'
            : '${BrainShopCatalog.singleArcadeEntryPrice} COINS';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _busy ? null : () => _play(item),
        borderRadius: BorderRadius.circular(15),
        child: Ink(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: owned
                ? const Color(0xFF183B43)
                : const Color(0xFF211B43),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: owned
                  ? GameTheme.green
                  : GameTheme.border,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    owned
                        ? Icons.check_circle_rounded
                        : Icons.lock_rounded,
                    color: owned
                        ? GameTheme.green
                        : GameTheme.gold,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    owned ? 'UNLOCKED' : 'LOCKED',
                    style: TextStyle(
                      color: owned
                          ? GameTheme.green
                          : GameTheme.gold,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Container(
                width: compact ? 40 : 46,
                height: compact ? 40 : 46,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(
                    owned ? 0.18 : 0.09,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                    color: item.color.withOpacity(0.55),
                  ),
                ),
                child: Icon(
                  item.icon,
                  color: item.color.withOpacity(
                    owned ? 1 : 0.7,
                  ),
                  size: compact ? 25 : 29,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Center(
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 10 : 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: GameTheme.muted,
                  fontSize: compact ? 9 : 10,
                ),
              ),
              const SizedBox(height: 9),
              Container(
                height: 29,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: owned
                      ? GameTheme.green.withOpacity(0.22)
                      : canAfford
                          ? GameTheme.gold.withOpacity(
                              0.20,
                            )
                          : GameTheme.red.withOpacity(
                              0.18,
                            ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      owned
                          ? Icons.play_arrow_rounded
                          : canAfford
                              ? Icons.lock_open_rounded
                              : Icons.lock_rounded,
                      size: 14,
                      color: owned
                          ? GameTheme.green
                          : canAfford
                              ? GameTheme.gold
                              : GameTheme.red,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      actionLabel,
                      style: TextStyle(
                        color: owned
                            ? GameTheme.green
                            : canAfford
                                ? GameTheme.gold
                                : GameTheme.red,
                        fontWeight: FontWeight.w900,
                        fontSize: compact ? 9 : 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final games = BrainShopCatalog.items
        .where(
          (item) => item.kind == ShopKind.gameUnlock,
        )
        .toList();

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
                    padding:
                        const EdgeInsets.fromLTRB(
                      13, 9, 13, 25,
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
                              'Knowledge Arcade',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.monetization_on_rounded,
                            color: GameTheme.gold,
                            size: 21,
                          ),
                          Text(
                            ' $_coins',
                            style: const TextStyle(
                              color: GameTheme.gold,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: GameTheme.card(
                          accent: GameTheme.gold,
                          radius: 17,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.confirmation_number_rounded,
                              size: 31,
                              color: GameTheme.cyan,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$_passes Arcade Passes',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                          FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Green = unlocked and free. '
                                    'Gold lock = pay 1 pass or '
                                    '20 coins per play.',
                                    style: TextStyle(
                                      color: GameTheme.muted,
                                      fontSize: 11,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Choose a Game',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width =
                              constraints.maxWidth;

                          final columns = width >= 555
                              ? 4
                              : width >= 410
                                  ? 3
                                  : 2;

                          final compact = columns >= 4;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount: games.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              mainAxisExtent:
                                  compact ? 184 : 192,
                              mainAxisSpacing: 9,
                              crossAxisSpacing: 9,
                            ),
                            itemBuilder: (_, index) =>
                                _card(
                              games[index],
                              compact,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
