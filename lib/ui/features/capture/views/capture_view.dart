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
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(l10n.captureRecording),
                  ],
                ),
              ),
            if (vm.lastLaeq != null) ...[
              _LaeqMeter(
                laeq: vm.lastLaeq!,
                threshold: vm.zoneThresholdDb,
                l10n: l10n,
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    l10n.captureLaeq(vm.lastLaeq!.toStringAsFixed(1)),
                  ),
                ),
              ),
            ],
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
            Semantics(
              button: true,
              label: l10n.captureRecord,
              enabled: vm.canRecord,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                child: FilledButton(
                  key: const ValueKey('capture_record_button'),
                  onPressed: vm.canRecord ? () => vm.record() : null,
                  child: Text(l10n.captureRecord),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LaeqMeter extends StatelessWidget {
  const _LaeqMeter({
    required this.laeq,
    required this.threshold,
    required this.l10n,
  });

  final double laeq;
  final double threshold;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final color = _meterColor(laeq, threshold);
    final fraction = (laeq / (threshold + 10)).clamp(0.0, 1.0);

    return Semantics(
      label: l10n.captureLaeqMeterLabel,
      value: l10n.captureLaeq(laeq.toStringAsFixed(1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              key: const ValueKey('capture_laeq_meter'),
              value: fraction,
              minHeight: 12,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _meterColor(double laeq, double threshold) {
    if (laeq <= threshold) {
      return Colors.green.shade600;
    }
    if (laeq <= threshold + 5) {
      return Colors.amber.shade700;
    }
    return Colors.red.shade700;
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
      GuardState.unsteady => (
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
