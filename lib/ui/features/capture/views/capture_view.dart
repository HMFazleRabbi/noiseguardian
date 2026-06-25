import 'package:flutter/material.dart';
import 'package:noise_guardian/domain/models/guard_state.dart';
import 'package:noise_guardian/domain/models/noise_class.dart';
import 'package:noise_guardian/l10n/app_localizations.dart';
import 'package:noise_guardian/ui/features/capture/view_models/capture_view_model.dart';
import 'package:provider/provider.dart';

class CaptureView extends StatefulWidget {
  const CaptureView({super.key});

  @override
  State<CaptureView> createState() => _CaptureViewState();
}

class _CaptureViewState extends State<CaptureView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CaptureViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<CaptureViewModel>();

    return SafeArea(
      key: const ValueKey('capture_view'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.captureTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            _GuardBanner(state: vm.guardState, l10n: l10n),
            const SizedBox(height: 16),
            if (vm.isRecording)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Recording…'),
                  ],
                ),
              ),
            if (vm.lastLaeq != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    l10n.captureLaeq(vm.lastLaeq!.toStringAsFixed(1)),
                  ),
                ),
              ),
            if (vm.lastResult != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.captureClassLabel(vm.lastResult!.label.displayName),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        l10n.captureConfidence(
                          (vm.lastResult!.confidence * 100).toStringAsFixed(0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (vm.errorMessage != null)
              Text(
                vm.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const Spacer(),
            FilledButton(
              key: const ValueKey('capture_record_button'),
              onPressed: vm.canRecord ? () => vm.record() : null,
              child: Text(l10n.captureRecord),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuardBanner extends StatelessWidget {
  const _GuardBanner({required this.state, required this.l10n});

  final GuardState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (color, message) = switch (state) {
      GuardState.ok => (
          Theme.of(context).colorScheme.primaryContainer,
          l10n.guardOk,
        ),
      GuardState.muffled => (
          Theme.of(context).colorScheme.errorContainer,
          l10n.guardMuffled,
        ),
      GuardState.pocketed => (
          Theme.of(context).colorScheme.errorContainer,
          l10n.guardPocketed,
        ),
      GuardState.obscured => (
          Theme.of(context).colorScheme.errorContainer,
          l10n.guardObscured,
        ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(message),
      ),
    );
  }
}
