import 'package:flutter/material.dart';

import '../../core/widgets/app_banner_ad.dart';
import '../daily/daily_page.dart';
import '../free_play/free_play_page.dart';
import '../stats/stats_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _ageController = TextEditingController(text: '25');

  int heartsLeft = 3;
  int age = 25;

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _startDaily() {
    _dismissKeyboard();

    if (heartsLeft <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No daily attempts left.')),
      );
      return;
    }

    setState(() {
      heartsLeft--;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DailyPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color pageBg = Color(0xFF5F5AE6);

    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: pageBg,
          child: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Brain Age Daily',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'YOUR BRAIN AGE',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.psychology,
                              size: 88,
                              color: Color(0x11000000),
                            ),
                            Text(
                              '40',
                              style: TextStyle(
                                fontSize: 62,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            3,
                            (i) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                Icons.favorite,
                                color: i < heartsLeft ? Colors.red : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$heartsLeft / 3 Daily Attempts Left',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: _startDaily,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: pageBg,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              'Start Daily Brain Check',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Age',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
  controller: _ageController,
  keyboardType: TextInputType.number,
  textInputAction: TextInputAction.done,
  onEditingComplete: _dismissKeyboard,
  decoration: InputDecoration(
    hintText: 'Enter age',
    helperText: 'Tap away or press done to save',
    helperStyle: TextStyle(
      fontSize: 11,
      color: Colors.grey.shade600,
    ),
    filled: true,
    fillColor: Colors.grey.shade100,
    suffixIcon: IconButton(
      tooltip: 'Clear age',
      icon: const Icon(Icons.clear),
      onPressed: () {
        setState(() {
          _ageController.clear();
        });
      },
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  onChanged: (value) {
    final parsed = int.tryParse(value);
    if (parsed != null) {
      setState(() {
        age = parsed;
      });
    }
  },
),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _navButton(
                          title: 'Free Play',
                          subtitle: 'Unlimited training',
                          icon: Icons.sports_esports,
                          onTap: () {
                            _dismissKeyboard();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FreePlayPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _navButton(
                          title: 'Progress',
                          subtitle: 'Graphs & stats',
                          icon: Icons.show_chart,
                          onTap: () {
                            _dismissKeyboard();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const StatsPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const AppBannerAd(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Icon(icon, size: 34),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}