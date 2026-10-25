
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'game_animations.dart';
import 'game_theme.dart';
import 'game_widgets.dart';

enum ArcadeQuizStyle {
  science,
  biology,
  antonyms,
  wordSnap,
  wordScramble,
}

class ArcadeQuizQuestion {
  final String prompt;
  final List<String> options;
  final String answer;

  const ArcadeQuizQuestion({
    required this.prompt,
    required this.options,
    required this.answer,
  });
}

class ArcadeQuizPage extends StatefulWidget {
  final String title;
  final String instruction;
  final IconData icon;
  final Color accent;
  final ArcadeQuizStyle style;
  final List<ArcadeQuizQuestion> questions;

  const ArcadeQuizPage({
    super.key,
    required this.title,
    required this.instruction,
    required this.icon,
    required this.accent,
    required this.style,
    required this.questions,
  });

  @override
  State<ArcadeQuizPage> createState() =>
      _ArcadeQuizPageState();
}

class _ArcadeQuizPageState extends State<ArcadeQuizPage> {
  static const int maxQuestions = 10;

  final Random _random = Random();

  late List<ArcadeQuizQuestion> _deck;
  late ArcadeQuizQuestion _question;
  late List<String> _options;

  Timer? _advanceTimer;

  int _score = 0;
  int _round = 1;
  int _deckIndex = 0;

  String? _selected;
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _resetDeck();
    _loadQuestion();
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  void _resetDeck() {
    // Prefer varied underlying prompts, rather than
    // repeating rotated-option variants in one round.
    final unique = <String, ArcadeQuizQuestion>{};

    for (final item in widget.questions) {
      unique.putIfAbsent(
        '${item.prompt}|${item.answer}',
        () => item,
      );
    }

    _deck = unique.values.toList()..shuffle(_random);
    _deckIndex = 0;
  }

  List<String> _buildOptions(ArcadeQuizQuestion question) {
    final choices = <String>{question.answer};

    // Keep the original question's answer choices.
    for (final option in question.options) {
      if (option.trim().isNotEmpty) {
        choices.add(option);
      }
      if (choices.length >= 4) break;
    }

    // Fill missing choices from the same game's
    // question bank, rather than inventing answers.
    if (choices.length < 4) {
      final alternatives = widget.questions
          .map((item) => item.answer)
          .where((value) => value != question.answer)
          .toSet()
          .toList()
        ..shuffle(_random);

      for (final option in alternatives) {
        choices.add(option);
        if (choices.length >= 4) break;
      }
    }

    return choices.take(4).toList()..shuffle(_random);
  }

  void _loadQuestion() {
    _advanceTimer?.cancel();

    if (_deck.isEmpty) return;

    if (_deckIndex >= _deck.length) {
      _resetDeck();
    }

    _question = _deck[_deckIndex++];
    _options = _buildOptions(_question);

    _selected = null;
    _locked = false;

    if (mounted) setState(() {});
  }

  void _answer(String value) {
    if (_locked) return;

    final correct = value == _question.answer;

    setState(() {
      _selected = value;
      _locked = true;

      if (correct) _score++;
    });

    _advanceTimer?.cancel();

    _advanceTimer = Timer(
      const Duration(milliseconds: 950),
      () {
        if (!mounted) return;

        if (_round >= maxQuestions) {
          _showResults();
          return;
        }

        setState(() => _round++);
        _loadQuestion();
      },
    );
  }

  void _restart() {
    _advanceTimer?.cancel();

    setState(() {
      _score = 0;
      _round = 1;
      _resetDeck();
      _loadQuestion();
    });
  }

  void _showResults() {
    _advanceTimer?.cancel();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return GameResultsDialog(
          title: widget.title,
          score: _score,
          total: maxQuestions,
          onReplay: () {
            Navigator.of(dialogContext).pop();
            _restart();
          },
          onExit: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  // =====================================================
  // VISUAL QUESTION PRESENTATIONS
  // =====================================================

  Widget _scienceVisual() {
    return _heroCard(
      icon: Icons.science_rounded,
      label: 'SCIENCE QUESTION',
      child: Text(
        _question.prompt,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          height: 1.35,
        ),
      ),
    );
  }

  Widget _biologyVisual() {
    return _heroCard(
      icon: Icons.biotech_rounded,
      label: 'BIOLOGY QUESTION',
      child: Text(
        _question.prompt,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          height: 1.35,
        ),
      ),
    );
  }

