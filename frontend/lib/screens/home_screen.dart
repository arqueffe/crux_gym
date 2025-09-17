import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/route_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/route_card.dart';
import '../widgets/filter_drawer.dart';
import '../widgets/interactive_climbing_wall.dart';
import '../widgets/custom_app_bar.dart';
import 'route_detail_screen.dart';
import 'add_route_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routeProvider = context.read<RouteProvider>();
      routeProvider.loadInitialData();
      routeProvider.loadGradeColors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Climbing Gym Routes',
        automaticallyImplyLeading:
            false, // Remove back button since we're using bottom nav
        actions: [
          Builder(builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filters',
            );
          }),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              // Only show add route button if user has permission
              if (!authProvider.canCreateRoutes) {
                return const SizedBox.shrink();
              }
              return IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddRouteScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                tooltip: 'Add Route',
              );
            },
          ),
        ],
      ),
      endDrawer: const FilterDrawer(),
      body: Consumer<RouteProvider>(
        builder: (context, routeProvider, child) {
          if (routeProvider.isLoading && routeProvider.routes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (routeProvider.error != null && routeProvider.routes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${routeProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => routeProvider.loadInitialData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Interactive Climbing Wall
              const InteractiveClimbingWall(),

              // Consistent spacer or active filters indicator
              Container(
                width: double.infinity,
                height: 48, // Fixed height to prevent layout jumps
                padding: const EdgeInsets.all(12),
                decoration: routeProvider.hasActiveFilters
                    ? BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      )
                    : null,
                child: routeProvider.hasActiveFilters
                    ? Row(
                        children: [
                          Icon(
                            Icons.filter_alt,
                            size: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Filters active - ${routeProvider.routes.length} routes shown',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => routeProvider.clearAllFilters(),
                            child: Text(
                              'Clear All',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      )
                    : null, // Empty space when no filters but same height
              ),
              Expanded(
                child: routeProvider.routes.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.terrain, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No routes found',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters or add a new route',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => routeProvider.loadRoutes(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: routeProvider.routes.length,
                          itemBuilder: (context, index) {
                            final route = routeProvider.routes[index];
                            return RouteCard(
                              route: route,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RouteDetailScreen(
                                      routeId: route.id,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
