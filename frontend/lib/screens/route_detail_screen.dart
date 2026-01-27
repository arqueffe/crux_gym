import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generated/l10n/app_localizations.dart';
import '../providers/route_provider.dart';
import '../models/route_models.dart' as models;
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

class RouteImageDialog extends StatelessWidget {
  final String url;
  const RouteImageDialog(this.url, {super.key});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(20.0),
        minScale: 0.1,
        maxScale: 4.0,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: Image.network(
            url,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class RouteImage extends StatelessWidget {
  final double? width;
  final String url;

  const RouteImage(this.url, {super.key, this.width});

  @override
  Widget build(BuildContext context) {
    // Should be clickable to be seen in big.
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: GestureDetector(
          onTap: () async {
            await showDialog(
                context: context, builder: (_) => RouteImageDialog(url));
          },
          child: Image.network(
            url,
            width: width,
            fit: BoxFit.contain,
          )),
    );
  }
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

          final screenWidth = MediaQuery.of(context).size.width;
          final isWideScreen = screenWidth > 600;

          return Stack(
            children: [
              // Background Image
              if (route.image != null)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (_) => RouteImageDialog(route.image!),
                      );
                    },
                    child: Image.network(
                      route.image!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              // Zoom indicator for background
              if (route.image != null)
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (_) => RouteImageDialog(route.image!),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Tap to zoom',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Scrollable Content with top spacing
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Empty space to show the background image - transparent to taps
                    if (route.image != null)
                      GestureDetector(
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (_) => RouteImageDialog(route.image!),
                          );
                        },
                        child: Container(
                          height: isWideScreen ? 300 : 250,
                          color: Colors.transparent,
                        ),
                      ),

