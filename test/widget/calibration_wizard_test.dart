import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/ui/features/calibration/view_models/calibration_view_model.dart';
import 'package:noise_guardian/ui/features/calibration/views/calibration_wizard_view.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_calibration_service.dart';

void main() {
  testWidgets('CalibrationWizardView shows start button on intro step', (tester) async {
    final fake = FakeCalibrationService(correctionFactor: 3.0);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => CalibrationViewModel(calibrationService: fake),
          child: const CalibrationWizardView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('calibration_wizard_view')), findsOneWidget);
    expect(find.text('Start calibration'), findsOneWidget);
    expect(find.textContaining('Current Cd:'), findsOneWidget);
  });
}
