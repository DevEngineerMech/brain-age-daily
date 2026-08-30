// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';

class DailyHeader extends StatelessWidget {
  final VoidCallback onBack;
  final int heartsLeft;
  final VoidCallback? onWatchAdForHeart;
  final double scale;

  const DailyHeader({
    super.key,
    required this.onBack,
    required this.heartsLeft,
    this.onWatchAdForHeart,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool canWatchAd = onWatchAdForHeart != null;

    final double height = (46 * scale).clamp(40.0, 54.0);
    final double iconSize = (28 * scale).clamp(24.0, 32.0);
    final double titleSize = (24 * scale).clamp(20.0, 28.0);

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Material(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(
              (15 * scale).clamp(12.0, 18.0),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(
                (15 * scale).clamp(12.0, 18.0),
              ),
              onTap: onBack,
              child: SizedBox(
                width: height,
                height: height,
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
            ),
          ),

          SizedBox(
            width: (11 * scale).clamp(8.0, 14.0),
          ),

          Expanded(
            child: Text(
              'Daily Brain Check',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: titleSize,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
          ),

          SizedBox(
            width: (8 * scale).clamp(6.0, 10.0),
          ),

          Material(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(
              (17 * scale).clamp(14.0, 20.0),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(
                (17 * scale).clamp(14.0, 20.0),
              ),
              onTap: canWatchAd ? onWatchAdForHeart : null,
              child: Container(
                height: height,
                padding: EdgeInsets.symmetric(
                  horizontal: (12 * scale).clamp(9.0, 15.0),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    (17 * scale).clamp(14.0, 20.0),
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '❤️',
                      style: TextStyle(
                        fontSize: (18 * scale).clamp(15.0, 21.0),
                      ),
                    ),

                    SizedBox(
                      width: (5 * scale).clamp(4.0, 7.0),
                    ),

                    Text(
                      '$heartsLeft',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: (17 * scale).clamp(15.0, 20.0),
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    if (canWatchAd) ...[
                      SizedBox(
                        width: (5 * scale).clamp(4.0, 7.0),
                      ),
                      Icon(
                        Icons.play_circle_fill_rounded,
                        color: const Color(0xFFFFD247),
                        size: (19 * scale).clamp(17.0, 22.0),
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
  final double scale;

  const DailyStepProgress({
    super.key,
    required this.gamesCount,
    required this.activeIndex,
    required this.progress,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final double boxHeight =
        (40 * scale).clamp(34.0, 48.0);

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
                  height: boxHeight,
                  margin: EdgeInsets.symmetric(
                    horizontal: (3 * scale).clamp(2.0, 5.0),
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFFFFD247)
                        : done
                            ? const Color(0xFFFFB92E)
                            : Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(
                      (11 * scale).clamp(9.0, 14.0),
                    ),
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
                      fontSize:
                          (19 * scale).clamp(16.0, 22.0),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(
          height: (8 * scale).clamp(6.0, 10.0),
        ),

        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight:
                (6 * scale).clamp(5.0, 8.0),
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
  final String inputText;

  final List<int> memoryGridPattern;
  final Set<int> memoryGridSelected;
  final bool memoryGridShowingPattern;
  final ValueChanged<int>? onMemoryGridTap;

  final double scale;

  const DailyQuestionCard({
    super.key,
    required this.title,
    required this.instruction,
    required this.question,
    required this.questionColor,
    required this.timeLeft,
    required this.inputText,
    required this.memoryGridPattern,
    required this.memoryGridSelected,
    required this.memoryGridShowingPattern,
    required this.onMemoryGridTap,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFocusCount =
        title.toLowerCase().contains('focus count');

    final double starSize =
        (62 * scale).clamp(54.0, 74.0);

    final double cardRadius =
        (28 * scale).clamp(23.0, 34.0);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          margin: EdgeInsets.only(
            top: starSize * 0.43,
          ),
          padding: EdgeInsets.fromLTRB(
            (16 * scale).clamp(13.0, 20.0),
            starSize * 0.62,
            (16 * scale).clamp(13.0, 20.0),
            (13 * scale).clamp(10.0, 17.0),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double innerHeight =
                  constraints.maxHeight;

              final double titleSize =
                  (22 * scale).clamp(19.0, 27.0);

              final double instructionSize =
                  (14 * scale).clamp(12.0, 17.0);

              final double questionSize =
                  (30 * scale).clamp(24.0, 38.0);

              final bool shortCard =
                  innerHeight < 280;

              return Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF55178A),
                      fontSize: titleSize,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  SizedBox(
                    height: shortCard ? 2 : 4,
                  ),

                  Text(
                    instruction,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF55178A)
                          .withOpacity(0.76),
                      fontSize: instructionSize,
                      fontWeight: FontWeight.w600,
                      height: 1.12,
                    ),
                  ),

                  SizedBox(
                    height: shortCard ? 5 : 8,
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          (12 * scale).clamp(9.0, 15.0),
                      vertical:
                          (6 * scale).clamp(4.0, 8.0),
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
                        Icon(
                          Icons.timer_rounded,
                          color: Colors.white,
                          size:
                              (17 * scale).clamp(15.0, 20.0),
                        ),
                        SizedBox(
                          width: (5 * scale).clamp(4.0, 7.0),
                        ),
                        Text(
                          '${timeLeft}s',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                (15 * scale).clamp(13.0, 18.0),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: shortCard ? 6 : 10,
                  ),

                  Expanded(
                    child: Center(
                      child: memoryGridPattern.isNotEmpty
                          ? DailyMemoryGridBoard(
                              pattern: memoryGridPattern,
                              selected: memoryGridSelected,
                              showingPattern:
                                  memoryGridShowingPattern,
                              onTap: onMemoryGridTap,
                              scale: scale,
                            )
                          : question.isNotEmpty && isFocusCount
                              ? DailyFocusCountGrid(
                                  question: question,
                                  scale: scale,
                                )
                              : question.isNotEmpty
                                  ? Container(
                                      width: double.infinity,
                                      constraints:
                                          const BoxConstraints(
                                        minHeight: 60,
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(
                                        horizontal:
                                            (12 * scale).clamp(
                                          9.0,
                                          16.0,
                                        ),
                                        vertical:
                                            (10 * scale).clamp(
                                          7.0,
                                          14.0,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFF3E8FF,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(
                                          (17 * scale).clamp(
                                            14.0,
                                            21.0,
                                          ),
                                        ),
                                        border: Border.all(
                                          color: const Color(
                                            0xFF7B22C9,
                                          ).withOpacity(0.18),
                                        ),
                                      ),
                                      alignment:
                                          Alignment.center,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          question,
                                          maxLines: 4,
                                          textAlign:
                                              TextAlign.center,
                                          style: TextStyle(
                                            color:
                                                questionColor ??
                                                    const Color(
                                                      0xFF4C1179,
                                                    ),
                                            fontSize:
                                                questionSize,
                                            fontWeight:
                                                FontWeight.w900,
                                            height: 1.1,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: double.infinity,
                                      constraints:
                                          const BoxConstraints(
                                        minHeight: 60,
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(
                                        horizontal:
                                            (12 * scale).clamp(
                                          9.0,
                                          16.0,
                                        ),
                                        vertical:
                                            (10 * scale).clamp(
                                          7.0,
                                          14.0,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFF3E8FF,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(
                                          (17 * scale).clamp(
                                            14.0,
                                            21.0,
                                          ),
                                        ),
                                      ),
                                      alignment:
                                          Alignment.center,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          inputText.isEmpty
                                              ? '_  _  _  _  _'
                                              : inputText,
                                          textAlign:
                                              TextAlign.center,
                                          style: TextStyle(
                                            color: const Color(
                                              0xFF4C1179,
                                            ),
                                            fontSize:
                                                (32 * scale)
                                                    .clamp(
                                              25.0,
                                              40.0,
                                            ),
                                            fontWeight:
                                                FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        Container(
          width: starSize,
          height: starSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF7B22C9),
            border: Border.all(
              color: Colors.white,
              width: (4 * scale).clamp(3.0, 5.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '⭐',
              style: TextStyle(
                fontSize:
                    (28 * scale).clamp(23.0, 34.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DailyFocusCountGrid extends StatelessWidget {
  final String question;
  final double scale;

  const DailyFocusCountGrid({
    super.key,
    required this.question,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> symbols = question
        .split(RegExp(r'\s+'))
        .where(
          (item) => item.trim().isNotEmpty,
        )
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final int count = symbols.length;

        final int columns = count <= 20 ? 5 : 6;

        final int rows =
            max(1, (count / columns).ceil());

        const double spacing = 5;

        final double widthAvailable =
            constraints.maxWidth -
                ((columns - 1) * spacing);

        final double heightAvailable =
            constraints.maxHeight -
                ((rows - 1) * spacing);

        final double tileWidth =
            widthAvailable / columns;

        final double tileHeight =
            heightAvailable / rows;

        final double tileSize = min(
          tileWidth,
          tileHeight,
        ).clamp(22.0, 42.0);

        return Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: spacing,
            runSpacing: spacing,
            children: symbols.map(
              (symbol) {
                return Container(
                  width: tileSize,
                  height: tileSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      (9 * scale).clamp(7.0, 12.0),
                    ),
                    border: Border.all(
                      color: const Color(0xFF7B22C9)
                          .withOpacity(0.12),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      symbol,
                      style: TextStyle(
                        color: const Color(0xFF4C1179),
                        fontSize:
                            (19 * scale).clamp(16.0, 23.0),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        );
      },
    );
  }
}

class DailyMemoryGridBoard extends StatelessWidget {
  final List<int> pattern;
  final Set<int> selected;
  final bool showingPattern;
  final ValueChanged<int>? onTap;
  final double scale;

  const DailyMemoryGridBoard({
    super.key,
    required this.pattern,
    required this.selected,
    required this.showingPattern,
    required this.onTap,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double boardSize = min(
          constraints.maxWidth,
          constraints.maxHeight,
        ).clamp(150.0, 300.0);

        return SizedBox(
          width: boardSize,
          height: boardSize,
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics:
                const NeverScrollableScrollPhysics(),
            itemCount: 16,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing:
                  (6 * scale).clamp(4.0, 8.0),
              crossAxisSpacing:
                  (6 * scale).clamp(4.0, 8.0),
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
                        BorderRadius.circular(
                      (11 * scale).clamp(8.0, 14.0),
                    ),
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
      },
    );
  }
}

class DailyAnswerButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final double scale;

  const DailyAnswerButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 52,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 5,
          shadowColor:
              const Color(0xFFFFC93A).withOpacity(0.35),
          backgroundColor:
              const Color(0xFFFFD247),
          foregroundColor:
              const Color(0xFF35125A),
          padding: EdgeInsets.symmetric(
            horizontal:
                (8 * scale).clamp(6.0, 12.0),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              (16 * scale).clamp(13.0, 20.0),
            ),
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
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize:
                  (18 * scale).clamp(15.0, 22.0),
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
  final double height;
  final double scale;

  const DailyBottomStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.height = 50,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal:
            (14 * scale).clamp(10.0, 18.0),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.11),
        borderRadius: BorderRadius.circular(
          (16 * scale).clamp(13.0, 19.0),
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.22),
        ),
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: TextStyle(
              fontSize:
                  (20 * scale).clamp(17.0, 24.0),
            ),
          ),

          SizedBox(
            width: (8 * scale).clamp(6.0, 10.0),
          ),

          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize:
                    (16 * scale).clamp(14.0, 19.0),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize:
                  (20 * scale).clamp(17.0, 24.0),
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
            top: 145,
            left: 20,
            child: DailySparkle(
              size: 8,
              opacity: 0.28,
            ),
          ),
          Positioned(
            top: 245,
            right: 28,
            child: DailySparkle(
              size: 7,
              opacity: 0.30,
            ),
          ),
          Positioned(
            bottom: 150,
            right: 25,
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
          color: Colors.white.withOpacity(opacity),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}