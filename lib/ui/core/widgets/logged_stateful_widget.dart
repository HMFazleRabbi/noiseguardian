import 'dart:async';

import 'package:flutter/material.dart';
import 'package:noise_guardian/core/logging/app_log.dart';

/// Logs [initState] and [dispose] for screen-level diagnostics.
mixin LoggedScreenState<T extends StatefulWidget> on State<T> {
  String get logScreenName => T.toString();

  @override
  void initState() {
    super.initState();
    unawaited(
      appLogInfo('ui', '$logScreenName initState', data: {'widget': logScreenName}),
    );
  }

  @override
  void dispose() {
    unawaited(
      appLogInfo('ui', '$logScreenName dispose', data: {'widget': logScreenName}),
    );
    super.dispose();
  }
}
