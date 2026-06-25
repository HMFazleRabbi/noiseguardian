import 'dart:async';

import 'package:flutter/material.dart';
import 'package:noise_guardian/core/logging/app_log.dart';
import 'package:noise_guardian/ui/core/strings.dart';
import 'package:go_router/go_router.dart';
import 'package:noise_guardian/router/app_routes.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  static const _branchRoutes = [
    AppRoutes.capture,
    AppRoutes.reports,
    AppRoutes.settings,
  ];

  void _goBranch(int index) {
    unawaited(
      appLogInfo(
        'navigation',
        'Bottom nav tab selected',
        data: {
          'fromIndex': navigationShell.currentIndex,
          'toIndex': index,
          'route': _branchRoutes[index],
        },
      ),
    );

    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    unawaited(
      appLogDebug(
        'ui',
        'ScaffoldWithNavBar.build()',
        data: {'selectedIndex': navigationShell.currentIndex},
      ),
    );

    return Scaffold(
      body: SafeArea(child: navigationShell),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: const [
          NavigationDestination(
            key: ValueKey('nav_capture'),
            icon: Icon(Icons.mic),
            label: AppStrings.navCapture,
          ),
          NavigationDestination(
            key: ValueKey('nav_reports'),
            icon: Icon(Icons.description_outlined),
            label: AppStrings.navReports,
          ),
          NavigationDestination(
            key: ValueKey('nav_settings'),
            icon: Icon(Icons.settings),
            label: AppStrings.navSettings,
          ),
        ],
      ),
    );
  }
}
