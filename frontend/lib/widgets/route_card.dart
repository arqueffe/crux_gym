import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generated/l10n/app_localizations.dart';
import '../models/route_models.dart' as models;
import '../providers/route_provider.dart';
import '../utils/color_utils.dart';
import '../utils/grade_utils.dart';
import 'grade_chip.dart';

class RouteCard extends StatelessWidget {
  final models.Route route;
  final VoidCallback onTap;

  const RouteCard({
    super.key,
    required this.route,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    print(
        'Rendering RouteCard for route ID: ${route.id}, Name: ${route.name}, Grade: ${route.grade}, Lane: ${route.lane}, Color: ${route.colorHex}, Likes: ${route.likesCount}, Comments: ${route.commentsCount}, Ticks: ${route.ticksCount}, Proposals: ${route.gradeProposalsCount}, Warnings: ${route.warningsCount}');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            GradeChip(
                              grade: route.grade,
                              gradeColorHex: route.gradeColor,
                            ),
                            // Show average proposed grade if there are proposals
                            if (route.gradeProposalsCount > 0) ...[
                              const SizedBox(width: 8),
                              Consumer<RouteProvider>(
                                builder: (context, routeProvider, child) {
                                  final averageGrade =
                                      GradeUtils.calculateAverageProposedGrade(
                                    route.gradeProposals,
                                    routeProvider.gradeDefinitions,
                                  );

                                  if (averageGrade == null) {
                                    return const SizedBox.shrink();
                                  }

                                  final averageGradeColor =
                                      routeProvider.getGradeColor(averageGrade);

                                  return AverageGradeChip(
                                    grade: averageGrade,
                                    gradeColorHex: averageGradeColor,
                                  );
                                },
                              ),
                            ],
                            if (route.color != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color:
                                      ColorUtils.parseHexColor(route.colorHex),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.favorite,
                              color: Colors.red, size: 16),
                          const SizedBox(width: 4),
                          Text('${route.likesCount}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.comment,
                              color: Colors.blue, size: 16),
                          const SizedBox(width: 4),
                          Text('${route.commentsCount}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 16),
                          const SizedBox(width: 4),
                          Text('${route.ticksCount}'),
                        ],
                      ),
                      if (route.gradeProposalsCount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.grade,
                                color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text('${route.gradeProposalsCount}'),
                          ],
                        ),
                      ],
                      if (route.warningsCount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.warning,
                                color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text('${route.warningsCount}'),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    l10n.setBy(route.routeSetter),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    route.wallSection,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.format_list_numbered,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    l10n.laneNumber(route.lane),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (route.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  route.description!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
