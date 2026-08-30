import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/game_ids.dart';
import '../../core/models/daily_session_result.dart';
import '../../core/models/game_result.dart';
import '../../core/services/admob_service.dart';
import '../../core/services/brain_age_service.dart';
import '../../core/services/stats_service.dart';
import '../../core/widgets/app_interstitial_ad.dart';
import '../../core/widgets/app_rewarded_ad.dart';

import '../games/quick_math/quick_math_questions.dart';
import '../games/time_difference/time_difference_questions.dart';
import '../games/antonyms/antonyms_questions.dart';
import '../games/science_quiz/science_quiz_questions.dart';
import '../games/biology_quiz/biology_quiz_questions.dart';
import '../games/focus_count/focus_count_questions.dart';
import '../games/word_snap/word_snap_questions.dart';
import '../games/word_scramble/word_scramble_questions.dart';
import '../games/stroop_shift/stroop_shift_questions.dart';
import '../games/reaction_switch/reaction_switch_questions.dart';
import '../games/sudoku/sudoku_questions.dart';
import '../games/symbol_match/symbol_match_questions.dart';
import '../games/pattern_logic/pattern_logic_questions.dart';
import '../games/memory_grid/memory_grid_questions.dart';
import '../games/order_recall/order_recall_questions.dart';

import 'daily_engine.dart';
import 'daily_page_widgets.dart';

class DailyPage extends StatefulWidget {
  const DailyPage({super.key});

  @override
  State<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  static const int secondsPerGame = 25;
  static const int maxHearts = 3;

  static const String _heartsKey = 'daily_hearts';

  static const String _lastHeartRegenKey =
      'daily_last_heart_regen_ms';

  final DailyEngine _engine = DailyEngine();
  final Random _random = Random();

  late final List<String> _games;

  final List<GameResult> _results = <GameResult>[];

  final List<QuestionResult> _questionResults =
      <QuestionResult>[];

  int _gameIndex = 0;
  int _timeLeft = secondsPerGame;
  int _score = 0;
  int _correct = 0;
  int _attempts = 0;
  int _heartsLeft = maxHearts;

  Timer? _timer;

  String _question = '';
  String _instruction = '';
  List<String> _options = <String>[];
  String _answer = '';

  Color? _questionColor;

  bool _orderRecallShowingSequence = false;
  String _orderRecallInput = '';

  List<String> _orderRecallAnswerSequence = <String>[];

  List<String> _orderRecallSelectedSequence = <String>[];

  List<String> _orderRecallSelectableOptions = <String>[];

  bool _memoryGridShowingPattern = false;

  List<int> _memoryGridPattern = <int>[];

  final Set<int> _memoryGridSelected = <int>{};

  bool _finishingGame = false;

