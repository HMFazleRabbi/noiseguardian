import 'package:flutter/material.dart';
import 'package:noise_guardian/domain/models/heatmap_cell.dart';

/// Dhaka bounding box for offline marker projection (no tile layer).
const double dhakaLatMin = 23.70;
const double dhakaLatMax = 23.95;
const double dhakaLonMin = 90.30;
const double dhakaLonMax = 90.50;

/// Offline heatmap marker map — plots obfuscated cell centres without network.
class HeatmapMapView extends StatelessWidget {
  const HeatmapMapView({
    super.key,
    required this.cells,
    this.height = 200,
  });

  final List<HeatmapCell> cells;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Noise heatmap map',
      child: SizedBox(
        key: const ValueKey('heatmap_map_view'),
        height: height,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomPaint(
              painter: _HeatmapMapPainter(cells: cells),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeatmapMapPainter extends CustomPainter {
  _HeatmapMapPainter({required this.cells});

  final List<HeatmapCell> cells;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFE8F0E8);
    canvas.drawRect(Offset.zero & size, bg);

    final border = Paint()
      ..color = const Color(0xFF607D8B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      border,
    );

    for (final cell in cells) {
      final x = _projectLon(cell.lonObfuscated, size.width);
      final y = _projectLat(cell.latObfuscated, size.height);
      final color = _pressureColor(cell.avgLaeqDb);
      final paint = Paint()..color = color;
      canvas.drawCircle(Offset(x, y), 8 + cell.count.clamp(1, 5).toDouble(), paint);
    }
  }

  double _projectLat(double lat, double height) {
    final t = (dhakaLatMax - lat) / (dhakaLatMax - dhakaLatMin);
    return t.clamp(0.0, 1.0) * (height - 16) + 8;
  }

  double _projectLon(double lon, double width) {
    final t = (lon - dhakaLonMin) / (dhakaLonMax - dhakaLonMin);
    return t.clamp(0.0, 1.0) * (width - 16) + 8;
  }

  Color _pressureColor(double avgLaeq) {
    if (avgLaeq >= 70) {
      return Colors.red.shade700;
    }
    if (avgLaeq >= 60) {
      return Colors.orange.shade700;
    }
    return Colors.green.shade700;
  }

  @override
  bool shouldRepaint(covariant _HeatmapMapPainter oldDelegate) =>
      oldDelegate.cells != cells;
}
