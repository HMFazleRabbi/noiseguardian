import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/app.dart';
import 'package:noise_guardian/data/repositories/app_settings_repository.dart';
import 'package:noise_guardian/data/repositories/consent_repository.dart';
import 'package:noise_guardian/data/services/sensor_guard_service.dart';
import 'package:noise_guardian/di/service_locator.dart';
import 'package:noise_guardian/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fake_report_repository.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'pdpo_has_consented': true});
    final prefs = await SharedPreferences.getInstance();
    configureDependencies(
      consentRepository: ConsentRepository(prefs),
      appSettingsRepository: AppSettingsRepository(prefs),
      sensorGuardService: StubSensorGuardService(),
      reportRepository: FakeReportRepository(),
    );
  });

  tearDown(() async {
    await resetDependencies();
  });

  testWidgets('app boots and navigates shell tabs without exception', (tester) async {
    await tester.pumpWidget(NoiseGuardianApp(router: createAppRouter()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('capture_view')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav_capture')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav_reports')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('reports_view')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav_settings')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('settings_view')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav_capture')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('capture_view')), findsOneWidget);
  });
}
