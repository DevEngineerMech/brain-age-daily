
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../shared/game_animations.dart';
import '../../shared/game_theme.dart';
import '../../shared/game_widgets.dart';
import 'symbol_match_questions.dart';

class SymbolMatchPage extends StatefulWidget {
  const SymbolMatchPage({super.key});

  @override
  State<SymbolMatchPage> createState() =>
      _SymbolMatchPageState();
}

class _SymbolMatchPageState extends State<SymbolMatchPage> {
  static const int maxQuestions = 10;

  static const List<String> _symbols = [
    '▲',
    '■',
    '●',
    '◆',
    '★',
    '♥',
    '⬟',
    '⬢',
  ];

  static const List<Color> _colors = [
    GameTheme.purple,
    GameTheme.cyan,
    GameTheme.gold,
    Color(0xFFFF80C7),
  ];

  final Random _random = Random();

  late SymbolMatchQuestion _question;
  late List<String> _options;

  int _score = 0;
  int _round = 1;

  String? _selected;
  bool _answerLocked = false;

  Timer? _advanceTimer;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  void _loadQuestion({bool reset = false}) {
    _advanceTimer?.cancel();

    if (reset) {
      _score = 0;
      _round = 1;
    }

    final questions = SymbolMatchQuestions.all;
    _question = questions[_random.nextInt(questions.length)];

    // Some existing generated questions include duplicate
    // symbols. Make sure there are four distinct options.
    final unique = <String>{_question.answer};

    unique.addAll(_question.options);

    final alternatives = List<String>.from(_symbols)
      ..shuffle(_random);

    for (final symbol in alternatives) {
      if (unique.length >= 4) break;
      unique.add(symbol);
    }

    _options = unique.take(4).toList()..shuffle(_random);

    _selected = null;
    _answerLocked = false;

    if (mounted) setState(() {});
  }

  void _select(String symbol) {
    if (_answerLocked) return;

    final correct = symbol == _question.answer;

    setState(() {
      _selected = symbol;
      _answerLocked = true;

      if (correct) _score++;
    });

    _advanceTimer = Timer(
      const Duration(milliseconds: 950),
      () {
        if (!mounted) return;

        if (_round >= maxQuestions) {
          _showResults();
        } else {
          _round++;
          _loadQuestion();
        }
      },
    );
  }

  void _showResults() {
    _advanceTimer?.cancel();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return GameResultsDialog(
          title: 'Symbol Match',
          score: _score,
          total: maxQuestions,
          onReplay: () {
            Navigator.of(dialogContext).pop();
            _loadQuestion(reset: true);
          },
          onExit: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Widget _targetSymbol() {
    return Center(
      child: Container(
        width: 150,
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [
              Color(0xFF503390),
              Color(0xFF25174F),
            ],
          ),
          border: Border.all(
            color: GameTheme.gold,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: GameTheme.gold.withOpacity(0.25),
              blurRadius: 28,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          _question.target,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 83,
            fontWeight: FontWeight.w900,
            color: GameTheme.gold,
            shadows: [
              Shadow(
                color: Color(0x99FFC75D),
                blurRadius: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _symbolOption(String symbol, int index) {
    final selected = symbol == _selected;
    final isAnswer = symbol == _question.answer;

    final showingCorrect = _answerLocked && isAnswer;
    final showingWrong =
        _answerLocked && selected && !isAnswer;

    Color color = _colors[index % _colors.length];

    if (showingCorrect) {
      color = GameTheme.green;
    } else if (showingWrong) {
      color = GameTheme.red;
    }

    final highlighted =
        showingCorrect || showingWrong;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 210),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(highlighted ? 0.36 : 0.18),
            GameTheme.panel,
          ],
        ),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: color.withOpacity(0.85),
          width: highlighted ? 2.5 : 1.3,
        ),
        boxShadow: [
          if (highlighted)
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 19,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              _answerLocked ? null : () => _select(symbol),
          borderRadius: BorderRadius.circular(19),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                symbol,
                style: TextStyle(
                  color: color,
                  fontSize: 67,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 11,
                    ),
                  ],
                ),
              ),
              if (highlighted)
                Positioned(
                  right: 9,
                  top: 9,
                  child: Icon(
                    showingCorrect
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    size: 23,
                    color: color,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _answerGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;

        final side = min(
          (constraints.maxWidth - gap) / 2,
          150.0,
        );

        return Center(
          child: SizedBox(
            width: side * 2 + gap,
            child: Wrap(
              spacing: gap,
              runSpacing: gap,
              children: List.generate(
                _options.length,
                (index) => SizedBox(
                  width: side,
                  height: 110,
                  child: _symbolOption(
                    _options[index],
                    index,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _feedback() {
    if (_selected == null) {
      return const SizedBox(
        height: 22,
        child: Center(
          child: Text(
            'Tap the matching symbol',
            style: TextStyle(
              color: GameTheme.muted,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    final correct = _selected == _question.answer;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          correct
              ? Icons.check_circle_rounded
              : Icons.cancel_rounded,
          color:
              correct ? GameTheme.green : GameTheme.red,
          size: 20,
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            correct
                ? 'Perfect match!'
                : 'The correct symbol is '
                    '${_question.answer}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: correct
                  ? GameTheme.green
                  : GameTheme.red,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameScreen(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          15, 10, 15, 28,
        ),
        children: [
          GameHeader(
            title: 'Symbol Match',
            icon: Icons.interests_rounded,
            accent: GameTheme.cyan,
            onBack: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 22),
          GameRoundProgress(
            current: _round,
            total: maxQuestions,
            accent: GameTheme.gold,
          ),
          const SizedBox(height: 20),
          GameQuestionReveal(
            questionNumber: _round,
            child: GamePanel(
              title: 'Find the Match',
              instruction:
                  'Look at the large symbol. '
                  'Choose the exact matching shape below.',
              icon: Icons.visibility_rounded,
              accent: GameTheme.cyan,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GameAnswerFeedback(
                    correct: _selected == null
                        ? null
                        : _selected == _question.answer,
                    child: _targetSymbol(),
                  ),
                  const SizedBox(height: 23),
                  _answerGrid(),
                  const SizedBox(height: 14),
                  _feedback(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 17),
          GameScoreChip(
            score: _score,
            total: maxQuestions,
          ),
        ],
      ),
    );
  }
}
