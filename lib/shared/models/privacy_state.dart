import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the user has accepted the Privacy Policy.
/// Persisted locally so it only shows once, right after install.
class PrivacyState extends ChangeNotifier {
  static const _prefsKey = 'privacy_policy_accepted_v1';

  bool _accepted = false;
  bool _loaded = false;

  bool get accepted => _accepted;
  bool get isLoaded => _loaded;

  PrivacyState() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _accepted = prefs.getBool(_prefsKey) ?? false;
    _loaded = true;
    notifyListeners();
  }

  Future<void> accept() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
    _accepted = true;
    notifyListeners();
  }
}