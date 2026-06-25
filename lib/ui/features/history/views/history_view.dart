import 'package:flutter/material.dart';
import 'package:noise_guardian/domain/models/queue_status.dart';
import 'package:noise_guardian/l10n/app_localizations.dart';
import 'package:noise_guardian/ui/core/widgets/logged_stateful_widget.dart';
import 'package:noise_guardian/ui/features/history/view_models/history_view_model.dart';
import 'package:provider/provider.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> with LoggedScreenState {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<HistoryViewModel>();

    return Scaffold(
      key: const ValueKey('history_view'),
      appBar: AppBar(
        title: Text(l10n.historyTitle),
        actions: [
          TextButton(
            key: const ValueKey('history_sync_button'),
            onPressed: vm.syncing ? null : () => vm.sync(),
            child: vm.syncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Sync'),
          ),
        ],
      ),
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(HistoryViewModel vm) {
    if (vm.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null) {
      return Center(child: Text(vm.errorMessage!));
    }
    if (vm.items.isEmpty) {
      return const Center(child: Text('No evidence queued yet.'));
    }

    return ListView.separated(
      itemCount: vm.items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = vm.items[index];
        return ListTile(
          key: ValueKey('history_item_${item.id}'),
          title: Text(item.packet.metrics.noiseClass),
          subtitle: Text(
            'LAeq ${item.packet.metrics.laeqDb.toStringAsFixed(1)} dB(A)',
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatusChip(status: item.status),
              if (item.receiptId != null)
                Text(
                  item.receiptId!,
                  key: ValueKey('receipt_${item.id}'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final QueueStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      QueueStatus.pending => (Colors.orange, HistoryViewModel.statusLabel(status)),
      QueueStatus.syncing => (Colors.blue, HistoryViewModel.statusLabel(status)),
      QueueStatus.synced => (Colors.green, HistoryViewModel.statusLabel(status)),
      QueueStatus.failed => (Colors.red, HistoryViewModel.statusLabel(status)),
    };

    return Chip(
      key: ValueKey('status_chip_${status.wireName}'),
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.15),
      side: BorderSide(color: color),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
