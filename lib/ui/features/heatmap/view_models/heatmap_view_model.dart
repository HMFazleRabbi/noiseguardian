import 'package:flutter/foundation.dart';
import 'package:noise_guardian/data/repositories/evidence_queue_repository.dart';
import 'package:noise_guardian/data/services/heatmap_aggregation_service.dart';
import 'package:noise_guardian/domain/models/heatmap_cell.dart';

class HeatmapViewModel extends ChangeNotifier {
  HeatmapViewModel({
    required EvidenceQueueRepository queue,
    HeatmapAggregationService? aggregation,
  })  : _queue = queue,
        _aggregation = aggregation ?? const HeatmapAggregationService();

  final EvidenceQueueRepository _queue;
  final HeatmapAggregationService _aggregation;

  List<HeatmapCell> _cells = [];
  bool _loading = false;
  String? _errorMessage;

  List<HeatmapCell> get cells => List.unmodifiable(_cells);
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final syncedPackets = await _queue.syncedPackets();
      _cells = _aggregation.aggregate(syncedPackets);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
