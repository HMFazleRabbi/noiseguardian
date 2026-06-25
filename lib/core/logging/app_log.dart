import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:noise_guardian/data/services/debug_log_service.dart';
import 'package:noise_guardian/di/service_locator.dart';

DebugLogService? get _logger =>
    getIt.isRegistered<DebugLogService>() ? getIt<DebugLogService>() : null;

Future<void> _consoleFallback(String message) {
  debugPrint(message);
  return Future<void>.value();
}

Future<void> appLogDebug(
  String category,
  String message, {
  Map<String, Object?>? data,
}) {
  final logger = _logger;
  if (logger != null) {
    return logger.debug(category, message, data: data);
  }
  return _consoleFallback('[DEBUG] [$category] $message');
}

Future<void> appLogInfo(
  String category,
  String message, {
  Map<String, Object?>? data,
}) {
  final logger = _logger;
  if (logger != null) {
    return logger.info(category, message, data: data);
  }
  return _consoleFallback('[INFO] [$category] $message');
}

Future<void> appLogWarn(
  String category,
  String message, {
  Object? error,
  StackTrace? stackTrace,
  Map<String, Object?>? data,
}) {
  final logger = _logger;
  if (logger != null) {
    return logger.warn(
      category,
      message,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }
  return _consoleFallback('[WARN] [$category] $message');
}

Future<void> appLogError(
  String category,
  String message, {
  Object? error,
  StackTrace? stackTrace,
  Map<String, Object?>? data,
}) {
  final logger = _logger;
  if (logger != null) {
    return logger.error(
      category,
      message,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }
  return _consoleFallback('[ERROR] [$category] $message');
}

void installGlobalErrorLogging(DebugLogService logger) {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    unawaited(
      logger.error(
        'flutter',
        'Flutter framework error',
        error: details.exception,
        stackTrace: details.stack,
        data: {
          'library': details.library ?? 'unknown',
          'context': details.context?.toDescription(),
        },
      ),
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(
      logger.error(
        'platform',
        'Uncaught platform error',
        error: error,
        stackTrace: stack,
      ),
    );
    return true;
  };
}
