import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/constants/game_ids.dart';
import '../../core/models/daily_session_result.dart';
import '../../core/models/game_result.dart';
import '../../core/services/admob_service.dart';
import '../../core/services/brain_age_service.dart';
import '../../core/services/stats_service.dart';
import '../../core/widgets/app_interstitial_ad.dart';

import '../games/quick_math/quick_math_questions.dart';
import '../games/time_difference/time_difference_questions.dart';
import '../games/antonyms/antonyms_questions.dart';
import '../games/science_quiz/science_quiz_questions.dart';
import '../games/biology_quiz/biology_quiz_questions.dart';
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
  static const int secondsPerGame = 40;

  final DailyEngine _engine = DailyEngine();
  final Random _random = Random();

  late final List<String> _games;
  final List<GameResult> _results = <GameResult>[];

  int _gameIndex = 0;
  int _timeLeft = secondsPerGame;
  int _score = 0;
  int _correct = 0;
  int _attempts = 0;

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

  @override
  void initState() {
    super.initState();
    _games = _engine.getTodayGames();
    AdMobService.initialize();
    AppInterstitialAd.load();
    _startGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _score = 0;
    _correct = 0;
    _attempts = 0;
    _timeLeft = secondsPerGame;

    _nextQuestion();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        _timeLeft--;
      });

      if (_timeLeft <= 0) {
        _finishGame();
      }
    });

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
    final String game = _games[_gameIndex];

    _resetSpecialGameState();

    if (game == GameIds.quickMath) {
      final QuickMathQuestion q =
          QuickMathQuestions.all[_random.nextInt(QuickMathQuestions.all.length)];

      _instruction = 'Solve as fast as you can';
      _question = q.text;
      _answer = '${q.answer}';
      _options = <String>[
        '${q.answer}',
        '${q.answer + 1}',
        '${q.answer - 1}',
        '${q.answer + 2}',
      ].toSet().toList();

      while (_options.length < 4) {
        _options.add('${q.answer + _options.length + 3}');
      }

      _options.shuffle(_random);
      return;
    }

    if (game == GameIds.timeDifference) {
      final TimeDifferenceQuestion q = TimeDifferenceQuestions
          .all[_random.nextInt(TimeDifferenceQuestions.all.length)];

      _instruction = 'How many minutes elapsed?';
      _question = '${q.from} → ${q.to}';
      _answer = '${q.minutes}';
      _options = <String>[
        '${q.minutes}',
        '${q.minutes + 5}',
        '${q.minutes - 5}',
        '${q.minutes + 10}',
      ].where((e) => int.tryParse(e) != null && int.parse(e) >= 0).toSet().toList();

      while (_options.length < 4) {
        _options.add('${q.minutes + (_options.length * 15)}');
      }

      _options.shuffle(_random);
      return;
    }

    if (game == GameIds.antonyms) {
      final AntonymQuestion q =
          AntonymQuestions.all[_random.nextInt(AntonymQuestions.all.length)];

      _instruction = 'Choose the opposite meaning';
      _question = q.word;
      _options = List<String>.from(q.options)..shuffle(_random);
      _answer = q.answer;
      return;
    }

    if (game == GameIds.scienceQuiz) {
      final ScienceQuizQuestion q = ScienceQuizQuestions
          .all[_random.nextInt(ScienceQuizQuestions.all.length)];

      _instruction = 'Choose the correct answer';
      _question = q.question;
      _options = List<String>.from(q.options)..shuffle(_random);
      _answer = q.answer;
      return;
    }

    if (game == GameIds.biologyQuiz) {
      final BiologyQuizQuestion q = BiologyQuizQuestions
          .all[_random.nextInt(BiologyQuizQuestions.all.length)];

      _instruction = 'Choose the correct answer';
      _question = q.question;
      _options = List<String>.from(q.options)..shuffle(_random);
      _answer = q.answer;
      return;
    }

    if (game == GameIds.wordSnap) {
      final WordSnapQuestion q =
          WordSnapQuestions.all[_random.nextInt(WordSnapQuestions.all.length)];

      _instruction = 'Choose the correct category';
      _question = q.word;
      _options = List<String>.from(q.options)..shuffle(_random);
      _answer = q.answer;
      return;
    }

    if (game == GameIds.wordScramble) {
      final WordScrambleQuestion q = WordScrambleQuestions
          .all[_random.nextInt(WordScrambleQuestions.all.length)];

      _instruction = 'Unscramble the word';
      _question = q.scrambled;
      _options = List<String>.from(q.options)..shuffle(_random);
      _answer = q.answer;
      return;
    }

    if (game == GameIds.stroopShift) {
      final StroopShiftQuestion q = StroopShiftQuestions
          .all[_random.nextInt(StroopShiftQuestions.all.length)];

      _instruction = 'TAP THE COLOUR OF THE TEXT, NOT THE WORD';
      _question = q.word;
      _questionColor = _colourForName(q.inkColour);
      _options = List<String>.from(q.options)..shuffle(_random);
      _answer = q.answer;
      return;
    }

    if (game == GameIds.reactionSwitch) {
      final ReactionSwitchQuestion q = ReactionSwitchQuestions
          .all[_random.nextInt(ReactionSwitchQuestions.all.length)];

      _instruction = q.prompt;
      _question = q.display;
      _options = <String>['YES', 'NO']..shuffle(_random);
      _answer = q.answer;
      return;
    }

    if (game == GameIds.sudoku) {
      final SudokuQuestion q =
          SudokuQuestions.all[_random.nextInt(SudokuQuestions.all.length)];

      _instruction = 'Fill the missing number';
      _question = q.row;
      _options = List<String>.from(q.options)..shuffle(_random);
      _answer = q.answer;
      return;
    }

    if (game == GameIds.symbolMatch) {
      final SymbolMatchQuestion q = SymbolMatchQuestions
          .all[_random.nextInt(SymbolMatchQuestions.all.length)];

      _instruction = 'Tap the matching symbol';
      _question = q.target;
      _options = List<String>.from(q.options)..shuffle(_random);
      _answer = q.answer;
      return;
    }

    if (game == GameIds.patternLogic) {
      final PatternLogicQuestion q = PatternLogicQuestion.generate();

      _instruction = 'What comes next?';
      _question = q.sequence;
      _options = List<String>.from(q.options)..shuffle(_random);
      _answer = q.answer;
      return;
    }

    if (game == GameIds.memoryGrid) {
      final MemoryGridQuestion q = MemoryGridQuestions
          .all[_random.nextInt(MemoryGridQuestions.all.length)];

      _instruction = 'Remember the highlighted squares';
      _question = '';
      _options = <String>[];
      _answer = q.pattern.join(',');
      _memoryGridPattern = List<int>.from(q.pattern);
      _memoryGridSelected.clear();
      _memoryGridShowingPattern = true;

      Future.delayed(const Duration(milliseconds: 1300), () {
        if (!mounted) return;
        if (_games[_gameIndex] != GameIds.memoryGrid) return;

        setState(() {
          _memoryGridShowingPattern = false;
          _instruction = 'Tap the squares that were highlighted';
        });
      });

      return;
    }

    if (game == GameIds.orderRecall) {
      final OrderRecallQuestion q = OrderRecallQuestions
          .all[_random.nextInt(OrderRecallQuestions.all.length)];

      _instruction = 'Remember the order';
      _question = q.shown.join('   ');
      _orderRecallAnswerSequence =
          q.answer.map((number) => number.toString()).toList();
      _orderRecallSelectableOptions =
          q.shown.map((number) => number.toString()).toList()..shuffle(_random);
      _orderRecallSelectedSequence = <String>[];
      _orderRecallInput = '';
      _options = <String>['OK'];
      _answer = _orderRecallAnswerSequence.join('|');
      _orderRecallShowingSequence = true;
      return;
    }

    _instruction = 'Ready?';
    _question = 'Ready?';
    _options = <String>['OK'];
    _answer = 'OK';
  }

  Color _colourForName(String name) {
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

  void _showResultToast(bool correct) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(correct ? '✅ Correct' : '❌ Wrong'),
          duration: const Duration(milliseconds: 450),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              correct ? const Color(0xFF26B957) : const Color(0xFFE94D5F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  void _tapMemoryGridTile(int index) {
    if (_games[_gameIndex] != GameIds.memoryGrid) return;
    if (_memoryGridShowingPattern) return;
    if (_memoryGridSelected.contains(index)) return;

    setState(() {
      _memoryGridSelected.add(index);
    });

    final bool correctTile = _memoryGridPattern.contains(index);

    if (!correctTile) {
      _attempts++;
      _showResultToast(false);

      setState(() {
        _nextQuestion();
      });
      return;
    }

    final bool completed = _memoryGridPattern.every(_memoryGridSelected.contains);
    if (!completed) return;

    _attempts++;
    _correct++;
    _score++;
    _showResultToast(true);

    setState(() {
      _nextQuestion();
    });
  }

  void _tapAnswer(String selected) {
    final String currentGame = _games[_gameIndex];

    if (currentGame == GameIds.memoryGrid) {
      return;
    }

    if (currentGame == GameIds.orderRecall) {
      if (_orderRecallShowingSequence) {
        setState(() {
          _orderRecallShowingSequence = false;
          _instruction = 'Tap the numbers in the same order';
          _question = '';
          _orderRecallInput = '';
          _orderRecallSelectedSequence = <String>[];
          _options = List<String>.from(_orderRecallSelectableOptions);
        });
        return;
      }

      if (_orderRecallSelectedSequence.contains(selected)) return;
      if (!_orderRecallSelectableOptions.contains(selected)) return;

      setState(() {
        _orderRecallSelectedSequence.add(selected);
        _orderRecallInput = _orderRecallSelectedSequence.join('   ');
        _options = _orderRecallSelectableOptions
            .where((option) => !_orderRecallSelectedSequence.contains(option))
            .toList();
      });

      if (_orderRecallSelectedSequence.length <
          _orderRecallAnswerSequence.length) {
        return;
      }

      _attempts++;

      bool correct = true;

      for (int i = 0; i < _orderRecallAnswerSequence.length; i++) {
        if (_orderRecallSelectedSequence[i] != _orderRecallAnswerSequence[i]) {
          correct = false;
          break;
        }
      }

      if (correct) {
        _correct++;
        _score++;
      }

      _showResultToast(correct);

      Future.delayed(const Duration(milliseconds: 450), () {
        if (!mounted) return;

        setState(() {
          _nextQuestion();
        });
      });

      return;
    }

    _attempts++;

    final bool correct = selected == _answer;

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
    _timer?.cancel();

    _results.add(
      GameResult(
        gameId: _games[_gameIndex],
        score: _score,
        correct: _correct,
        attempts: _attempts,
        averageResponseTimeMs: 1200,
        playedAt: DateTime.now(),
      ),
    );

    if (_gameIndex >= _games.length - 1) {
      await _finishDaily();
      return;
    }

    if (_gameIndex == 2) {
      await AppInterstitialAd.show(context);
    }

    if (!mounted) return;

    setState(() {
      _gameIndex++;
    });

    _startGame();
  }

  Future<void> _finishDaily() async {
    final double accuracy = _results
            .map((e) => e.accuracy)
            .fold<double>(0, (a, b) => a + b) /
        _results.length;

    final int totalScore =
        _results.map((e) => e.score).fold<int>(0, (a, b) => a + b);

    final int brainAge = BrainAgeService.calculate(
      accuracy: accuracy,
      responseTime: 1200,
      score: totalScore,
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
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Daily Complete'),
        content: Text('Your Brain Age: $brainAge'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final double progress =
        (_gameIndex + ((secondsPerGame - _timeLeft) / secondsPerGame)) /
            _games.length;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxHeight < 760;

          return Container(
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
              child: Stack(
                children: [
                  const DailySparklesBackground(),
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      18,
                      compact ? 10 : 16,
                      18,
                      compact ? 14 : 20,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom -
                            30,
                      ),
                      child: Column(
                        children: [
                          DailyHeader(
                            onBack: () => Navigator.pop(context),
                            heartsLeft: 3,
                          ),
                          SizedBox(height: compact ? 18 : 24),
                          DailyStepProgress(
                            gamesCount: _games.length,
                            activeIndex: _gameIndex,
                            progress: progress,
                          ),
                          SizedBox(height: compact ? 28 : 38),
                          DailyQuestionCard(
                            title: GameIds.label(_games[_gameIndex]),
                            instruction: _instruction,
                            question: _question,
                            questionColor: _questionColor,
                            timeLeft: _timeLeft,
                            compact: compact,
                            inputText: _orderRecallInput,
                            memoryGridPattern: _memoryGridPattern,
                            memoryGridSelected: _memoryGridSelected,
                            memoryGridShowingPattern: _memoryGridShowingPattern,
                            onMemoryGridTap: _tapMemoryGridTile,
                          ),
                          SizedBox(height: compact ? 22 : 30),
                          ..._options.map((option) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: DailyAnswerButton(
                                text: option,
                                onPressed: () => _tapAnswer(option),
                              ),
                            );
                          }).toList(),
                          SizedBox(height: compact ? 10 : 18),
                          DailyBottomStatCard(
                            icon: '🏆',
                            label: 'Score',
                            value: '$_score',
                          ),
                          const SizedBox(height: 12),
                          DailyBottomStatCard(
                            icon: '✅',
                            label: 'Correct',
                            value: '$_correct',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}