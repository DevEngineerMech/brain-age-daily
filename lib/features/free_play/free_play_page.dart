// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/constants/game_ids.dart';
import '../../core/widgets/app_banner_ad.dart';
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
    return 5 + _random.nextInt(6);
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

  Future<void> _openGame(
    BuildContext context,
    String gameId,
  ) async {
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
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4B0B8F),
              Color(0xFF6413A8),
              Color(0xFF7C20C8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
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
                        padding: const EdgeInsets.only(
                          bottom: 14,
                        ),
                        child: Row(
                          children: [
                            Material(
                              color: Colors.white.withOpacity(
                                0.10,
                              ),
                              borderRadius:
                                  BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(16),
                                onTap: () =>
                                    Navigator.pop(context),
                                child: const SizedBox(
                                  width: 46,
                                  height: 46,
                                  child: Icon(
                                    Icons.arrow_back_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            const Expanded(
                              child: Text(
                                'Free Play',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final String gameId =
                        gameIds[index - 1];

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(24),
                          onTap: () =>
                              _openGame(context, gameId),
                          child: Ink(
                            padding:
                                const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(
                                0.12,
                              ),
                              borderRadius:
                                  BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white
                                    .withOpacity(0.16),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 14,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFFFD247,
                                    ).withOpacity(0.22),
                                    borderRadius:
                                        BorderRadius.circular(
                                      16,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.extension_rounded,
                                    color: Color(
                                      0xFFFFD247,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: Text(
                                    GameIds.label(gameId),
                                    style:
                                        const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.w800,
                                    ),
                                  ),
                                ),

                                const Icon(
                                  Icons
                                      .chevron_right_rounded,
                                  color: Color(
                                    0xFFFFD247,
                                  ),
                                  size: 30,
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

              const AppBannerAd(),
            ],
          ),
        ),
      ),
    );
  }
}