import 'package:climbing_gym_app/widgets/grade_chip.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profile_models.dart';
import '../providers/route_provider.dart';
import '../generated/l10n/app_localizations.dart';

class GradeStatisticsChart extends StatelessWidget {
  final List<GradeStatistics> gradeStats;

  const GradeStatisticsChart({
    super.key,
    required this.gradeStats,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final routeProvider = context.read<RouteProvider>();

    if (gradeStats.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l10n.noGradeData,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Legend
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildLegendItem(context, l10n.lead, Colors.blue),
            _buildLegendItem(context, l10n.flashed, Colors.orange),
            _buildLegendItem(context, l10n.flashRate, Colors.green),
          ],
        ),
        const SizedBox(height: 16),

        // Chart
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 420;
            final chartHeight = isCompact ? 260.0 : 320.0;
            final itemWidth = isCompact ? 56.0 : 64.0;
            final barWidth = isCompact ? 30.0 : 40.0;
            final maxLeadSends = gradeStats.fold<int>(
              0,
              (maxValue, stat) => stat.leadAttemptedRoutes > maxValue
                  ? stat.leadAttemptedRoutes
                  : maxValue,
            );

            return SizedBox(
              height: chartHeight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: gradeStats
                        .map(
                          (stat) => _buildGradeBar(
                            context,
                            stat,
                            maxLeadSends,
                            l10n,
                            routeProvider,
                            totalHeight: chartHeight,
                            itemWidth: itemWidth,
                            barWidth: barWidth,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Summary table
        _buildSummaryTable(context, l10n, routeProvider),
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

  Widget _buildGradeBar(BuildContext context, GradeStatistics stat,
      int maxTicks, AppLocalizations l10n, RouteProvider routeProvider,
      {required double totalHeight,
      required double itemWidth,
      required double barWidth}) {
    const indicatorHeight = 16.0;
    const verticalSpacing = 18.0;
    const countLabelHeight = 14.0;
    const gradeChipHeight = 28.0;
    final availableBarHeight = totalHeight -
        indicatorHeight -
        verticalSpacing -
        countLabelHeight -
        gradeChipHeight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: itemWidth,
        height: totalHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Flash rate indicator
            Container(
              width: barWidth,
              height: indicatorHeight,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  stat.flashRate == null
                      ? '-'
                      : stat.flashRate!.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),

            SizedBox(
              height: availableBarHeight > 0 ? availableBarHeight : 0,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final currentBarAreaHeight = constraints.maxHeight;
                  final barHeight = maxTicks > 0
                      ? (stat.leadAttemptedRoutes / maxTicks) *
                          currentBarAreaHeight
                      : 0.0;
                  final clampedBarHeight =
                      barHeight.clamp(0.0, currentBarAreaHeight);
                  final flashHeight =
                      (clampedBarHeight * stat.flashShareOnLeadAttempts)
                          .clamp(0.0, clampedBarHeight);

                  return Container(
                    width: barWidth,
                    height: currentBarAreaHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: GestureDetector(
                      onTap: () => _showGradeDetails(context, stat, l10n),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            width: double.infinity,
                            height: clampedBarHeight,
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: flashHeight,
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Tick count
            Text(
              '${stat.leadAttemptedRoutes}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Grade label
            GradeChip(
                grade: stat.grade,
                gradeColorHex: routeProvider.getGradeColor(stat.grade)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTable(BuildContext context, AppLocalizations l10n,
      RouteProvider routeProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.detailedStatistics,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                columns: [
                  DataColumn(label: Text(l10n.grade)),
                  DataColumn(label: Text(l10n.lead)),
                  DataColumn(label: Text(l10n.flashes)),
                  DataColumn(label: Text(l10n.leadAverageAttempts)),
                  DataColumn(label: Text(l10n.flashRate)),
                ],
                rows: gradeStats
                    .map((stat) => DataRow(
                          cells: [
                            DataCell(
                              GradeChip(
                                grade: stat.grade,
                                gradeColorHex:
                                    routeProvider.getGradeColor(stat.grade),
                              ),
                            ),
                            DataCell(Text('${stat.leadAttemptedRoutes}')),
                            DataCell(Text('${stat.flashCount}')),
                            DataCell(
                                Text(stat.averageAttempts.toStringAsFixed(1))),
                            DataCell(Text(
                              stat.flashRate == null
                                  ? '-'
                                  : stat.flashRate!.toStringAsFixed(2),
                            )),
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

  void _showGradeDetails(
      BuildContext context, GradeStatistics stat, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.gradeStatistics(stat.grade)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(l10n.lead, '${stat.leadAttemptedRoutes}'),
            _buildDetailRow(l10n.totalAttemptsColon,
                '${stat.leadAttempts + stat.topRopeAttempts}'),
            _buildDetailRow(l10n.flashes, '${stat.flashCount}'),
            _buildDetailRow(l10n.leadAverageAttempts,
                stat.averageAttempts.toStringAsFixed(1)),
            _buildDetailRow(
              l10n.flashRate,
              stat.flashRate == null ? '-' : stat.flashRate!.toStringAsFixed(2),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
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
}
