import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/repositories/consent_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ConsentRepository', () {
    late ConsentRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = ConsentRepository(prefs);
    });

    test('hasConsented false by default', () {
      expect(repository.hasConsented, isFalse);
    });

    test('setConsented persists flag and version', () async {
      await repository.setConsented(value: true);
      expect(repository.hasConsented, isTrue);
      expect(repository.consentVersion, currentConsentVersion);
    });

    test('revoke clears version', () async {
      await repository.setConsented(value: true);
      await repository.setConsented(value: false);
      expect(repository.hasConsented, isFalse);
      expect(repository.consentVersion, isNull);
    });
  });
}
