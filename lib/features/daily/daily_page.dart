
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/game_ids.dart';
import '../../core/models/daily_session_result.dart';
import '../../core/models/game_result.dart';
import '../../core/services/admob_service.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/brain_age_service.dart';
import '../../core/services/daily_notification_service.dart';
import '../../core/services/daily_progress_service.dart';
import '../../core/services/stats_service.dart';
import '../../core/widgets/app_interstitial_ad.dart';
import '../../core/widgets/app_rewarded_ad.dart';

import '../games/brain_training/quick_math/quick_math_questions.dart';
import '../games/brain_training/time_difference/time_difference_questions.dart';
import '../games/coin_arcade/antonyms/antonyms_questions.dart';
import '../games/coin_arcade/science_quiz/science_quiz_questions.dart';
import '../games/coin_arcade/biology_quiz/biology_quiz_questions.dart';
import '../games/brain_training/focus_count/focus_count_questions.dart';
import '../games/coin_arcade/word_snap/word_snap_questions.dart';
import '../games/coin_arcade/word_scramble/word_scramble_questions.dart';
import '../games/brain_training/stroop_shift/stroop_shift_questions.dart';
import '../games/brain_training/reaction_switch/reaction_switch_questions.dart';
import '../games/brain_training/sudoku/sudoku_questions.dart';
import '../games/brain_training/symbol_match/symbol_match_questions.dart';
import '../games/brain_training/pattern_logic/pattern_logic_questions.dart';
import '../games/brain_training/memory_grid/memory_grid_questions.dart';
import '../games/brain_training/order_recall/order_recall_questions.dart';

