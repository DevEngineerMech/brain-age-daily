import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/daily_hearts_service.dart';
import '../../core/widgets/app_banner_ad.dart';
import '../../core/widgets/app_rewarded_ad.dart';
import '../daily/daily_page.dart';
import '../free_play/free_play_page.dart';
import '../stats/stats_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _ageKey = 'user_age';

  final TextEditingController _ageController = TextEditingController();

  final int _brainAge = 40;
  int _hearts = DailyHeartsService.maxHearts;

  @override
  void initState() {
    super.initState();
    _loadHome();

    if (!kIsWeb) {
      AppRewardedAd.load();
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadHome() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final int savedAge = prefs.getInt(_ageKey) ?? 25;
    final int hearts = await DailyHeartsService.getHearts();

    if (!mounted) return;

    setState(() {
      _ageController.text = '$savedAge';
      _hearts = hearts;
    });
  }

  Future<void> _saveAge() async {
    final int? age = int.tryParse(_ageController.text.trim());
    if (age == null) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_ageKey, age);
  }

  Future<void> _startDailyBrainCheck() async {
    final bool canPlay = await DailyHeartsService.consumeHeart();

    if (!mounted) return;

    if (!canPlay) {
      setState(() => _hearts = 0);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hearts left. Watch an ad to get another heart.'),
          duration: Duration(milliseconds: 1400),
        ),
      );
      return;
    }

    final int hearts = await DailyHeartsService.getHearts();

    if (!mounted) return;

    setState(() => _hearts = hearts);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DailyPage(),
      ),
    );

    if (!mounted) return;

    final int refreshedHearts = await DailyHeartsService.getHearts();

    if (!mounted) return;

    setState(() => _hearts = refreshedHearts);
  }

  Future<void> _watchAdForHeart() async {
    if (_hearts >= DailyHeartsService.maxHearts) return;

    final bool earnedReward = await AppRewardedAd.show();

    if (!mounted) return;

    if (!earnedReward) {
      AppRewardedAd.load();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad not ready yet. Try again soon.'),
          duration: Duration(milliseconds: 1200),
        ),
      );
      return;
    }

    final int hearts = await DailyHeartsService.addHeart();

    if (!mounted) return;

    setState(() => _hearts = hearts);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❤️ +1 Heart'),
        duration: Duration(milliseconds: 900),
      ),
    );
  }

  Widget _heartIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(DailyHeartsService.maxHearts, (index) {
        final bool filled = index < _hearts;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            filled ? '❤️' : '🩶',
            style: const TextStyle(fontSize: 25),
          ),
        );
      }),
    );
  }

  Widget _watchAdButton() {
    if (_hearts >= DailyHeartsService.maxHearts) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 38,
      child: ElevatedButton.icon(
        onPressed: _watchAdForHeart,
        icon: const Icon(
          Icons.play_circle_fill_rounded,
          size: 18,
        ),
        label: const Text('Watch Ad'),
        style: ElevatedButton.styleFrom(
          elevation: 4,
          backgroundColor: const Color(0xFFFFD247),
          foregroundColor: const Color(0xFF35125A),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }

  Widget _brainAgeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 28, 26, 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
      ),
      child: Column(
        children: [
          const Text(
            'YOUR BRAIN AGE',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '$_brainAge',
            style: const TextStyle(
              color: Color(0xFF202024),
              fontSize: 72,
              fontWeight: FontWeight.w900,
              height: 0.95,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _heartIcons(),
              const SizedBox(width: 12),
              _watchAdButton(),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 72,
            child: ElevatedButton(
              onPressed: _startDailyBrainCheck,
              style: ElevatedButton.styleFrom(
                elevation: 4,
                backgroundColor: const Color(0xFF625BEA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Start Daily Brain Check',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Age',
            style: TextStyle(
              color: Color(0xFF202024),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              FocusScope.of(context).unfocus();
              _saveAge();
            },
            onTapOutside: (_) {
              FocusScope.of(context).unfocus();
              _saveAge();
            },
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: () => _ageController.clear(),
                icon: const Icon(Icons.close_rounded),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: Color(0xFF625BEA),
                  width: 2,
                ),
              ),
            ),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          const Padding(
            padding: EdgeInsets.only(left: 14),
            child: Text(
              'Tap away or press done to save',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
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
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Container(
            height: 170,
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 34,
                  color: const Color(0xFF202024),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF202024),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _saveAge();
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF625BEA),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Brain Age Daily',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        _brainAgeCard(),
                        const SizedBox(height: 20),
                        _ageCard(),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _menuCard(
                              icon: Icons.sports_esports_rounded,
                              title: 'Free Play',
                              subtitle: 'Unlimited training',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const FreePlayPage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 18),
                            _menuCard(
                              icon: Icons.trending_up_rounded,
                              title: 'Progress',
                              subtitle: 'Graphs & stats',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const StatsPage(),
                                  ),
                                );
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