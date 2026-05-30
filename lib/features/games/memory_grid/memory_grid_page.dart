import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'memory_grid_questions.dart';

class MemoryGridPage extends StatefulWidget {
  const MemoryGridPage({super.key});

  @override
  State<MemoryGridPage> createState() => _MemoryGridPageState();
}

class _MemoryGridPageState extends State<MemoryGridPage> {
  final Random _random = Random();

  late MemoryGridQuestion _question;

  int score = 0;
  bool showPattern = true;

  final Set<int> selected = <int>{};
  Timer? hideTimer;

  @override
  void initState() {
    super.initState();
    _next();
  }

  @override
  void dispose() {
    hideTimer?.cancel();
    super.dispose();
  }

  void _next() {
    hideTimer?.cancel();

    _question = MemoryGridQuestions.all[_random.nextInt(MemoryGridQuestions.all.length)];

    selected.clear();
    showPattern = true;

    setState(() {});

    hideTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        showPattern = false;
      });
    });
  }

  void _tap(int index) {
    if (showPattern) return;
    if (selected.contains(index)) return;

    selected.add(index);

    final bool correctTile = _question.pattern.contains(index);

    if (!correctTile) {
      setState(() {});
      Future.delayed(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        _next();
      });
      return;
    }

    if (selected.length == _question.pattern.length) {
      score++;
      setState(() {});
      Future.delayed(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        _next();
      });
      return;
    }

    setState(() {});
  }

  Color _tileColor(int index) {
    final bool lit = showPattern && _question.pattern.contains(index);
    final bool picked = selected.contains(index);
    final bool correctTile = _question.pattern.contains(index);

    if (lit) return Colors.blue;
    if (picked && correctTile) return Colors.green;
    if (picked && !correctTile) return Colors.red;

    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Grid'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Text('Score: $score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                showPattern
                    ? 'Remember the highlighted squares'
                    : 'Tap the squares that were highlighted',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double size = min(constraints.maxWidth, constraints.maxHeight);

                    return Center(
                      child: SizedBox(
                        width: size,
                        height: size,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 16,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                          itemBuilder: (_, index) {
                            return GestureDetector(
                              onTap: () => _tap(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                decoration: BoxDecoration(
                                  color: _tileColor(index),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.black.withOpacity(0.08)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}