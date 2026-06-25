import 'package:shared_preferences/shared_preferences.dart';

const String _cdKey = 'calibration_correction_factor';

/// Persists device-specific correction factor Cd (Module A).
class CalibrationRepository {
  CalibrationRepository(this._prefs);

  final SharedPreferences _prefs;

  Future<double?> loadCorrectionFactor() async {
    if (!_prefs.containsKey(_cdKey)) {
      return null;
    }
    return _prefs.getDouble(_cdKey);
  }

  Future<void> saveCorrectionFactor(double cd) async {
    await _prefs.setDouble(_cdKey, cd);
  }

  Future<void> clearCorrectionFactor() async {
    await _prefs.remove(_cdKey);
  }
}
