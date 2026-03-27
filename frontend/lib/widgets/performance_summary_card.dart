import 'package:flutter/material.dart';
import '../generated/l10n/app_localizations.dart';
import '../models/profile_models.dart';
import '../models/route_models.dart';

class PerformanceSummaryCard extends StatelessWidget {
  final ProfileStats? stats;
  final List<UserTick> filteredTicks;
  final List<Project> filteredProjects;
  final ProfileTimeFilter timeFilter;
  final String? filteredHardestGrade;

  const PerformanceSummaryCard({
    super.key,
    required this.stats,
    required this.filteredTicks,
    required this.filteredProjects,
    required this.timeFilter,
    required this.filteredHardestGrade,
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

    final filteredLeadFlashes =
        filteredTicks.where((tick) => tick.isLeadFlash).length;
    final filteredLeadAttemptedRoutes = filteredTicks
        .where((tick) => tick.leadAttempts > 0 || tick.leadSend)
        .length;
    final filteredTopRopeSends =
        filteredTicks.where((tick) => tick.topRopeSend).length;
    final filteredLeadSends =
        filteredTicks.where((tick) => tick.leadSend).length;

    // Average attempts are computed from ticks where the style was actually sent.
    final filteredTopRopeAttempts = filteredTicks
        .where((tick) => tick.topRopeSend)
        .fold<int>(0, (sum, tick) => sum + tick.topRopeAttempts);
    final filteredLeadAttempts = filteredTicks
        .where((tick) => tick.leadSend)
        .fold<int>(0, (sum, tick) => sum + tick.leadAttempts);
    final filteredTopRopeAverageAttempts = filteredTopRopeSends > 0
        ? filteredTopRopeAttempts / filteredTopRopeSends
        : 0.0;
    final filteredLeadAverageAttempts =
        filteredLeadSends > 0 ? filteredLeadAttempts / filteredLeadSends : 0.0;

    final screenWidth = MediaQuery.of(context).size.width;
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
              crossAxisCount: 3,
              childAspectRatio: screenWidth < 600
                  ? 1
                  : ((screenWidth > 1000)
                      ? 4.0
                      : 2.2), // Handle card more responsively
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
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
                  '${filteredProjects.length}',
                  Icons.flag,
                  Colors.blue,
                ),
                _buildStatCard(
                  context,
                  l10n.hardestGrade,
                  filteredHardestGrade ?? stats!.hardestGrade ?? 'N/A',
                  Icons.emoji_events,
                  Colors.purple,
                ),
                _buildStatCard(
                  context,
                  l10n.trAverageAttempts,
                  filteredTopRopeAverageAttempts.toStringAsFixed(1),
                  Icons.arrow_upward,
                  Colors.blue,
                  infoDescription: l10n.trAverageAttemptsInfoDescription,
                ),
                _buildStatCard(
                  context,
                  l10n.leadAverageAttempts,
                  filteredLeadAverageAttempts.toStringAsFixed(1),
                  Icons.trending_up,
                  Colors.green,
                  infoDescription: l10n.leadAverageAttemptsInfoDescription,
                ),
                _buildSendTypeCard(
                  context,
                  l10n.leadFlash,
                  filteredLeadFlashes,
                  filteredLeadAttemptedRoutes,
                  Icons.trending_up,
                  Colors.green,
                  infoDescription: l10n.flashRateInfoDescription,
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
    Color color, {
    String? infoDescription,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
              if (infoDescription != null)
                Tooltip(
                  message: AppLocalizations.of(context).profileDataInfoTooltip,
                  child: InkWell(
                    onTap: () => _showInfoDialog(
                      context,
                      title,
                      infoDescription,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
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

  Widget _buildSendTypeCard(
    BuildContext context,
    String title,
    int numerator,
    int denominator,
    IconData icon,
    Color color, {
    String? infoDescription,
  }) {
    final ratio = denominator > 0 ? (numerator / denominator) : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (infoDescription != null)
                Tooltip(
                  message: AppLocalizations.of(context).profileDataInfoTooltip,
                  child: InkWell(
                    onTap: () => _showInfoDialog(
                      context,
                      title,
                      infoDescription,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.info_outline,
                        size: 14,
                        color: color,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$numerator / $denominator',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            ratio == null ? '-' : ratio.toStringAsFixed(2),
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

  void _showInfoDialog(BuildContext context, String title, String description) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );
  }
}
