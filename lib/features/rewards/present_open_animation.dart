
import 'dart:math' as math;

import 'package:flutter/material.dart';

class PresentOpenAnimation extends StatefulWidget {
  final int day;
  final int coins;

  const PresentOpenAnimation({
    super.key,
    required this.day,
    required this.coins,
  });

  @override
  State<PresentOpenAnimation> createState() =>
      _PresentOpenAnimationState();
}

class _PresentOpenAnimationState
    extends State<PresentOpenAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const Color gold = Color(0xFFFFD15A);
  static const Color purple = Color(0xFF8B4CF6);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _range(double start, double end) {
    return ((_controller.value - start) / (end - start))
        .clamp(0.0, 1.0);
  }

  Widget _gift(double value) {
    final shake = _range(0.05, 0.36);
    final opening = Curves.easeOutBack.transform(
      _range(0.34, 0.62),
    );
    final disappearing = _range(0.65, 0.85);

    final wiggle = shake < 1
        ? math.sin(shake * math.pi * 15) * 0.07 * shake
        : 0.0;

    return Opacity(
      opacity: (1 - disappearing).clamp(0.0, 1.0),
      child: Transform.rotate(
        angle: wiggle,
        child: SizedBox(
          width: 188,
          height: 196,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              // Glowing background.
              Positioned(
                bottom: 3,
                child: Container(
                  width: 175,
                  height: 175,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: gold.withOpacity(
                          0.15 + opening * 0.55,
                        ),
                        blurRadius: 22 + opening * 65,
                        spreadRadius: opening * 18,
                      ),
                    ],
                  ),
                ),
              ),

              // Gift box.
              Positioned(
                bottom: 9,
                child: Container(
                  width: 145,
                  height: 117,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFD655FF),
                        Color(0xFF8E3AFF),
                        Color(0xFF582CC0),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFE9BAFF),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x885E2CD8),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 29,
                        height: double.infinity,
                        color: gold,
                      ),
                      Container(
                        width: double.infinity,
                        height: 25,
                        color: gold,
                      ),
                      const Icon(
                        Icons.star_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),

              // Animated lid.
              Positioned(
                bottom: 119 + opening * 100,
                left: 7 - opening * 42,
                child: Transform.rotate(
                  angle: -opening * 0.6,
                  child: Container(
                    width: 174,
                    height: 41,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFF173FF),
                          Color(0xFF973FF6),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFFFFD8FF),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x884E21C0),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 31,
                        color: gold,
                      ),
                    ),
                  ),
                ),
              ),

              // Ribbon bow.
              Positioned(
                bottom: 158 + opening * 100,
                left: 61 - opening * 42,
                child: Transform.rotate(
                  angle: -opening * 0.6,
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: gold,
                    size: 63,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rewardText() {
    final reveal = Curves.easeOutBack.transform(
      _range(0.56, 0.86),
    );

    return Opacity(
      opacity: _range(0.56, 0.75),
      child: Transform.scale(
        scale: 0.45 + reveal * 0.55,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.monetization_on_rounded,
              color: gold,
              size: 75,
              shadows: [
                Shadow(
                  color: Color(0xBBFFC658),
                  blurRadius: 25,
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              '+${widget.coins}',
              style: const TextStyle(
                color: gold,
                fontSize: 50,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Text(
              'BRAIN COINS!',
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final finished = _controller.value >= 0.97;
          final opening = _range(0.37, 0.76);

          return Container(
            height: 450,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(27),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF52258D),
                  Color(0xFF21134B),
                  Color(0xFF101033),
                ],
              ),
              border: Border.all(
                color: gold,
                width: 1.5,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ConfettiPainter(
                      progress: opening,
                    ),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'DAY ${widget.day} REWARD',
                      style: const TextStyle(
                        color: gold,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            _gift(_controller.value),
                            if (_controller.value > 0.55)
                              _rewardText(),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20, 0, 20, 22,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 49,
                        child: ElevatedButton(
                          onPressed: finished
                              ? () => Navigator.pop(context)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor:
                                const Color(0xFF241444),
                            disabledBackgroundColor:
                                const Color(0xFF554277),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            finished
                                ? 'Collect Reward!'
                                : 'Opening your gift...',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;

  _ConfettiPainter({
    required this.progress,
  });

  static const colors = [
    Color(0xFFFFD15A),
    Color(0xFFDA76FF),
    Color(0xFF45E2CD),
    Color(0xFFFF83AD),
    Colors.white,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final random = math.Random(73);
    final origin = Offset(size.width / 2, size.height * 0.53);

    for (int i = 0; i < 80; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final speed = 60 + random.nextDouble() * 180;
      final drift = 30 + random.nextDouble() * 110;

      final x = origin.dx +
          math.cos(angle) * speed * progress;
      final y = origin.dy +
          math.sin(angle) * speed * progress +
          drift * progress * progress;

      final paint = Paint()
        ..color = colors[i % colors.length]
            .withOpacity((1 - progress * 0.5).clamp(0, 1));

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + progress * 8);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: 4 + random.nextDouble() * 5,
            height: 8 + random.nextDouble() * 8,
          ),
          const Radius.circular(2),
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
