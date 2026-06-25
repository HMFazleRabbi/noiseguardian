import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noise_guardian/core/logging/app_log.dart';
import 'package:noise_guardian/data/services/debug_log_service.dart';
import 'package:noise_guardian/di/service_locator.dart';
import 'package:noise_guardian/ui/core/strings.dart';
import 'package:noise_guardian/ui/features/calibration/view_models/calibration_view_model.dart';
import 'package:noise_guardian/ui/features/calibration/views/calibration_wizard_view.dart';
import 'package:noise_guardian/ui/features/settings/view_models/settings_view_model.dart';
import 'package:printing/printing.dart';
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
      const SnackBar(content: Text(AppStrings.settingsLogPathCopied)),
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

  Future<void> _exportLastPdf(
    BuildContext context,
    SettingsViewModel vm,
  ) async {
    final bytes = await vm.exportLastSyncedPdf();
    if (!context.mounted) {
      return;
    }
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.settingsNoSyncedEvidence)),
      );
      return;
    }
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final logPath = _logger.logFilePath ?? 'Log file not initialized';

    return Material(
      child: SafeArea(
        key: const ValueKey('settings_view'),
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppStrings.settingsTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (vm.loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: LinearProgressIndicator(),
                      )
                    else ...[
                      if (vm.useMockDoe) ...[
                        const SizedBox(height: 12),
                        const ListTile(
                          key: ValueKey('settings_mock_doe_indicator'),
                          leading: Icon(Icons.cloud_off),
                          title: Text(AppStrings.settingsMockDoeStatus),
                          dense: true,
                        ),
                      ],
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        key: const ValueKey('settings_export_pdf_button'),
                        onPressed: () => unawaited(_exportLastPdf(context, vm)),
                        child: const Text(AppStrings.settingsExportLastPdf),
                      ),
                    ],
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
                      child: const Text(AppStrings.calibrationOpen),
                    ),
                    const SizedBox(height: 16),
                    Text(AppStrings.settingsDebugLog, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    SelectableText(
                      logPath,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonal(
                          onPressed: () => unawaited(_copyLogPath()),
                          child: const Text(AppStrings.settingsCopyPath),
                        ),
                        OutlinedButton(
                          onPressed: _clearLog,
                          child: const Text(AppStrings.settingsClearLog),
                        ),
                        OutlinedButton(
                          onPressed: () => unawaited(_loadInitialTail()),
                          child: const Text(AppStrings.settingsRefreshLog),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: _lines.isEmpty
                    ? const Center(child: Text(AppStrings.settingsNoLogLines))
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
      ),
    );
  }
}
