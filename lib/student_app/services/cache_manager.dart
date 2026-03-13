import 'package:shared_preferences/shared_preferences.dart';

/// A lightweight TTL-based cache manager.
///
/// Each service call can be guarded by [isFresh] before hitting the
/// network.  If the cached timestamp is within [ttl] we consider the
/// data fresh and skip the server round-trip.
///
/// Usage in a service:
/// ```dart
/// if (!forceRefresh && await CacheManager.isFresh('my_cache_key')) {
///   return cachedData;
/// }
/// // … fetch from server …
/// await CacheManager.touch('my_cache_key');
/// ```
class CacheManager {
  /// Default TTL: 30 minutes.
  static const Duration defaultTtl = Duration(minutes: 15);

  static String _tsKey(String cacheKey) => '__ts_$cacheKey';

  /// Returns `true` when the cached entry for [cacheKey] is younger
  /// than [ttl] (so we can safely skip the network call).
  static Future<bool> isFresh(
    String cacheKey, {
    Duration ttl = defaultTtl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tsKey(cacheKey));
    if (raw == null) return false;

    final ts = DateTime.tryParse(raw);
    if (ts == null) return false;

    return DateTime.now().difference(ts) < ttl;
  }

  /// Record the current timestamp for [cacheKey].
  /// Call this every time you successfully persist new data.
  static Future<void> touch(String cacheKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tsKey(cacheKey), DateTime.now().toIso8601String());
  }

  /// Remove the timestamp for [cacheKey], effectively invalidating
  /// the cache so the next call will hit the network.
  static Future<void> invalidate(String cacheKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tsKey(cacheKey));
    await prefs.remove(cacheKey);
  }

  /// Invalidate all keys that start with [prefix].
  static Future<void> invalidatePrefix(String prefix) async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith(prefix) || key.startsWith('__ts_$prefix')) {
        await prefs.remove(key);
      }
    }
  }
}
