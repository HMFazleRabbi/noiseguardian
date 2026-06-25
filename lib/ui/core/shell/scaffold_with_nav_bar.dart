import 'dart:async';

import 'package:flutter/material.dart';
import 'package:noise_guardian/core/logging/app_log.dart';
import 'package:noise_guardian/l10n/app_localizations.dart';
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
    AppRoutes.history,
    AppRoutes.heatmap,
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
    final l10n = AppLocalizations.of(context)!;

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
        destinations: [
          NavigationDestination(
            key: const ValueKey('nav_capture'),
            icon: const Icon(Icons.mic),
            label: l10n.navCapture,
          ),
          NavigationDestination(
            key: const ValueKey('nav_history'),
            icon: const Icon(Icons.history),
            label: l10n.navHistory,
          ),
          NavigationDestination(
            key: const ValueKey('nav_heatmap'),
            icon: const Icon(Icons.map),
            label: l10n.navHeatmap,
          ),
          NavigationDestination(
            key: const ValueKey('nav_settings'),
            icon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
