// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'memory_grid_questions.dart';

class MemoryGridPage extends StatefulWidget {
  const MemoryGridPage({super.key});

  @override
  State<MemoryGridPage> createState() =>
      _MemoryGridPageState();
}

class _MemoryGridPageState
    extends State<MemoryGridPage> {
  static const String _ageKey =
      'user_age';

  final Random _random = Random();

  late MemoryGridQuestion _question;

  int score = 0;
  int questionNumber = 1;
  int userAge = 25;

  static const int maxQuestions = 10;
  static const int baseShowMilliseconds =
      1500;

  bool showPattern = true;

  final Set<int> selected = <int>{};
  Timer? hideTimer;

  @override
  void initState() {
    super.initState();
    _loadAgeThenStart();
  }

  @override
  void dispose() {
    hideTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAgeThenStart() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    if (!mounted) return;

    userAge =
        prefs.getInt(_ageKey) ?? 25;

    _next();
  }

  int get _patternShowMilliseconds {
    int bonusMilliseconds = 0;

    if (userAge >= 25 && userAge < 45) {
      bonusMilliseconds = 2000;
    } else if (userAge >= 45 &&
        userAge < 65) {
      bonusMilliseconds = 4000;
    } else if (userAge >= 65) {
      bonusMilliseconds = 6000;
    }

    return baseShowMilliseconds +
        bonusMilliseconds;
  }

  String get _patternTimeText {
    final double seconds =
        _patternShowMilliseconds / 1000;

    if (seconds ==
        seconds.roundToDouble()) {
      return '${seconds.toInt()}s';
    }

    return '${seconds.toStringAsFixed(1)}s';
  }

  void _hidePatternNow() {
    hideTimer?.cancel();

    if (!mounted) return;

    setState(() {
      showPattern = false;
    });
  }

  void _next() {
    hideTimer?.cancel();

    _question =
        MemoryGridQuestions.all[
          _random.nextInt(
            MemoryGridQuestions.all.length,
          )
        ];

    selected.clear();
    showPattern = true;

    if (mounted) {
      setState(() {});
    }

    hideTimer = Timer(
      Duration(
        milliseconds:
            _patternShowMilliseconds,
      ),
      () {
        if (!mounted) return;

        setState(() {
          showPattern = false;
        });
      },
    );
  }

  void _tap(int index) {
    if (showPattern) return;
    if (selected.contains(index)) return;

    selected.add(index);

    final bool correctTile =
        _question.pattern.contains(index);

    if (!correctTile) {
      setState(() {});

      Future.delayed(
        const Duration(
          milliseconds: 350,
        ),
        () {
          if (!mounted) return;
          _advanceQuestion();
        },
      );

      return;
    }

    final bool complete =
        _question.pattern.every(
      selected.contains,
    );

    if (complete) {
      score++;

      setState(() {});

      Future.delayed(
        const Duration(
          milliseconds: 350,
        ),
        () {
          if (!mounted) return;
          _advanceQuestion();
        },
      );

      return;
    }

    setState(() {});
  }

  void _advanceQuestion() {
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
    hideTimer?.cancel();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(24),
          ),
          title: const Text(
            'Round Complete',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'You scored $score out of $maxQuestions.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
            ElevatedButton(
              onPressed: _restart,
              child:
                  const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  Color _tileColor(int index) {
    final bool lit =
        showPattern &&
            _question.pattern.contains(index);

    final bool picked =
        selected.contains(index);

    final bool correctTile =
        _question.pattern.contains(index);

    if (lit) {
      return const Color(0xFFFFD247);
    }

    if (picked && correctTile) {
      return const Color(0xFF26B957);
    }

    if (picked && !correctTile) {
      return const Color(0xFFE94D5F);
    }

    return const Color(0xFFF3E8FF);
  }

  Widget _header() {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          Material(
            color:
                Colors.white.withOpacity(0.10),
            borderRadius:
                BorderRadius.circular(13),
            child: InkWell(
              borderRadius:
                  BorderRadius.circular(13),
              onTap: () =>
                  Navigator.pop(context),
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
              'Memory Grid',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progress() {
    return Row(
      children: List.generate(
        maxQuestions,
        (index) {
          final bool active =
              index + 1 == questionNumber;

          final bool done =
              index + 1 < questionNumber;

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 180,
              ),
              height: 7,
              margin:
                  const EdgeInsets.symmetric(
                horizontal: 2,
              ),
              decoration: BoxDecoration(
                color: active || done
                    ? const Color(0xFFFFD247)
                    : Colors.white
                        .withOpacity(0.18),
                borderRadius:
                    BorderRadius.circular(999),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _questionCard(bool compact) {
    final String instruction =
        showPattern
            ? 'Remember the highlighted squares for $_patternTimeText'
            : 'Tap the squares that were highlighted';

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          margin:
              const EdgeInsets.only(top: 25),
          padding: EdgeInsets.fromLTRB(
            14,
            compact ? 38 : 42,
            14,
            12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Memory Grid',
                style: TextStyle(
                  color: Color(0xFF55178A),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                instruction,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF55178A)
                      .withOpacity(0.72),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: Center(
                  child: LayoutBuilder(
                    builder: (
                      context,
                      constraints,
                    ) {
                      final double size =
                          min(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );

                      return SizedBox(
                        width: size,
                        height: size,
                        child: GridView.builder(
                          padding:
                              EdgeInsets.zero,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          itemCount: 16,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 6,
                            crossAxisSpacing: 6,
                          ),
                          itemBuilder: (
                            _,
                            index,
                          ) {
                            return GestureDetector(
                              onTap: () =>
                                  _tap(index),
                              child:
                                  AnimatedContainer(
                                duration:
                                    const Duration(
                                  milliseconds:
                                      150,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      _tileColor(
                                    index,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    10,
                                  ),
                                  border:
                                      Border.all(
                                    color:
                                        const Color(
                                      0xFF7B22C9,
                                    ).withOpacity(
                                      0.20,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),

              if (showPattern)
                SizedBox(
                  height: 36,
                  child: TextButton.icon(
                    onPressed:
                        _hidePatternNow,
                    icon: const Icon(
                      Icons
                          .fast_forward_rounded,
                      size: 17,
                    ),
                    label: const Text(
                      'Answer now',
                    ),
                    style:
                        TextButton.styleFrom(
                      foregroundColor:
                          const Color(
                        0xFF7B22C9,
                      ),
                      textStyle:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .w900,
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
          ),
          alignment: Alignment.center,
          child: const Text(
            '⭐',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ],
    );
  }

  Widget _scoreCard() {
    return Container(
      height: 44,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(0.11),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color:
              Colors.white.withOpacity(0.20),
        ),
      ),
      child: Row(
        children: [
          const Text(
            '🏆',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Score',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            '$score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final bool compact =
              constraints.maxHeight < 760;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration:
                const BoxDecoration(
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
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  12,
                  8,
                  12,
                  8,
                ),
                child: Column(
                  children: [
                    _header(),
                    const SizedBox(height: 8),
                    _progress(),
                    const SizedBox(height: 8),

                    Expanded(
                      child: _questionCard(
                        compact,
                      ),
                    ),

                    const SizedBox(height: 8),
                    _scoreCard(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}