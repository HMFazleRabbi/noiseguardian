import 'package:noise_guardian/data/repositories/app_settings_repository.dart';

class FakeAppSettingsRepository implements AppSettingsRepository {
  FakeAppSettingsRepository({
    this.useMockDoe = true,
  });

  @override
  bool useMockDoe;

  @override
  Future<void> setUseMockDoe(bool value) async {
    useMockDoe = value;
  }
}
