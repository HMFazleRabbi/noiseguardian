import 'dart:async';

import 'package:flutter/material.dart';
import 'package:noise_guardian/core/logging/app_log.dart';

class DebugLogNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    unawaited(
      appLogInfo(
        'navigation',
        'Route pushed',
        data: {
          'route': route.settings.name ?? route.runtimeType.toString(),
          'previous': previousRoute?.settings.name,
        },
      ),
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    unawaited(
      appLogInfo(
        'navigation',
        'Route popped',
        data: {
          'route': route.settings.name ?? route.runtimeType.toString(),
          'previous': previousRoute?.settings.name,
        },
      ),
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    unawaited(
      appLogInfo(
        'navigation',
        'Route replaced',
        data: {
          'newRoute': newRoute?.settings.name,
          'oldRoute': oldRoute?.settings.name,
        },
      ),
    );
  }
}
