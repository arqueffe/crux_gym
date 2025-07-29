import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/route_provider.dart';

class FilterDrawer extends StatelessWidget {
  const FilterDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 400,
      child: Consumer<RouteProvider>(
        builder: (context, routeProvider, child) {
          return Column(
            children: [
              // Header
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Filters & Sorting',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Filter content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Sorting section
                    _buildSectionHeader('Sort By'),
                    const SizedBox(height: 8),
                    _buildSortDropdown(context, routeProvider),
                    const SizedBox(height: 24),

                    // Basic filters section
                    _buildSectionHeader('Basic Filters'),
                    const SizedBox(height: 8),
                    _buildWallSectionFilter(routeProvider),
                    const SizedBox(height: 16),
                    _buildGradeFilter(routeProvider),
                    const SizedBox(height: 16),
                    _buildLaneFilter(routeProvider),
                    const SizedBox(height: 16),
                    _buildRouteSetterFilter(routeProvider),
                    const SizedBox(height: 24),

                    // User interaction filters
                    _buildSectionHeader('User Interactions'),
                    const SizedBox(height: 12),
                    _buildTickedFilter(routeProvider),
                    const SizedBox(height: 16),
                    _buildLikedFilter(routeProvider),
                    const SizedBox(height: 16),
                    _buildWarnedFilter(routeProvider),
                    const SizedBox(height: 32),

                    // Clear filters button
                    if (routeProvider.hasActiveFilters) ...[
                      ElevatedButton.icon(
                        onPressed: () => routeProvider.clearAllFilters(),
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear All Filters'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[100],
                          foregroundColor: Colors.red[800],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSortDropdown(BuildContext context, RouteProvider routeProvider) {
    return DropdownButtonFormField<SortOption>(
      decoration: const InputDecoration(
        labelText: 'Sort by',
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(),
      ),
      value: routeProvider.selectedSort,
      items: SortOption.values.map((option) {
        return DropdownMenuItem<SortOption>(
          value: option,
          child: Text(option.displayName),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          routeProvider.setSortOption(value);
        }
      },
    );
  }

  Widget _buildWallSectionFilter(RouteProvider routeProvider) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Wall Section',
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(),
      ),
      value: routeProvider.selectedWallSection,
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('All Sections'),
        ),
        ...routeProvider.wallSections.map(
          (section) => DropdownMenuItem<String>(
            value: section,
            child: Text(section),
          ),
        ),
      ],
      onChanged: (value) {
        routeProvider.setWallSectionFilter(value);
      },
    );
  }

  Widget _buildGradeFilter(RouteProvider routeProvider) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Grade',
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(),
      ),
      value: routeProvider.selectedGrade,
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('All Grades'),
        ),
        ...routeProvider.grades.map(
          (grade) => DropdownMenuItem<String>(
            value: grade,
            child: Text(grade),
          ),
        ),
      ],
      onChanged: (value) {
        routeProvider.setGradeFilter(value);
      },
    );
  }

  Widget _buildLaneFilter(RouteProvider routeProvider) {
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(
        labelText: 'Lane',
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(),
      ),
      value: routeProvider.selectedLane,
      items: [
        const DropdownMenuItem<int>(
          value: null,
          child: Text('All Lanes'),
        ),
        ...routeProvider.lanes.map(
          (lane) => DropdownMenuItem<int>(
            value: lane,
            child: Text('Lane $lane'),
          ),
        ),
      ],
      onChanged: (value) {
        routeProvider.setLaneFilter(value);
      },
    );
  }

  Widget _buildRouteSetterFilter(RouteProvider routeProvider) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Route Setter',
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(),
      ),
      value: routeProvider.selectedRouteSetter,
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('All Route Setters'),
        ),
        ...routeProvider.routeSetters.map(
          (setter) => DropdownMenuItem<String>(
            value: setter,
            child: Text(setter),
          ),
        ),
      ],
      onChanged: (value) {
        routeProvider.setRouteSetterFilter(value);
      },
    );
  }

  Widget _buildTickedFilter(RouteProvider routeProvider) {
    return _buildThreeStageFilter(
      'Ticked Routes',
      routeProvider.tickedFilter,
      (state) => routeProvider.setTickedFilter(state),
    );
  }

  Widget _buildLikedFilter(RouteProvider routeProvider) {
    return _buildThreeStageFilter(
      'Liked Routes',
      routeProvider.likedFilter,
      (state) => routeProvider.setLikedFilter(state),
    );
  }

  Widget _buildWarnedFilter(RouteProvider routeProvider) {
    return _buildThreeStageFilter(
      'Warned Routes',
      routeProvider.warnedFilter,
      (state) => routeProvider.setWarnedFilter(state),
    );
  }

  Widget _buildThreeStageFilter(
    String label,
    FilterState currentState,
    Function(FilterState) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: FilterState.values.map((state) {
              final isSelected = currentState == state;
              final isFirst = state == FilterState.values.first;
              final isLast = state == FilterState.values.last;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(state),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? state.color : Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft:
                            isFirst ? const Radius.circular(6) : Radius.zero,
                        bottomLeft:
                            isFirst ? const Radius.circular(6) : Radius.zero,
                        topRight:
                            isLast ? const Radius.circular(6) : Radius.zero,
                        bottomRight:
                            isLast ? const Radius.circular(6) : Radius.zero,
                      ),
                      border: !isLast
                          ? Border(
                              right: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          state.icon,
                          size: 16,
                          color: isSelected ? Colors.white : state.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          state.displayName,
                          style: TextStyle(
                            color: isSelected ? Colors.white : state.color,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

enum SortOption {
  newest,
  oldest,
  nameAZ,
  nameZA,
  gradeAsc,
  gradeDesc,
  mostLikes,
  leastLikes,
  mostComments,
  leastComments,
  mostTicks,
  leastTicks,
}

extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.newest:
        return 'Newest First';
      case SortOption.oldest:
        return 'Oldest First';
      case SortOption.nameAZ:
        return 'Name (A-Z)';
      case SortOption.nameZA:
        return 'Name (Z-A)';
      case SortOption.gradeAsc:
        return 'Grade (Easy to Hard)';
      case SortOption.gradeDesc:
        return 'Grade (Hard to Easy)';
      case SortOption.mostLikes:
        return 'Most Likes';
      case SortOption.leastLikes:
        return 'Least Likes';
      case SortOption.mostComments:
        return 'Most Comments';
      case SortOption.leastComments:
        return 'Least Comments';
      case SortOption.mostTicks:
        return 'Most Ticks';
      case SortOption.leastTicks:
        return 'Least Ticks';
    }
  }
}

enum FilterState {
  all,
  only,
  exclude,
}

extension FilterStateExtension on FilterState {
  String get displayName {
    switch (this) {
      case FilterState.all:
        return 'All';
      case FilterState.only:
        return 'Only';
      case FilterState.exclude:
        return 'Exclude';
    }
  }

  IconData get icon {
    switch (this) {
      case FilterState.all:
        return Icons.remove;
      case FilterState.only:
        return Icons.check;
      case FilterState.exclude:
        return Icons.close;
    }
  }

  Color get color {
    switch (this) {
      case FilterState.all:
        return Colors.grey;
      case FilterState.only:
        return Colors.green;
      case FilterState.exclude:
        return Colors.red;
    }
  }
}
