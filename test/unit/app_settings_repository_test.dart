import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/repositories/app_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppSettingsRepository', () {
    test('can be constructed with SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      expect(AppSettingsRepository(prefs), isA<AppSettingsRepository>());
    });
  });
}
