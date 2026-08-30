// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class DailyHeader extends StatelessWidget {
  final VoidCallback onBack;
  final int heartsLeft;
  final VoidCallback? onWatchAdForHeart;

  const DailyHeader({
    super.key,
    required this.onBack,
    required this.heartsLeft,
    this.onWatchAdForHeart,
  });

  @override
  Widget build(BuildContext context) {
    final bool canWatchAd = onWatchAdForHeart != null;

    return SizedBox(
      height: 42,
      child: Row(
        children: [
          Material(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              borderRadius: BorderRadius.circular(13),
              onTap: onBack,
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Daily Brain Check',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
          ),
          Material(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: canWatchAd ? onWatchAdForHeart : null,
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '❤️',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$heartsLeft',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (canWatchAd) ...[
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.play_circle_fill_rounded,
                        color: Color(0xFFFFD247),
                        size: 18,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DailyStepProgress extends StatelessWidget {
  final int gamesCount;
  final int activeIndex;
  final double progress;

  const DailyStepProgress({
    super.key,
    required this.gamesCount,
    required this.activeIndex,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List<Widget>.generate(
            gamesCount,
            (index) {
              final bool active = index == activeIndex;
              final bool done = index < activeIndex;

              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 34,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 3,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFFFFD247)
                        : done
                            ? const Color(0xFFFFB92E)
                            : Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: active
                          ? const Color(0xFFFFF0A6)
                          : Colors.white.withOpacity(0.10),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: active
                          ? const Color(0xFF37135A)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 5,
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
    super.key,
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
    final bool isFocusCount =
        title.toLowerCase().contains('focus count');

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 25),
          padding: const EdgeInsets.fromLTRB(
            16,
            36,
            16,
            14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF55178A),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                instruction,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF55178A)
                      .withOpacity(0.76),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 7),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8C31E8),
                      Color(0xFFB33CF2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${timeLeft}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              if (memoryGridPattern.isNotEmpty)
                DailyMemoryGridBoard(
                  pattern: memoryGridPattern,
                  selected: memoryGridSelected,
                  showingPattern: memoryGridShowingPattern,
                  onTap: onMemoryGridTap,
                )
              else if (question.isNotEmpty && isFocusCount)
                DailyFocusCountGrid(
                  question: question,
                )
              else if (question.isNotEmpty)
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    minHeight: 65,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF7B22C9)
                          .withOpacity(0.18),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      question,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: questionColor ??
                            const Color(0xFF4C1179),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    minHeight: 62,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      inputText.isEmpty
                          ? '_  _  _  _  _'
                          : inputText.split('').join('   '),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF4C1179),
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF7B22C9),
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '⭐',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
      ],
    );
  }
}

class DailyFocusCountGrid extends StatelessWidget {
  final String question;

  const DailyFocusCountGrid({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> symbols = question
        .split(RegExp(r'\s+'))
        .where(
          (item) => item.trim().isNotEmpty,
        )
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 5,
        runSpacing: 5,
        children: symbols.map(
          (symbol) {
            return Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                symbol,
                style: const TextStyle(
                  color: Color(0xFF4C1179),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}

class DailyMemoryGridBoard extends StatelessWidget {
  final List<int> pattern;
  final Set<int> selected;
  final bool showingPattern;
  final ValueChanged<int>? onTap;

  const DailyMemoryGridBoard({
    super.key,
    required this.pattern,
    required this.selected,
    required this.showingPattern,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double availableHeight =
        MediaQuery.of(context).size.height;

    final double boardSize =
        availableHeight < 760 ? 180 : 205;

    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics:
            const NeverScrollableScrollPhysics(),
        itemCount: 16,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ),
        itemBuilder: (_, index) {
          final bool lit =
              showingPattern &&
                  pattern.contains(index);

          final bool picked =
              selected.contains(index);

          return GestureDetector(
            onTap: () => onTap?.call(index),
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 140),
              decoration: BoxDecoration(
                color: lit
                    ? const Color(0xFFFFD247)
                    : picked
                        ? const Color(0xFF26B957)
                        : const Color(0xFFF3E8FF),
                borderRadius:
                    BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF7B22C9)
                      .withOpacity(0.22),
                  width: 1.2,
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
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 4,
          shadowColor:
              const Color(0xFFFFC93A)
                  .withOpacity(0.35),
          backgroundColor:
              const Color(0xFFFFD247),
          foregroundColor:
              const Color(0xFF35125A),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
            side: const BorderSide(
              color: Color(0xFFFFF0A6),
              width: 1.2,
            ),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 17,
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
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.11),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: Colors.white.withOpacity(0.22),
        ),
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class DailySparklesBackground extends StatelessWidget {
  const DailySparklesBackground({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 120,
            left: 20,
            child: DailySparkle(
              size: 8,
              opacity: 0.28,
            ),
          ),
          Positioned(
            top: 210,
            right: 32,
            child: DailySparkle(
              size: 7,
              opacity: 0.30,
            ),
          ),
          Positioned(
            bottom: 180,
            right: 26,
            child: DailySparkle(
              size: 8,
              opacity: 0.28,
            ),
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
    super.key,
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
          color:
              Colors.white.withOpacity(opacity),
          borderRadius:
              BorderRadius.circular(2),
        ),
      ),
    );
  }
}