
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class PlayerAccountService {
  PlayerAccountService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  static bool _deleting = false;

  static Future<void> _deleteOwnedAnalytics(
    String uid,
  ) async {
    while (true) {
      final page = await _db
          .collection('owner_analytics_sessions')
          .where('uid', isEqualTo: uid)
          .limit(100)
          .get();

      if (page.docs.isEmpty) return;

      final batch = _db.batch();

      for (final doc in page.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    }
  }

  static DateTime _weekStart(DateTime date) {
    final utc = date.toUtc();

    final midnight = DateTime.utc(
      utc.year,
      utc.month,
      utc.day,
    );

    return midnight.subtract(
      Duration(days: utc.weekday - DateTime.monday),
    );
  }

  static String _weekId(DateTime monday) {
    final thursday = monday.add(
      const Duration(days: 3),
    );

    final isoYear = thursday.year;
    final jan4 = DateTime.utc(isoYear, 1, 4);

    final firstMonday = _weekStart(jan4);

    final weekNumber =
        monday.difference(firstMonday).inDays ~/ 7 + 1;

    return '$isoYear-W${weekNumber.toString().padLeft(2, '0')}';
  }

  static Future<void> _deleteWeeklyScores(
    String uid,
    DateTime earliest,
  ) async {
    // Existing leaderboard writes a document for the
    // player under each year/week.
    //
    // Delete all weeks since profile creation, rather
    // than deleting only the current leaderboard.
    var week = _weekStart(earliest);
    final currentWeek = _weekStart(DateTime.now());

    while (!week.isAfter(currentWeek)) {
      final reference = _db
          .collection('weeklyScores')
          .doc(_weekId(week))
          .collection('players')
          .doc(uid);

      final snapshot = await reference.get();

      if (snapshot.exists) {
        await reference.delete();
      }

      week = week.add(const Duration(days: 7));
    }
  }

  /// Deletes this player's social account and associated
  /// server-side data. Keeps local SharedPreferences intact.
  ///
  /// Requires the deletion Firestore rules supplied below.
  static Future<void> deletePlayerAccount() async {
    if (_deleting) {
      throw StateError(
        'Account deletion is already running.',
      );
    }

    _deleting = true;

    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw StateError(
          'No Firebase account is currently signed in.',
        );
      }

      final uid = user.uid;
      final playerRef = _db.collection('players').doc(uid);

      final player = await playerRef.get();
      final data = player.data();

      final usernameLower =
          data?['usernameLower']?.toString() ?? '';

      final createdAt =
          (data?['createdAt'] as Timestamp?)?.toDate() ??
          user.metadata.creationTime ??
          DateTime.now();

      // Remove historical leaderboard scores first.
      await _deleteWeeklyScores(
        uid,
        createdAt,
      );

      // Remove analytics sessions belonging to this UID.
      await _deleteOwnedAnalytics(uid);

      // Remove the device push-token record, if it exists.
      // Deleting a missing document is harmless with
      // the new owner-delete rule.
      final tokenRef =
          _db.collection('device_tokens').doc(uid);

      final token = await tokenRef.get();

      if (token.exists) {
        await tokenRef.delete();
      }

      // Remove player profile and username reservation
      // together, so the username can be reused.
      if (player.exists) {
        final batch = _db.batch();

        if (usernameLower.isNotEmpty) {
          batch.delete(
            _db.collection('usernames').doc(usernameLower),
          );
        }

        batch.delete(playerRef);

        await batch.commit();
      }

      // Last operation: delete the authenticated account.
      // If Auth requires a recent login, the deletion
      // operation must report the error to the user.
      await user.delete();

      debugPrint(
        '[PlayerAccount] Online account deleted.',
      );
    } on FirebaseAuthException catch (error) {
      if (error.code == 'requires-recent-login') {
        throw StateError(
          'Firebase requires a recent sign-in before '
          'deleting this account. Your online data '
          'deletion may be partially complete. '
          'Please try again after signing in again.',
        );
      }

      rethrow;
    } finally {
      _deleting = false;
    }
  }
}
