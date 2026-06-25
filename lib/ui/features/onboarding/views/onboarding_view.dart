import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noise_guardian/data/repositories/consent_repository.dart';
import 'package:noise_guardian/di/service_locator.dart';
import 'package:noise_guardian/router/app_routes.dart';
import 'package:noise_guardian/ui/core/strings.dart';

/// First-launch PDPO 2025 consent screen (design doc §12.1).
class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key, ConsentRepository? consentRepository})
      : _consentRepository = consentRepository;

  final ConsentRepository? _consentRepository;

  ConsentRepository get _consent =>
      _consentRepository ??
      (getIt.isRegistered<ConsentRepository>()
          ? getIt<ConsentRepository>()
          : throw StateError('ConsentRepository not registered'));

  Future<void> _agree(BuildContext context) async {
    await _consent.setConsented(value: true);
    if (!context.mounted) {
      return;
    }
    context.go(AppRoutes.capture);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: const ValueKey('onboarding_view'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.hearing,
                size: 64,
                color: theme.colorScheme.primary,
                semanticLabel: AppStrings.onboardingIconLabel,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.onboardingTitle,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(AppStrings.onboardingConsentIntro),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.onboardingPurgePolicy,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(AppStrings.onboardingPdpoRights),
                      const SizedBox(height: 12),
                      const Text(AppStrings.onboardingDataUse),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                button: true,
                label: AppStrings.onboardingAgree,
                child: FilledButton(
                  key: const ValueKey('onboarding_agree_button'),
                  onPressed: () => _agree(context),
                  child: const Text(AppStrings.onboardingAgree),
                ),
              ),
              const SizedBox(height: 8),
              Semantics(
                button: true,
                label: AppStrings.onboardingDecline,
                child: OutlinedButton(
                  key: const ValueKey('onboarding_decline_button'),
                  onPressed: () {},
                  child: const Text(AppStrings.onboardingDecline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
