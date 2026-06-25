import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/domain/models/guard_state.dart';
import 'package:noise_guardian/l10n/app_localizations.dart';
import 'package:noise_guardian/ui/features/capture/view_models/capture_view_model.dart';
import 'package:noise_guardian/ui/features/capture/views/capture_view.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_capture_services.dart';

void main() {
  testWidgets('CaptureView shows guard banner and disabled record when muffled', (tester) async {
    final vm = CaptureViewModel(
      sensorGuard: FakeSensorGuardService(initialState: GuardState.muffled),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChangeNotifierProvider.value(
          value: vm,
          child: const CaptureView(),
        ),
      ),
    );
    await vm.initialize();
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('capture_view')), findsOneWidget);
    expect(find.textContaining('muffled'), findsOneWidget);

    final recordButton = find.byKey(const ValueKey('capture_record_button'));
    final button = tester.widget<FilledButton>(recordButton);
    expect(button.onPressed, isNull);
  });
}
