
import 'package:flutter/material.dart';

import 'game_theme.dart';

class GameQuestionReveal extends StatelessWidget {
  final int questionNumber;
  final Widget child;

  const GameQuestionReveal({
    super.key,
    required this.questionNumber,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(questionNumber),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      builder: (context, value, content) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 22 * (1 - value)),
            child: content,
          ),
        );
      },
      child: child,
    );
  }
}

class GameAnswerFeedback extends StatelessWidget {
  final bool? correct;
  final Widget child;

  const GameAnswerFeedback({
    super.key,
    required this.correct,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final color = correct == null
        ? Colors.transparent
        : correct!
            ? GameTheme.green
            : GameTheme.red;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 210),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (correct != null)
            BoxShadow(
              color: color.withOpacity(0.28),
              blurRadius: 20,
              spreadRadius: 1,
            ),
        ],
      ),
      child: child,
    );
  }
}
