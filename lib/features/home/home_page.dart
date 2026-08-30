import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/daily_hearts_service.dart';
import '../../core/services/daily_notification_service.dart';
import '../../core/services/stats_service.dart';
import '../../core/widgets/app_banner_ad.dart';
import '../../core/widgets/app_rewarded_ad.dart';

import '../daily/daily_page.dart';
import '../daily/daily_results_page.dart';
import '../free_play/free_play_page.dart';
import '../stats/stats_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver {
  static const String _ageKey =
      'user_age';

  static const String _notificationEnabledKey =
      'daily_notifications_enabled';

  final TextEditingController _ageController =
      TextEditingController();

  int _brainAge = 40;
  int _userAge = 25;
  int _totalChecks = 0;
  int _currentStreak = 0;
  int _hearts = DailyHeartsService.maxHearts;

  bool _notificationsEnabled = false;
  bool _notificationToggleBusy = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(
      this,
    );

    _loadHome();

    if (!kIsWeb) {
      AppRewardedAd.load();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(
      this,
    );

    _ageController.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    /*
     * When the Apple permission popup closes,
     * or when the user returns from iOS Settings,
     * refresh the saved notification state.
     *
     * This makes the toggle update automatically.
     */
    if (state == AppLifecycleState.resumed) {
      _refreshNotificationToggle();
    }
  }

  Future<void> _refreshNotificationToggle() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    final bool enabled =
        prefs.getBool(
          _notificationEnabledKey,
        ) ??
        false;

    if (!mounted) return;

    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  Future<void> _loadHome() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    final int savedAge =
        prefs.getInt(_ageKey) ??
        25;

    final int hearts =
        await DailyHeartsService.getHearts();

    final int latestBrainAge =
        await StatsService.getLatestBrainAge();

    final int totalChecks =
        await StatsService.getTotalChecks();

    final int currentStreak =
        await StatsService.getCurrentStreak();

    final bool notificationsEnabled =
        prefs.getBool(
          _notificationEnabledKey,
        ) ??
        false;

    if (!mounted) return;

    setState(() {
      _ageController.text =
          '$savedAge';

      _userAge = savedAge;

      _brainAge =
          latestBrainAge;

      _totalChecks =
          totalChecks;

      _currentStreak =
          currentStreak;

      _hearts =
          hearts;

      _notificationsEnabled =
          notificationsEnabled;
    });

    if (notificationsEnabled) {
      await DailyNotificationService
          .scheduleDailyReminder();
    }
  }

  Future<void> _toggleNotifications(
    bool enabled,
  ) async {
    if (_notificationToggleBusy) {
      return;
    }

    setState(() {
      _notificationToggleBusy = true;
    });

    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    /*
     * USER TURNED NOTIFICATIONS OFF
     */
    if (!enabled) {
      await DailyNotificationService
          .cancelDailyReminder();

      await prefs.setBool(
        _notificationEnabledKey,
        false,
      );

      if (!mounted) return;

      setState(() {
        _notificationsEnabled = false;
        _notificationToggleBusy = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Daily reminders turned off.',
            ),
            duration: Duration(
              milliseconds: 1200,
            ),
          ),
        );

      return;
    }

    /*
     * USER TURNED NOTIFICATIONS ON
     *
     * Ask Apple for permission.
     */
    final bool granted =
        await DailyNotificationService
            .requestPermission();

    if (!mounted) return;

    /*
     * Apple permission denied.
     */
    if (!granted) {
      await prefs.setBool(
        _notificationEnabledKey,
        false,
      );

      await DailyNotificationService
          .cancelDailyReminder();

      if (!mounted) return;

      setState(() {
        _notificationsEnabled = false;
        _notificationToggleBusy = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Notifications are disabled in iPhone settings.',
            ),
            duration: Duration(
              milliseconds: 1800,
            ),
          ),
        );

      return;
    }

    /*
     * Apple permission accepted.
     *
     * Immediately save the app toggle as ON
     * and schedule BOTH reminders.
     */
    await prefs.setBool(
      _notificationEnabledKey,
      true,
    );

    await DailyNotificationService
        .scheduleDailyReminder();

    if (!mounted) return;

    setState(() {
      _notificationsEnabled = true;
      _notificationToggleBusy = false;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            '🔔 Daily reminders on for 10 AM and 6 PM.',
          ),
          duration: Duration(
            milliseconds: 1600,
          ),
        ),
      );
  }

  Future<void> _saveAge() async {
    final int? age =
        int.tryParse(
      _ageController.text.trim(),
    );

    if (age == null) {
      return;
    }

    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setInt(
      _ageKey,
      age,
    );

    if (!mounted) return;

    setState(() {
      _userAge = age;
    });
  }

  Future<void> _startDailyBrainCheck() async {
    final bool canPlay =
        await DailyHeartsService
            .consumeHeart();

    if (!mounted) return;

    if (!canPlay) {
      setState(() {
        _hearts = 0;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'No hearts left. Watch an ad to get another heart.',
          ),
          duration: Duration(
            milliseconds: 1400,
          ),
        ),
      );

      return;
    }

    final int hearts =
        await DailyHeartsService
            .getHearts();

    if (!mounted) return;

    setState(() {
      _hearts = hearts;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const DailyPage(),
      ),
    );

    if (!mounted) return;

    await _loadHome();
  }

  Future<void> _watchAdForHeart() async {
    if (_hearts >=
        DailyHeartsService.maxHearts) {
      return;
    }

    final bool earnedReward =
        await AppRewardedAd.show();

    if (!mounted) return;

    if (!earnedReward) {
      AppRewardedAd.load();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Ad not ready yet. Try again soon.',
          ),
          duration: Duration(
            milliseconds: 1200,
          ),
        ),
      );

      return;
    }

    final int hearts =
        await DailyHeartsService
            .addHeart();

    if (!mounted) return;

    setState(() {
      _hearts = hearts;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          '❤️ +1 Heart',
        ),
        duration: Duration(
          milliseconds: 900,
        ),
      ),
    );
  }

  String _comparisonText() {
    if (_totalChecks == 0) {
      return 'Complete your first Daily Brain Check';
    }

    final int difference =
        _userAge - _brainAge;

    if (difference >= 3) {
      return 'You perform like someone $difference years younger.';
    }

    if (difference <= -3) {
      return 'Your result is ${difference.abs()} years above your age today.';
    }

    return 'Your result is close to your age range.';
  }

  Widget _heartIcons() {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: List.generate(
        DailyHeartsService.maxHearts,
        (index) {
          final bool filled =
              index < _hearts;

          return Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            child: Text(
              filled
                  ? '❤️'
                  : '🩶',
              style:
                  const TextStyle(
                fontSize: 25,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _watchAdButton() {
    if (_hearts >=
        DailyHeartsService.maxHearts) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        onPressed:
            _watchAdForHeart,
        icon: const Icon(
          Icons.play_circle_fill_rounded,
          size: 17,
        ),
        label: const Text(
          'Watch Ad',
        ),
        style:
            ElevatedButton.styleFrom(
          elevation: 3,
          backgroundColor:
              const Color(
            0xFFFFD247,
          ),
          foregroundColor:
              const Color(
            0xFF35125A,
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              999,
            ),
          ),
        ),
      ),
    );
  }

  Widget _notificationToggle() {
    return Container(
      height: 42,
      padding:
          const EdgeInsets.only(
        left: 8,
        right: 3,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.14,
        ),
        borderRadius:
            BorderRadius.circular(
          999,
        ),
        border: Border.all(
          color:
              Colors.white.withOpacity(
            0.18,
          ),
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            _notificationsEnabled
                ? Icons
                    .notifications_active_rounded
                : Icons
                    .notifications_none_rounded,
            color:
                Colors.white,
            size: 20,
          ),

          Transform.scale(
            scale: 0.78,
            child: Switch(
              value:
                  _notificationsEnabled,
              onChanged:
                  _notificationToggleBusy
                      ? null
                      : _toggleNotifications,
              activeColor:
                  const Color(
                0xFFFFD247,
              ),
              activeTrackColor:
                  Colors.white,
              inactiveThumbColor:
                  Colors.white,
              inactiveTrackColor:
                  Colors.white
                      .withOpacity(
                0.28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _brainAgeCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        22,
        18,
        22,
        18,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          30,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'YOUR BRAIN AGE',
            style: TextStyle(
              color:
                  Colors.grey,
              fontSize: 14,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            '$_brainAge',
            style:
                const TextStyle(
              color:
                  Color(
                0xFF202024,
              ),
              fontSize: 58,
              fontWeight:
                  FontWeight.w900,
              height: 0.95,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            _comparisonText(),
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 7,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFF4F2FF,
              ),
              borderRadius:
                  BorderRadius.circular(
                999,
              ),
            ),
            child: Text(
              '🔥 $_currentStreak day streak',
              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF625BEA,
                ),
                fontSize: 14,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              _heartIcons(),

              const SizedBox(
                width: 10,
              ),

              _watchAdButton(),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          SizedBox(
            width:
                double.infinity,
            height: 54,
            child:
                ElevatedButton(
              onPressed:
                  _startDailyBrainCheck,
              style:
                  ElevatedButton
                      .styleFrom(
                elevation: 4,
                backgroundColor:
                    const Color(
                  0xFF625BEA,
                ),
                foregroundColor:
                    Colors.white,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    17,
                  ),
                ),
              ),
              child:
                  const Text(
                'Start Daily Brain Check',
                style:
                    TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          SizedBox(
            width:
                double.infinity,
            height: 48,
            child:
                OutlinedButton.icon(
              onPressed:
                  () async {
                await Navigator
                    .push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const DailyResultsPage(),
                  ),
                );

                if (!mounted) {
                  return;
                }

                await _loadHome();
              },
              icon: const Icon(
                Icons.analytics_rounded,
                size: 20,
              ),
              label:
                  const Text(
                'View Daily Results',
              ),
              style:
                  OutlinedButton
                      .styleFrom(
                foregroundColor:
                    const Color(
                  0xFF625BEA,
                ),
                side:
                    const BorderSide(
                  color:
                      Color(
                    0xFF625BEA,
                  ),
                  width: 2,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    17,
                  ),
                ),
                textStyle:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ageCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        18,
        14,
        18,
        12,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          24,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Age',
            style: TextStyle(
              color:
                  Color(
                0xFF202024,
              ),
              fontSize: 19,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 7,
          ),

          SizedBox(
            height: 48,
            child: TextField(
              controller:
                  _ageController,
              keyboardType:
                  TextInputType.number,
              textInputAction:
                  TextInputAction.done,
              onSubmitted: (_) {
                FocusScope.of(
                  context,
                ).unfocus();

                _saveAge();
              },
              onTapOutside: (_) {
                FocusScope.of(
                  context,
                ).unfocus();

                _saveAge();
              },
              decoration:
                  InputDecoration(
                contentPadding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                suffixIcon:
                    IconButton(
                  onPressed: () =>
                      _ageController
                          .clear(),
                  icon:
                      const Icon(
                    Icons.close_rounded,
                  ),
                ),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    16,
                  ),
                ),
                focusedBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    16,
                  ),
                  borderSide:
                      const BorderSide(
                    color:
                        Color(
                      0xFF625BEA,
                    ),
                    width: 2,
                  ),
                ),
              ),
              style:
                  const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          const Padding(
            padding:
                EdgeInsets.only(
              left: 10,
            ),
            child: Text(
              'Tap away or press done to save',
              style:
                  TextStyle(
                color:
                    Colors.grey,
                fontSize: 12,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          24,
        ),
        child: InkWell(
          borderRadius:
              BorderRadius.circular(
            24,
          ),
          onTap: onTap,
          child: Container(
            height: 112,
            padding:
                const EdgeInsets.all(
              12,
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 28,
                  color:
                      const Color(
                    0xFF202024,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  title,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF202024,
                    ),
                    fontSize: 19,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  subtitle,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color:
                        Colors.grey,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(
          context,
        ).unfocus();

        _saveAge();
      },
      child: Scaffold(
        body: Container(
          width:
              double.infinity,
          height:
              double.infinity,
          decoration:
              const BoxDecoration(
            color:
                Color(
              0xFF625BEA,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child:
                      SingleChildScrollView(
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      12,
                      8,
                      12,
                      10,
                    ),
                    child:
                        Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child:
                                  Text(
                                'Brain Age Daily',
                                style:
                                    TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize:
                                      29,
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            _notificationToggle(),
                          ],
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        _brainAgeCard(),

                        const SizedBox(
                          height: 10,
                        ),

                        _ageCard(),

                        const SizedBox(
                          height: 10,
                        ),

                        Row(
                          children: [
                            _menuCard(
                              icon:
                                  Icons.sports_esports_rounded,
                              title:
                                  'Free Play',
                              subtitle:
                                  'Unlimited training',
                              onTap:
                                  () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const FreePlayPage(),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            _menuCard(
                              icon:
                                  Icons.trending_up_rounded,
                              title:
                                  'Progress',
                              subtitle:
                                  'Graphs & stats',
                              onTap:
                                  () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const StatsPage(),
                                  ),
                                );

                                if (!mounted) {
                                  return;
                                }

                                await _loadHome();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const AppBannerAd(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}