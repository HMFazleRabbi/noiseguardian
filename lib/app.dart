import 'dart:async';

import 'package:flutter/material.dart';
import 'package:noise_guardian/core/locale/app_locale_notifier.dart';
import 'package:noise_guardian/di/service_locator.dart';
import 'package:noise_guardian/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:noise_guardian/core/logging/app_log.dart';
import 'package:noise_guardian/router/app_router.dart';
import 'package:noise_guardian/ui/core/theme/app_theme.dart';

class NoiseGuardianApp extends StatelessWidget {
  NoiseGuardianApp({super.key, GoRouter? router})
      : router = router ?? createAppRouter();

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    unawaited(
      appLogDebug(
        'app',
        'NoiseGuardianApp.build()',
        data: {'routerHash': router.hashCode},
      ),
    );

    final localeNotifier = getIt.isRegistered<AppLocaleNotifier>()
        ? getIt<AppLocaleNotifier>()
        : null;

    return ListenableBuilder(
      listenable: localeNotifier ?? const _NullListenable(),
      builder: (context, _) {
        return MaterialApp.router(
          title: 'NoiseGuardian',
          theme: buildAppTheme(),
          darkTheme: buildDarkAppTheme(),
          locale: localeNotifier?.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        );
      },
    );
  }
}

class _NullListenable implements Listenable {
  const _NullListenable();

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}
