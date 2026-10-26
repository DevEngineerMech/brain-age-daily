
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/analytics_service.dart';
import '../../core/services/achievements_service.dart';
import '../../core/services/daily_hearts_service.dart';
import '../../core/services/daily_notification_service.dart';
import '../../core/services/stats_service.dart';
import '../../core/services/player_xp_service.dart';

import '../../core/widgets/app_banner_ad.dart';
import '../../core/widgets/app_rewarded_ad.dart';

import 'home_animations.dart';
import 'home_navigation.dart';
import 'home_style.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver {

  // ==================================================
  // SAVED PREFERENCES
  // ==================================================

  static const String _ageKey = 'user_age';

  static const String _notificationKey =
      'daily_notifications_enabled';

  final TextEditingController _ageController =
      TextEditingController();

  // ==================================================
  // PLAYER DATA
  // ==================================================

  int _brainAge = 40;
  int _userAge = 25;
  int _totalChecks = 0;
  int _currentStreak = 0;
  int _hearts = DailyHeartsService.maxHearts;

  bool _notificationsEnabled = false;
  bool _notificationBusy = false;
  bool _startingDaily = false;
  bool _watchingAd = false;

  AchievementUpdate? _achievementsData;

  // NEW: XP progression data.
  PlayerXpSnapshot? _playerXp;

  // ==================================================
  // LIFECYCLE
  // ==================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _loadHome();
    AnalyticsService.screen('home');

    if (!kIsWeb) {
      AppRewardedAd.load();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      _loadHome();
    }
  }

  // ==================================================
  // LOAD SAVED PLAYER DATA
  // ==================================================

  Future<void> _loadHome() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      final age =
          prefs.getInt(_ageKey) ?? 25;

      final notificationsEnabled =
          prefs.getBool(_notificationKey) ?? false;

      final hearts =
          await DailyHeartsService.getHearts();

      final brainAge =
          await StatsService.getLatestBrainAge();

      final totalChecks =
          await StatsService.getTotalChecks();

      final streak =
          await StatsService.getCurrentStreak();

      AchievementUpdate? achievements;

      try {
        achievements =
            await AchievementsService.refresh();
      } catch (error) {
        debugPrint(
          'Achievements loading error: $error',
        );
      }

      // NEW: Read the player's existing XP.
      // This does not award XP or backfill old games.
      PlayerXpSnapshot? xp;

      try {
        xp = await PlayerXpService.getSnapshot();
      } catch (error) {
        debugPrint(
          'Player XP loading error: $error',
        );
      }

      if (!mounted) return;

      setState(() {
        _userAge = age;
        _ageController.text = '$age';

        _notificationsEnabled =
            notificationsEnabled;

        _hearts = hearts;
        _brainAge = brainAge;
        _totalChecks = totalChecks;
        _currentStreak = streak;

        if (achievements != null) {
          _achievementsData = achievements;
        }

        if (xp != null) {
          _playerXp = xp;
        }
      });

      // Display new achievements only when
      // refresh() reports a first-time unlock.
      if (achievements != null &&
          achievements.newlyUnlocked.isNotEmpty) {
        final newBadges =
            achievements.newlyUnlocked;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          HomeAchievementCelebration.show(
            context,
            newBadges,
          );
        });
      }

      if (notificationsEnabled) {
        await DailyNotificationService
            .scheduleDailyReminder();
      }
    } catch (error) {
      debugPrint(
        'Home loading error: $error',
      );
    }
  }

  // ==================================================
  // USER MESSAGES
  // ==================================================

  void _message(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          backgroundColor:
              const Color(0xFF30205F),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(13),
          ),
        ),
      );
  }

  void _comingSoon(String feature) {
    _message('$feature is coming soon.');
  }

  // ==================================================
  // NAVIGATION
  // ==================================================

  Future<void> _openDailyResults() async {
    await HomeNavigation.openDailyResults(context);

    if (mounted) {
      await _loadHome();
    }
  }

  Future<void> _openFreePlay() async {
    await HomeNavigation.openFreePlay(context);

    if (mounted) {
      await _loadHome();
    }
  }

  Future<void> _openProgress() async {
    await HomeNavigation.openProgress(context);

    if (mounted) {
      await _loadHome();
    }
  }

  Future<void> _openAchievements() async {
    await HomeNavigation.openAchievements(context);

    if (mounted) {
      await _loadHome();
    }
  }

  Future<void> _openDailyMissions() async {
    await HomeNavigation.openDailyMissions(context);

    if (mounted) {
      await _loadHome();
    }
  }

  // ==================================================
  // DAILY BRAIN CHECK AND HEARTS
  // ==================================================

  Future<void> _startDailyBrainCheck() async {
    if (_startingDaily) return;

    _startingDaily = true;

    try {
      // A heart is consumed before navigation.
      final canPlay =
          await DailyHeartsService.consumeHeart();

      if (!mounted) return;

      if (!canPlay) {
        final hearts =
            await DailyHeartsService.getHearts();

        if (!mounted) return;

        setState(() {
          _hearts = hearts;
        });

        _message(
          'No hearts left. Watch an ad for another heart.',
        );
        return;
      }

      final hearts =
          await DailyHeartsService.getHearts();

      if (!mounted) return;

      setState(() {
        _hearts = hearts;
      });

      await HomeNavigation.openDailyCheck(context);

      if (mounted) {
        await _loadHome();
      }
    } catch (error) {
      debugPrint(
        'Daily Brain Check error: $error',
      );

      if (mounted) {
        _message(
          'Unable to open Daily Brain Check.',
        );
      }
    } finally {
      _startingDaily = false;
    }
  }

  // ==================================================
  // REWARDED AD FOR A HEART
  // ==================================================

  Future<void> _watchAdForHeart() async {
    if (_watchingAd) return;

    if (_hearts >= DailyHeartsService.maxHearts) {
      return;
    }

    _watchingAd = true;

    try {
      final rewarded =
          await AppRewardedAd.show(
        placement: 'home_heart',
      );

      if (!mounted) return;

      if (!rewarded) {
        AppRewardedAd.load();

        _message(
          'Ad not ready yet. Try again soon.',
        );
        return;
      }

      final hearts =
          await DailyHeartsService.addHeart();

      if (!mounted) return;

      setState(() {
        _hearts = hearts;
      });

      _message('❤️ +1 Heart');
    } catch (error) {
      debugPrint(
        'Rewarded ad error: $error',
      );

      if (mounted) {
        _message(
          'Unable to load the advert.',
        );
      }
    } finally {
      _watchingAd = false;
    }
  }

  // ==================================================
  // NOTIFICATION SETTINGS
  // ==================================================

  Future<void> _toggleNotifications(
    bool enabled,
  ) async {
    if (_notificationBusy) return;

    setState(() {
      _notificationBusy = true;
    });

    try {
      final prefs =
          await SharedPreferences.getInstance();

      if (!enabled) {
        await DailyNotificationService
            .cancelDailyReminder();

        await prefs.setBool(
          _notificationKey,
          false,
        );

        if (!mounted) return;

        setState(() {
          _notificationsEnabled = false;
        });

        _message(
          'Daily reminders turned off.',
        );
        return;
      }

      final granted =
          await DailyNotificationService
              .requestPermission();

      if (!mounted) return;

      if (!granted) {
        await DailyNotificationService
            .cancelDailyReminder();

        await prefs.setBool(
          _notificationKey,
          false,
        );

        if (!mounted) return;

        setState(() {
          _notificationsEnabled = false;
        });

        _message(
          'Enable notifications in iPhone settings.',
        );
        return;
      }

      await prefs.setBool(
        _notificationKey,
        true,
      );

      await DailyNotificationService
          .scheduleDailyReminder();

      if (!mounted) return;

      setState(() {
        _notificationsEnabled = true;
      });

      _message(
        'Daily reminders enabled.',
      );
    } catch (error) {
      debugPrint(
        'Notification settings error: $error',
      );

      if (mounted) {
        _message(
          'Could not update notifications.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _notificationBusy = false;
        });
      }
    }
  }

  // ==================================================
  // EDIT PLAYER AGE
  // ==================================================

  Future<void> _editAge() async {
    _ageController.text = '$_userAge';

    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Your Age',
          ),
          content: TextField(
            controller: _ageController,
            autofocus: true,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Enter your age',
            ),
            onSubmitted: (_) {
              Navigator.pop(
                dialogContext,
                int.tryParse(
                  _ageController.text.trim(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  int.tryParse(
                    _ageController.text.trim(),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null ||
        result < 1 ||
        result > 120) {
      return;
    }

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setInt(
      _ageKey,
      result,
    );

    if (!mounted) return;

    setState(() {
      _userAge = result;
    });
  }

  // ==================================================
  // MAIN PAGE
  // ==================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0929),
      body: Column(
        children: [
          Expanded(
            child: HomeDailyLaunchTransition(
              brainAge: _brainAge,
              hearts: _hearts,

              // The existing animation calls this
              // once at the end of the transition.
              onLaunch: _startDailyBrainCheck,

              builder: (startDailyAnimation) {
                return HomeStyle(
                  brainAge: _brainAge,
                  userAge: _userAge,
                  totalChecks: _totalChecks,
                  currentStreak: _currentStreak,
                  hearts: _hearts,
                  
onShopReturn: _loadHome,


                  // NEW: Pass XP to the existing
                  // Home screen layout.
                  playerXp: _playerXp,

                  notificationsEnabled:
                      _notificationsEnabled,

                  notificationBusy:
                      _notificationBusy,

                  achievements:
                      _achievementsData,

                  onEditAge:
                      _editAge,

                  onNotificationsChanged:
                      _toggleNotifications,

                  // Preserve the cinematic launch.
                  onStartDaily:
                      startDailyAnimation,

                  onWatchAdForHeart:
                      _watchAdForHeart,

                  onDailyResults:
                      _openDailyResults,

                  onFreePlay:
                      _openFreePlay,

                  onProgress:
                      _openProgress,

                  onAchievements:
                      _openAchievements,

                  onDailyMissions:
                      _openDailyMissions,

                  onComingSoon:
                      _comingSoon,
                );
              },
            ),
          ),

          // Existing AdMob banner remains unchanged.
          const AppBannerAd(),
        ],
      ),
    );
  }
}
