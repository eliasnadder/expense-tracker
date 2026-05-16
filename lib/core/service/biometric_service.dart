import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static const String _prefKey = 'biometric_enabled';
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> canCheckBiometrics() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final available = await _auth.getAvailableBiometrics();
      return isSupported && available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate({bool biometricOnly = false}) async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Authenticate to access Expense Tracker',
        biometricOnly: biometricOnly,
      );
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  static Future<void> setBiometricEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
  }
}
