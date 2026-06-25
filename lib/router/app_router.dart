import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noise_guardian/core/logging/app_log.dart';
import 'package:noise_guardian/data/repositories/consent_repository.dart';
import 'package:noise_guardian/data/services/debug_log_service.dart';
import 'package:noise_guardian/di/service_locator.dart';
import 'package:noise_guardian/router/app_routes.dart';
import 'package:noise_guardian/router/debug_log_navigator_observer.dart';
import 'package:noise_guardian/ui/core/shell/scaffold_with_nav_bar.dart';
import 'package:noise_guardian/ui/features/capture/view_models/capture_view_model.dart';
import 'package:noise_guardian/ui/features/capture/views/capture_view.dart';
import 'package:noise_guardian/ui/features/heatmap/view_models/heatmap_view_model.dart';
import 'package:noise_guardian/ui/features/heatmap/views/heatmap_view.dart';
import 'package:noise_guardian/ui/features/history/view_models/history_view_model.dart';
import 'package:noise_guardian/ui/features/history/views/history_view.dart';
import 'package:noise_guardian/ui/features/onboarding/views/onboarding_view.dart';
import 'package:noise_guardian/ui/features/settings/view_models/settings_view_model.dart';
import 'package:noise_guardian/ui/features/settings/views/settings_view.dart';
import 'package:provider/provider.dart';

GoRouter createAppRouter() {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final observers = <NavigatorObserver>[];

  if (getIt.isRegistered<DebugLogService>()) {
    observers.add(DebugLogNavigatorObserver());
  }

  unawaited(
    appLogInfo(
      'router',
      'Creating GoRouter',
      data: {
        'initialLocation': AppRoutes.capture,
        'observers': observers.length,
      },
    ),
  );

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.capture,
    observers: observers,
    redirect: (context, state) {
      if (!getIt.isRegistered<ConsentRepository>()) {
        return null;
      }
      final hasConsented = getIt<ConsentRepository>().hasConsented;
      final onOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (!hasConsented && !onOnboarding) {
        return AppRoutes.onboarding;
      }
      if (hasConsented && onOnboarding) {
        return AppRoutes.capture;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingView(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          unawaited(
            appLogDebug(
              'router',
              'Shell builder invoked',
              data: {
                'uri': state.uri.toString(),
                'branchIndex': navigationShell.currentIndex,
              },
            ),
          );
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.capture,
                builder: (context, state) => ChangeNotifierProvider(
                  create: (_) => getIt<CaptureViewModel>(),
                  child: const CaptureView(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                builder: (context, state) => ChangeNotifierProvider(
                  create: (_) => getIt<HistoryViewModel>(),
                  child: const HistoryView(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.heatmap,
                builder: (context, state) => ChangeNotifierProvider(
                  create: (_) => getIt<HeatmapViewModel>(),
                  child: const HeatmapView(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => ChangeNotifierProvider(
                  create: (_) => getIt<SettingsViewModel>()..load(),
                  child: const SettingsView(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      unawaited(
        appLogError(
          'router',
          'Route error',
          error: state.error,
          data: {'uri': state.uri.toString()},
        ),
      );
      return Scaffold(
        body: Center(child: Text('Route not found: ${state.uri}')),
      );
    },
  );
}
