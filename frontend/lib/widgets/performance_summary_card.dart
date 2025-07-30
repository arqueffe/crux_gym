import 'package:flutter/material.dart';
import '../models/profile_models.dart';

class PerformanceSummaryCard extends StatelessWidget {
  final ProfileStats? stats;
  final List<UserTick> filteredTicks;
  final ProfileTimeFilter timeFilter;

  const PerformanceSummaryCard({
    super.key,
    required this.stats,
    required this.filteredTicks,
    required this.timeFilter,
  });

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No performance data available'),
          ),
        ),
      );
    }

    final filteredFlashes = filteredTicks.where((tick) => tick.flash).length;
    final filteredTotalAttempts =
        filteredTicks.fold<int>(0, (sum, tick) => sum + tick.attempts);
    final filteredAverageAttempts = filteredTicks.isNotEmpty
        ? filteredTotalAttempts / filteredTicks.length
        : 0.0;
    final filteredFlashRate =
        filteredTicks.isNotEmpty ? filteredFlashes / filteredTicks.length : 0.0;

    // Get hardest grade from filtered ticks
    String? filteredHardestGrade;
    if (filteredTicks.isNotEmpty) {
      final grades =
          filteredTicks.map((tick) => tick.routeGrade).toSet().toList();
      grades.sort((a, b) => _gradeOrder(b).compareTo(_gradeOrder(a)));
      filteredHardestGrade = grades.first;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Performance Summary',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    timeFilter.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Statistics Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatCard(
                  context,
                  'Routes Completed',
                  '${filteredTicks.length}',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  context,
                  'Flash Rate',
                  '${(filteredFlashRate * 100).toStringAsFixed(1)}%',
                  Icons.flash_on,
                  Colors.orange,
                ),
                _buildStatCard(
                  context,
                  'Avg. Attempts',
                  filteredAverageAttempts.toStringAsFixed(1),
                  Icons.repeat,
                  Colors.blue,
                ),
                _buildStatCard(
                  context,
                  'Hardest Grade',
                  filteredHardestGrade ?? stats!.hardestGrade ?? 'N/A',
                  Icons.emoji_events,
                  Colors.purple,
                ),
              ],
            ),

            if (timeFilter == ProfileTimeFilter.all) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // All-time stats
              Text(
                'All-Time Stats',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      context,
                      'Total Likes Given',
                      '${stats!.totalLikes}',
                      Icons.favorite,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoRow(
                      context,
                      'Comments Posted',
                      '${stats!.totalComments}',
                      Icons.comment,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      context,
                      'Wall Sections Climbed',
                      '${stats!.uniqueWallSections}',
                      Icons.location_on,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoRow(
                      context,
                      'Grades Achieved',
                      '${stats!.achievedGrades.length}',
                      Icons.grade,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  int _gradeOrder(String grade) {
    // Simple V-scale ordering
    if (grade.startsWith('V')) {
      final number = int.tryParse(grade.substring(1));
      return number ?? 0;
    }
    return 0;
  }
}