  Widget _antonymVisual() {
    return _heroCard(
      icon: Icons.compare_arrows_rounded,
      label: 'FIND THE OPPOSITE',
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _question.prompt,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 33,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 13),
          const Icon(
            Icons.swap_vert_rounded,
            color: GameTheme.gold,
            size: 31,
          ),
          const SizedBox(height: 5),
          const Text(
            'What means the opposite?',
            style: TextStyle(
              color: GameTheme.muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _cleanWordSnapPrompt(String text) {
    for (final prefix in [
      'Category: ',
      'Where does ',
      'Pick the group for ',
    ]) {
      if (text.startsWith(prefix)) {
        var result = text.substring(prefix.length);
        if (result.endsWith(' belong?')) {
          result = result.substring(
            0,
            result.length - ' belong?'.length,
          );
        }
        return result;
      }
    }
    return text;
  }

  Widget _wordSnapVisual() {
    return _heroCard(
      icon: Icons.category_rounded,
      label: 'WHICH CATEGORY?',
      child: Column(
        children: [
          Text(
            _cleanWordSnapPrompt(_question.prompt),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 33,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Choose the group this belongs to.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: GameTheme.muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _wordScrambleVisual() {
    final letters = _question.prompt.split('');

    return _heroCard(
      icon: Icons.text_fields_rounded,
      label: 'UNSCRAMBLE THE WORD',
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 5,
            runSpacing: 7,
            children: List.generate(letters.length, (index) {
              final color = [
                GameTheme.purple,
                GameTheme.cyan,
                GameTheme.gold,
                const Color(0xFFFF86C8),
              ][index % 4];

              return Container(
                width: 39,
                height: 51,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.21),
                  border: Border.all(
                    color: color.withOpacity(0.75),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  letters[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          const Text(
            'Put the letters into a real word.',
            style: TextStyle(
              color: GameTheme.muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroCard({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    final accent = widget.accent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withOpacity(0.24),
            GameTheme.panel,
          ],
        ),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: accent.withOpacity(0.85),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.17),
            blurRadius: 22,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: accent,
            size: 35,
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _questionVisual() {
    switch (widget.style) {
      case ArcadeQuizStyle.science:
        return _scienceVisual();
      case ArcadeQuizStyle.biology:
        return _biologyVisual();
      case ArcadeQuizStyle.antonyms:
        return _antonymVisual();
      case ArcadeQuizStyle.wordSnap:
        return _wordSnapVisual();
      case ArcadeQuizStyle.wordScramble:
        return _wordScrambleVisual();
    }
  }

  // =====================================================
  // ANSWER OPTIONS
  // =====================================================

  Widget _answerOptions() {
    return Column(
      children: _options.map((option) {
        final highlighted = _locked &&
            (option == _selected ||
                option == _question.answer);

        bool? correct;

        if (_locked && highlighted) {
          correct = option == _question.answer;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GameAnswerButton(
            text: option,
            accent: widget.accent,
            selected: highlighted,
            correct: correct,
            onPressed:
                _locked ? null : () => _answer(option),
          ),
        );
      }).toList(),
    );
  }

  Widget _feedback() {
    if (_selected == null) {
      return const Text(
        'Choose the answer you think is correct.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: GameTheme.muted,
          fontSize: 12,
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
          color: correct
              ? GameTheme.green
              : GameTheme.red,
          size: 21,
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            correct
                ? 'Correct! Nicely done.'
                : 'Correct answer: ${_question.answer}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: correct
                  ? GameTheme.green
                  : GameTheme.red,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return GameScreen(
        child: Center(
          child: Text(
            'No questions available for ${widget.title}.',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return GameScreen(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          15, 10, 15, 28,
        ),
        children: [
          GameHeader(
            title: widget.title,
            icon: widget.icon,
            accent: widget.accent,
            onBack: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 21),
          GameRoundProgress(
            current: _round,
            total: maxQuestions,
            accent: GameTheme.gold,
          ),
          const SizedBox(height: 20),
          GameQuestionReveal(
            questionNumber: _round,
            child: GamePanel(
              title: widget.title,
              instruction: widget.instruction,
              icon: widget.icon,
              accent: widget.accent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GameAnswerFeedback(
                    correct: _selected == null
                        ? null
                        : _selected == _question.answer,
                    child: _questionVisual(),
                  ),
                  const SizedBox(height: 21),
                  const Text(
                    'CHOOSE YOUR ANSWER',
                    style: TextStyle(
                      color: GameTheme.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _answerOptions(),
                  const SizedBox(height: 7),
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