  @override
  void initState() {
    super.initState();

    _games = _engine.getTodayGames();

    AdMobService.initialize();

    // Preload the interstitial for after game 3.
    AppInterstitialAd.load();

    AppRewardedAd.load();

    _loadHearts();
    _startGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadHearts() async {
    if (kIsWeb) {
      if (!mounted) return;

      setState(() {
        _heartsLeft = maxHearts;
      });

      return;
    }

    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    int hearts =
        prefs.getInt(_heartsKey) ?? maxHearts;

    final int nowMs =
        DateTime.now().millisecondsSinceEpoch;

    final int? lastRegenMs =
        prefs.getInt(
      _lastHeartRegenKey,
    );

    if (lastRegenMs == null) {
      await prefs.setInt(
        _lastHeartRegenKey,
        nowMs,
      );
    } else if (hearts < maxHearts) {
      final int elapsedMs =
          nowMs - lastRegenMs;

      final int daysPassed =
          elapsedMs ~/
              const Duration(
                hours: 24,
              ).inMilliseconds;

      if (daysPassed > 0) {
        hearts += daysPassed;

        if (hearts > maxHearts) {
          hearts = maxHearts;
        }

        final int newLastRegenMs =
            lastRegenMs +
                (
                  daysPassed *
                      const Duration(
                        hours: 24,
                      ).inMilliseconds
                );

        await prefs.setInt(
          _heartsKey,
          hearts,
        );

        await prefs.setInt(
          _lastHeartRegenKey,
          newLastRegenMs,
        );
      }
    }

    if (!mounted) return;

    setState(() {
      _heartsLeft =
          hearts
              .clamp(
                0,
                maxHearts,
              )
              .toInt();
    });
  }

  Future<void> _saveHearts(
    int hearts,
  ) async {
    if (kIsWeb) {
      setState(() {
        _heartsLeft = maxHearts;
      });
      return;
    }

    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    final int safeHearts =
        hearts
            .clamp(
              0,
              maxHearts,
            )
            .toInt();

    await prefs.setInt(
      _heartsKey,
      safeHearts,
    );

    if (safeHearts < maxHearts) {
      await prefs.setInt(
        _lastHeartRegenKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    }

    if (!mounted) return;

    setState(() {
      _heartsLeft = safeHearts;
    });
  }

  Future<void> _watchAdForHeart() async {
    if (_heartsLeft >= maxHearts) {
      return;
    }

    final bool earnedReward =
        await AppRewardedAd.show();

    if (!mounted) return;

    if (earnedReward) {
      final int newHearts =
          (_heartsLeft + 1)
              .clamp(
                0,
                maxHearts,
              )
              .toInt();

      await _saveHearts(
        newHearts,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            '❤️ +1 Heart',
          ),
          duration: Duration(
            milliseconds: 900,
          ),
        ),
      );
    } else {
      AppRewardedAd.load();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Ad not ready yet. Try again soon.',
          ),
          duration: Duration(
            milliseconds: 900,
          ),
        ),
      );
    }
  }

  void _startGame() {
    _score = 0;
    _correct = 0;
    _attempts = 0;
    _timeLeft = secondsPerGame;
    _finishingGame = false;

    _nextQuestion();

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) return;

        setState(() {
          _timeLeft--;
        });

        if (_timeLeft <= 0) {
          _finishGame();
        }
      },
    );

    setState(() {});
  }

  void _resetSpecialGameState() {
    _questionColor = null;

    _orderRecallShowingSequence = false;
    _orderRecallInput = '';

    _orderRecallAnswerSequence = <String>[];

    _orderRecallSelectedSequence = <String>[];

    _orderRecallSelectableOptions = <String>[];

    _memoryGridShowingPattern = false;

    _memoryGridPattern = <int>[];

    _memoryGridSelected.clear();
  }

  void _nextQuestion() {
    final String game =
        _games[_gameIndex];

    _resetSpecialGameState();

    if (game == GameIds.quickMath) {
      final QuickMathQuestion q =
          QuickMathQuestions.all[
            _random.nextInt(
              QuickMathQuestions.all.length,
            )
          ];

      _instruction =
          'Solve as fast as you can';

      _question = q.text;

      _answer = '${q.answer}';

      _options = <String>[
        '${q.answer}',
        '${q.answer + 1}',
        '${q.answer - 1}',
        '${q.answer + 2}',
      ].toSet().toList();

      while (_options.length < 4) {
        _options.add(
          '${q.answer + _options.length + 3}',
        );
      }

      _options.shuffle(_random);
      return;
    }

    if (game == GameIds.timeDifference) {
      final TimeDifferenceQuestion q =
          TimeDifferenceQuestions.all[
            _random.nextInt(
              TimeDifferenceQuestions
                  .all.length,
            )
          ];

      _instruction =
          'How many minutes elapsed?';

      _question =
          '${q.from} → ${q.to}';

      _answer =
          '${q.minutes}';

      _options = <String>[
        '${q.minutes}',
        '${q.minutes + 5}',
        '${q.minutes - 5}',
        '${q.minutes + 10}',
      ]
          .where(
            (e) =>
                int.tryParse(e) != null &&
                int.parse(e) >= 0,
          )
          .toSet()
          .toList();

      while (_options.length < 4) {
        _options.add(
          '${q.minutes + (_options.length * 15)}',
        );
      }

      _options.shuffle(_random);
      return;
    }

    if (game == GameIds.antonyms) {
      final AntonymQuestion q =
          AntonymQuestions.all[
            _random.nextInt(
              AntonymQuestions.all.length,
            )
          ];

      _instruction =
          'Choose the opposite meaning';

      _question = q.word;

      _options =
          List<String>.from(
        q.options,
      )..shuffle(_random);

      _answer = q.answer;

      return;
    }

    if (game == GameIds.scienceQuiz) {
      final ScienceQuizQuestion q =
          ScienceQuizQuestions.all[
            _random.nextInt(
              ScienceQuizQuestions
                  .all.length,
            )
          ];

      _instruction =
          'Choose the correct answer';

      _question = q.question;

      _options =
          List<String>.from(
        q.options,
      )..shuffle(_random);

      _answer = q.answer;

      return;
    }

    if (game == GameIds.biologyQuiz) {
      final BiologyQuizQuestion q =
          BiologyQuizQuestions.all[
            _random.nextInt(
              BiologyQuizQuestions
                  .all.length,
            )
          ];

      _instruction =
          'Choose the correct answer';

      _question = q.question;

      _options =
          List<String>.from(
        q.options,
      )..shuffle(_random);

      _answer = q.answer;

      return;
    }

    if (game == GameIds.wordSnap) {
      final WordSnapQuestion q =
          WordSnapQuestions.all[
            _random.nextInt(
              WordSnapQuestions
                  .all.length,
            )
          ];

      _instruction =
          'Choose the correct category';

      _question = q.word;

      _options =
          List<String>.from(
        q.options,
      )..shuffle(_random);

      _answer = q.answer;

      return;
    }

    if (game == GameIds.wordScramble) {
      final WordScrambleQuestion q =
          WordScrambleQuestions.all[
            _random.nextInt(
              WordScrambleQuestions
                  .all.length,
            )
          ];

      _instruction =
          'Unscramble the word';

      _question = q.scrambled;

      _options =
          List<String>.from(
        q.options,
      )..shuffle(_random);

      _answer = q.answer;

      return;
    }

    if (game == GameIds.focusCount) {
      final FocusCountQuestion q =
          FocusCountQuestions.random(
        _random,
      );

      _instruction = q.instruction;

      _question =
          q.grid.join('   ');

      _options =
          FocusCountQuestions
              .optionsFor(
                q,
                _random,
              )
              .map(
                (value) =>
                    value.toString(),
              )
              .toList();

      _answer =
          q.answer.toString();

      return;
    }

    if (game == GameIds.stroopShift) {
      final StroopShiftQuestion q =
          StroopShiftQuestions.all[
            _random.nextInt(
              StroopShiftQuestions
                  .all.length,
            )
          ];

      _instruction =
          'TAP THE COLOUR OF THE TEXT, NOT THE WORD';

      _question = q.word;

      _questionColor =
          _colourForName(
        q.inkColour,
      );

      _options =
          List<String>.from(
        q.options,
      )..shuffle(_random);

      _answer = q.answer;

      return;
    }

    if (game == GameIds.reactionSwitch) {
      final ReactionSwitchQuestion q =
          ReactionSwitchQuestions.all[
            _random.nextInt(
              ReactionSwitchQuestions
                  .all.length,
            )
          ];

      _instruction = q.prompt;
      _question = q.display;

      _options = <String>[
        'YES',
        'NO',
      ]..shuffle(_random);

      _answer = q.answer;

      return;
    }

    if (game == GameIds.sudoku) {
      final SudokuQuestion q =
          SudokuQuestions.all[
            _random.nextInt(
              SudokuQuestions.all.length,
            )
          ];

      _instruction =
          'Fill the missing number';

      _question = q.row;

      _options =
          List<String>.from(
        q.options,
      )..shuffle(_random);

      _answer = q.answer;

      return;
    }

    if (game == GameIds.symbolMatch) {
      final SymbolMatchQuestion q =
          SymbolMatchQuestions.all[
            _random.nextInt(
              SymbolMatchQuestions
                  .all.length,
            )
          ];

      _instruction =
          'Tap the matching symbol';

      _question = q.target;

      _options =
          List<String>.from(
        q.options,
      )..shuffle(_random);

      _answer = q.answer;

      return;
    }

    if (game == GameIds.patternLogic) {
      final PatternLogicQuestion q =
          PatternLogicQuestion.generate();

      _instruction =
          'What comes next?';

      _question = q.sequence;

      _options =
          List<String>.from(
        q.options,
      )..shuffle(_random);

      _answer = q.answer;

      return;
    }

    if (game == GameIds.memoryGrid) {
      final MemoryGridQuestion q =
          MemoryGridQuestions.all[
            _random.nextInt(
              MemoryGridQuestions
                  .all.length,
            )
          ];

      _instruction =
          'Remember the highlighted squares';

      _question = '';

      _options = <String>[];

      _answer =
          q.pattern.join(',');

      _memoryGridPattern =
          List<int>.from(
        q.pattern,
      );

      _memoryGridSelected.clear();

      _memoryGridShowingPattern = true;

      Future.delayed(
        const Duration(
          milliseconds: 1300,
        ),
        () {
          if (!mounted) return;

          if (_games[_gameIndex] !=
              GameIds.memoryGrid) {
            return;
          }

          setState(() {
            _memoryGridShowingPattern =
                false;

            _instruction =
                'Tap the squares that were highlighted';
          });
        },
      );

      return;
    }

    if (game == GameIds.orderRecall) {
      final OrderRecallQuestion q =
          OrderRecallQuestions.all[
            _random.nextInt(
              OrderRecallQuestions
                  .all.length,
            )
          ];

      _instruction =
          'Remember the order';

      _question =
          q.shown.join('   ');

      _orderRecallAnswerSequence =
          q.answer
              .map(
                (number) =>
                    number.toString(),
              )
              .toList();

      _orderRecallSelectableOptions =
          q.shown
              .map(
                (number) =>
                    number.toString(),
              )
              .toList()
            ..shuffle(_random);

      _orderRecallSelectedSequence =
          <String>[];

      _orderRecallInput = '';

      _options = <String>['OK'];

      _answer =
          _orderRecallAnswerSequence
              .join('|');

      _orderRecallShowingSequence =
          true;

      return;
    }

    _instruction = 'Ready?';
    _question = 'Ready?';

    _options = <String>['OK'];

    _answer = 'OK';
  }

  Color _colourForName(
    String name,
  ) {
    switch (name) {
      case 'Red':
        return Colors.red;

      case 'Blue':
        return Colors.blue;

      case 'Green':
        return Colors.green;

      case 'Yellow':
        return Colors.orange;

      case 'Purple':
        return Colors.purple;

      case 'Orange':
        return Colors.deepOrange;

      default:
        return Colors.black;
    }
  }

  void _showResultToast(
    bool correct,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            correct
                ? '✅ Correct'
                : '❌ Wrong',
          ),
          duration: const Duration(
            milliseconds: 450,
          ),
          behavior:
              SnackBarBehavior.floating,
          backgroundColor: correct
              ? const Color(
                  0xFF26B957,
                )
              : const Color(
                  0xFFE94D5F,
                ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),
          margin:
              const EdgeInsets.all(16),
        ),
      );
  }

  void _tapMemoryGridTile(
    int index,
  ) {
    if (_games[_gameIndex] !=
        GameIds.memoryGrid) {
      return;
    }

    if (_memoryGridShowingPattern) {
      return;
    }

    if (_memoryGridSelected
        .contains(index)) {
      return;
    }

    setState(() {
      _memoryGridSelected.add(index);
    });

    final bool correctTile =
        _memoryGridPattern
            .contains(index);

    if (!correctTile) {
      _attempts++;

      _showResultToast(false);

      setState(() {
        _nextQuestion();
      });

      return;
    }

    final bool completed =
        _memoryGridPattern.every(
      _memoryGridSelected.contains,
    );

    if (!completed) return;

    _attempts++;
    _correct++;
    _score++;

    _showResultToast(true);

    setState(() {
      _nextQuestion();
    });
  }

  void _tapAnswer(
    String selected,
  ) {
    final String currentGame =
        _games[_gameIndex];

    if (currentGame ==
        GameIds.memoryGrid) {
      return;
    }

    if (currentGame ==
        GameIds.orderRecall) {
      if (_orderRecallShowingSequence) {
        setState(() {
          _orderRecallShowingSequence =
              false;

          _instruction =
              'Tap the numbers in the same order';

          _question = '';

          _orderRecallInput = '';

          _orderRecallSelectedSequence =
              <String>[];

          _options =
              List<String>.from(
            _orderRecallSelectableOptions,
          );
        });

        return;
      }

      if (_orderRecallSelectedSequence
          .contains(selected)) {
        return;
      }

      if (!_orderRecallSelectableOptions
          .contains(selected)) {
        return;
      }

      setState(() {
        _orderRecallSelectedSequence
            .add(selected);

        _orderRecallInput =
            _orderRecallSelectedSequence
                .join('   ');

        _options =
            _orderRecallSelectableOptions
                .where(
                  (option) =>
                      !_orderRecallSelectedSequence
                          .contains(
                    option,
                  ),
                )
                .toList();
      });

      if (_orderRecallSelectedSequence
              .length <
          _orderRecallAnswerSequence
              .length) {
        return;
      }

      _attempts++;

      bool correct = true;

      for (
        int i = 0;
        i <
            _orderRecallAnswerSequence
                .length;
        i++
      ) {
        if (_orderRecallSelectedSequence[i] !=
            _orderRecallAnswerSequence[i]) {
          correct = false;
          break;
        }
      }

      _questionResults.add(
        QuestionResult(
          gameId:
              _games[_gameIndex],
          question:
              'Repeat the sequence',
          userAnswer:
              _orderRecallSelectedSequence
                  .join(', '),
          correctAnswer:
              _orderRecallAnswerSequence
                  .join(', '),
          isCorrect: correct,
        ),
      );

      if (correct) {
        _correct++;
        _score++;
      }

      _showResultToast(correct);

      Future.delayed(
        const Duration(
          milliseconds: 450,
        ),
        () {
          if (!mounted) return;

          setState(() {
            _nextQuestion();
          });
        },
      );

      return;
    }

    _attempts++;

    final bool correct =
        selected == _answer;

    _questionResults.add(
      QuestionResult(
        gameId:
            _games[_gameIndex],
        question: _question,
        userAnswer: selected,
        correctAnswer: _answer,
        isCorrect: correct,
      ),
    );

    if (correct) {
      _correct++;
      _score++;
    }

    _showResultToast(correct);

    setState(() {
      _nextQuestion();
    });
  }

  Future<void> _finishGame() async {
    if (_finishingGame) return;

    _finishingGame = true;

    _timer?.cancel();

    final double elapsedMs =
        (
          (
            secondsPerGame -
                _timeLeft
          ).clamp(
            1,
            secondsPerGame,
          ) *
              1000.0
        );

    final double averageResponseTimeMs =
        max(
      500.0,
      elapsedMs /
          max(
            1,
            _attempts,
          ),
    );

    _results.add(
      GameResult(
        gameId:
            _games[_gameIndex],
        score: _score,
        correct: _correct,
        attempts: _attempts,
        averageResponseTimeMs:
            averageResponseTimeMs,
        playedAt:
            DateTime.now(),
        questionResults:
            _questionResults
                .where(
                  (result) =>
                      result.gameId ==
                      _games[_gameIndex],
                )
                .toList(),
      ),
    );

    /*
     * GAME 3 HAS JUST FINISHED.
     *
     * _gameIndex starts at 0, so:
     *
     * 0 = game 1
     * 1 = game 2
     * 2 = game 3
     *
     * Show an interstitial before game 4.
     */
    if (_gameIndex == 2) {
      await AppInterstitialAd.show(
        context,
      );

      if (!mounted) return;

      /*
       * The game-3 ad has now been used.
       * Preload another interstitial so it
       * is ready when the user finishes all
       * five games and presses Home.
       */
      AppInterstitialAd.load();
    }

    if (_gameIndex >=
        _games.length - 1) {
      await _finishDaily();
      return;
    }

    if (!mounted) return;

    setState(() {
      _gameIndex++;
    });

    _startGame();
  }

  Future<void> _finishDaily() async {
    final double accuracy =
        _results
                .map(
                  (e) => e.accuracy,
                )
                .fold<double>(
                  0,
                  (a, b) => a + b,
                ) /
            _results.length;

    final int totalScore =
        _results
            .map(
              (e) => e.score,
            )
            .fold<int>(
              0,
              (a, b) => a + b,
            );

    final int totalCorrect =
        _results
            .map(
              (e) => e.correct,
            )
            .fold<int>(
              0,
              (a, b) => a + b,
            );

    final int totalAttempts =
        _results
            .map(
              (e) => e.attempts,
            )
            .fold<int>(
              0,
              (a, b) => a + b,
            );

    final double averageResponseTime =
        _results
                .map(
                  (e) =>
                      e.averageResponseTimeMs,
                )
                .fold<double>(
                  0,
                  (a, b) => a + b,
                ) /
            _results.length;

    final SharedPreferences prefs =
        await SharedPreferences
            .getInstance();

    final int userAge =
        prefs.getInt('user_age') ?? 25;

    final int brainAge =
        BrainAgeService.calculate(
      accuracy: accuracy,
      responseTime:
          averageResponseTime,
      score: totalScore,
      chronologicalAge: userAge,
    );

    await StatsService.saveDailySession(
      DailySessionResult(
        gameResults: _results,
        brainAge: brainAge,
        completedAt: DateTime.now(),
      ),
    );

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (
        dialogContext,
      ) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                26,
              ),
            ),
            title: const Column(
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  color: Color(
                    0xFFFFB92E,
                  ),
                  size: 46,
                ),
                SizedBox(height: 8),
                Text(
                  'Daily Complete!',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Text(
                  'YOUR BRAIN AGE',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '$brainAge',
                  style: const TextStyle(
                    color:
                        Color(0xFF202024),
                    fontSize: 60,
                    fontWeight:
                        FontWeight.w900,
                    height: 1,
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(
                    14,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFF4F2FF,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                        children: [
                          const Text(
                            'Score',
                            style: TextStyle(
                              color:
                                  Colors.grey,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                          Text(
                            '$totalScore',
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF625BEA,
                              ),
                              fontWeight:
                                  FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                        children: [
                          const Text(
                            'Correct',
                            style: TextStyle(
                              color:
                                  Colors.grey,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                          Text(
                            '$totalCorrect / $totalAttempts',
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF625BEA,
                              ),
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                        children: [
                          const Text(
                            'Accuracy',
                            style: TextStyle(
                              color:
                                  Colors.grey,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${(accuracy * 100).round()}%',
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF625BEA,
                              ),
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actionsAlignment:
                MainAxisAlignment.center,
            actions: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child:
                    ElevatedButton.icon(
                  onPressed: () async {
                    /*
                     * The results remain visible
                     * until the user presses Home.
                     *
                     * Then the second interstitial
                     * is shown.
                     */
                    await AppInterstitialAd
                        .show(context);

                    if (!mounted) {
                      return;
                    }

                    if (Navigator.of(
                      dialogContext,
                    ).canPop()) {
                      Navigator.of(
                        dialogContext,
                      ).pop();
                    }

                    if (!mounted) {
                      return;
                    }

                    Navigator.of(context)
                        .pop();
                  },
                  icon: const Icon(
                    Icons.home_rounded,
                  ),
                  label: const Text(
                    'Home',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF625BEA,
                    ),
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _answerGrid({
    required double answerHeight,
    required double scale,
  }) {
    if (_options.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_options.length == 1) {
      return DailyAnswerButton(
        text: _options.first,
        onPressed: () =>
            _tapAnswer(
          _options.first,
        ),
        height: answerHeight,
        scale: scale,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: _options.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing:
            (8 * scale).clamp(
          6.0,
          11.0,
        ),
        mainAxisSpacing:
            (8 * scale).clamp(
          6.0,
          11.0,
        ),
        mainAxisExtent: answerHeight,
      ),
      itemBuilder:
          (context, index) {
        final String option =
            _options[index];

        return DailyAnswerButton(
          text: option,
          onPressed: () =>
              _tapAnswer(
            option,
          ),
          height: answerHeight,
          scale: scale,
        );
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final double progress =
        (
          _gameIndex +
              (
                (
                  secondsPerGame -
                      _timeLeft
                ) /
                    secondsPerGame
              )
        ) /
            _games.length;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration:
            const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4B0B8F),
              Color(0xFF6413A8),
              Color(0xFF7C20C8),
            ],
            begin:
                Alignment.topCenter,
            end:
                Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (
              context,
              constraints,
            ) {
              final double h =
                  constraints.maxHeight;

              final double w =
                  constraints.maxWidth;

              final double widthScale =
                  w / 390.0;

              final double heightScale =
                  h / 760.0;

              final double scale =
                  min(
                    widthScale,
                    heightScale,
                  ).clamp(
                    0.82,
                    1.18,
                  );

              final double outerPadding =
                  (12 * scale).clamp(
                9.0,
                15.0,
              );

              final double smallGap =
                  (8 * scale).clamp(
                6.0,
                11.0,
              );

              final double answerHeight =
                  (54 * scale).clamp(
                46.0,
                64.0,
              );

              final double statHeight =
                  (52 * scale).clamp(
                45.0,
                62.0,
              );

              final int answerRows =
                  _options.isEmpty
                      ? 0
                      : _options.length == 1
                          ? 1
                          : (_options.length / 2)
                              .ceil();

              final double answerAreaHeight =
                  answerRows == 0
                      ? 0
                      : (answerRows *
                              answerHeight) +
                          ((answerRows - 1) *
                              smallGap);

              final double headerHeight =
                  (46 * scale).clamp(
                40.0,
                54.0,
              );

              final double progressHeight =
                  (54 * scale).clamp(
                46.0,
                64.0,
              );

              final double fixedHeight =
                  outerPadding +
                      headerHeight +
                      smallGap +
                      progressHeight +
                      smallGap +
                      answerAreaHeight +
                      (answerRows > 0
                          ? smallGap
                          : 0) +
                      statHeight +
                      outerPadding;

              final double questionHeight =
                  (h - fixedHeight).clamp(
                285.0,
                520.0,
              );

              return Stack(
                children: [
                  const DailySparklesBackground(),

                  Padding(
                    padding:
                        EdgeInsets.fromLTRB(
                      outerPadding,
                      outerPadding,
                      outerPadding,
                      outerPadding,
                    ),
                    child: Column(
                      children: [
                        DailyHeader(
                          onBack: () =>
                              Navigator.pop(
                            context,
                          ),
                          heartsLeft:
                              _heartsLeft,
                          onWatchAdForHeart:
                              _heartsLeft <
                                      maxHearts
                                  ? _watchAdForHeart
                                  : null,
                          scale: scale,
                        ),

                        SizedBox(
                          height: smallGap,
                        ),

                        DailyStepProgress(
                          gamesCount:
                              _games.length,
                          activeIndex:
                              _gameIndex,
                          progress:
                              progress,
                          scale: scale,
                        ),

                        SizedBox(
                          height: smallGap,
                        ),

                        SizedBox(
                          height:
                              questionHeight,
                          child:
                              DailyQuestionCard(
                            title:
                                GameIds.label(
                              _games[
                                _gameIndex
                              ],
                            ),
                            instruction:
                                _instruction,
                            question:
                                _question,
                            questionColor:
                                _questionColor,
                            timeLeft:
                                _timeLeft,
                            inputText:
                                _orderRecallInput,
                            memoryGridPattern:
                                _memoryGridPattern,
                            memoryGridSelected:
                                _memoryGridSelected,
                            memoryGridShowingPattern:
                                _memoryGridShowingPattern,
                            onMemoryGridTap:
                                _tapMemoryGridTile,
                            scale:
                                scale,
                          ),
                        ),

                        if (answerRows > 0)
                          SizedBox(
                            height:
                                smallGap,
                          ),

                        _answerGrid(
                          answerHeight:
                              answerHeight,
                          scale:
                              scale,
                        ),

                        SizedBox(
                          height:
                              smallGap,
                        ),

                        Row(
                          children: [
                            Expanded(
                              child:
                                  DailyBottomStatCard(
                                icon:
                                    '🏆',
                                label:
                                    'Score',
                                value:
                                    '$_score',
                                height:
                                    statHeight,
                                scale:
                                    scale,
                              ),
                            ),

                            SizedBox(
                              width:
                                  smallGap,
                            ),

                            Expanded(
                              child:
                                  DailyBottomStatCard(
                                icon:
                                    '✅',
                                label:
                                    'Correct',
                                value:
                                    '$_correct',
                                height:
                                    statHeight,
                                scale:
                                    scale,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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