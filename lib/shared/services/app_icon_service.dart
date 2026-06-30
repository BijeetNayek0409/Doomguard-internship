import 'package:flutter/services.dart';

/// Fetches and caches real app icons from Android via a MethodChannel.
/// No third-party dependencies — uses PackageManager directly via MainActivity.
class AppIconService {
  AppIconService._();
  static final AppIconService instance = AppIconService._();

  static const _channel =
      MethodChannel('com.example.doomguard/app_icons');

  /// In-memory icon cache: packageName -> PNG bytes (or null if not found).
  final Map<String, Uint8List?> _cache = {};

  /// Returns the icon bytes for [packageName], or null if unavailable.
  Future<Uint8List?> getIcon(String packageName) async {
    if (_cache.containsKey(packageName)) {
      return _cache[packageName];
    }

    try {
      final result = await _channel.invokeMethod<Uint8List>(
        'getAppIcon',
        {'package_name': packageName},
      );
      _cache[packageName] = result;
      return result;
    } catch (_) {
      _cache[packageName] = null;
      return null;
    }
  }

  /// Preloads icons for a list of package names in parallel.
  Future<void> preload(Iterable<String> packages) async {
    await Future.wait(
      packages.map((pkg) => getIcon(pkg)),
      eagerError: false,
    );
  }
}
