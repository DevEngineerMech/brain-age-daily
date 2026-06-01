// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';

import 'focus_count_questions.dart';

class FocusCountPage extends StatefulWidget {
  final String? gameId;
  final String title;

  const FocusCountPage({
    super.key,
    this.gameId,
    this.title = 'Focus Count',
  });

  @override
  State<FocusCountPage> createState() => _FocusCountPageState();
}

class _FocusCountPageState extends State<FocusCountPage> {
  final Random _random = Random();

  late FocusCountQuestion _question;
  List<int> _options = <int>[];

  int score = 0;
  int questionNumber = 1;

  static const int maxQuestions = 10;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    _question = FocusCountQuestions.random(_random);
    _options = FocusCountQuestions.optionsFor(_question, _random);

    if (mounted) {
      setState(() {});
    }
  }

  void _tap(int value) {
    if (value == _question.answer) {
      score++;
    }

    if (questionNumber >= maxQuestions) {
      _showFinishedDialog();
      return;
    }

    setState(() {
      questionNumber++;
    });

    _next();
  }

  void _restart() {
    Navigator.pop(context);

    setState(() {
      score = 0;
      questionNumber = 1;
    });

    _next();
  }

  void _showFinishedDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Round Complete'),
          content: Text(
            'You scored $score out of $maxQuestions.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: _restart,
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool compact = constraints.maxHeight < 760;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  18,
                  compact ? 10 : 16,
                  18,
                  20,
                ),
                child: Column(
                  children: [
                    _GameHeader(
                      title: widget.title,
                      onBack: () => Navigator.pop(context),
                    ),
                    SizedBox(height: compact ? 18 : 24),
                    _RoundProgress(
                      current: questionNumber,
                      total: maxQuestions,
                    ),
                    SizedBox(height: compact ? 28 : 38),
                    _FocusCard(
                      title: widget.title,
                      instruction: _question.instruction,
                      grid: _question.grid,
                      compact: compact,
                    ),
                    SizedBox(height: compact ? 22 : 30),
                    ..._options.map(
                      (value) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AnswerButton(
                          text: '$value',
                          onPressed: () => _tap(value),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _StatCard(
                      icon: '🏆',
                      label: 'Score',
                      value: '$score',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GameHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _GameHeader({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onBack,
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
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundProgress extends StatelessWidget {
  final int current;
  final int total;

  const _RoundProgress({
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        final bool active = index + 1 == current;
        final bool done = index + 1 < current;

        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            decoration: BoxDecoration(
              color: active || done
                  ? const Color(0xFFFFD247)
                  : Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}

class _FocusCard extends StatelessWidget {
  final String title;
  final String instruction;
  final List<String> grid;
  final bool compact;

  const _FocusCard({
    required this.title,
    required this.instruction,
    required this.grid,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: compact ? 300 : 370,
          ),
          margin: const EdgeInsets.only(top: 34),
          padding: EdgeInsets.fromLTRB(
            24,
            compact ? 52 : 62,
            24,
            compact ? 28 : 34,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 26,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF55178A),
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                instruction,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF55178A).withOpacity(0.76),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
              SizedBox(height: compact ? 24 : 34),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF7B22C9).withOpacity(0.18),
                  ),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: grid.map((symbol) {
                    return Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF7B22C9).withOpacity(0.12),
                        ),
                      ),
                      child: Text(
                        symbol,
                        style: const TextStyle(
                          color: Color(0xFF4C1179),
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF7B22C9),
            border: Border.all(
              color: Colors.white,
              width: 5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '⭐',
              style: TextStyle(fontSize: 34),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _AnswerButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 7,
          shadowColor: const Color(0xFFFFC93A).withOpacity(0.45),
          backgroundColor: const Color(0xFFFFD247),
          foregroundColor: const Color(0xFF35125A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: const BorderSide(
              color: Color(0xFFFFF0A6),
              width: 1.4,
            ),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.11),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.22),
        ),
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}