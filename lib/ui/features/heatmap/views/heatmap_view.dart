import 'package:flutter/material.dart';
import 'package:noise_guardian/l10n/app_localizations.dart';
import 'package:noise_guardian/ui/core/widgets/logged_stateful_widget.dart';
import 'package:noise_guardian/ui/features/heatmap/view_models/heatmap_view_model.dart';
import 'package:noise_guardian/ui/features/heatmap/views/heatmap_map_view.dart';
import 'package:provider/provider.dart';

class HeatmapView extends StatefulWidget {
  const HeatmapView({super.key});

  @override
  State<HeatmapView> createState() => _HeatmapViewState();
}

class _HeatmapViewState extends State<HeatmapView> with LoggedScreenState {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HeatmapViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<HeatmapViewModel>();

    return Scaffold(
      key: const ValueKey('heatmap_view'),
      appBar: AppBar(title: Text(l10n.heatmapTitle)),
      body: _buildBody(context, vm, l10n),
    );
  }

  Widget _buildBody(
    BuildContext context,
    HeatmapViewModel vm,
    AppLocalizations l10n,
  ) {
    if (vm.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null) {
      return Center(child: Text(vm.errorMessage!));
    }
    if (vm.cells.isEmpty) {
      return Center(child: Text(l10n.heatmapEmpty));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: HeatmapMapView(cells: vm.cells),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            l10n.heatmapMapLegend,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.4,
            ),
            itemCount: vm.cells.length,
            itemBuilder: (context, index) {
              final cell = vm.cells[index];
              return Card(
                key: ValueKey('heatmap_cell_${cell.cellKey}'),
                color: _pressureColor(cell.avgLaeqDb),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${cell.latObfuscated.toStringAsFixed(2)}, '
                        '${cell.lonObfuscated.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const Spacer(),
                      Text(l10n.heatmapCellCount(cell.count)),
                      Text(l10n.heatmapCellAvg(cell.avgLaeqDb.toStringAsFixed(1))),
                      Text(l10n.heatmapCellMax(cell.maxLaeqDb.toStringAsFixed(1))),
                      Text(l10n.heatmapCellViolations(cell.violationCount)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _pressureColor(double avgLaeq) {
    if (avgLaeq >= 70) {
      return Colors.red.shade200;
    }
    if (avgLaeq >= 60) {
      return Colors.orange.shade200;
    }
    return Colors.green.shade200;
  }
}
