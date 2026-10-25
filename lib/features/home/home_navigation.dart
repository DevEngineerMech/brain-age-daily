
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../daily/daily_page.dart';
import '../daily/daily_results_page.dart';
import '../free_play/free_play_page.dart';
import '../stats/stats_page.dart';
import '../achievements/achievements_page.dart';
import '../missions/daily_missions_page.dart';

class HomeNavigation {
  const HomeNavigation._();

  static Future<void> _push(
    BuildContext context,
    Widget page,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  static Future<void> openDailyCheck(
    BuildContext context,
  ) async {
    await _push(context, const DailyPage());
  }

  static Future<void> openDailyResults(
    BuildContext context,
  ) async {
    await _push(context, const DailyResultsPage());
  }

  static Future<void> openFreePlay(
    BuildContext context,
  ) async {
    await _push(context, const FreePlayPage());
  }

  static Future<void> openProgress(
    BuildContext context,
  ) async {
    await _push(context, const StatsPage());
  }

  static Future<void> openAchievements(
    BuildContext context,
  ) async {
    await _push(context, const AchievementsPage());
  }

  static Future<void> openDailyMissions(
    BuildContext context,
  ) async {
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration:
            const Duration(milliseconds: 650),
        reverseTransitionDuration:
            const Duration(milliseconds: 320),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const DailyMissionsPage();
        },
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          final progress = Curves.easeOutCubic.transform(
            animation.value.clamp(0.0, 1.0),
          );

          return ClipPath(
            clipper: _MissionCircleRevealClipper(
              progress: progress,
            ),
            child: child,
          );
        },
      ),
    );
  }
}

class _MissionCircleRevealClipper extends CustomClipper<Path> {
  final double progress;

  const _MissionCircleRevealClipper({
    required this.progress,
  });

  @override
  Path getClip(Size size) {
    // Begins near the Daily Missions icon in the home screen.
    final origin = Offset(
      size.width * 0.12,
      size.height * 0.63,
    );

    final maxRadius = math.sqrt(
      math.pow(math.max(origin.dx, size.width - origin.dx), 2) +
          math.pow(math.max(origin.dy, size.height - origin.dy), 2),
    );

    return Path()
      ..addOval(
        Rect.fromCircle(
          center: origin,
          radius: maxRadius * progress,
        ),
      );
  }

  @override
  bool shouldReclip(
    covariant _MissionCircleRevealClipper oldClipper,
  ) {
    return oldClipper.progress != progress;
  }
}
