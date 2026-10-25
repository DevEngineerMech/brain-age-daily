
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'stats_service.dart';

class PlayerProfile {
  final String uid;
  final String username;
  final DateTime? createdAt;

  const PlayerProfile({
    required this.uid,
    required this.username,
    this.createdAt,
  });

  factory PlayerProfile.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return PlayerProfile(
      uid: doc.id,
      username: data['username']?.toString() ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class WeeklyPlayerScore {
  final String uid;
  final String username;
  final int points;
  final int daysPlayed;

  const WeeklyPlayerScore({
    required this.uid,
    required this.username,
    required this.points,
    required this.daysPlayed,
  });

  factory WeeklyPlayerScore.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return WeeklyPlayerScore(
      uid: doc.id,
      username: data['username']?.toString() ?? 'Player',
      points: (data['points'] as num?)?.toInt() ?? 0,
      daysPlayed:
          (data['daysPlayed'] as num?)?.toInt() ?? 0,
    );
  }
}

class WeeklyLeaderboardData {
  final String weekId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<WeeklyPlayerScore> players;
  final WeeklyPlayerScore? currentPlayer;

  const WeeklyLeaderboardData({
    required this.weekId,
    required this.weekStart,
    required this.weekEnd,
    required this.players,
    required this.currentPlayer,
  });
}

class SocialLeaderboardService {
  SocialLeaderboardService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  static Future<User> ensureSignedIn() async {
    final existing = _auth.currentUser;

    if (existing != null) return existing;

    final credential = await _auth.signInAnonymously();
    final user = credential.user;

    if (user == null) {
      throw StateError('Could not create player session.');
    }

    return user;
  }

  static String? validateUsername(String value) {
    final clean = value.trim();

    if (clean.length < 3 || clean.length > 18) {
      return 'Username must contain 3–18 characters.';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(clean)) {
      return 'Use only letters, numbers and underscores.';
    }

    if (clean.startsWith('_') || clean.endsWith('_')) {
      return 'Username cannot start or end with _.';
    }

    return null;
  }

  static Future<PlayerProfile?> getMyProfile() async {
    final user = await ensureSignedIn();

    final snapshot =
        await _db.collection('players').doc(user.uid).get();

    if (!snapshot.exists) return null;

    return PlayerProfile.fromDocument(snapshot);
  }

  static Future<bool> usernameAvailable(
    String username,
  ) async {
    if (validateUsername(username) != null) {
      return false;
    }

    final normalized = username.trim().toLowerCase();

    final doc = await _db
        .collection('usernames')
        .doc(normalized)
        .get();

    return !doc.exists;
  }

