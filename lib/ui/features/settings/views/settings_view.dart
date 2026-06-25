import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noise_guardian/core/logging/app_log.dart';
import 'package:noise_guardian/data/services/debug_log_service.dart';
import 'package:noise_guardian/di/service_locator.dart';
import 'package:noise_guardian/l10n/app_localizations.dart';
import 'package:noise_guardian/ui/features/calibration/view_models/calibration_view_model.dart';
import 'package:noise_guardian/ui/features/calibration/views/calibration_wizard_view.dart';
import 'package:provider/provider.dart';
import 'package:noise_guardian/ui/core/widgets/logged_stateful_widget.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> with LoggedScreenState {
  final List<String> _lines = [];
  StreamSubscription<String>? _subscription;
  late final DebugLogService _logger;

  @override
  void initState() {
    super.initState();
    _logger = getIt.isRegistered<DebugLogService>()
        ? getIt<DebugLogService>()
        : NoopDebugLogService();
    unawaited(_loadInitialTail());
    _subscription = _logger.lineStream.listen(_appendLine);
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  Future<void> _loadInitialTail() async {
    final tail = await _logger.readTail(lines: 200);
    if (!mounted) {
      return;
    }
    setState(() {
      _lines
        ..clear()
        ..addAll(tail);
    });
  }

  void _appendLine(String line) {
    if (!mounted) {
      return;
    }
    setState(() {
      _lines.add(line);
      if (_lines.length > 300) {
        _lines.removeRange(0, _lines.length - 300);
      }
    });
  }

  Future<void> _copyLogPath() async {
    final path = _logger.logFilePath;
    if (path == null) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: path));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Log file path copied')),
    );
    await appLogInfo('settings', 'Log path copied to clipboard', data: {'path': path});
  }

  Future<void> _clearLog() async {
    await _logger.clear();
    if (!mounted) {
      return;
    }
    setState(_lines.clear);
    await appLogInfo('settings', 'Debug log cleared by user');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final logPath = _logger.logFilePath ?? 'Log file not initialized';

    return SafeArea(
      key: const ValueKey('settings_view'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.settingsTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => ChangeNotifierProvider(
                      create: (_) => CalibrationViewModel(),
                      child: const CalibrationWizardView(),
                    ),
                  ),
                );
              },
              child: Text(l10n.calibrationOpen),
            ),
            const SizedBox(height: 16),
            Text('Debug log (live)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SelectableText(
              logPath,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                FilledButton.tonal(
                  onPressed: _copyLogPath,
                  child: const Text('Copy path'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _clearLog,
                  child: const Text('Clear log'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => unawaited(_loadInitialTail()),
                  child: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: _lines.isEmpty
                    ? const Center(child: Text('No log lines yet'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _lines.length,
                        itemBuilder: (context, index) {
                          return Text(
                            _lines[index],
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
