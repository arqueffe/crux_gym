import 'package:flutter/material.dart';
import '../models/profile_models.dart';

class GradeStatisticsChart extends StatelessWidget {
  final List<GradeStatistics> gradeStats;

  const GradeStatisticsChart({
    super.key,
    required this.gradeStats,
  });

  @override
  Widget build(BuildContext context) {
    if (gradeStats.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No grade data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final maxTicks = gradeStats
        .map((stat) => stat.tickCount)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendItem(context, 'Completed', Colors.blue),
            _buildLegendItem(context, 'Flashed', Colors.orange),
            _buildLegendItem(context, 'Flash Rate', Colors.green),
          ],
        ),
        const SizedBox(height: 16),

        // Chart
        SizedBox(
          height: 320, // Increased from 300 to 320
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: gradeStats
                  .map((stat) => _buildGradeBar(context, stat, maxTicks))
                  .toList(),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Summary table
        _buildSummaryTable(context),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildGradeBar(
      BuildContext context, GradeStatistics stat, int maxTicks) {
    // Calculate available height for the bar (total - other elements)
    const totalHeight = 280.0;
    const indicatorHeight = 16.0;
    const spacingHeight = 4.0; // 3 SizedBox widgets
    const textHeight =
        26.0; // Even more conservative estimate for 2 text widgets
    const availableBarHeight = totalHeight -
        indicatorHeight -
        spacingHeight -
        textHeight -
        12; // Extra padding to prevent overflow

    final barHeight =
        maxTicks > 0 ? (stat.tickCount / maxTicks) * availableBarHeight : 0.0;
    final flashHeight = barHeight * stat.flashRate;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        height: totalHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Flash rate indicator
            Container(
              width: 40,
              height: indicatorHeight,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${(stat.flashRate * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),

            // Bar chart container with fixed height
            Container(
              width: 40,
              height: availableBarHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: GestureDetector(
                onTap: () => _showGradeDetails(context, stat),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Total bar (blue)
                    Container(
                      width: double.infinity,
                      height: barHeight - 2,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Stack(
                        children: [
                          // Flash overlay (orange)
                          Container(
                            width: double.infinity,
                            height: flashHeight,
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Tick count
            Text(
              '${stat.tickCount}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Grade label
            Text(
              stat.grade,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _getGradeColor(stat.grade),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTable(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                columns: const [
                  DataColumn(label: Text('Grade')),
                  DataColumn(label: Text('Completed')),
                  DataColumn(label: Text('Flashes')),
                  DataColumn(label: Text('Avg. Attempts')),
                  DataColumn(label: Text('Flash Rate')),
                ],
                rows: gradeStats
                    .map((stat) => DataRow(
                          cells: [
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getGradeColor(stat.grade),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  stat.grade,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text('${stat.tickCount}')),
                            DataCell(Text('${stat.flashCount}')),
                            DataCell(
                                Text(stat.averageAttempts.toStringAsFixed(1))),
                            DataCell(Text(
                                '${(stat.flashRate * 100).toStringAsFixed(1)}%')),
                          ],
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGradeDetails(BuildContext context, GradeStatistics stat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${stat.grade} Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Routes Completed:', '${stat.tickCount}'),
            _buildDetailRow('Total Attempts:', '${stat.totalAttempts}'),
            _buildDetailRow('Flashes:', '${stat.flashCount}'),
            _buildDetailRow(
                'Average Attempts:', stat.averageAttempts.toStringAsFixed(1)),
            _buildDetailRow(
                'Flash Rate:', '${(stat.flashRate * 100).toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(String grade) {
    // Simple color coding based on grade difficulty
    if (grade.contains('V0') || grade.contains('V1')) return Colors.green;
    if (grade.contains('V2') || grade.contains('V3'))
      return Colors.yellow.shade700;
    if (grade.contains('V4') || grade.contains('V5')) return Colors.orange;
    if (grade.contains('V6') || grade.contains('V7')) return Colors.red;
    return Colors.purple;
  }
}
