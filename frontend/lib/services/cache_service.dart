/// Cache entry containing data and timestamp
class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final bool isPermanent;

  CacheEntry(this.data, this.timestamp, {this.isPermanent = false});

  bool isExpired(Duration maxAge) {
    if (isPermanent) return false; // Permanent entries never expire
    return DateTime.now().difference(timestamp) > maxAge;
  }
}

/// Service to cache API responses with configurable expiration times
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final Map<String, CacheEntry<dynamic>> _cache = {};

  /// Default cache duration - 30 seconds
  static const Duration defaultCacheDuration = Duration(seconds: 30);

  /// Permanent cache duration - used as a marker but entries are actually permanent
  static const Duration permanentCacheDuration = Duration(days: 365);

  /// Check if a cache entry exists and is still valid
  bool isValid(String key, {Duration? maxAge}) {
    final entry = _cache[key];
    if (entry == null) return false;

    final age = maxAge ?? defaultCacheDuration;
    return !entry.isExpired(age);
  }

  /// Get cached data if valid, null otherwise
  T? get<T>(String key, {Duration? maxAge}) {
    final entry = _cache[key];
    if (entry == null) return null;

    final age = maxAge ?? defaultCacheDuration;
    if (entry.isExpired(age)) {
      _cache.remove(key);
      return null;
    }

    return entry.data as T?;
  }

  /// Cache data with timestamp
  void put<T>(String key, T data, {bool isPermanent = false}) {
    _cache[key] = CacheEntry<T>(data, DateTime.now(), isPermanent: isPermanent);
  }

  /// Cache data permanently (never expires)
  void putPermanent<T>(String key, T data) {
    _cache[key] = CacheEntry<T>(data, DateTime.now(), isPermanent: true);
  }

  /// Remove specific cache entry
  void removeEntry(String key) {
    _cache.remove(key);
  }

  /// Remove all permanent cache entries (for refreshing static data)
  void clearPermanentCache() {
    _cache.removeWhere((key, entry) => entry.isPermanent);
  }

  /// Remove entries by key pattern (useful for clearing related cache entries)
  void removeByPattern(String pattern) {
    final regex = RegExp(pattern);
    _cache.removeWhere((key, entry) => regex.hasMatch(key));
  }

  /// Remove specific cache entry
  void remove(String key) {
    _cache.remove(key);
  }

  /// Clear all cache entries
  void clear() {
    _cache.clear();
  }

  /// Clear expired entries
  void clearExpired({Duration? maxAge}) {
    final age = maxAge ?? defaultCacheDuration;
    final now = DateTime.now();

    _cache.removeWhere((key, entry) => now.difference(entry.timestamp) > age);
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    final now = DateTime.now();
    int validEntries = 0;
    int expiredEntries = 0;

    for (final entry in _cache.values) {
      if (now.difference(entry.timestamp) <= defaultCacheDuration) {
        validEntries++;
      } else {
        expiredEntries++;
      }
    }

    return {
      'totalEntries': _cache.length,
      'validEntries': validEntries,
      'expiredEntries': expiredEntries,
      'hitRate': validEntries / (_cache.length + validEntries),
    };
  }

  /// Generate cache key for API endpoints
  static String generateKey(String endpoint, [Map<String, dynamic>? params]) {
    if (params == null || params.isEmpty) {
      return endpoint;
    }

    // Sort parameters for consistent key generation
    final sortedParams = Map.fromEntries(
        params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));

    final paramString =
        sortedParams.entries.map((e) => '${e.key}=${e.value}').join('&');

    return '$endpoint?$paramString';
  }

  /// Cache invalidation patterns
  void invalidatePattern(String pattern) {
    _cache.removeWhere((key, value) => key.contains(pattern));
  }

  /// Invalidate user-specific caches (useful for auth changes)
  void invalidateUserData() {
    invalidatePattern('/user/');
    invalidatePattern('/auth/');
  }

  /// Invalidate route-related caches
  void invalidateRouteData() {
    invalidatePattern('/routes');
    invalidatePattern('/route/');
  }
}
