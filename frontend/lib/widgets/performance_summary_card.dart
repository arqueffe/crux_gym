import 'package:flutter/material.dart';
import '../generated/l10n/app_localizations.dart';
import '../models/profile_models.dart';

class PerformanceSummaryCard extends StatelessWidget {
  final ProfileStats? stats;
  final List<UserTick> filteredTicks;
  final ProfileTimeFilter timeFilter;
  final List<Map<String, dynamic>> gradeDefinitions;

  const PerformanceSummaryCard({
    super.key,
    required this.stats,
    required this.filteredTicks,
    required this.timeFilter,
    required this.gradeDefinitions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (stats == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(l10n.noPerformanceData),
          ),
        ),
      );
    }

    final filteredFlashes =
        filteredTicks.where((tick) => tick.hasAnyFlash).length;
    final filteredTopRopeFlashes =
        filteredTicks.where((tick) => tick.topRopeFlash).length;
    final filteredLeadFlashes =
        filteredTicks.where((tick) => tick.leadFlash).length;
    final filteredTopRopeSends =
        filteredTicks.where((tick) => tick.topRopeSend).length;
    final filteredLeadSends =
        filteredTicks.where((tick) => tick.leadSend).length;
    final filteredTotalSends =
        filteredTicks.where((tick) => tick.hasAnySend).length;
    final filteredTotalAttempts =
        filteredTicks.fold<int>(0, (sum, tick) => sum + tick.attempts);
    final filteredAverageAttempts = filteredTotalSends > 0
        ? filteredTotalAttempts / filteredTotalSends
        : 0.0;
    final filteredFlashRate =
        filteredTotalSends > 0 ? filteredFlashes / filteredTotalSends : 0.0;

    // Get hardest grade from filtered ticks using proper grade ordering
    String? filteredHardestGrade;
    if (filteredTicks.isNotEmpty) {
      final grades =
          filteredTicks.map((tick) => tick.routeGrade).toSet().toList();

      // Sort using grade definitions if available
      if (gradeDefinitions.isNotEmpty) {
        grades.sort((a, b) {
          final aOrder = _getGradeOrder(a, gradeDefinitions);
          final bOrder = _getGradeOrder(b, gradeDefinitions);
          return bOrder.compareTo(aOrder); // Descending order for hardest first
        });
      } else {
        // Fallback to V-scale ordering
        grades.sort((a, b) => _gradeOrder(b).compareTo(_gradeOrder(a)));
      }
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
                  l10n.performanceSummary,
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
                    _getTimeFilterDisplayName(timeFilter, l10n),
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
              childAspectRatio: 2.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatCard(
                  context,
                  l10n.totalTicks,
                  '${filteredTicks.length}', // Show total ticks, not just sends
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  context,
                  l10n.topRope,
                  '$filteredTopRopeSends',
                  Icons.arrow_upward,
                  Colors.blue,
                ),
                _buildStatCard(
                  context,
                  l10n.lead,
                  '$filteredLeadSends',
                  Icons.trending_up,
                  Colors.green,
                ),
                _buildStatCard(
                  context,
                  l10n.projectsTab,
                  '${stats!.totalProjects}',
                  Icons.flag,
                  Colors.blue,
                ),
                _buildStatCard(
                  context,
                  l10n.flashRate,
                  '${(filteredFlashRate * 100).toStringAsFixed(1)}%',
                  Icons.flash_on,
                  Colors.orange,
                ),
                _buildStatCard(
                  context,
                  l10n.averageAttempts,
                  filteredAverageAttempts.toStringAsFixed(1),
                  Icons.repeat,
                  Colors.blue,
                ),
                _buildStatCard(
                  context,
                  l10n.hardestGrade,
                  filteredHardestGrade ?? stats!.hardestGrade ?? 'N/A',
                  Icons.emoji_events,
                  Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Send Type Breakdown
            Row(
              children: [
                Expanded(
                  child: _buildSendTypeCard(
                    context,
                    l10n.trFlash,
                    filteredTopRopeFlashes,
                    filteredTopRopeSends,
                    Icons.arrow_upward,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSendTypeCard(
                    context,
                    l10n.leadFlash,
                    filteredLeadFlashes,
                    filteredLeadSends,
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
              ],
            ),

            if (timeFilter == ProfileTimeFilter.all) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // All-time stats
              Text(
                l10n.allTimeStats,
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
                      l10n.totalLikesGiven,
                      '${stats!.totalLikes}',
                      Icons.favorite,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoRow(
                      context,
                      l10n.commentsPosted,
                      '${stats!.totalComments}',
                      Icons.comment,
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
    // Return 0 if grade definitions are not loaded yet
    if (gradeDefinitions.isEmpty) return 0;

    // Find the grade in the definitions and return its value (not difficulty_order)
    for (final gradeDefinition in gradeDefinitions) {
      if (gradeDefinition['french_name'] == grade) {
        final value = gradeDefinition['value'];
        if (value is String) {
          return double.tryParse(value)?.toInt() ?? 0;
        } else if (value is num) {
          return value.toInt();
        }
      }
    }
    // Return 0 for unknown grades (will be sorted first)
    return 0;
  }

  int _getGradeOrder(
      String grade, List<Map<String, dynamic>> gradeDefinitions) {
    // Find the grade in the definitions and return its value (not difficulty_order)
    for (final gradeDefinition in gradeDefinitions) {
      if (gradeDefinition['french_name'] == grade) {
        final value = gradeDefinition['value'];
        if (value is String) {
          return double.tryParse(value)?.toInt() ?? 0;
        } else if (value is num) {
          return value.toInt();
        }
      }
    }
    // Return 0 for unknown grades (will be sorted first)
    return 0;
  }

  Widget _buildSendTypeCard(
    BuildContext context,
    String title,
    int flashCount,
    int totalCount,
    IconData icon,
    Color color,
  ) {
    final percentage = totalCount > 0 ? (flashCount / totalCount * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$flashCount / $totalCount',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeFilterDisplayName(
      ProfileTimeFilter filter, AppLocalizations l10n) {
    switch (filter) {
      case ProfileTimeFilter.all:
        return l10n.filterAll;
      case ProfileTimeFilter.lastWeek:
        return l10n.filterThisWeek;
      case ProfileTimeFilter.lastMonth:
        return l10n.filterThisMonth;
      case ProfileTimeFilter.last3Months:
        return l10n.filterLast3Months;
      case ProfileTimeFilter.lastYear:
        return l10n.filterThisYear;
    }
  }
}
