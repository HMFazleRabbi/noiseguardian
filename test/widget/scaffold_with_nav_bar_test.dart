import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/app.dart';
import 'package:noise_guardian/data/repositories/app_settings_repository.dart';
import 'package:noise_guardian/data/repositories/consent_repository.dart';
import 'package:noise_guardian/data/services/sensor_guard_service.dart';
import 'package:noise_guardian/di/service_locator.dart';
import 'package:noise_guardian/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fake_evidence_queue_repository.dart';

void main() {
  group('ScaffoldWithNavBar', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({'pdpo_has_consented': true});
      final prefs = await SharedPreferences.getInstance();
      configureDependencies(
        consentRepository: ConsentRepository(prefs),
        appSettingsRepository: AppSettingsRepository(prefs),
        sensorGuardService: StubSensorGuardService(),
        evidenceQueueRepository: FakeEvidenceQueueRepository(),
      );
    });

    tearDown(() async {
      await resetDependencies();
    });

    testWidgets('renders three navigation destinations', (tester) async {
      final router = createAppRouter();

      await tester.pumpWidget(NoiseGuardianApp(router: router));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('nav_capture')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_history')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_settings')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_heatmap')), findsNothing);
    });

    testWidgets('navigates between shell tabs', (tester) async {
      final router = createAppRouter();

      await tester.pumpWidget(NoiseGuardianApp(router: router));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('capture_view')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('nav_history')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('history_view')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('nav_settings')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('settings_view')), findsOneWidget);
    });
  });
}
