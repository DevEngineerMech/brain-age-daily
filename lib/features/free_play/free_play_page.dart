import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/constants/game_ids.dart';
import '../../core/widgets/app_interstitial_ad.dart';
import '../../core/widgets/timed_free_play_ad_wrapper.dart';

import '../games/antonyms/antonyms_page.dart';
import '../games/biology_quiz/biology_quiz_page.dart';
import '../games/focus_count/focus_count_page.dart';
import '../games/memory_grid/memory_grid_page.dart';
import '../games/order_recall/order_recall_page.dart';
import '../games/pattern_logic/pattern_logic_page.dart';
import '../games/quick_math/quick_math_page.dart';
import '../games/reaction_switch/reaction_switch_page.dart';
import '../games/science_quiz/science_quiz_page.dart';
import '../games/stroop_shift/stroop_shift_page.dart';
import '../games/symbol_match/symbol_match_page.dart';
import '../games/time_difference/time_difference_page.dart';
import '../games/word_scramble/word_scramble_page.dart';
import '../games/word_snap/word_snap_page.dart';
import '../games/sudoku/sudoku_page.dart';

class FreePlayPage extends StatefulWidget {
  const FreePlayPage({super.key});

  @override
  State<FreePlayPage> createState() => _FreePlayPageState();
}

class _FreePlayPageState extends State<FreePlayPage> {
  final Random _random = Random();

  int _openedGamesSinceAd = 0;
  late int _nextAdAt;

  @override
  void initState() {
    super.initState();
    _nextAdAt = _randomTarget();
    AppInterstitialAd.load();
  }

  int _randomTarget() {
    return 5 + _random.nextInt(6); // 5 to 10
  }

  Widget _pageForGame(String gameId) {
    switch (gameId) {
      case GameIds.quickMath:
        return const QuickMathPage();
      case GameIds.timeDifference:
        return const TimeDifferencePage();
      case GameIds.antonyms:
        return const AntonymsPage();
      case GameIds.scienceQuiz:
        return const ScienceQuizPage();
      case GameIds.biologyQuiz:
        return const BiologyQuizPage();
      case GameIds.wordSnap:
        return const WordSnapPage();
      case GameIds.wordScramble:
        return const WordScramblePage();
      case GameIds.focusCount:
        return FocusCountPage(
          gameId: gameId,
          title: GameIds.label(gameId),
        );
      case GameIds.stroopShift:
        return const StroopShiftPage();
      case GameIds.reactionSwitch:
        return const ReactionSwitchPage();
      case GameIds.sudoku:
        return const SudokuPage();
      case GameIds.symbolMatch:
        return const SymbolMatchPage();
      case GameIds.patternLogic:
        return const PatternLogicPage();
      case GameIds.memoryGrid:
        return const MemoryGridPage();
      case GameIds.orderRecall:
        return const OrderRecallPage();
      default:
        return FocusCountPage(
          gameId: gameId,
          title: GameIds.label(gameId),
        );
    }
  }

  Future<void> _openGame(BuildContext context, String gameId) async {
    _openedGamesSinceAd++;

    if (_openedGamesSinceAd >= _nextAdAt) {
      _openedGamesSinceAd = 0;
      _nextAdAt = _randomTarget();
      await AppInterstitialAd.show(context);
    }

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TimedFreePlayAdWrapper(
  child: _pageForGame(gameId),
),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> gameIds = GameIds.all;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A1020),
              Color(0xFF11182B),
              Color(0xFF1A2250),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: gameIds.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Free Play',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final String gameId = gameIds[index - 1];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () => _openGame(context, gameId),
                          child: Ink(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B2344),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.10),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C63FF)
                                        .withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.extension_rounded,
                                    color: Color(0xFF8F88FF),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    GameIds.label(gameId),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white54,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}