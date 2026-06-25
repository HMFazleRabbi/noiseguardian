import 'package:shared_preferences/shared_preferences.dart';

const String _hasConsentedKey = 'pdpo_has_consented';
const String _consentVersionKey = 'pdpo_consent_version';

/// Current PDPO 2025 consent copy version (design doc §12.1).
const String currentConsentVersion = '2025.1';

/// Persists onboarding consent for PDPO 2025 (Stage 6).
class ConsentRepository {
  ConsentRepository(this._prefs);

  final SharedPreferences _prefs;

  bool get hasConsented => _prefs.getBool(_hasConsentedKey) ?? false;

  String? get consentVersion => _prefs.getString(_consentVersionKey);

  Future<void> setConsented({required bool value}) async {
    await _prefs.setBool(_hasConsentedKey, value);
    if (value) {
      await _prefs.setString(_consentVersionKey, currentConsentVersion);
    } else {
      await _prefs.remove(_consentVersionKey);
    }
  }
}
