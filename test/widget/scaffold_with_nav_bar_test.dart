import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/app.dart';
import 'package:noise_guardian/router/app_router.dart';

void main() {
  group('ScaffoldWithNavBar', () {
    testWidgets('renders four navigation destinations', (tester) async {
      final router = createAppRouter();

      await tester.pumpWidget(NoiseGuardianApp(router: router));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('nav_capture')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_history')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_heatmap')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav_settings')), findsOneWidget);
    });

    testWidgets('navigates between shell tabs', (tester) async {
      final router = createAppRouter();

      await tester.pumpWidget(NoiseGuardianApp(router: router));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('capture_view')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('nav_history')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('history_view')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('nav_heatmap')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('heatmap_view')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('nav_settings')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('settings_view')), findsOneWidget);
    });
  });
}
