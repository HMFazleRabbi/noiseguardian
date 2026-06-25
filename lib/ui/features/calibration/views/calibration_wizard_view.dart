import 'package:flutter/material.dart';
import 'package:noise_guardian/ui/core/strings.dart';
import 'package:noise_guardian/ui/features/calibration/view_models/calibration_view_model.dart';
import 'package:provider/provider.dart';

class CalibrationWizardView extends StatefulWidget {
  const CalibrationWizardView({super.key});

  @override
  State<CalibrationWizardView> createState() => _CalibrationWizardViewState();
}

class _CalibrationWizardViewState extends State<CalibrationWizardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalibrationViewModel>().loadExisting();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CalibrationViewModel>();

    return SafeArea(
      key: const ValueKey('calibration_wizard_view'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.calibrationTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            if (viewModel.savedCd != null && viewModel.step != CalibrationWizardStep.result)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    AppStrings.calibrationCurrentCd(
                      viewModel.savedCd!.toStringAsFixed(2),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Expanded(child: _buildStep(context, viewModel)),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(
    BuildContext context,
    CalibrationViewModel viewModel,
  ) {
    switch (viewModel.step) {
      case CalibrationWizardStep.intro:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(AppStrings.calibrationIntro),
              const SizedBox(height: 24),
              if (viewModel.errorMessage != null) ...[
                Text(
                  viewModel.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 8),
              ],
              FilledButton(
                onPressed: viewModel.busy ? null : viewModel.startCalibration,
                child: const Text(AppStrings.calibrationStart),
              ),
            ],
          ),
        );
      case CalibrationWizardStep.playing:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Playing reference pink noise…'),
            ],
          ),
        );
      case CalibrationWizardStep.result:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.calibrationSuccess(viewModel.savedCd!.toStringAsFixed(2)),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.calibrationDone),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: viewModel.reset,
              child: const Text(AppStrings.calibrationRetry),
            ),
          ],
        );
    }
  }
}
