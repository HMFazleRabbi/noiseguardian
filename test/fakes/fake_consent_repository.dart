import 'package:noise_guardian/data/repositories/consent_repository.dart';

class FakeConsentRepository implements ConsentRepository {
  FakeConsentRepository({this.hasConsented = true});

  @override
  bool hasConsented;

  @override
  String? consentVersion = currentConsentVersion;

  @override
  Future<void> setConsented({required bool value}) async {
    hasConsented = value;
    consentVersion = value ? currentConsentVersion : null;
  }
}
