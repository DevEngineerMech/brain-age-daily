
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/game_ids.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/daily_missions_service.dart';
import '../../core/services/stats_service.dart';
import '../../core/services/player_xp_service.dart';

import '../../core/widgets/app_interstitial_ad.dart';
import '../../core/widgets/timed_free_play_ad_wrapper.dart';

import '../games/brain_training/focus_count/focus_count_page.dart';
import '../games/brain_training/memory_grid/memory_grid_page.dart';
import '../games/brain_training/order_recall/order_recall_page.dart';
import '../games/brain_training/pattern_logic/pattern_logic_page.dart';
import '../games/brain_training/quick_math/quick_math_page.dart';
import '../games/brain_training/reaction_switch/reaction_switch_page.dart';
import '../games/brain_training/stroop_shift/stroop_shift_page.dart';
import '../games/brain_training/sudoku/sudoku_page.dart';
import '../games/brain_training/symbol_match/symbol_match_page.dart';
import '../games/brain_training/time_difference/time_difference_page.dart';

import '../shop/brain_shop_catalog.dart';
import '../shop/brain_shop_page.dart';

class FreePlayPage extends StatefulWidget {
  const FreePlayPage({super.key});

  @override
  State<FreePlayPage> createState() => _FreePlayPageState();
}

class _GameAppearance {
  final IconData icon;
  final Color color;
  final String category;
  final String description;

  const _GameAppearance(
    this.icon,
    this.color,
    this.category,
    this.description,
  );
}

class _FreePlayPageState extends State<FreePlayPage> {
  static const Color _bg = Color(0xFF0C0929);
  static const Color _panel = Color(0xFF1A1646);
  static const Color _gold = Color(0xFFFFC75D);
  static const Color _muted = Color(0xFFC5B9DF);

  static const String _columnsKey =
      'free_play_grid_columns';

  static const String _completedSinceAdKey =
      'free_play_completed_since_interstitial_v2';

  static const int _gamesPerAd = 2;

  final Map<String, int> _bestScores = {};

  int _columns = 2;
  int _completedSinceAd = 0;

  bool _loadingScores = true;
  bool _openingGame = false;

  @override
  void initState() {
    super.initState();

    AppInterstitialAd.load();

    AnalyticsService.freePlayOpened();
    AnalyticsService.screen('free_play');

    _loadPreferences();
    _loadBestScores();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    final columns = prefs.getInt(_columnsKey) ?? 2;

    final completed =
        prefs.getInt(_completedSinceAdKey) ?? 0;

    setState(() {
      _columns = columns == 3 ? 3 : 2;
      _completedSinceAd = completed.clamp(0, 1);
    });
  }

