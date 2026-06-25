import 'dart:async';

import 'package:flutter/material.dart';
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

    return MaterialApp.router(
      title: 'NoiseGuardian',
      theme: buildAppTheme(),
      darkTheme: buildDarkAppTheme(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
