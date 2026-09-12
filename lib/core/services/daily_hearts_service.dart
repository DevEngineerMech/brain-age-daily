import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyHeartsService {
  static const int maxHearts = 3;

  static const String _heartsKey = 'daily_hearts';
  static const String _lastRegenKey = 'daily_hearts_last_regen_ms';

  static int _webHearts = maxHearts;

  static Future<int> getHearts() async {
    if (kIsWeb) {
      return _webHearts;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int hearts = prefs.getInt(_heartsKey) ?? maxHearts;
    int lastRegenMs = prefs.getInt(_lastRegenKey) ??
        DateTime.now().millisecondsSinceEpoch;

    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final int elapsedMs = nowMs - lastRegenMs;
    final int daysPassed = elapsedMs ~/ const Duration(hours: 24).inMilliseconds;

    if (daysPassed > 0 && hearts < maxHearts) {
      hearts += daysPassed;

      if (hearts > maxHearts) {
        hearts = maxHearts;
      }

      lastRegenMs += daysPassed * const Duration(hours: 24).inMilliseconds;

      await prefs.setInt(_heartsKey, hearts);
      await prefs.setInt(_lastRegenKey, lastRegenMs);
    }

    return hearts.clamp(0, maxHearts).toInt();
  }

  static Future<bool> consumeHeart() async {
    int hearts = await getHearts();

    if (hearts <= 0) {
      return false;
    }

    hearts--;

    if (kIsWeb) {
      _webHearts = hearts;
      return true;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_heartsKey, hearts);

    if (hearts < maxHearts) {
      await prefs.setInt(
        _lastRegenKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    }

    return true;
  }

  static Future<int> addHeart() async {
    int hearts = await getHearts();

    if (hearts >= maxHearts) {
      return maxHearts;
    }

    hearts++;

    if (kIsWeb) {
      _webHearts = hearts.clamp(0, maxHearts).toInt();
      return _webHearts;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_heartsKey, hearts.clamp(0, maxHearts).toInt());

    return hearts.clamp(0, maxHearts).toInt();
  }
}