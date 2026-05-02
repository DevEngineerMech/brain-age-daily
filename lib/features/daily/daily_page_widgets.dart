import 'package:flutter/material.dart';

class DailyHeader extends StatelessWidget {
  final VoidCallback onBack;
  final int heartsLeft;

  const DailyHeader({
    required this.onBack,
    required this.heartsLeft,
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
        const Expanded(
          child: Text(
            'Daily Brain Check',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
            ),
          ),
          child: Row(
            children: [
              const Text(
                '❤️',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 6),
              Text(
                '$heartsLeft',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DailyStepProgress extends StatelessWidget {
  final int gamesCount;
  final int activeIndex;
  final double progress;

  const DailyStepProgress({
    required this.gamesCount,
    required this.activeIndex,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List<Widget>.generate(gamesCount, (index) {
            final bool active = index == activeIndex;
            final bool done = index < activeIndex;

            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 46,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFFFD247)
                      : done
                          ? const Color(0xFFFFB92E)
                          : Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: active
                        ? const Color(0xFFFFF0A6)
                        : Colors.white.withOpacity(0.10),
                    width: 1.4,
                  ),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFFD247).withOpacity(0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: active ? const Color(0xFF37135A) : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.18),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFFFFD247),
            ),
          ),
        ),
      ],
    );
  }
}

class DailyQuestionCard extends StatelessWidget {
  final String title;
  final String instruction;
  final String question;
  final Color? questionColor;
  final int timeLeft;
  final bool compact;
  final String inputText;
  final List<int> memoryGridPattern;
  final Set<int> memoryGridSelected;
  final bool memoryGridShowingPattern;
  final ValueChanged<int>? onMemoryGridTap;

  const DailyQuestionCard({
    required this.title,
    required this.instruction,
    required this.question,
    required this.questionColor,
    required this.timeLeft,
    required this.compact,
    required this.inputText,
    required this.memoryGridPattern,
    required this.memoryGridSelected,
    required this.memoryGridShowingPattern,
    required this.onMemoryGridTap,
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
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8C31E8),
                      Color(0xFFB33CF2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8C31E8).withOpacity(0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      '${timeLeft}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: compact ? 28 : 42),
              if (memoryGridPattern.isNotEmpty)
                DailyMemoryGridBoard(
                  pattern: memoryGridPattern,
                  selected: memoryGridSelected,
                  showingPattern: memoryGridShowingPattern,
                  onTap: onMemoryGridTap,
                )
              else if (question.isNotEmpty)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    question,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(
                      color: questionColor ?? const Color(0xFF4C1179),
                      fontSize: compact ? 38 : 46,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF7B22C9).withOpacity(0.18),
                    ),
                  ),
                  child: Text(
                    inputText.isEmpty
                        ? '_  _  _  _  _'
                        : inputText.split('').join('   '),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF4C1179),
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
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

class DailyMemoryGridBoard extends StatelessWidget {
  final List<int> pattern;
  final Set<int> selected;
  final bool showingPattern;
  final ValueChanged<int>? onTap;

  const DailyMemoryGridBoard({
    required this.pattern,
    required this.selected,
    required this.showingPattern,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 16,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (_, index) {
          final bool lit = showingPattern && pattern.contains(index);
          final bool picked = selected.contains(index);

          return GestureDetector(
            onTap: () => onTap?.call(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              decoration: BoxDecoration(
                color: lit
                    ? const Color(0xFFFFD247)
                    : picked
                        ? const Color(0xFF26B957)
                        : const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF7B22C9).withOpacity(0.22),
                  width: 1.4,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DailyAnswerButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const DailyAnswerButton({
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

class DailyBottomStatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const DailyBottomStatCard({
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

class DailySparklesBackground extends StatelessWidget {
  const DailySparklesBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: const [
          Positioned(
            top: 120,
            left: 20,
            child: DailySparkle(size: 8, opacity: 0.28),
          ),
          Positioned(
            top: 210,
            right: 32,
            child: DailySparkle(size: 7, opacity: 0.30),
          ),
          Positioned(
            top: 470,
            left: 46,
            child: DailySparkle(size: 6, opacity: 0.30),
          ),
          Positioned(
            bottom: 180,
            right: 26,
            child: DailySparkle(size: 8, opacity: 0.28),
          ),
          Positioned(
            bottom: 72,
            left: 28,
            child: DailySparkle(size: 6, opacity: 0.22),
          ),
        ],
      ),
    );
  }
}

class DailySparkle extends StatelessWidget {
  final double size;
  final double opacity;

  const DailySparkle({
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.8,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(opacity),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}