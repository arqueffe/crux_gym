import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generated/l10n/app_localizations.dart';
import '../providers/route_provider.dart';
import '../widgets/route_interactions.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/route_detail/route_detail_media.dart';
import '../widgets/route_detail/route_detail_header_card.dart';
import '../widgets/route_detail/route_detail_activity_sections.dart';
import '../widgets/route_detail/name_proposal_section.dart';

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
                      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
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
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                                .withValues(alpha: 0.92),
                            Theme.of(context)
                                .colorScheme
                                .surface
                                .withValues(alpha: 0.97),
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
                            RouteHeaderCard(route: route, l10n: l10n),
                            const SizedBox(height: 20),

                            // User Interactions
                            RouteInteractions(route: route),

                            // Name Proposals Section (only for unnamed routes)
                            if (route.name == 'Unnamed') ...[
                              const SizedBox(height: 20),
                              NameProposalSection(route: route),
                            ],

                            // Comments Section
                            if (route.comments != null &&
                                route.comments!.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              RouteCommentsSection(
                                comments: route.comments!,
                                l10n: l10n,
                              ),
                            ],

                            // Grade Proposals Section
                            if (route.gradeProposals != null &&
                                route.gradeProposals!.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              RouteGradeProposalsSection(
                                proposals: route.gradeProposals!,
                                l10n: l10n,
                              ),
                            ],

                            // Warnings Section
                            if (route.warnings != null &&
                                route.warnings!.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              RouteWarningsSection(
                                warnings: route.warnings!,
                                l10n: l10n,
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
}
