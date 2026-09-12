// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';

import 'stroop_shift_questions.dart';

class StroopShiftPage extends StatefulWidget {
  const StroopShiftPage({super.key});

  @override
  State<StroopShiftPage> createState() =>
      _StroopShiftPageState();
}

class _StroopShiftPageState
    extends State<StroopShiftPage> {
  final Random _random = Random();

  late StroopShiftQuestion _question;
  late List<String> _options;

  int score = 0;
  int questionNumber = 1;

  static const int maxQuestions = 10;

  final Map<String, Color> _colourMap =
      const {
    'Red': Colors.red,
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Yellow': Colors.orange,
    'Purple': Colors.purple,
    'Orange': Colors.deepOrange,
  };

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    _question = StroopShiftQuestions.all[
        _random.nextInt(
          StroopShiftQuestions.all.length,
        )];

    _options = List<String>.from(
      _question.options,
    )..shuffle(_random);

    if (mounted) {
      setState(() {});
    }
  }

  void _tap(String value) {
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
      builder: (_) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              24,
            ),
          ),
          title: const Text(
            'Round Complete',
            style: TextStyle(
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          content: Text(
            'You scored $score out of $maxQuestions.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );

                Navigator.pop(
                  context,
                );
              },
              child:
                  const Text(
                'Done',
              ),
            ),
            ElevatedButton(
              onPressed:
                  _restart,
              child:
                  const Text(
                'Play Again',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _header() {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          Material(
            color:
                Colors.white
                    .withOpacity(
              0.10,
            ),
            borderRadius:
                BorderRadius
                    .circular(
              13,
            ),
            child:
                InkWell(
              borderRadius:
                  BorderRadius
                      .circular(
                13,
              ),
              onTap: () =>
                  Navigator.pop(
                context,
              ),
              child:
                  const SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  Icons
                      .arrow_back_rounded,
                  color:
                      Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          const Expanded(
            child: Text(
              'Stroop Shift',
              style: TextStyle(
                color:
                    Colors.white,
                fontSize: 22,
                fontWeight:
                    FontWeight
                        .w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progress() {
    return Row(
      children:
          List.generate(
        maxQuestions,
        (index) {
          final bool active =
              index + 1 ==
                  questionNumber;

          final bool done =
              index + 1 <
                  questionNumber;

          return Expanded(
            child:
                AnimatedContainer(
              duration:
                  const Duration(
                milliseconds:
                    180,
              ),
              height: 7,
              margin:
                  const EdgeInsets
                      .symmetric(
                horizontal:
                    2,
              ),
              decoration:
                  BoxDecoration(
                color:
                    active ||
                            done
                        ? const Color(
                            0xFFFFD247,
                          )
                        : Colors
                            .white
                            .withOpacity(
                            0.18,
                          ),
                borderRadius:
                    BorderRadius
                        .circular(
                  999,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _questionCard(
    bool compact,
  ) {
    final Color ink =
        _colourMap[
                _question
                    .inkColour] ??
            Colors.black;

    return Stack(
      clipBehavior:
          Clip.none,
      alignment:
          Alignment.topCenter,
      children: [
        Container(
          width:
              double.infinity,
          height:
              double.infinity,
          margin:
              const EdgeInsets
                  .only(
            top: 25,
          ),
          padding:
              EdgeInsets.fromLTRB(
            18,
            compact
                ? 38
                : 42,
            18,
            14,
          ),
          decoration:
              BoxDecoration(
            color:
                Colors.white,
            borderRadius:
                BorderRadius
                    .circular(
              24,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black
                        .withOpacity(
                  0.18,
                ),
                blurRadius:
                    16,
                offset:
                    const Offset(
                  0,
                  8,
                ),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,
            children: [
              const Text(
                'Stroop Shift',
                textAlign:
                    TextAlign
                        .center,
                style:
                    TextStyle(
                  color:
                      Color(
                    0xFF55178A,
                  ),
                  fontSize:
                      20,
                  fontWeight:
                      FontWeight
                          .w900,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                'Tap the INK colour, not the word',
                textAlign:
                    TextAlign
                        .center,
                style:
                    TextStyle(
                  color:
                      const Color(
                    0xFF55178A,
                  ).withOpacity(
                    0.72,
                  ),
                  fontSize:
                      13,
                  fontWeight:
                      FontWeight
                          .w600,
                ),
              ),

              const Spacer(),

              FittedBox(
                fit:
                    BoxFit
                        .scaleDown,
                child:
                    Text(
                  _question.word,
                  textAlign:
                      TextAlign
                          .center,
                  maxLines:
                      1,
                  style:
                      TextStyle(
                    color:
                        ink,
                    fontSize:
                        compact
                            ? 46
                            : 54,
                    fontWeight:
                        FontWeight
                            .w900,
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),

        Container(
          width: 56,
          height: 56,
          decoration:
              BoxDecoration(
            shape:
                BoxShape.circle,
            color:
                const Color(
              0xFF7B22C9,
            ),
            border:
                Border.all(
              color:
                  Colors.white,
              width:
                  4,
            ),
          ),
          alignment:
              Alignment.center,
          child:
              const Text(
            '⭐',
            style:
                TextStyle(
              fontSize:
                  24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _answerButton(
    String text,
  ) {
    return SizedBox(
      height: 48,
      child:
          ElevatedButton(
        onPressed:
            () =>
                _tap(text),
        style:
            ElevatedButton
                .styleFrom(
          elevation:
              4,
          backgroundColor:
              const Color(
            0xFFFFD247,
          ),
          foregroundColor:
              const Color(
            0xFF35125A,
          ),
          padding:
              const EdgeInsets
                  .symmetric(
            horizontal:
                6,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius
                    .circular(
              14,
            ),
          ),
        ),
        child:
            FittedBox(
          fit:
              BoxFit
                  .scaleDown,
          child:
              Text(
            text,
            maxLines:
                1,
            style:
                const TextStyle(
              fontSize:
                  16,
              fontWeight:
                  FontWeight
                      .w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _answerGrid() {
    return GridView.builder(
      shrinkWrap:
          true,
      physics:
          const NeverScrollableScrollPhysics(),
      padding:
          EdgeInsets.zero,
      itemCount:
          _options.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            2,
        crossAxisSpacing:
            8,
        mainAxisSpacing:
            8,
        mainAxisExtent:
            48,
      ),
      itemBuilder:
          (_, index) {
        return _answerButton(
          _options[index],
        );
      },
    );
  }

  Widget _scoreCard() {
    return Container(
      height:
          44,
      padding:
          const EdgeInsets
              .symmetric(
        horizontal:
            14,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white
                .withOpacity(
          0.11,
        ),
        borderRadius:
            BorderRadius
                .circular(
          14,
        ),
        border:
            Border.all(
          color:
              Colors.white
                  .withOpacity(
            0.20,
          ),
        ),
      ),
      child: Row(
        children: [
          const Text(
            '🏆',
            style:
                TextStyle(
              fontSize:
                  18,
            ),
          ),

          const SizedBox(
            width:
                8,
          ),

          const Expanded(
            child:
                Text(
              'Score',
              style:
                  TextStyle(
                color:
                    Colors
                        .white,
                fontSize:
                    15,
                fontWeight:
                    FontWeight
                        .w900,
              ),
            ),
          ),

          Text(
            '$score',
            style:
                const TextStyle(
              color:
                  Colors.white,
              fontSize:
                  19,
              fontWeight:
                  FontWeight
                      .w900,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body:
          LayoutBuilder(
        builder:
            (
              context,
              constraints,
            ) {
          final bool compact =
              constraints
                      .maxHeight <
                  760;

          return Container(
            width:
                double.infinity,
            height:
                double.infinity,
            decoration:
                const BoxDecoration(
              gradient:
                  LinearGradient(
                colors: [
                  Color(
                    0xFF4B0B8F,
                  ),
                  Color(
                    0xFF6413A8,
                  ),
                  Color(
                    0xFF7C20C8,
                  ),
                ],
                begin:
                    Alignment
                        .topCenter,
                end:
                    Alignment
                        .bottomCenter,
              ),
            ),
            child:
                SafeArea(
              child:
                  Padding(
                padding:
                    const EdgeInsets
                        .fromLTRB(
                  12,
                  8,
                  12,
                  8,
                ),
                child:
                    Column(
                  children: [
                    _header(),

                    const SizedBox(
                      height:
                          8,
                    ),

                    _progress(),

                    const SizedBox(
                      height:
                          8,
                    ),

                    Expanded(
                      child:
                          _questionCard(
                        compact,
                      ),
                    ),

                    const SizedBox(
                      height:
                          8,
                    ),

                    _answerGrid(),

                    const SizedBox(
                      height:
                          8,
                    ),

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