import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:noise_guardian/l10n/app_localizations.dart';
import 'package:noise_guardian/router/app_routes.dart';
import 'package:noise_guardian/ui/features/onboarding/views/onboarding_view.dart';
import '../fakes/fake_consent_repository.dart';

void main() {
  testWidgets('OnboardingView agree navigates to capture', (tester) async {
    final consent = FakeConsentRepository(hasConsented: false);
    final router = GoRouter(
      initialLocation: AppRoutes.onboarding,
      routes: [
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => OnboardingView(consentRepository: consent),
        ),
        GoRoute(
          path: AppRoutes.capture,
          builder: (context, state) =>
              const Scaffold(key: ValueKey('capture_placeholder')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('onboarding_view')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('onboarding_agree_button')));
    await tester.pumpAndSettle();

    expect(consent.hasConsented, isTrue);
    expect(find.byKey(const ValueKey('capture_placeholder')), findsOneWidget);
  });

  testWidgets('OnboardingView decline stays on onboarding', (tester) async {
    final consent = FakeConsentRepository(hasConsented: false);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: OnboardingView(consentRepository: consent),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('onboarding_decline_button')));
    await tester.pumpAndSettle();

    expect(consent.hasConsented, isFalse);
    expect(find.byKey(const ValueKey('onboarding_view')), findsOneWidget);
  });
}
