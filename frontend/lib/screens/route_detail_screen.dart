import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generated/l10n/app_localizations.dart';
import '../providers/route_provider.dart';
import '../widgets/route_interactions.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/color_utils.dart';
import '../utils/grade_utils.dart';
import '../widgets/grade_chip.dart';

class RouteDetailScreen extends StatefulWidget {
  final int routeId;

  const RouteDetailScreen({super.key, required this.routeId});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routeProvider = context.read<RouteProvider>();
      routeProvider
          .loadRoute(widget.routeId); // This now handles all dependencies
      routeProvider
          .loadGradeColors(); // Still needed for other grade color operations
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.routeTitle,
      ),
      body: Consumer<RouteProvider>(
        builder: (context, routeProvider, child) {
          if (routeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (routeProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    '${l10n.error}: ${routeProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => routeProvider.loadRoute(widget.routeId),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          final route = routeProvider.selectedRoute;
          if (route == null) {
            return Center(child: Text(l10n.routeNotFound));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route Header
                Card(
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      GradeChip(
                                        grade: route.grade,
                                        gradeColorHex: route.gradeColor,
                                      ),
                                      // Show averaged proposed grade if available
                                      Consumer<RouteProvider>(
                                        builder:
                                            (context, routeProvider, child) {
                                          try {
                                            final averageGrade = GradeUtils
                                                .calculateAverageProposedGrade(
                                              route.gradeProposals,
                                              routeProvider.gradeDefinitions,
                                            );

                                            if (averageGrade == null) {
                                              return const SizedBox.shrink();
                                            }

                                            final averageGradeColor =
                                                routeProvider.getGradeColor(
                                                    averageGrade);

                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8),
                                              child: AverageGradeChip(
                                                grade: averageGrade,
                                                gradeColorHex:
                                                    averageGradeColor,
                                              ),
                                            );
                                          } catch (e) {
                                            // If there's an error calculating average grade, just don't show it
                                            print(
                                                'Error calculating average grade: $e');
                                            return const SizedBox.shrink();
                                          }
                                        },
                                      ),
                                      if (route.color != null) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: ColorUtils.parseHexColor(
                                                route.colorHex ?? '#808080'),
                                            shape: BoxShape.circle,
                                            border:
                                                Border.all(color: Colors.grey),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  // Explanation for averaged proposed grade
                                  Consumer<RouteProvider>(
                                    builder: (context, routeProvider, child) {
                                      try {
                                        final averageGrade = GradeUtils
                                            .calculateAverageProposedGrade(
                                          route.gradeProposals,
                                          routeProvider.gradeDefinitions,
                                        );

                                        if (averageGrade == null) {
                                          return const SizedBox.shrink();
                                        }

                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                size: 14,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                l10n.communitySuggested(
                                                    averageGrade,
                                                    route.gradeProposalsCount),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } catch (e) {
                                        // If there's an error calculating average grade, just don't show it
                                        print(
                                            'Error calculating average grade: $e');
                                        return const SizedBox.shrink();
                                      }
                                    },
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
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.person,
                                size: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(l10n.setBy(route.routeSetter)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(route.wallSection),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.format_list_numbered,
                                size: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(l10n.laneLabel(route.lane)),
                          ],
                        ),
                        if (route.description != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            route.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // User Interactions
                RouteInteractions(route: route),

                // Comments Section
                if (route.comments != null && route.comments!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.comments,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ...route.comments!.map((comment) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          comment.userName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _formatDate(comment.createdAt),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(comment.content),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ],

                // Grade Proposals Section
                if (route.gradeProposals != null &&
                    route.gradeProposals!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.gradeProposals,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ...route.gradeProposals!.map((proposal) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          proposal.userName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: context
                                                        .read<RouteProvider>()
                                                        .getGradeColor(proposal
                                                            .proposedGrade) !=
                                                    null
                                                ? ColorUtils.parseHexColor(
                                                    context
                                                        .read<RouteProvider>()
                                                        .getGradeColor(proposal
                                                            .proposedGrade)!)
                                                : Colors.grey,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            proposal.proposedGrade,
                                            style: TextStyle(
                                              color: GradeChip.getTextColor(
                                                context
                                                            .read<
                                                                RouteProvider>()
                                                            .getGradeColor(proposal
                                                                .proposedGrade) !=
                                                        null
                                                    ? ColorUtils.parseHexColor(
                                                        context
                                                            .read<
                                                                RouteProvider>()
                                                            .getGradeColor(proposal
                                                                .proposedGrade)!)
                                                    : Colors.grey,
                                              ),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _formatDate(proposal.createdAt),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (proposal.reasoning != null) ...[
                                      const SizedBox(height: 4),
                                      Text(proposal.reasoning!),
                                    ],
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ],

                // Warnings Section
                if (route.warnings != null && route.warnings!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning, color: Colors.orange),
                              const SizedBox(width: 8),
                              Text(
                                l10n.warnings,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...route.warnings!.map((warning) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          warning.userName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.orange,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            warning.warningType
                                                .replaceAll('_', ' '),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _formatDate(warning.createdAt),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(warning.description),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
