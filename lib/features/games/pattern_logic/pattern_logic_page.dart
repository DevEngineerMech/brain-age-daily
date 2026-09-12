// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'pattern_logic_questions.dart';

class PatternLogicPage extends StatefulWidget {
  const PatternLogicPage({super.key});

  @override
  State<PatternLogicPage> createState() => _PatternLogicPageState();
}

class _PatternLogicPageState extends State<PatternLogicPage> {
  late PatternLogicQuestion _question;
  int _score = 0;
  int _questionNumber = 1;

  static const int _maxQuestions = 10;

  @override
  void initState() {
    super.initState();
    _question = PatternLogicQuestion.generate();
  }

  void _next() {
    setState(() {
      _question = PatternLogicQuestion.generate();
      _questionNumber++;
    });
  }

  void _select(String value) {
    if (value == _question.answer) {
      _score++;
    }

    if (_questionNumber >= _maxQuestions) {
      _showFinishedDialog();
      return;
    }

    _next();
  }

  void _restart() {
    Navigator.pop(context);
    setState(() {
      _score = 0;
      _questionNumber = 1;
      _question = PatternLogicQuestion.generate();
    });
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
          content: Text('You scored $_score out of $_maxQuestions.'),
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
                    _FreePlayHeader(
                      title: 'Pattern Logic',
                      onBack: () => Navigator.pop(context),
                    ),
                    SizedBox(height: compact ? 18 : 24),
                    _RoundProgress(
                      current: _questionNumber,
                      total: _maxQuestions,
                    ),
                    SizedBox(height: compact ? 28 : 38),
                    _GameCard(
                      title: 'Pattern Logic',
                      instruction: 'What comes next?',
                      question: _question.sequence,
                      compact: compact,
                    ),
                    SizedBox(height: compact ? 22 : 30),
                    ..._question.options.map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AnswerButton(
                          text: option,
                          onPressed: () => _select(option),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _StatCard(
                      icon: '🏆',
                      label: 'Score',
                      value: '$_score',
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

class _FreePlayHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _FreePlayHeader({
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

class _GameCard extends StatelessWidget {
  final String title;
  final String instruction;
  final String question;
  final bool compact;

  const _GameCard({
    required this.title,
    required this.instruction,
    required this.question,
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
                style: TextStyle(
                  color: const Color(0xFF55178A).withOpacity(0.76),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: compact ? 40 : 70),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  question,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  style: TextStyle(
                    color: const Color(0xFF4C1179),
                    fontSize: compact ? 38 : 46,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
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
            color: const Color(0xFF8E22D8),
            border: Border.all(
              color: Colors.white,
              width: 5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 20,
                offset: const Offset(0, 10),
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
          backgroundColor: const Color(0xFFFFD247),
          foregroundColor: const Color(0xFF37135A),
          shadowColor: const Color(0xFFFFD247).withOpacity(0.28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(
              color: Colors.white.withOpacity(0.46),
              width: 1.2,
            ),
          ),
        ),
        child: FittedBox(
          child: Text(
            text,
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.16),
        ),
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}