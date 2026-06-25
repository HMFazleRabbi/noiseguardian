import 'dart:async';

import 'package:flutter/material.dart';
import 'package:noise_guardian/data/models/saved_report.dart';
import 'package:noise_guardian/ui/core/strings.dart';
import 'package:noise_guardian/ui/core/widgets/logged_stateful_widget.dart';
import 'package:noise_guardian/ui/features/reports/view_models/reports_view_model.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> with LoggedScreenState {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportsViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReportsViewModel>();

    return Scaffold(
      key: const ValueKey('reports_view'),
      appBar: AppBar(
        title: const Text(AppStrings.reportsTitle),
      ),
      body: _buildBody(context, vm),
    );
  }

  Widget _buildBody(BuildContext context, ReportsViewModel vm) {
    if (vm.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null) {
      return Center(child: Text(vm.errorMessage!));
    }
    if (vm.items.isEmpty) {
      return const Center(child: Text(AppStrings.reportsEmpty));
    }

    return ListView.separated(
      itemCount: vm.items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = vm.items[index];
        return ListTile(
          key: ValueKey('reports_item_${item.id}'),
          title: Text(item.packet.metrics.noiseClass),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.reportsLaeqSubtitle(
                  item.packet.metrics.laeqDb.toStringAsFixed(1),
                ),
              ),
              Text(
                item.packet.metadata.timestampIso,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Wrap(
                spacing: 4,
                runSpacing: 0,
                children: [
                  TextButton(
                    key: ValueKey('reports_export_json_${item.id}'),
                    onPressed: () => unawaited(_shareJson(context, vm, item)),
                    child: const Text(AppStrings.reportsShareJson),
                  ),
                  TextButton(
                    key: ValueKey('reports_export_pdf_${item.id}'),
                    onPressed: () => unawaited(_printPdf(context, vm, item)),
                    child: const Text(AppStrings.reportsExportPdf),
                  ),
                  TextButton(
                    key: ValueKey('reports_share_pdf_${item.id}'),
                    onPressed: () => unawaited(_sharePdf(context, vm, item)),
                    child: const Text(AppStrings.reportsSharePdf),
                  ),
                ],
              ),
            ],
          ),
          isThreeLine: true,
        );
      },
    );
  }

  Future<void> _shareJson(
    BuildContext context,
    ReportsViewModel vm,
    SavedReport item,
  ) async {
    await vm.shareJson(item);
  }

  Future<void> _printPdf(
    BuildContext context,
    ReportsViewModel vm,
    SavedReport item,
  ) async {
    final bytes = await vm.exportPdfBytes(item);
    if (!context.mounted) {
      return;
    }
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  Future<void> _sharePdf(
    BuildContext context,
    ReportsViewModel vm,
    SavedReport item,
  ) async {
    await vm.sharePdf(item);
  }
}
