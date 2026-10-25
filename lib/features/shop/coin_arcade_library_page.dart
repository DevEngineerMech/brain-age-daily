
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
      final state = await DailyMissionsService.getShopState();

      if (!mounted) return;

      setState(() {
        _wallet = state;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Arcade library error: $e');

      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _pageFor(String id) {
    switch (id) {
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
        throw ArgumentError('Unknown Arcade game: $id');
    }
  }

  Future<void> _play(String id) async {
    if (_busy) return;

    final owned = _unlocks.contains(id);

    if (!owned) {
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: GameTheme.panel,
          title: Text(
            GameIds.label(id),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            _passes > 0
                ? 'Use one Arcade Pass? You have $_passes passes.'
                : 'Play for ${BrainShopCatalog.singleArcadeEntryPrice} '
                    'Brain Coins? You have $_coins coins.',
            style: const TextStyle(
              color: GameTheme.muted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('Play'),
            ),
          ],
        ),
      );

      if (result != true || !mounted) return;
    }

    setState(() => _busy = true);

    int paymentType = 0;
    bool opened = false;

    try {
      final page = _pageFor(id);

      paymentType =
          await DailyMissionsService.enterArcadeGame(id);

      if (paymentType == 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Not enough coins or Arcade Passes.',
              ),
            ),
          );
        }
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
    } catch (e) {
      debugPrint('Arcade game launch error: $e');

      if (!opened && paymentType >= 2) {
        await DailyMissionsService.refundArcadeEntry(
          paymentType,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open the game.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _card(BrainShopItem item) {
    final owned = _unlocks.contains(item.gameId);

    return InkWell(
      onTap: _busy ? null : () => _play(item.gameId!),
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(13),
        decoration: GameTheme.card(
          accent: item.color,
          radius: 20,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  owned
                      ? Icons.verified_rounded
                      : Icons.lock_outline_rounded,
                  color: owned
                      ? GameTheme.green
                      : GameTheme.muted,
                  size: 17,
                ),
                const Spacer(),
                if (owned)
                  const Text(
                    'OWNED',
                    style: TextStyle(
                      color: GameTheme.green,
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.18),
                border: Border.all(color: item.color),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                item.icon,
                color: item.color,
                size: 37,
              ),
            ),
            const SizedBox(height: 11),
            Text(
              item.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              owned
                  ? 'Unlimited plays'
                  : _passes > 0
                      ? 'Use 1 Arcade Pass'
                      : '${BrainShopCatalog.singleArcadeEntryPrice} coins per play',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: GameTheme.muted,
                fontSize: 11,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.play_circle_fill_rounded,
              color: item.color,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final games = BrainShopCatalog.items
        .where((item) => item.kind == ShopKind.gameUnlock)
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
                    padding: const EdgeInsets.fromLTRB(
                      14, 10, 14, 28,
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
                        padding: const EdgeInsets.all(17),
                        decoration: GameTheme.card(
                          accent: GameTheme.gold,
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.sports_esports_rounded,
                              size: 43,
                              color: GameTheme.gold,
                            ),
                            const SizedBox(height: 9),
                            const Text(
                              'Choose Your Challenge',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              '$_passes Arcade Passes available',
                              style: const TextStyle(
                                color: GameTheme.cyan,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Owned games are free to replay. '
                              'Locked games cost one Arcade Pass '
                              'or Brain Coins per attempt.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: GameTheme.muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount: games.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 242,
                          mainAxisSpacing: 11,
                          crossAxisSpacing: 11,
                        ),
                        itemBuilder: (_, i) => _card(games[i]),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
