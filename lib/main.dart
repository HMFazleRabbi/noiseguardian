import 'dart:async';

import 'package:flutter/material.dart';
import 'package:noise_guardian/app.dart';
import 'package:noise_guardian/core/logging/app_log.dart';
import 'package:noise_guardian/data/services/debug_log_service.dart';
import 'package:noise_guardian/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final debugLog = FileDebugLogService();
  configureDependencies(debugLogService: debugLog);

  final logger = getIt<DebugLogService>();
  await logger.init();
  installGlobalErrorLogging(logger);

  await appLogInfo(
    'bootstrap',
    'Application main() started',
    data: {
      'stage': 'Stage 1 Foundation',
      'loggerPath': logger.logFilePath,
    },
  );

  runApp(NoiseGuardianApp());

  await appLogInfo('bootstrap', 'runApp() invoked');
}
