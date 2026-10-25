
import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/social_leaderboard_service.dart';

class CreateUsernamePage extends StatefulWidget {
  const CreateUsernamePage({super.key});

  @override
  State<CreateUsernamePage> createState() =>
      _CreateUsernamePageState();
}

class _CreateUsernamePageState
    extends State<CreateUsernamePage> {
  static const Color background = Color(0xFF100C2F);
  static const Color panel = Color(0xFF241A4A);
  static const Color purple = Color(0xFF8545F5);
  static const Color gold = Color(0xFFFFC75D);
  static const Color cyan = Color(0xFF42D9D0);

  final TextEditingController _controller =
      TextEditingController();

  Timer? _debounce;

  bool _checking = false;
  bool _available = false;
  bool _saving = false;

  String? _message;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _changed(String value) {
    _debounce?.cancel();

    final error =
        SocialLeaderboardService.validateUsername(value);

    setState(() {
      _available = false;
      _message = error;
      _checking = error == null;
    });

    if (error != null) return;

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => _checkAvailability(value.trim()),
    );
  }

  Future<void> _checkAvailability(String value) async {
    try {
      final available =
          await SocialLeaderboardService.usernameAvailable(
        value,
      );

      if (!mounted ||
          _controller.text.trim() != value) {
        return;
      }

      setState(() {
        _checking = false;
        _available = available;
        _message = available
            ? 'Username available!'
            : 'That username is already taken.';
      });
    } catch (error) {
      SocialLeaderboardService.logError(
        'username availability',
        error,
      );

      if (!mounted) return;

      setState(() {
        _checking = false;
        _available = false;
        _message = 'Could not check this username.';
      });
    }
  }

  Future<void> _createProfile() async {
    if (_saving || _checking || !_available) return;

    setState(() => _saving = true);

    try {
      await SocialLeaderboardService.createUsername(
        _controller.text,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (error) {
      SocialLeaderboardService.logError(
        'create username',
        error,
      );

      if (!mounted) return;

      final message = error.toString();

      setState(() {
        _available = false;
        _message = message.contains('already taken')
            ? 'That username has just been taken.'
            : 'Unable to create your profile. Try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = _controller.text.trim();

    final canCreate =
        _available && !_checking && !_saving;

    return Scaffold(
      backgroundColor: background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF291052),
              Color(0xFF100C2F),
              Color(0xFF10183A),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: purple.withOpacity(0.2),
                    border: Border.all(
                      color: const Color(0xFFB88AFF),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: purple.withOpacity(0.28),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFFD9B6FF),
                    size: 58,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'CREATE YOUR\nPLAYER PROFILE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose a unique username to appear on '
                'the weekly leaderboard and unlock '
                'future friend challenges.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFC8B9E1),
                  fontSize: 13,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(19),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(
                    color: const Color(0xFF7154AE),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR USERNAME',
                      style: TextStyle(
                        color: gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controller,
                      onChanged: _changed,
                      maxLength: 18,
                      autocorrect: false,
                      textCapitalization:
                          TextCapitalization.none,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. BrainMaster25',
                        hintStyle: const TextStyle(
                          color: Color(0xFF9184B6),
                        ),
                        prefixIcon: const Icon(
                          Icons.alternate_email_rounded,
                          color: cyan,
                        ),
                        suffixIcon: _checking
                            ? const Padding(
                                padding: EdgeInsets.all(13),
                                child: SizedBox(
                                  width: 17,
                                  height: 17,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: cyan,
                                  ),
                                ),
                              )
                            : _available
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFF4BE09D),
                                  )
                                : null,
                        filled: true,
                        fillColor: background,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const Text(
                      '3–18 characters. Letters, numbers '
                      'and underscores only.',
                      style: TextStyle(
                        color: Color(0xFFB8AACA),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 9),
                    if (_message != null)
                      Text(
                        _message!,
                        style: TextStyle(
                          color: _available
                              ? const Color(0xFF4BE09D)
                              : const Color(0xFFFF8A9D),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF183D46),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.shield_rounded,
                      color: cyan,
                    ),
                    SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        'No email or password needed. '
                        'Your profile is linked to this '
                        'app installation.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 23),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: canCreate
                      ? _createProfile
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFF45376A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          username.isEmpty
                              ? 'CHOOSE A USERNAME'
                              : 'CREATE PROFILE',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Your existing Brain Age, achievements, '
                'Brain Coins and game progress stay unchanged.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFB4A5D0),
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
