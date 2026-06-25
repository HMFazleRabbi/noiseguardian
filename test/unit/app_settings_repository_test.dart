import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/repositories/app_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppSettingsRepository', () {
    late AppSettingsRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = AppSettingsRepository(prefs);
    });

    test('useMockDoe defaults true', () {
      expect(repository.useMockDoe, isTrue);
    });

    test('persists locale', () async {
      await repository.setLocaleCode('bn');
      expect(repository.localeCode, 'bn');
    });

    test('setUseMockDoe persists', () async {
      await repository.setUseMockDoe(false);
      expect(repository.useMockDoe, isFalse);
    });
  });
}