                    // Content area with semi-transparent background
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0.92),
                            Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0.97),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Route Header Card
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withOpacity(0.95),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                route.name == 'Unnamed'
                                                    ? l10n.unnamed
                                                    : route.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 12),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  GradeChip(
                                                    grade: route.gradeName!,
                                                    gradeColorHex:
                                                        route.gradeColor,
                                                  ),
                                                  // Show averaged proposed grade if available
                                                  Consumer<RouteProvider>(
                                                    builder: (context,
                                                        routeProvider, child) {
                                                      try {
                                                        final averageGrade =
                                                            GradeUtils
                                                                .calculateAverageProposedGrade(
                                                          route.gradeProposals,
                                                          routeProvider
                                                              .gradeDefinitions,
                                                        );

                                                        if (averageGrade ==
                                                            null) {
                                                          return const SizedBox
                                                              .shrink();
                                                        }

                                                        final averageGradeColor =
                                                            routeProvider
                                                                .getGradeColor(
                                                                    averageGrade);

                                                        return AverageGradeChip(
                                                          grade: averageGrade,
                                                          gradeColorHex:
                                                              averageGradeColor,
                                                        );
                                                      } catch (e) {
                                                        print(
                                                            'Error calculating average grade: $e');
                                                        return const SizedBox
                                                            .shrink();
                                                      }
                                                    },
                                                  ),
                                                  if (route.colorHex != null)
                                                    Container(
                                                      width: 24,
                                                      height: 24,
                                                      decoration: BoxDecoration(
                                                        color: ColorUtils
                                                            .parseHexColor(route
                                                                    .colorHex ??
                                                                '#808080'),
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors
                                                              .grey.shade300,
                                                          width: 2,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              // Explanation for averaged proposed grade
                                              Consumer<RouteProvider>(
                                                builder: (context,
                                                    routeProvider, child) {
                                                  try {
                                                    final averageGrade = GradeUtils
                                                        .calculateAverageProposedGrade(
                                                      route.gradeProposals,
                                                      routeProvider
                                                          .gradeDefinitions,
                                                    );

                                                    if (averageGrade == null) {
                                                      return const SizedBox
                                                          .shrink();
                                                    }

                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.info_outline,
                                                            size: 14,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary,
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Flexible(
                                                            child: Text(
                                                              l10n.communitySuggested(
                                                                  averageGrade,
                                                                  route
                                                                      .gradeProposalsCount),
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  } catch (e) {
                                                    print(
                                                        'Error calculating average grade: $e');
                                                    return const SizedBox
                                                        .shrink();
                                                  }
                                                },
                                              ),
                                              const SizedBox(height: 16),
                                              const Divider(),
                                              const SizedBox(height: 12),
                                              _InfoRow(
                                                icon: Icons.person,
                                                label: l10n
                                                    .setBy(route.routeSetter),
                                              ),
                                              const SizedBox(height: 8),
                                              _InfoRow(
                                                icon: Icons.location_on,
                                                label: route.wallSection,
                                              ),
                                              const SizedBox(height: 8),
                                              _InfoRow(
                                                icon:
                                                    Icons.format_list_numbered,
                                                label:
                                                    l10n.laneLabel(route.lane),
                                              ),
                                              if (route.description !=
                                                  null) ...[
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
                                        // Social Stats
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
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
                            ),
                            const SizedBox(height: 20),

                            // User Interactions
                            RouteInteractions(route: route),

                            // Name Proposals Section (only for unnamed routes)
                            if (route.name == 'Unnamed') ...[
                              const SizedBox(height: 20),
                              _NameProposalSection(route: route),
                            ],

                            // Comments Section
                            if (route.comments != null &&
                                route.comments!.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withOpacity(0.95),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.comments,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(height: 16),
                                      ...route.comments!.map((comment) =>
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      comment.userName,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      _formatDate(
                                                          comment.createdAt),
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
                              const SizedBox(height: 20),
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withOpacity(0.95),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.gradeProposals,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(height: 16),
                                      ...route.gradeProposals!.map((proposal) =>
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      proposal.userName,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: context
                                                                    .read<
                                                                        RouteProvider>()
                                                                    .getGradeColor(
                                                                        proposal
                                                                            .proposedGrade) !=
                                                                null
                                                            ? ColorUtils.parseHexColor(context
                                                                .read<
                                                                    RouteProvider>()
                                                                .getGradeColor(
                                                                    proposal
                                                                        .proposedGrade)!)
                                                            : Colors.grey,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Text(
                                                        proposal.proposedGrade,
                                                        style: TextStyle(
                                                          color: GradeChip
                                                              .getTextColor(
                                                            context.read<RouteProvider>().getGradeColor(
                                                                        proposal
                                                                            .proposedGrade) !=
                                                                    null
                                                                ? ColorUtils.parseHexColor(context
                                                                    .read<
                                                                        RouteProvider>()
                                                                    .getGradeColor(
                                                                        proposal
                                                                            .proposedGrade)!)
                                                                : Colors.grey,
                                                          ),
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      _formatDate(
                                                          proposal.createdAt),
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (proposal.reasoning !=
                                                    null) ...[
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
                            if (route.warnings != null &&
                                route.warnings!.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.orange.withOpacity(0.15)
                                    : Colors.orange[50]?.withOpacity(0.95),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.warning,
                                              color: Colors.orange),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.warnings,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      ...route.warnings!.map((warning) =>
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      warning.userName,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Text(
                                                        warning.warningType
                                                            .replaceAll(
                                                                '_', ' '),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      _formatDate(
                                                          warning.createdAt),
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
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Hero Image Widget for top of screen
class _HeroImageSection extends StatelessWidget {
  final String imageUrl;
  final bool isWideScreen;

  const _HeroImageSection({
    required this.imageUrl,
    required this.isWideScreen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await showDialog(
          context: context,
          builder: (_) => RouteImageDialog(imageUrl),
        );
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: isWideScreen ? 500 : 400,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            // Gradient overlay for better text visibility if needed
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
            // Tap indicator
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.zoom_in,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tap to zoom',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Info row widget for cleaner code
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

// Stat chip widget for modern social stats
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
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

class _NameProposalSection extends StatefulWidget {
  final models.Route route;

  const _NameProposalSection({required this.route});

  @override
  State<_NameProposalSection> createState() => _NameProposalSectionState();
}

class _NameProposalSectionState extends State<_NameProposalSection> {
  List<models.NameProposal> _proposals = [];
  Map<String, dynamic>? _userAction;
  bool _isLoading = true;
  bool _isSubmitting = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProposals();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProposals() async {
    setState(() => _isLoading = true);
    try {
      final routeProvider = context.read<RouteProvider>();
      final proposals =
          await routeProvider.apiService.getRouteNameProposals(widget.route.id);
      final userAction = await routeProvider.apiService
          .getUserNameProposalAction(widget.route.id);

      if (mounted) {
        setState(() {
          _proposals = proposals;
          _userAction = userAction;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorLoadingProposals(e.toString()))),
        );
      }
    }
  }

  Future<void> _submitProposal() async {
    final l10n = AppLocalizations.of(context);
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterName)),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmProposalTitle),
        content: Text(l10n.confirmProposalMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    try {
      final routeProvider = context.read<RouteProvider>();
      await routeProvider.apiService.proposeRouteName(
        widget.route.id,
        _nameController.text.trim(),
      );

      if (mounted) {
        _nameController.clear();
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.nameProposedSuccess)),
        );
        await _loadProposals();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).error}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _voteForProposal(models.NameProposal proposal) async {
    final l10n = AppLocalizations.of(context);
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmVoteTitle),
        content: Text(l10n.confirmVoteMessage(proposal.proposedName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    try {
      final routeProvider = context.read<RouteProvider>();
      await routeProvider.apiService
          .voteForNameProposal(widget.route.id, proposal.id);

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.voteRecordedSuccess)),
        );
        await _loadProposals();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).error}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline),
                const SizedBox(width: 8),
                Text(
                  l10n.proposeAName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.unnamedRouteDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              // Show proposal form or user status
              if (_userAction?['has_proposed'] == true) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.youProposed(
                              _userAction!['proposal']['proposed_name']),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (_userAction?['has_voted'] == true) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.how_to_vote, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.youVotedFor(
                              _userAction!['voted_for']['proposed_name']),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Show proposal form
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: l10n.yourProposedName,
                          border: const OutlineInputBorder(),
                          hintText: l10n.enterCreativeNameProposal,
                        ),
                        enabled: !_isSubmitting,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitProposal,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.proposeButton),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.proposalWarning,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[800],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              // Show existing proposals
              if (_proposals.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  l10n.proposedNames(_proposals.length),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ..._proposals.map((proposal) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    proposal.proposedName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.byUser(proposal.userName),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.thumb_up, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${proposal.voteCount}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_userAction?['has_proposed'] != true &&
                                    _userAction?['has_voted'] != true) ...[
                                  const SizedBox(height: 4),
                                  TextButton(
                                    onPressed: _isSubmitting
                                        ? null
                                        : () => _voteForProposal(proposal),
                                    child: Text(l10n.voteButton),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