  static Future<PlayerProfile> createUsername(
    String username,
  ) async {
    final clean = username.trim();
    final error = validateUsername(clean);

    if (error != null) {
      throw ArgumentError(error);
    }

    final user = await ensureSignedIn();
    final normalized = clean.toLowerCase();

    final profileRef =
        _db.collection('players').doc(user.uid);
    final nameRef =
        _db.collection('usernames').doc(normalized);

    await _db.runTransaction((transaction) async {
      // All reads happen before any writes.
      final profile = await transaction.get(profileRef);
      final reserved = await transaction.get(nameRef);

      if (profile.exists) {
        throw StateError(
          'This device already has a player profile.',
        );
      }

      if (reserved.exists) {
        throw StateError(
          'That username is already taken.',
        );
      }

      transaction.set(nameRef, {
        'uid': user.uid,
        'username': clean,
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.set(profileRef, {
        'uid': user.uid,
        'username': clean,
        'usernameLower': normalized,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    final profile = await getMyProfile();

    if (profile == null) {
      throw StateError(
        'Username was reserved, but the profile '
        'could not be loaded.',
      );
    }

    return profile;
  }

  static DateTime weekStartUtc([DateTime? now]) {
    final date = (now ?? DateTime.now()).toUtc();

    final midnight = DateTime.utc(
      date.year,
      date.month,
      date.day,
    );

    return midnight.subtract(
      Duration(days: date.weekday - DateTime.monday),
    );
  }

  static String _two(int number) {
    return number.toString().padLeft(2, '0');
  }

  // ISO week-year is the year containing Thursday.
  static String weekId([DateTime? now]) {
    final monday = weekStartUtc(now);
    final thursday = monday.add(
      const Duration(days: 3),
    );

    final isoYear = thursday.year;
    final jan4 = DateTime.utc(isoYear, 1, 4);

    final firstMonday = jan4.subtract(
      Duration(days: jan4.weekday - DateTime.monday),
    );

    final weekNumber =
        monday.difference(firstMonday).inDays ~/ 7 + 1;

    return '$isoYear-W${_two(weekNumber)}';
  }

  static DateTime _utcDay(DateTime value) {
    final utc = value.toUtc();
    return DateTime.utc(utc.year, utc.month, utc.day);
  }

  static Future<Map<String, int>> _myDailyPoints() async {
    final start = weekStartUtc();
    final end = start.add(const Duration(days: 7));

    final sessions = await StatsService.getDailySessions();
    final dailyScores = <String, int>{};

    for (final session in sessions) {
      final completed = session.completedAt.toUtc();

      if (completed.isBefore(start) ||
          !completed.isBefore(end)) {
        continue;
      }

      if (session.totalAttempts <= 0) continue;

      final day = _utcDay(completed);
      final dayKey =
          '${day.year}-${_two(day.month)}-${_two(day.day)}';

      final accuracy =
          session.averageAccuracy.clamp(0.0, 1.0);

      final points =
          (accuracy * 1000).round().clamp(0, 1000);

      dailyScores[dayKey] = math.max(
        dailyScores[dayKey] ?? 0,
        points,
      );
    }

    return dailyScores;
  }

  static Future<void> publishMyWeeklyScore() async {
    final profile = await getMyProfile();

    if (profile == null) {
      throw StateError(
        'Create a username before joining the leaderboard.',
      );
    }

    final dailyScores = await _myDailyPoints();

    final points = dailyScores.values.fold<int>(
      0,
      (sum, value) => sum + value,
    ).clamp(0, 7000);

    final reference = _db
        .collection('weeklyScores')
        .doc(weekId())
        .collection('players')
        .doc(profile.uid);

    // Updating this document also refreshes an existing
    // score instead of creating duplicate entries.
    await reference.set({
      'uid': profile.uid,
      'username': profile.username,
      'points': points,
      'daysPlayed': dailyScores.length,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<WeeklyLeaderboardData> getLeaderboard({
    int limit = 50,
  }) async {
    final user = await ensureSignedIn();

    // Publish this device's latest daily results.
    await publishMyWeeklyScore();

    final start = weekStartUtc();
    final id = weekId();

    final collection = _db
        .collection('weeklyScores')
        .doc(id)
        .collection('players');

    final query = await collection
        .orderBy('points', descending: true)
        .limit(limit)
        .get();

    final players = query.docs
        .map(WeeklyPlayerScore.fromDocument)
        .toList();

    WeeklyPlayerScore? mine;

    for (final player in players) {
      if (player.uid == user.uid) {
        mine = player;
        break;
      }
    }

    // Still show the user's own score if outside
    // the top 50.
    if (mine == null) {
      final myDocument =
          await collection.doc(user.uid).get();

      if (myDocument.exists) {
        mine = WeeklyPlayerScore.fromDocument(myDocument);
      }
    }

    return WeeklyLeaderboardData(
      weekId: id,
      weekStart: start,
      weekEnd: start.add(const Duration(days: 7)),
      players: players,
      currentPlayer: mine,
    );
  }

  static Future<int> getMyRank() async {
    final profile = await getMyProfile();
    if (profile == null) return 0;

    final reference = _db
        .collection('weeklyScores')
        .doc(weekId())
        .collection('players');

    final mine = await reference.doc(profile.uid).get();

    if (!mine.exists) return 0;

    final points =
        (mine.data()?['points'] as num?)?.toInt() ?? 0;

    // For scores outside the top 50, count players
    // with strictly higher scores. Ties share a rank.
    final higher = await reference
        .where('points', isGreaterThan: points)
        .count()
        .get();

    return (higher.count ?? 0) + 1;
  }

  static void logError(String action, Object error) {
    debugPrint('[SocialLeaderboard] $action: $error');
  }
}
