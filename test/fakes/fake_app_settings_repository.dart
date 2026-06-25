import 'package:noise_guardian/data/repositories/app_settings_repository.dart';

class FakeAppSettingsRepository implements AppSettingsRepository {
  FakeAppSettingsRepository({
    this.useMockDoe = true,
    this.localeCode,
  });

  @override
  bool useMockDoe;

  @override
  String? localeCode;

  @override
  Future<void> setUseMockDoe(bool value) async {
    useMockDoe = value;
  }

  @override
  Future<void> setLocaleCode(String? code) async {
    localeCode = code;
  }
}