import 'daily_engine.dart';
import 'daily_page_widgets.dart';
import '../games/shared/game_theme.dart';

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

  static const Color _background = GameTheme.background;
  static const Color _panel = Color(0xFF1A1646);
  static const Color _gold = Color(0xFFFFC75D);
  static const Color _cyan = Color(0xFF42D9D0);

  final DailyEngine _engine = DailyEngine();
  final Random _random = Random();

  late final List<String> _games;
  late final DateTime _dailyStartedAt;

  final List<GameResult> _results = [];
  final List<QuestionResult> _questionResults = [];

  int _gameIndex = 0;
  int _timeLeft = secondsPerGame;
  int _score = 0;
  int _correct = 0;
  int _attempts = 0;
  int _heartsLeft = maxHearts;

  bool _dailyFinished = false;
  bool _finishingGame = false;

  Timer? _timer;

  String _question = '';
  String _instruction = '';
  List<String> _options = [];
  String _answer = '';
  Color? _questionColor;

  bool _orderRecallShowingSequence = false;
  String _orderRecallInput = '';
  List<String> _orderRecallAnswerSequence = [];
  List<String> _orderRecallSelectedSequence = [];
  List<String> _orderRecallSelectableOptions = [];

  bool _memoryGridShowingPattern = false;
  List<int> _memoryGridPattern = [];
  final Set<int> _memoryGridSelected = {};

  @override
  void initState() {
    super.initState();

    _dailyStartedAt = DateTime.now();
    _games = _engine.getTodayGames();

    AdMobService.initialize();
    AppInterstitialAd.load();
    AppRewardedAd.load();

    _startGame();
    _initialiseTracking();
  }

  Future<void> _initialiseTracking() async {
    await _loadHearts();
    await DailyProgressService.markStarted();

    await AnalyticsService.dailyChallengeStarted(
      games: _games.length,
      heartsRemaining: _heartsLeft,
    );

    await AnalyticsService.screen('daily_challenge');
    await DailyNotificationService.rescheduleDailyReminder();
  }

  @override
  void dispose() {
    _timer?.cancel();

    if (!_dailyFinished) {
      final secondsPlayed =
          DateTime.now().difference(_dailyStartedAt).inSeconds;

      AnalyticsService.dailyChallengeAbandoned(
        gamesCompleted: _results.length,
        currentGame: _gameIndex + 1,
        secondsPlayed: secondsPlayed,
      );

      DailyNotificationService.rescheduleDailyReminder();
    }

    super.dispose();
  }

  // ======================================================
  // HEARTS AND REWARDED ADVERTS
  // ======================================================

  Future<void> _loadHearts() async {
    if (kIsWeb) {
      if (mounted) setState(() => _heartsLeft = maxHearts);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    int hearts = prefs.getInt(_heartsKey) ?? maxHearts;

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final lastRegenMs = prefs.getInt(_lastHeartRegenKey);

    if (lastRegenMs == null) {
      await prefs.setInt(_lastHeartRegenKey, nowMs);
    } else if (hearts < maxHearts) {
      final elapsedMs = nowMs - lastRegenMs;
      final daysPassed =
          elapsedMs ~/ const Duration(hours: 24).inMilliseconds;

      if (daysPassed > 0) {
        hearts = min(maxHearts, hearts + daysPassed);

        await prefs.setInt(_heartsKey, hearts);
        await prefs.setInt(
          _lastHeartRegenKey,
          lastRegenMs +
              daysPassed *
                  const Duration(hours: 24).inMilliseconds,
        );
      }
    }

    if (!mounted) return;

    setState(() {
      _heartsLeft = hearts.clamp(0, maxHearts).toInt();
    });
  }

  Future<void> _saveHearts(int hearts) async {
    if (kIsWeb) {
      if (mounted) setState(() => _heartsLeft = maxHearts);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final safeHearts = hearts.clamp(0, maxHearts).toInt();

    await prefs.setInt(_heartsKey, safeHearts);

    if (safeHearts < maxHearts) {
      await prefs.setInt(
        _lastHeartRegenKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    }

    if (mounted) {
      setState(() => _heartsLeft = safeHearts);
    }
  }

  Future<void> _watchAdForHeart() async {
    if (_heartsLeft >= maxHearts) return;

    await AnalyticsService.heartRewardedAdStarted();
    final earnedReward = await AppRewardedAd.show();

    if (!mounted) return;

    if (earnedReward) {
      await _saveHearts(
          (_heartsLeft + 1).clamp(0, maxHearts).toInt());

      await AnalyticsService.heartRewardedAdCompleted();

      if (!mounted) return;
      _showMessage('❤️ +1 Heart', true);
    } else {
      await AnalyticsService.heartRewardFailed();
      AppRewardedAd.load();

      if (!mounted) return;
      _showMessage('Ad not ready yet. Try again soon.', false);
    }
  }

  void _showMessage(String text, bool success) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          duration: const Duration(milliseconds: 900),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success
              ? const Color(0xFF168B83)
              : const Color(0xFF9A3966),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ======================================================
  // GAME TIMER AND RESET
  // ======================================================

  void _startGame() {
    _finishingGame = false;
    _score = 0;
    _correct = 0;
    _attempts = 0;
    _timeLeft = secondsPerGame;

    AnalyticsService.dailyGameStarted(
      gameId: _games[_gameIndex],
      position: _gameIndex + 1,
    );

    _nextQuestion();
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) return;

        setState(() => _timeLeft--);

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
    _orderRecallAnswerSequence = [];
    _orderRecallSelectedSequence = [];
    _orderRecallSelectableOptions = [];

    _memoryGridShowingPattern = false;
    _memoryGridPattern = [];
    _memoryGridSelected.clear();
  }

  // ======================================================
  // QUESTION GENERATION
  // ======================================================

  void _nextQuestion() {
    final game = _games[_gameIndex];
    _resetSpecialGameState();

    if (game == GameIds.quickMath) {
      final q = QuickMathQuestions.all[
          _random.nextInt(QuickMathQuestions.all.length)];

      _instruction = 'Solve as fast as you can';
      _question = q.text;
      _answer = '${q.answer}';

      _options = [
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
      final q = TimeDifferenceQuestions.all[
          _random.nextInt(TimeDifferenceQuestions.all.length)];

      _instruction = 'How many minutes elapsed?';
      _question = '${q.from} → ${q.to}';
      _answer = '${q.minutes}';

      _options = [
        '${q.minutes}',
        '${q.minutes + 5}',
        '${q.minutes - 5}',
        '${q.minutes + 10}',
      ]
          .where((value) =>
              int.tryParse(value) != null &&
              int.parse(value) >= 0)
          .toSet()
          .toList();

      while (_options.length < 4) {
        _options.add('${q.minutes + _options.length * 15}');
      }

      _options.shuffle(_random);
      return;
    }

    if (game == GameIds.antonyms) {
      final q = AntonymQuestions.all[
          _random.nextInt(AntonymQuestions.all.length)];

      _instruction = 'Choose the opposite meaning';
      _question = q.word;
      _options = List<String>.from(q.options)..shuffle(_random);
      _answer = q.answer;
      return;
    }

    if (game == GameIds.scienceQuiz) {
      final q = ScienceQuizQuestions.all[
          _random.nextInt(ScienceQuizQuestions.all.length)];

      _instruction = 'Choose the correct answer';
      _question = q.question;
      _options = List<String>.from(q.options)..shuffle(_random);
      _answer = q.answer;
      return;
    }

    if (game == GameIds.biologyQuiz) {
      final q = BiologyQuizQuestions.all[
          _random.nextInt(BiologyQuizQuestions.all.length)];

      _instruction = 'Choose the correct answer';
      _question = q.question;
      _options = List<String>.from(q.options)..shuffle(_random);
      _answer = q.answer;
      return;
    }

    if (game == GameIds.wordSnap) {
      final q = WordSnapQuestions.all[
          _random.nextInt(WordSnapQuestions.all.length)];

      _instruction = 'Choose the correct category';
      _question = q.word;
      _options = List<String>.from(q.options)..shuffle(_random);
      _answer = q.answer;
      return;
    }

    if (game == GameIds.wordScramble) {
      final q = WordScrambleQuestions.all[
          _random.nextInt(WordScrambleQuestions.all.length)];

      _instruction = 'Unscramble the word';
      _question = q.scrambled;
      _options = List<String>.from(q.options)..shuffle(_random);
      _answer = q.answer;
      return;
    }

    if (game == GameIds.focusCount) {
      final q = FocusCountQuestions.random(_random);

      _instruction = q.instruction;
      _question = q.grid.join('   ');
      _options = FocusCountQuestions.optionsFor(q, _random)
          .map((value) => value.toString())
          .toList();
      _answer = q.answer.toString();
      return;
    }

    if (game == GameIds.stroopShift) {
      final q = StroopShiftQuestions.all[
          _random.nextInt(StroopShiftQuestions.all.length)];

      _instruction = 'TAP THE COLOUR OF THE TEXT, NOT THE WORD';
      _question = q.word;
      _questionColor = _colourForName(q.inkColour);
      _options = List<String>.from(q.options)..shuffle(_random);
      _answer = q.answer;
      return;
    }

    if (game == GameIds.reactionSwitch) {
      final q = ReactionSwitchQuestions.all[
          _random.nextInt(ReactionSwitchQuestions.all.length)];

      _instruction = q.prompt;
      _question = q.display;
      _options = ['YES', 'NO']..shuffle(_random);
      _answer = q.answer;
      return;
    }

    if (game == GameIds.sudoku) {
      final q = SudokuQuestions.all[
          _random.nextInt(SudokuQuestions.all.length)];

      _instruction = 'Fill the missing number';
      _question = q.row;
      _options = List<String>.from(q.options)..shuffle(_random);
      _answer = q.answer;
      return;
    }

    if (game == GameIds.symbolMatch) {
      final q = SymbolMatchQuestions.all[
          _random.nextInt(SymbolMatchQuestions.all.length)];

      _instruction = 'Tap the matching symbol';
      _question = q.target;
      _options = List<String>.from(q.options)..shuffle(_random);
      _answer = q.answer;
      return;
    }

    if (game == GameIds.patternLogic) {
      final q = PatternLogicQuestion.generate();

      _instruction = 'What comes next?';
      _question = q.sequence;
      _options = List<String>.from(q.options)..shuffle(_random);
      _answer = q.answer;
      return;
    }

    if (game == GameIds.memoryGrid) {
      final q = MemoryGridQuestions.all[
          _random.nextInt(MemoryGridQuestions.all.length)];

      _instruction = 'Remember the highlighted squares';
      _question = '';
      _options = [];
      _answer = q.pattern.join(',');

      _memoryGridPattern = List<int>.from(q.pattern);
      _memoryGridSelected.clear();
      _memoryGridShowingPattern = true;

      Future.delayed(
        const Duration(milliseconds: 1300),
        () {
          if (!mounted) return;
          if (_games[_gameIndex] != GameIds.memoryGrid) return;

          setState(() {
            _memoryGridShowingPattern = false;
            _instruction =
                'Tap the squares that were highlighted';
          });
        },
      );
      return;
    }

    if (game == GameIds.orderRecall) {
      final q = OrderRecallQuestions.all[
          _random.nextInt(OrderRecallQuestions.all.length)];

      _instruction = 'Remember the order';
      _question = q.shown.join('   ');

      _orderRecallAnswerSequence = q.answer
          .map((number) => number.toString())
          .toList();

      _orderRecallSelectableOptions = q.shown
          .map((number) => number.toString())
          .toList()
        ..shuffle(_random);

      _orderRecallSelectedSequence = [];
      _orderRecallInput = '';
      _options = ['OK'];
      _answer = _orderRecallAnswerSequence.join('|');
      _orderRecallShowingSequence = true;
      return;
    }

    _instruction = 'Ready?';
    _question = 'Ready?';
    _options = ['OK'];
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

  // ======================================================
  // CORRECT / WRONG FEEDBACK
  // ======================================================

  void _showResultToast(bool correct) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                correct
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: Colors.white,
                size: 21,
              ),
              const SizedBox(width: 8),
              Text(
                correct ? 'Correct!' : 'Wrong!',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 450),
          behavior: SnackBarBehavior.floating,
          backgroundColor: correct
              ? const Color(0xFF168B83)
              : const Color(0xFFB83B65),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.all(15),
        ),
      );
  }

  // ======================================================
  // MEMORY GRID INPUT
  // ======================================================

  void _tapMemoryGridTile(int index) {
    if (_finishingGame) return;
    if (_games[_gameIndex] != GameIds.memoryGrid) return;
    if (_memoryGridShowingPattern) return;
    if (_memoryGridSelected.contains(index)) return;

    setState(() {
      _memoryGridSelected.add(index);
    });

    final correctTile = _memoryGridPattern.contains(index);

    if (!correctTile) {
      _attempts++;

      _questionResults.add(
        QuestionResult(
          gameId: _games[_gameIndex],
          question: 'Remember the highlighted squares',
          userAnswer: index.toString(),
          correctAnswer: _memoryGridPattern.join(', '),
          isCorrect: false,
        ),
      );

      _showResultToast(false);

      setState(() => _nextQuestion());
      return;
    }

    final completed = _memoryGridPattern.every(
      _memoryGridSelected.contains,
    );

    if (!completed) return;

    _attempts++;
    _correct++;
    _score++;

    _questionResults.add(
      QuestionResult(
        gameId: _games[_gameIndex],
        question: 'Remember the highlighted squares',
        userAnswer: _memoryGridSelected.join(', '),
        correctAnswer: _memoryGridPattern.join(', '),
        isCorrect: true,
      ),
    );

    _showResultToast(true);
    setState(() => _nextQuestion());
  }

  // ======================================================
  // ANSWER HANDLING
  // ======================================================

  void _tapAnswer(String selected) {
    if (_finishingGame) return;

    final currentGame = _games[_gameIndex];
    if (currentGame == GameIds.memoryGrid) return;

    if (currentGame == GameIds.orderRecall) {
      if (_orderRecallShowingSequence) {
        setState(() {
          _orderRecallShowingSequence = false;
          _instruction = 'Tap the numbers in the same order';
          _question = '';
          _orderRecallInput = '';
          _orderRecallSelectedSequence = [];
          _options =
              List<String>.from(_orderRecallSelectableOptions);
        });
        return;
      }

      if (_orderRecallSelectedSequence.contains(selected)) {
        return;
      }

      if (!_orderRecallSelectableOptions.contains(selected)) {
        return;
      }

      setState(() {
        _orderRecallSelectedSequence.add(selected);
        _orderRecallInput =
            _orderRecallSelectedSequence.join('   ');

        _options = _orderRecallSelectableOptions
            .where((option) =>
                !_orderRecallSelectedSequence.contains(option))
            .toList();
      });

      if (_orderRecallSelectedSequence.length <
          _orderRecallAnswerSequence.length) {
        return;
      }

      _attempts++;
      bool correct = true;

      for (int i = 0;
          i < _orderRecallAnswerSequence.length;
          i++) {
        if (_orderRecallSelectedSequence[i] !=
            _orderRecallAnswerSequence[i]) {
          correct = false;
          break;
        }
      }

      _questionResults.add(
        QuestionResult(
          gameId: _games[_gameIndex],
          question: 'Repeat the sequence',
          userAnswer:
              _orderRecallSelectedSequence.join(', '),
          correctAnswer:
              _orderRecallAnswerSequence.join(', '),
          isCorrect: correct,
        ),
      );

      if (correct) {
        _correct++;
        _score++;
      }

      _showResultToast(correct);

      Future.delayed(
        const Duration(milliseconds: 450),
        () {
          if (!mounted || _finishingGame) return;
          setState(() => _nextQuestion());
        },
      );
      return;
    }

    _attempts++;
    final correct = selected == _answer;

    _questionResults.add(
      QuestionResult(
        gameId: _games[_gameIndex],
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
    setState(() => _nextQuestion());
  }

  // ======================================================
  // FINISH MINI GAME
  // ======================================================

  Future<void> _finishGame() async {
    if (_finishingGame) return;
    _finishingGame = true;
    _timer?.cancel();

    final durationSeconds =
        (secondsPerGame - _timeLeft)
            .clamp(1, secondsPerGame);

    final elapsedMs = durationSeconds * 1000.0;

    final averageResponseTimeMs =
        max(500.0, elapsedMs / max(1, _attempts));

    await AnalyticsService.dailyGameCompleted(
      gameId: _games[_gameIndex],
      position: _gameIndex + 1,
      score: _score,
      correct: _correct,
      attempts: _attempts,
      durationSeconds: durationSeconds,
    );

    _results.add(
      GameResult(
        gameId: _games[_gameIndex],
        score: _score,
        correct: _correct,
        attempts: _attempts,
        averageResponseTimeMs: averageResponseTimeMs,
        playedAt: DateTime.now(),
        questionResults: _questionResults
            .where((result) =>
                result.gameId == _games[_gameIndex])
            .toList(),
      ),
    );

    await DailyProgressService.setGamesCompleted(
      _results.length,
    );
    await DailyNotificationService.rescheduleDailyReminder();

    if (_gameIndex >= _games.length - 1) {
      await _finishDaily();
      return;
    }

    // Preserve the existing interstitial after game three.
    if (_gameIndex == 2) {
      if (!mounted) return;
      await AppInterstitialAd.show(context);
    }

    if (!mounted) return;

    setState(() => _gameIndex++);
    _startGame();
  }

  // ======================================================
  // COMPLETE DAILY CHALLENGE
  // ======================================================

  Future<void> _finishDaily() async {
    final accuracy = _results
            .map((e) => e.accuracy)
            .fold<double>(0, (a, b) => a + b) /
        _results.length;

    final totalScore = _results
        .map((e) => e.score)
        .fold<int>(0, (a, b) => a + b);

    final totalCorrect = _results
        .map((e) => e.correct)
        .fold<int>(0, (a, b) => a + b);

    final totalAttempts = _results
        .map((e) => e.attempts)
        .fold<int>(0, (a, b) => a + b);

    final averageResponseTime = _results
            .map((e) => e.averageResponseTimeMs)
            .fold<double>(0, (a, b) => a + b) /
        _results.length;

    final prefs = await SharedPreferences.getInstance();
    final userAge = prefs.getInt('user_age') ?? 25;

    final brainAge = BrainAgeService.calculate(
      accuracy: accuracy,
      responseTime: averageResponseTime,
      score: totalScore,
      chronologicalAge: userAge,
    );

    final dailyDurationSeconds =
        DateTime.now().difference(_dailyStartedAt).inSeconds;

    await AnalyticsService.brainAgeCalculated(
      brainAge: brainAge,
      chronologicalAge: userAge,
    );

    await StatsService.saveDailySession(
      DailySessionResult(
        gameResults: _results,
        brainAge: brainAge,
        completedAt: DateTime.now(),
      ),
    );

    _dailyFinished = true;
    await DailyProgressService.markCompleted();

    await AnalyticsService.dailyChallengeCompleted(
      brainAge: brainAge,
      chronologicalAge: userAge,
      score: totalScore,
      correct: totalCorrect,
      attempts: totalAttempts,
      durationSeconds: dailyDurationSeconds,
    );

    await DailyNotificationService.rescheduleDailyReminder();

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF32156E),
                  Color(0xFF17143D),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: const Color(0xFFAA73FF), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events_rounded,
                    color: _gold, size: 54),
                const SizedBox(height: 12),
                const Text(
                  'DAILY COMPLETE!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'YOUR BRAIN AGE',
                  style: TextStyle(
                    color: Color(0xFFBDB3DB),
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween:
                      Tween(begin: 0, end: brainAge.toDouble()),
                  duration: const Duration(milliseconds: 950),
                  builder: (context, value, _) => Text(
                    value.round().toString(),
                    style: const TextStyle(
                      color: _gold,
                      fontSize: 76,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  'Score: $totalScore',
                  style: const TextStyle(
                    color: _cyan,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$totalCorrect correct out of $totalAttempts attempts',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 49,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BrainGameTheme.purple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (mounted) Navigator.pop(context);
  }

  // ======================================================
  // ANSWER BUTTONS
  // ======================================================

  Widget _buildAnswers(Color accent, bool compact) {
    if (_options.isEmpty) {
      return const SizedBox.shrink();
    }

    final buttonHeight = compact ? 50.0 : 58.0;

    if (_options.length == 1) {
      return SizedBox(
        height: buttonHeight,
        child: DailyAnswerButton(
          text: _options.first,
          accent: accent,
          onPressed: () => _tapAnswer(_options.first),
        ),
      );
    }

    final rows = (_options.length / 2).ceil();

    return SizedBox(
      height: rows * buttonHeight + (rows - 1) * 9,
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _options.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 9,
          mainAxisSpacing: 9,
          mainAxisExtent: buttonHeight,
        ),
        itemBuilder: (context, index) {
          final option = _options[index];
          return DailyAnswerButton(
            text: option,
            accent: accent,
            onPressed: () => _tapAnswer(option),
          );
        },
      ),
    );
  }

  // ======================================================
  // LIVE SCORE
  // ======================================================

  Widget _buildMiniStats() {
    return Container(
      height: 43,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF51418C)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded,
              color: _gold, size: 20),
          const SizedBox(width: 7),
          Text(
            'Score $_score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          const Icon(Icons.check_circle_rounded,
              color: _cyan, size: 19),
          const SizedBox(width: 7),
          Text(
            'Correct $_correct',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // NEW BALANCED SCREEN LAYOUT
  // ======================================================

  @override
  Widget build(BuildContext context) {
    final progress = (_gameIndex +
            (secondsPerGame - _timeLeft) / secondsPerGame) /
        _games.length;

    final gameTitle = GameIds.label(_games[_gameIndex]);
    final visual = GameVisual.forTitle(gameTitle);

    return Scaffold(
      backgroundColor: _background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: GameTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 720;

              return Stack(
                children: [
                  const DailySparklesBackground(),
                  Column(
                    children: [
                      // Fixed top information.
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            12, 8, 12, 6),
                        child: Column(
                          children: [
                            DailyHeader(
                              onBack: () => Navigator.pop(context),
                              heartsLeft: _heartsLeft,
                              onWatchAdForHeart:
                                  _heartsLeft < maxHearts
                                      ? _watchAdForHeart
                                      : null,
                            ),
                            const SizedBox(height: 9),
                            DailyStepProgress(
                              gamesCount: _games.length,
                              activeIndex: _gameIndex,
                              progress: progress,
                            ),
                          ],
                        ),
                      ),

                      // The question and answers remain together.
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(
                              12, 10, 12, 12),
                          children: [
                            AnimatedSwitcher(
                              duration:
                                  const Duration(milliseconds: 220),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                              child: DailyQuestionCard(
                                key: ValueKey(
                                  '${_gameIndex}_${_question}_'
                                  '${_instruction}_'
                                  '${_memoryGridShowingPattern}_'
                                  '${_memoryGridSelected.length}',
                                ),
                                title: gameTitle,
                                instruction: _instruction,
                                question: _question,
                                questionColor: _questionColor,
                                timeLeft: _timeLeft,
                                compact: compact,
                                inputText: _orderRecallInput,
                                memoryGridPattern:
                                    _memoryGridPattern,
                                memoryGridSelected:
                                    _memoryGridSelected,
                                memoryGridShowingPattern:
                                    _memoryGridShowingPattern,
                                onMemoryGridTap: _tapMemoryGridTile,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Icon(Icons.touch_app_rounded,
                                    color: visual.color, size: 17),
                                const SizedBox(width: 6),
                                const Text(
                                  'CHOOSE YOUR ANSWER',
                                  style: TextStyle(
                                    color: BrainGameTheme.muted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.7,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildAnswers(visual.color, compact),
                            const SizedBox(height: 14),
                            _buildMiniStats(),
                          ],
                        ),
                      ),
                    ],
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
