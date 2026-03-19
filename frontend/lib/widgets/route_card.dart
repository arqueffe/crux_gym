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
    final holdColor = ColorUtils.parseHexColor(route.colorHex ?? '#9E9E9E');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: holdColor.withValues(alpha: 0.2),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: holdColor.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      holdColor.withValues(alpha: 0.95),
                      holdColor.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
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
                              route.displayName(unnamedFallback: l10n.unnamed),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _RouteCardGradeChip(route: route),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Prises:',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: holdColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                              const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text('${route.likesCount}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.comment,
                                color: Colors.blue,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text('${route.commentsCount}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text('${route.ticksCount}'),
                            ],
                          ),
                          if (route.warningsCount > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.warning,
                                  color: Colors.orange,
                                  size: 16,
                                ),
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
                      Icon(
                        Icons.person,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
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
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        route.wallSection,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.format_list_numbered,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
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
          ],
        ),
      ),
    );
  }
}

class _RouteCardGradeChip extends StatefulWidget {
  final models.Route route;

  const _RouteCardGradeChip({required this.route});

  @override
  State<_RouteCardGradeChip> createState() => _RouteCardGradeChipState();
}

class _RouteCardGradeChipState extends State<_RouteCardGradeChip> {
  Future<models.Route>? _detailFuture;

  @override
  void initState() {
    super.initState();
    _syncDetailFuture();
  }

  @override
  void didUpdateWidget(covariant _RouteCardGradeChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.route.id != widget.route.id ||
        oldWidget.route.gradeProposalsCount !=
            widget.route.gradeProposalsCount) {
      _syncDetailFuture();
    }
  }

  void _syncDetailFuture() {
    if (widget.route.gradeProposalsCount > 0) {
      _detailFuture = context.read<RouteProvider>().apiService.getRoute(
            widget.route.id,
          );
      return;
    }

    _detailFuture = null;
  }

  Widget? _buildTrendIcon(
    models.Route detailedRoute,
    RouteProvider routeProvider,
  ) {
    final baseGrade = widget.route.gradeName;
    if (baseGrade == null || routeProvider.gradeDefinitions.isEmpty) {
      return null;
    }

    final comparison = GradeUtils.compareAverageProposedToGrade(
      detailedRoute.gradeProposals,
      baseGrade,
      routeProvider.gradeDefinitions,
    );

    if (comparison > 0) {
      return const Icon(
        Icons.keyboard_arrow_up,
        color: Colors.red,
        size: 14,
      );
    }

    if (comparison < 0) {
      return const Icon(
        Icons.keyboard_arrow_down,
        color: Colors.green,
        size: 14,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RouteProvider>(
      builder: (context, routeProvider, child) {
        if (widget.route.gradeProposalsCount == 0 ||
            routeProvider.gradeDefinitions.isEmpty ||
            _detailFuture == null) {
          return GradeChip(
            grade: widget.route.gradeName ?? '-',
            gradeColorHex: widget.route.gradeColor,
          );
        }

        return FutureBuilder<models.Route>(
          future: _detailFuture,
          builder: (context, snapshot) {
            final detailedRoute = snapshot.data;
            final trendIcon = detailedRoute == null
                ? null
                : _buildTrendIcon(detailedRoute, routeProvider);

            return GradeChip(
              grade: widget.route.gradeName ?? '-',
              gradeColorHex: widget.route.gradeColor,
              icon: trendIcon,
            );
          },
        );
      },
    );
  }
}
