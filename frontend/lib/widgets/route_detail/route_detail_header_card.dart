import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n/app_localizations.dart';
import '../../models/route_models.dart' as models;
import '../../providers/route_provider.dart';
import '../../utils/color_utils.dart';
import '../../utils/grade_utils.dart';
import '../grade_chip.dart';

class RouteHeaderCard extends StatelessWidget {
  final models.Route route;
  final AppLocalizations l10n;

  const RouteHeaderCard({
    super.key,
    required this.route,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                        route.displayName(
                          unnamedFallback: l10n.unnamed,
                        ),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          GradeChip(
                            grade: route.gradeName!,
                            gradeColorHex: route.gradeColor,
                          ),
                          Consumer<RouteProvider>(
                            builder: (context, routeProvider, child) {
                              try {
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
                              } catch (e) {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                          if (route.colorHex != null)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: ColorUtils.parseHexColor(
                                  route.colorHex ?? '#808080',
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Consumer<RouteProvider>(
                        builder: (context, routeProvider, child) {
                          try {
                            final averageGrade =
                                GradeUtils.calculateAverageProposedGrade(
                              route.gradeProposals,
                              routeProvider.gradeDefinitions,
                            );

                            if (averageGrade == null) {
                              return const SizedBox.shrink();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 14,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      l10n.communitySuggested(
                                        averageGrade,
                                        route.gradeProposalsCount,
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } catch (e) {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.person,
                        label: l10n.setBy(route.routeSetter),
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.location_on,
                        label: route.wallSection,
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.format_list_numbered,
                        label: l10n.laneLabel(route.lane),
                      ),
                      if (route.description != null) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        Text(
                          route.description!,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(height: 1.5),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StatChip(
                      icon: Icons.favorite,
                      count: route.likesCount,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 8),
                    _StatChip(
                      icon: Icons.comment,
                      count: route.commentsCount,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    _StatChip(
                      icon: Icons.check_circle,
                      count: route.ticksCount,
                      color: Colors.green,
                    ),
                    if (route.warningsCount > 0) ...[
                      const SizedBox(height: 8),
                      _StatChip(
                        icon: Icons.warning,
                        count: route.warningsCount,
                        color: Colors.orange,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
