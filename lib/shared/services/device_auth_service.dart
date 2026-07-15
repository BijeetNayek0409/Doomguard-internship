import 'package:local_auth/local_auth.dart';

/// Thin wrapper around `local_auth` so the rest of the app never talks
/// to the platform auth API directly. Centralizing it here means any
/// future screen that needs device authentication (PIN / password /
/// fingerprint / Face ID) can reuse the exact same behavior.
class DeviceAuthService {
  DeviceAuthService._();
  static final DeviceAuthService instance = DeviceAuthService._();

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Prompts the user for device authentication.
  /// Returns true only on a genuine successful authentication.
  /// Returns false on cancel, failure, lockout, or if the device has no
  /// authentication method configured at all.
  Future<bool> authenticate({
    String reason = 'Authenticate to continue',
  }) async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) return false;

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          // false = allow PIN/password/pattern fallback, not biometrics-only.
          biometricOnly: false,
          // Keep the auth prompt open across app lifecycle blips
          // (e.g. a notification interrupting the biometric sheet).
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      // Any platform exception (no enrolled biometrics, hardware error,
      // etc.) is treated as "not authenticated" — fail closed, never open.
      return false;
    }
  }
}