import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class OwnerAnalyticsService {
  OwnerAnalyticsService._();

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static Timer? _heartbeatTimer;

  static String? _sessionId;
  static DateTime? _sessionStartedAt;

  static bool _initialised = false;

  // ------------------------------------------------------------
  // INITIALISE
  // ------------------------------------------------------------

  static Future<void> initialize() async {
    if (kIsWeb) return;

    if (_initialised) {
      return;
    }

    _initialised = true;

    try {
      await _ensureAnonymousUser();

      await _messaging.setAutoInitEnabled(true);

      await _messaging
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      _messaging.onTokenRefresh.listen(
        (String token) async {
          await _saveDeviceToken(token);
        },
      );

      await startSession();

      // Token registration may not be ready immediately
      // during a cold iOS launch, so try after startup too.
      Future.delayed(
        const Duration(seconds: 3),
        () {
          refreshDeviceToken();
        },
      );
    } catch (e) {
      debugPrint(
        'OwnerAnalyticsService initialise error: $e',
      );
    }
  }

  // ------------------------------------------------------------
  // ANONYMOUS USER
  // ------------------------------------------------------------

  static Future<User> _ensureAnonymousUser() async {
    final User? existingUser =
        _auth.currentUser;

    if (existingUser != null) {
      return existingUser;
    }

    final UserCredential credential =
        await _auth.signInAnonymously();

    final User? user =
        credential.user;

    if (user == null) {
      throw Exception(
        'Anonymous Firebase sign-in failed.',
      );
    }

    return user;
  }

  // ------------------------------------------------------------
  // PUSH TOKEN
  // ------------------------------------------------------------

  static Future<void> refreshDeviceToken() async {
    if (kIsWeb) return;

    try {
      final User user =
          await _ensureAnonymousUser();

      // On iOS Firebase cannot create the FCM token
      // until APNs has first supplied its token.
      String? apnsToken;

      for (int attempt = 0;
          attempt < 10;
          attempt++) {
        apnsToken =
            await _messaging.getAPNSToken();

        if (apnsToken != null &&
            apnsToken.isNotEmpty) {
          break;
        }

        await Future.delayed(
          const Duration(seconds: 1),
        );
      }

      if (apnsToken == null ||
          apnsToken.isEmpty) {
        debugPrint(
          'APNs token not available yet.',
        );

        return;
      }

      debugPrint(
        'APNs token received.',
      );

      final String? fcmToken =
          await _messaging.getToken();

      if (fcmToken == null ||
          fcmToken.isEmpty) {
        debugPrint(
          'FCM token not available yet.',
        );

        return;
      }

      await _saveDeviceToken(
        fcmToken,
        user: user,
      );
    } catch (e) {
      debugPrint(
        'FCM token refresh error: $e',
      );
    }
  }

  static Future<void> _saveDeviceToken(
    String token, {
    User? user,
  }) async {
    try {
      final User activeUser =
          user ??
              await _ensureAnonymousUser();

      await _firestore
          .collection(
            'device_tokens',
          )
          .doc(
            activeUser.uid,
          )
          .set(
        <String, dynamic>{
          'uid':
              activeUser.uid,
          'token':
              token,
          'platform':
              'ios',
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      debugPrint(
        'Device token saved for UID: ${activeUser.uid}',
      );
    } catch (e) {
      debugPrint(
        'Saving FCM token failed: $e',
      );
    }
  }

  // ------------------------------------------------------------
  // SESSION START
  // ------------------------------------------------------------

  static Future<void> startSession() async {
    if (kIsWeb) return;

    if (_sessionId != null) {
      return;
    }

    try {
      final User user =
          await _ensureAnonymousUser();

      final DateTime now =
          DateTime.now();

      final DocumentReference<
              Map<String, dynamic>>
          session =
          _firestore
              .collection(
                'owner_analytics_sessions',
              )
              .doc();

      _sessionId =
          session.id;

      _sessionStartedAt =
          now;

      await session.set(
        <String, dynamic>{
          'uid':
              user.uid,
          'startedAt':
              FieldValue.serverTimestamp(),
          'lastActiveAt':
              FieldValue.serverTimestamp(),
          'durationSeconds':
              0,
          'active':
              true,
        },
      );

      _startHeartbeat();

      debugPrint(
        'Owner analytics session started.',
      );
    } catch (e) {
      debugPrint(
        'Starting owner analytics session failed: $e',
      );
    }
  }

  // ------------------------------------------------------------
  // SESSION HEARTBEAT
  // ------------------------------------------------------------

  static void _startHeartbeat() {
    _heartbeatTimer?.cancel();

    _heartbeatTimer =
        Timer.periodic(
      const Duration(
        seconds: 30,
      ),
      (_) {
        _updateSession(
          active: true,
        );
      },
    );
  }

  static Future<void> _updateSession({
    required bool active,
  }) async {
    final String? sessionId =
        _sessionId;

    final DateTime? startedAt =
        _sessionStartedAt;

    if (sessionId == null ||
        startedAt == null) {
      return;
    }

    try {
      final int durationSeconds =
          DateTime.now()
              .difference(
                startedAt,
              )
              .inSeconds;

      final Map<String, dynamic> data =
          <String, dynamic>{
        'durationSeconds':
            durationSeconds,
        'lastActiveAt':
            FieldValue.serverTimestamp(),
        'active':
            active,
      };

      if (!active) {
        data['endedAt'] =
            FieldValue.serverTimestamp();
      }

      await _firestore
          .collection(
            'owner_analytics_sessions',
          )
          .doc(
            sessionId,
          )
          .update(
            data,
          );
    } catch (e) {
      debugPrint(
        'Updating owner analytics session failed: $e',
      );
    }
  }

  // ------------------------------------------------------------
  // APP BACKGROUND
  // ------------------------------------------------------------

  static Future<void> pauseSession() async {
    if (kIsWeb) return;

    if (_sessionId == null) {
      return;
    }

    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;

    await _updateSession(
      active: false,
    );

    _sessionId = null;
    _sessionStartedAt = null;
  }

  // ------------------------------------------------------------
  // APP FOREGROUND
  // ------------------------------------------------------------

  static Future<void> resumeSession() async {
    if (kIsWeb) return;

    await refreshDeviceToken();

    if (_sessionId != null) {
      return;
    }

    await startSession();
  }
}