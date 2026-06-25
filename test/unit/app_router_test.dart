import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:noise_guardian/app.dart';
import 'package:noise_guardian/data/services/sensor_guard_service.dart';
import 'package:noise_guardian/di/service_locator.dart';
import 'package:noise_guardian/router/app_routes.dart';
import 'package:noise_guardian/router/app_router.dart';

import '../fakes/fake_evidence_queue_repository.dart';

void main() {
  group('AppRouter', () {
    late GoRouter router;

    setUp(() {
      configureDependencies(
        sensorGuardService: StubSensorGuardService(),
        evidenceQueueRepository: FakeEvidenceQueueRepository(),
      );
      router = createAppRouter();
    });

    tearDown(() async {
      await resetDependencies();
    });

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(NoiseGuardianApp(router: router));
      await tester.pumpAndSettle();
    }

    testWidgets('resolves capture route', (tester) async {
      router.go(AppRoutes.capture);
      await pumpApp(tester);
      expect(find.byKey(const ValueKey('capture_view')), findsOneWidget);
    });

    testWidgets('resolves history route', (tester) async {
      router.go(AppRoutes.history);
      await pumpApp(tester);
      expect(find.byKey(const ValueKey('history_view')), findsOneWidget);
    });

    testWidgets('resolves heatmap route', (tester) async {
      router.go(AppRoutes.heatmap);
      await pumpApp(tester);
      expect(find.byKey(const ValueKey('heatmap_view')), findsOneWidget);
    });

    testWidgets('resolves settings route', (tester) async {
      router.go(AppRoutes.settings);
      await pumpApp(tester);
      expect(find.byKey(const ValueKey('settings_view')), findsOneWidget);
    });

    test('defines all shell routes', () {
      expect(AppRoutes.shellRoutes, hasLength(4));
      expect(AppRoutes.shellRoutes, containsAll([
        AppRoutes.capture,
        AppRoutes.history,
        AppRoutes.heatmap,
        AppRoutes.settings,
      ]));
    });
  });
}
