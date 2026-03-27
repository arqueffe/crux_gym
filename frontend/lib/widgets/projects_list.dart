import 'package:flutter/material.dart';
import '../generated/l10n/app_localizations.dart';
import '../models/route_models.dart';
import '../screens/route_detail_screen.dart';
import '../utils/date_formatting.dart';
import '../widgets/grade_chip.dart';

class ProjectsList extends StatelessWidget {
  final List<Project> projects;
  final Map<String, String>? gradeColors;
  final VoidCallback? onRouteSelected;
  final String Function(int routeId, String routeName)? resolveRouteName;

  const ProjectsList({
    super.key,
    required this.projects,
    this.gradeColors,
    this.onRouteSelected,
    this.resolveRouteName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        final rawRouteName = project.routeName;
        final displayRouteName = rawRouteName != null
            ? (resolveRouteName?.call(project.routeId, rawRouteName) ??
                rawRouteName)
            : null;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RouteDetailScreen(
                    routeId: project.routeId,
                  ),
                ),
              );
              // Call the callback when returning from route detail
              onRouteSelected?.call();
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Flag icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.flag,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Route info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayRouteName ?? l10n.unknownRoute,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (project.routeGrade != null) ...[
                              GradeChip(
                                grade: project.routeGrade!,
                                gradeColorHex:
                                    gradeColors?[project.routeGrade!],
                                fontSize: 12,
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (project.routeWallSection != null)
                              Text(
                                project.routeWallSection!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                          ],
                        ),
                        if (project.notes != null &&
                            project.notes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.notes,
                                  size: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    project.notes!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          '${l10n.added} ${formatRelativeDate(project.createdAt, l10n, includeMonths: true)}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
