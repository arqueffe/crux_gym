import 'package:flutter/material.dart';
import '../generated/l10n/app_localizations.dart';
import '../models/route_models.dart' as models;
import '../utils/color_utils.dart';
import 'grade_chip.dart';

class RouteCard extends StatelessWidget {
  final models.Route route;
  final VoidCallback onTap;
  final bool hasLeadSent;

  const RouteCard({
    super.key,
    required this.route,
    required this.onTap,
    this.hasLeadSent = false,
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
            if (hasLeadSent)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                        colors: [
                          const Color(0x1F34D399),
                          holdColor.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.35, 0.85],
                      ),
                    ),
                  ),
                ),
              ),
            if (hasLeadSent)
              Positioned(
                bottom: -34,
                right: -28,
                child: IgnorePointer(
                  child: Container(
                    width: 128,
                    height: 128,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Color(0x2F34D399), Color(0x0034D399)],
                        stops: [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
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
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                route.displayName(
                                    unnamedFallback: l10n.unnamed),
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
            if (hasLeadSent)
              Positioned(
                right: 12,
                bottom: 12,
                child: _LeadSentChip(
                  tooltip: l10n.leadSent,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RouteCardGradeChip extends StatelessWidget {
  final models.Route route;

  const _RouteCardGradeChip({required this.route});

  @override
  Widget build(BuildContext context) {
    return GradeChip(
      grade: route.gradeName ?? '-',
      gradeColorHex: route.gradeColor,
    );
  }
}

class _LeadSentChip extends StatelessWidget {
  final String tooltip;

  const _LeadSentChip({
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        label: tooltip,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF00A86B), Color(0xFF2ECC71)],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.78),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3300A86B),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              const Center(
                child: Icon(
                  Icons.verified_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
