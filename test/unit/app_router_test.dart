import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/data/repositories/app_settings_repository.dart';
import 'package:noise_guardian/data/repositories/consent_repository.dart';
import 'package:noise_guardian/data/services/sensor_guard_service.dart';
import 'package:noise_guardian/di/service_locator.dart';
import 'package:noise_guardian/router/app_router.dart';
import 'package:noise_guardian/router/app_routes.dart';
import 'package:noise_guardian/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fake_evidence_queue_repository.dart';

Future<void> _configureTestDependencies() async {
  SharedPreferences.setMockInitialValues({'pdpo_has_consented': true});
  final prefs = await SharedPreferences.getInstance();
  configureDependencies(
    consentRepository: ConsentRepository(prefs),
    appSettingsRepository: AppSettingsRepository(prefs),
    sensorGuardService: StubSensorGuardService(),
    evidenceQueueRepository: FakeEvidenceQueueRepository(),
  );
}

void main() {
  group('AppRouter', () {
    test('shellRoutes are capture, history, settings only', () {
      expect(AppRoutes.shellRoutes, [
        AppRoutes.capture,
        AppRoutes.history,
        AppRoutes.settings,
      ]);
      expect(AppRoutes.shellRoutes, isNot(contains('/heatmap')));
    });

    tearDown(() async {
      await resetDependencies();
    });

    testWidgets('redirects to onboarding when consent not granted', (tester) async {
      SharedPreferences.setMockInitialValues({'pdpo_has_consented': false});
      final prefs = await SharedPreferences.getInstance();
      configureDependencies(
        consentRepository: ConsentRepository(prefs),
        appSettingsRepository: AppSettingsRepository(prefs),
        sensorGuardService: StubSensorGuardService(),
        evidenceQueueRepository: FakeEvidenceQueueRepository(),
      );
      final router = createAppRouter();

      await tester.pumpWidget(NoiseGuardianApp(router: router));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('onboarding_view')), findsOneWidget);
    });

    testWidgets('resolves capture route when consented', (tester) async {
      await _configureTestDependencies();
      final router = createAppRouter();
      router.go('/capture');

      await tester.pumpWidget(NoiseGuardianApp(router: router));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('capture_view')), findsOneWidget);
    });

    testWidgets('resolves history route', (tester) async {
      await _configureTestDependencies();
      final router = createAppRouter();
      router.go('/history');

      await tester.pumpWidget(NoiseGuardianApp(router: router));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('history_view')), findsOneWidget);
    });

    testWidgets('heatmap route is not registered', (tester) async {
      await _configureTestDependencies();
      final router = createAppRouter();
      router.go('/heatmap');

      await tester.pumpWidget(NoiseGuardianApp(router: router));
      await tester.pumpAndSettle();

      expect(find.textContaining('Route not found'), findsOneWidget);
    });

    testWidgets('resolves settings route', (tester) async {
      await _configureTestDependencies();
      final router = createAppRouter();
      router.go('/settings');

      await tester.pumpWidget(NoiseGuardianApp(router: router));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('settings_view')), findsOneWidget);
    });
  });
}