  Future<void> _changeColumns(int count) async {
    if (_columns == count) return;

    setState(() => _columns = count);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_columnsKey, count);
  }

  Future<void> _loadBestScores() async {
    try {
      final scores =
          await StatsService.getAllBestScores();

      if (!mounted) return;

      setState(() {
        _bestScores
          ..clear()
          ..addAll(scores);

        _loadingScores = false;
      });
    } catch (error) {
      debugPrint(
        '[FreePlay] Failed to load best scores: $error',
      );

      if (mounted) {
        setState(() => _loadingScores = false);
      }
    }
  }

  Future<void> _openShop() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const BrainShopPage(),
      ),
    );

    if (mounted) {
      await _loadBestScores();
    }
  }

  _GameAppearance _appearance(String id) {
    switch (id) {
      case GameIds.memoryGrid:
        return const _GameAppearance(
          Icons.grid_view_rounded,
          Color(0xFFAD8BFF),
          'MEMORY',
          'Remember the tiles',
        );

      case GameIds.orderRecall:
        return const _GameAppearance(
          Icons.format_list_numbered_rounded,
          Color(0xFF7CCBFF),
          'MEMORY',
          'Recall the sequence',
        );

      case GameIds.patternLogic:
        return const _GameAppearance(
          Icons.auto_awesome_mosaic_rounded,
          Color(0xFFBA91FF),
          'LOGIC',
          'Find the pattern',
        );

      case GameIds.symbolMatch:
        return const _GameAppearance(
          Icons.interests_rounded,
          Color(0xFF63C6FF),
          'VISUAL',
          'Match symbols',
        );

      case GameIds.focusCount:
        return const _GameAppearance(
          Icons.center_focus_strong_rounded,
          Color(0xFFFFBA60),
          'FOCUS',
          'Count the symbols',
        );

      case GameIds.reactionSwitch:
        return const _GameAppearance(
          Icons.bolt_rounded,
          Color(0xFFFFDB54),
          'SPEED',
          'React quickly',
        );

      case GameIds.stroopShift:
        return const _GameAppearance(
          Icons.palette_rounded,
          Color(0xFFFF926B),
          'COLOURS',
          'Test your focus',
        );

      case GameIds.quickMath:
        return const _GameAppearance(
          Icons.calculate_rounded,
          Color(0xFFFFC75D),
          'NUMBERS',
          'Solve fast calculations',
        );

      case GameIds.timeDifference:
        return const _GameAppearance(
          Icons.access_time_filled_rounded,
          Color(0xFFFFA16B),
          'TIME',
          'Work out the time',
        );

      case GameIds.sudoku:
        return const _GameAppearance(
          Icons.grid_on_rounded,
          Color(0xFF5FE2D3),
          'LOGIC',
          'Number puzzles',
        );

      default:
        return const _GameAppearance(
          Icons.psychology_rounded,
          Color(0xFFBA91FF),
          'BRAIN',
          'Train your brain',
        );
    }
  }

  Widget _pageForGame(String id) {
    switch (id) {
      case GameIds.memoryGrid:
        return const MemoryGridPage();

      case GameIds.orderRecall:
        return const OrderRecallPage();

      case GameIds.patternLogic:
        return const PatternLogicPage();

      case GameIds.symbolMatch:
        return const SymbolMatchPage();

      case GameIds.focusCount:
        return FocusCountPage(
          gameId: id,
          title: GameIds.label(id),
        );

      case GameIds.reactionSwitch:
        return const ReactionSwitchPage();

      case GameIds.stroopShift:
        return const StroopShiftPage();

      case GameIds.quickMath:
        return const QuickMathPage();

      case GameIds.timeDifference:
        return const TimeDifferencePage();

      case GameIds.sudoku:
        return const SudokuPage();

      default:
        throw ArgumentError(
          'Not a Free Play game: $id',
        );
    }
  }

  // =====================================================
  // COUNT ACTUALLY COMPLETED GAMES
  // =====================================================

  Future<int> _savedRoundCount(String gameId) async {
    final results =
        await StatsService.getFreePlayResults();

    return results.where((result) {
      return result.gameId == gameId &&
          result.attempts > 0;
    }).length;
  }

  /// Called only when at least one completed Free Play
  /// round has been saved during the game visit.
  ///
  /// One game visit counts as one completed game,
  /// even if it saved multiple round records.
  Future<void> _completedGameRecorded() async {
    final prefs = await SharedPreferences.getInstance();

    final previous =
        prefs.getInt(_completedSinceAdKey) ?? 0;

    final updated = previous + 1;

    if (updated < _gamesPerAd) {
      await prefs.setInt(
        _completedSinceAdKey,
        updated,
      );

      if (mounted) {
        setState(() => _completedSinceAd = updated);
      }

      debugPrint(
        '[FreePlayAds] Completed games: '
        '$updated / $_gamesPerAd',
      );

      return;
    }

    await prefs.setInt(
      _completedSinceAdKey,
      0,
    );

    if (mounted) {
      setState(() => _completedSinceAd = 0);
    }

    debugPrint(
      '[FreePlayAds] 2 completed games: '
      'interstitial opportunity.',
    );

    if (!mounted) return;

    await AppInterstitialAd.show(
      context,
      placement: 'free_play_after_2_completed',
    );

    AppInterstitialAd.load();
  }

  // =====================================================
  // GAME NAVIGATION AND XP REWARDS
  // =====================================================

  Future<void> _openGame(String id) async {
    if (_openingGame) return;

    if (!GameIds.brainTraining.contains(id)) {
      return;
    }

    _openingGame = true;

    try {
      final roundsBefore = await _savedRoundCount(id);

      await AnalyticsService.freePlayGameOpened(
        gameId: id,
      );

      await DailyMissionsService.recordFreePlayOpen(
        id,
      );

      if (!mounted) return;

      final started = DateTime.now();

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TimedFreePlayAdWrapper(
            child: _pageForGame(id),
          ),
        ),
      );

      if (!mounted) return;

      final elapsed =
          DateTime.now().difference(started).inSeconds;

      await AnalyticsService.freePlayGameExited(
        gameId: id,
        secondsPlayed: elapsed,
      );

      final roundsAfter = await _savedRoundCount(id);

      final completed = roundsAfter > roundsBefore;

      await _loadBestScores();

      if (!mounted) return;

      if (completed) {
        // One unique award for this completed visit.
        // Multiple saved rounds do not multiply XP.
        final eventId =
            'freeplay:${started.microsecondsSinceEpoch}:$id';

        try {
          final award = await PlayerXpService.award(
            eventId: eventId,
            xp: PlayerXpService.freePlayXp,
          );

          if (mounted && award.awarded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '+${award.xpEarned} XP earned!',
                ),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF5734A4),
              ),
            );
          }
        } catch (error) {
          debugPrint(
            '[FreePlay] XP award failed: $error',
          );
        }

        await _completedGameRecorded();
      } else {
        debugPrint(
          '[FreePlayAds] $id exited without '
          'a new saved completed round. '
          'Interstitial counter unchanged.',
        );
      }
    } catch (error) {
      debugPrint(
        '[FreePlay] Unable to launch game: $error',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to open this game.',
            ),
          ),
        );
      }
    } finally {
      _openingGame = false;
    }
  }

  // =====================================================
  // HEADER
  // =====================================================

  Widget _header() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: _panel,
            side: const BorderSide(
              color: Color(0xFF65509E),
            ),
          ),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Free Play',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        FutureBuilder<Map<String, dynamic>>(
          future: DailyMissionsService.getShopState(),
          builder: (context, snapshot) {
            final equipped =
                snapshot.data?['equipped']?.toString() ?? '';

            final badge =
                BrainShopCatalog.badge(equipped);

            if (badge == null) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Tooltip(
                message: badge.title,
                child: Icon(
                  badge.icon,
                  color: badge.color,
                  size: 26,
                ),
              ),
            );
          },
        ),
        IconButton(
          tooltip: 'Brain Shop',
          onPressed: _openShop,
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF302367),
            side: const BorderSide(color: _gold),
          ),
          icon: const Icon(
            Icons.storefront_rounded,
            color: _gold,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // HERO
  // =====================================================

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4D208D),
            Color(0xFF2A1B6D),
            Color(0xFF152256),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF9972EC),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRAIN YOUR BRAIN',
                  style: TextStyle(
                    color: _gold,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Pick a challenge',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Practice and beat your best score.',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '10 free brain-training games',
                  style: TextStyle(
                    color: Color(0xFF67E4D7),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Icon(
            Icons.psychology_rounded,
            size: 82,
            color: Color(0xFFBB9CFF),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // GRID LAYOUT SWITCH
  // =====================================================

  Widget _layoutPicker() {
    Widget option(int count) {
      final selected = _columns == count;

      return InkWell(
        onTap: () => _changeColumns(count),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF713DE0)
                : const Color(0xFF201A4C),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? const Color(0xFFBC9DFF)
                  : const Color(0xFF50417D),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                count == 2
                    ? Icons.grid_view_rounded
                    : Icons.apps_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 5),
              Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        const Icon(
          Icons.apps_rounded,
          color: _gold,
          size: 20,
        ),
        const SizedBox(width: 6),
        const Expanded(
          child: Text(
            'Brain Training',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        option(2),
        const SizedBox(width: 7),
        option(3),
      ],
    );
  }

  // =====================================================
  // GAME CARDS
  // =====================================================

  Widget _gameCard(String id, int index) {
    final appearance = _appearance(id);
    final best = _bestScores[id];
    final compact = _columns == 3;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openGame(id),
        borderRadius: BorderRadius.circular(17),
        child: Ink(
          padding: EdgeInsets.all(
            compact ? 8 : 12,
          ),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: appearance.color.withOpacity(0.55),
            ),
            boxShadow: [
              BoxShadow(
                color: appearance.color.withOpacity(0.09),
                blurRadius: 9,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      appearance.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: appearance.color,
                        fontSize: compact ? 8 : 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${index + 1}'.padLeft(2, '0'),
                    style: const TextStyle(
                      color: Color(0xFF8C80A9),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: compact ? 45 : 66,
                height: compact ? 45 : 66,
                decoration: BoxDecoration(
                  color: appearance.color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: appearance.color.withOpacity(0.65),
                  ),
                ),
                child: Icon(
                  appearance.icon,
                  color: appearance.color,
                  size: compact ? 27 : 37,
                ),
              ),
              const Spacer(),
              Text(
                GameIds.label(id),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 12 : 16,
                  fontWeight: FontWeight.w900,
                  height: 1.13,
                ),
              ),
              SizedBox(
                height: compact ? 5 : 8,
              ),
              if (!compact)
                Text(
                  appearance.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                  ),
                ),
              const Spacer(),
              Text(
                _loadingScores
                    ? 'Loading'
                    : best == null
                        ? 'Not played'
                        : 'Best: $best',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: best == null ? _muted : _gold,
                  fontSize: compact ? 9 : 11,
                ),
              ),
              const SizedBox(height: 7),
              Icon(
                Icons.play_circle_fill_rounded,
                color: appearance.color,
                size: compact ? 24 : 29,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gamesGrid(List<String> games) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        14, 0, 14, 24,
      ),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final width =
              constraints.crossAxisExtent - 28;

          final cellWidth =
              (width - (_columns - 1) * 10) / _columns;

          final height =
              _columns == 3 ? 175.0 : 225.0;

          return SliverGrid(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _columns,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: cellWidth / height,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _gameCard(games[index], index),
              childCount: games.length,
            ),
          );
        },
      ),
    );
  }

  // =====================================================
  // MAIN PAGE
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
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
          child: RefreshIndicator(
            onRefresh: _loadBestScores,
            color: const Color(0xFF8A4CFA),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    14, 9, 14, 12,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _header(),
                      const SizedBox(height: 14),
                      _hero(),
                      const SizedBox(height: 20),
                      _layoutPicker(),
                    ]),
                  ),
                ),
                _gamesGrid(GameIds.brainTraining),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
