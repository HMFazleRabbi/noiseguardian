import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noise_guardian/domain/models/guard_state.dart';
import 'package:noise_guardian/l10n/app_localizations.dart';
import 'package:noise_guardian/ui/features/capture/view_models/capture_view_model.dart';
import 'package:noise_guardian/ui/features/capture/views/capture_view.dart';
import 'package:provider/provider.dart';

import '../fakes/fake_capture_services.dart';

void main() {
  testWidgets('CaptureView shows advisory banner when unsteady but record stays enabled', (tester) async {
    final vm = CaptureViewModel(
      sensorGuard: FakeSensorGuardService(initialState: GuardState.unsteady),
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
    expect(find.textContaining('hold steady'), findsOneWidget);

    final recordButton = find.byKey(const ValueKey('capture_record_button'));
    final button = tester.widget<FilledButton>(recordButton);
    expect(button.onPressed, isNotNull);
  });

  testWidgets('record button meets 48dp minimum touch target', (tester) async {
    final vm = CaptureViewModel(
      sensorGuard: FakeSensorGuardService(),
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

    final size = tester.getSize(find.byKey(const ValueKey('capture_record_button')));
    expect(size.height, greaterThanOrEqualTo(48));
    expect(size.width, greaterThanOrEqualTo(48));
  });
}
