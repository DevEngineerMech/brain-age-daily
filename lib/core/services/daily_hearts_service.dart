
import 'package:shared_preferences/shared_preferences.dart';

class DailyHeartsService {
  static const int maxHearts = 3;
  static const String _heartsKey = 'daily_hearts';
  static const String _lastRegenKey = 'daily_hearts_last_regen_ms';

  static Future<int> getHearts() async {
    final prefs = await SharedPreferences.getInstance();
    var hearts = (prefs.getInt(_heartsKey) ?? maxHearts)
        .clamp(0, maxHearts).toInt();

    var lastRegenMs = prefs.getInt(_lastRegenKey) ??
        DateTime.now().millisecondsSinceEpoch;

    final elapsedMs =
        DateTime.now().millisecondsSinceEpoch - lastRegenMs;

    final daysPassed =
        elapsedMs ~/ const Duration(hours: 24).inMilliseconds;

    if (daysPassed > 0 && hearts < maxHearts) {
      hearts = (hearts + daysPassed)
          .clamp(0, maxHearts).toInt();

      lastRegenMs += daysPassed *
          const Duration(hours: 24).inMilliseconds;

      await prefs.setInt(_heartsKey, hearts);
      await prefs.setInt(_lastRegenKey, lastRegenMs);
    }

    return hearts;
  }

  static Future<bool> consumeHeart() async {
    final hearts = await getHearts();

    if (hearts <= 0) return false;

    final prefs = await SharedPreferences.getInstance();

    final saved = await prefs.setInt(
      _heartsKey,
      hearts - 1,
    );

    if (!saved) {
      throw StateError('Could not save heart usage.');
    }

    await prefs.setInt(
      _lastRegenKey,
      DateTime.now().millisecondsSinceEpoch,
    );

    return true;
  }

  static Future<int> addHeart() async {
    final hearts = await getHearts();

    if (hearts >= maxHearts) {
      return maxHearts;
    }

    final updated = hearts + 1;
    final prefs = await SharedPreferences.getInstance();

    final saved = await prefs.setInt(
      _heartsKey,
      updated,
    );

    if (!saved) {
      throw StateError('Could not save heart refill.');
    }

    return updated;
  }
}
