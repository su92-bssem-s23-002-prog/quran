import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Cache manager for offline data storage
class CacheManager {
  static const String _prayerTimesKey = 'prayer_times';
  static const String _prayerTimesTimestampKey = 'prayer_times_timestamp';
  static const String _islamicDateKey = 'islamic_date';
  static const String _islamicDateTimestampKey = 'islamic_date_timestamp';
  static const String _lastLocationKey = 'last_location';

  // Cache duration: 24 hours for prayer times
  static const Duration _prayerTimesCacheDuration = Duration(hours: 24);
  static const Duration _islamicDateCacheDuration = Duration(days: 1);

  /// Save prayer times to cache
  static Future<void> savePrayerTimes(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prayerTimesKey, jsonEncode(data));
    await prefs.setInt(
      _prayerTimesTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Get cached prayer times if still valid
  static Future<Map<String, dynamic>?> getCachedPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();

    final timestamp = prefs.getInt(_prayerTimesTimestampKey);
    if (timestamp == null) return null;

    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    // Check if cache is still valid
    if (now.difference(cacheTime) > _prayerTimesCacheDuration) {
      return null;
    }

    final dataString = prefs.getString(_prayerTimesKey);
    if (dataString == null) return null;

    return jsonDecode(dataString) as Map<String, dynamic>;
  }

  /// Save Islamic date to cache
  static Future<void> saveIslamicDate(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_islamicDateKey, jsonEncode(data));
    await prefs.setInt(
      _islamicDateTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Get cached Islamic date if still valid
  static Future<Map<String, dynamic>?> getCachedIslamicDate() async {
    final prefs = await SharedPreferences.getInstance();

    final timestamp = prefs.getInt(_islamicDateTimestampKey);
    if (timestamp == null) return null;

    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    if (now.difference(cacheTime) > _islamicDateCacheDuration) {
      return null;
    }

    final dataString = prefs.getString(_islamicDateKey);
    if (dataString == null) return null;

    return jsonDecode(dataString) as Map<String, dynamic>;
  }

  /// Save last known location
  static Future<void> saveLastLocation(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _lastLocationKey,
      jsonEncode({'lat': lat, 'lng': lng}),
    );
  }

  /// Get last known location
  static Future<Map<String, double>?> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_lastLocationKey);
    if (dataString == null) return null;

    final data = jsonDecode(dataString);
    return {'lat': data['lat'] as double, 'lng': data['lng'] as double};
  }

  /// Clear all cache
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prayerTimesKey);
    await prefs.remove(_prayerTimesTimestampKey);
    await prefs.remove(_islamicDateKey);
    await prefs.remove(_islamicDateTimestampKey);
  }

  /// Clear specific cache
  static Future<void> clearPrayerTimesCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prayerTimesKey);
    await prefs.remove(_prayerTimesTimestampKey);
  }

  /// Check if prayer times cache is valid
  static Future<bool> isPrayerTimesCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_prayerTimesTimestampKey);
    if (timestamp == null) return false;

    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cacheTime) <= _prayerTimesCacheDuration;
  }
}
