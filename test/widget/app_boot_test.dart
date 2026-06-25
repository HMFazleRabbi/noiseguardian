import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/app.dart';
import 'package:noise_guardian/data/services/sensor_guard_service.dart';
import 'package:noise_guardian/di/service_locator.dart';
import 'package:noise_guardian/router/app_router.dart';

void main() {
  setUp(() {
    configureDependencies(sensorGuardService: StubSensorGuardService());
  });

  tearDown(() async {
    await resetDependencies();
  });

  testWidgets('app boots from main entry configuration', (tester) async {
    await tester.pumpWidget(NoiseGuardianApp(router: createAppRouter()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('capture_view')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav_capture')), findsOneWidget);
  });
}
