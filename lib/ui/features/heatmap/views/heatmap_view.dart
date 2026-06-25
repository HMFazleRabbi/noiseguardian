import 'package:flutter/material.dart';
import 'package:noise_guardian/l10n/app_localizations.dart';
import 'package:noise_guardian/ui/core/widgets/logged_stateful_widget.dart';
import 'package:noise_guardian/ui/features/heatmap/view_models/heatmap_view_model.dart';
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
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(HeatmapViewModel vm) {
    if (vm.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null) {
      return Center(child: Text(vm.errorMessage!));
    }
    if (vm.cells.isEmpty) {
      return const Center(child: Text('No synced evidence for heatmap yet.'));
    }

    return GridView.builder(
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
                Text('n=${cell.count}'),
                Text('avg ${cell.avgLaeqDb.toStringAsFixed(1)} dB'),
                Text('max ${cell.maxLaeqDb.toStringAsFixed(1)} dB'),
                Text('violations ${cell.violationCount}'),
              ],
            ),
          ),
        );
      },
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
