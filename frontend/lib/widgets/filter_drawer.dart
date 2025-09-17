import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/route_provider.dart';
import '../generated/l10n/app_localizations.dart';

class FilterDrawer extends StatelessWidget {
  const FilterDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
                          l10n.filtersAndSorting,
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
                    _buildSectionHeader(l10n.sortBy),
                    const SizedBox(height: 8),
                    _buildSortDropdown(context, routeProvider, l10n),
                    const SizedBox(height: 24),

                    // Basic filters section
                    _buildSectionHeader(l10n.basicFilters),
                    const SizedBox(height: 8),
                    _buildWallSectionFilter(routeProvider, l10n),
                    const SizedBox(height: 16),
                    _buildGradeFilter(routeProvider, l10n),
                    const SizedBox(height: 16),
                    _buildLaneFilter(routeProvider, l10n),
                    const SizedBox(height: 16),
                    _buildRouteSetterFilter(routeProvider, l10n),
                    const SizedBox(height: 24),

                    // User interaction filters
                    _buildSectionHeader(l10n.userInteractions),
                    const SizedBox(height: 12),
                    _buildTickedFilter(routeProvider, l10n),
                    const SizedBox(height: 16),
                    _buildLikedFilter(routeProvider, l10n),
                    const SizedBox(height: 16),
                    _buildWarnedFilter(routeProvider, l10n),
                    const SizedBox(height: 16),
                    _buildProjectFilter(routeProvider, l10n),
                    const SizedBox(height: 32),

                    // Clear filters button
                    if (routeProvider.hasActiveFilters) ...[
                      ElevatedButton.icon(
                        onPressed: () => routeProvider.clearAllFilters(),
                        icon: const Icon(Icons.clear_all),
                        label: Text(l10n.clearAllFilters),
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

  Widget _buildSortDropdown(BuildContext context, RouteProvider routeProvider,
      AppLocalizations l10n) {
    return DropdownButtonFormField<SortOption>(
      decoration: InputDecoration(
        labelText: l10n.sortby,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: const OutlineInputBorder(),
      ),
      value: routeProvider.selectedSort,
      items: SortOption.values.map((option) {
        return DropdownMenuItem<SortOption>(
          value: option,
          child: Text(option.getDisplayName(l10n)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          routeProvider.setSortOption(value);
        }
      },
    );
  }

  Widget _buildWallSectionFilter(
      RouteProvider routeProvider, AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: l10n.wallSection,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: const OutlineInputBorder(),
      ),
      value: routeProvider.selectedWallSection,
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text(l10n.allSections),
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

  Widget _buildGradeFilter(RouteProvider routeProvider, AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: l10n.grade,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: const OutlineInputBorder(),
      ),
      value: routeProvider.selectedGrade,
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text(l10n.allGrades),
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

  Widget _buildLaneFilter(RouteProvider routeProvider, AppLocalizations l10n) {
    print(
        '🔍 Filter drawer lanes: ${routeProvider.lanes.length} lanes available');
    print(
        '🔍 Lanes: ${routeProvider.lanes.map((l) => 'ID:${l.id} Name:${l.name}').toList()}');

    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: l10n.lane,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: const OutlineInputBorder(),
      ),
      value: routeProvider.selectedLane,
      items: [
        DropdownMenuItem<int>(
          value: null,
          child: Text(l10n.allLanes),
        ),
        ...routeProvider.lanes.map(
          (lane) => DropdownMenuItem<int>(
            value: lane.id,
            child: Text(lane.name),
          ),
        ),
      ],
      onChanged: (value) {
        routeProvider.setLaneFilter(value);
      },
    );
  }

  Widget _buildRouteSetterFilter(
      RouteProvider routeProvider, AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: l10n.routeSetter,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: const OutlineInputBorder(),
      ),
      value: routeProvider.selectedRouteSetter,
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text(l10n.allRouteSetters),
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

  Widget _buildTickedFilter(
      RouteProvider routeProvider, AppLocalizations l10n) {
    return _buildThreeStageFilter(
      l10n.tickedRoutes,
      routeProvider.tickedFilter,
      (state) => routeProvider.setTickedFilter(state),
      l10n,
    );
  }

  Widget _buildLikedFilter(RouteProvider routeProvider, AppLocalizations l10n) {
    return _buildThreeStageFilter(
      l10n.likedRoutes,
      routeProvider.likedFilter,
      (state) => routeProvider.setLikedFilter(state),
      l10n,
    );
  }

  Widget _buildWarnedFilter(
      RouteProvider routeProvider, AppLocalizations l10n) {
    return _buildThreeStageFilter(
      l10n.warnedRoutes,
      routeProvider.warnedFilter,
      (state) => routeProvider.setWarnedFilter(state),
      l10n,
    );
  }

  Widget _buildProjectFilter(
      RouteProvider routeProvider, AppLocalizations l10n) {
    return _buildThreeStageFilter(
      l10n.projectRoutes,
      routeProvider.projectFilter,
      (state) => routeProvider.setProjectFilter(state),
      l10n,
    );
  }

  Widget _buildThreeStageFilter(
    String label,
    FilterState currentState,
    Function(FilterState) onChanged,
    AppLocalizations l10n,
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
                          state.getDisplayName(l10n),
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
  String getDisplayName(AppLocalizations l10n) {
    switch (this) {
      case SortOption.newest:
        return l10n.newestFirst;
      case SortOption.oldest:
        return l10n.oldestFirst;
      case SortOption.nameAZ:
        return l10n.nameAZ;
      case SortOption.nameZA:
        return l10n.nameZA;
      case SortOption.gradeAsc:
        return l10n.gradeEasyToHard;
      case SortOption.gradeDesc:
        return l10n.gradeHardToEasy;
      case SortOption.mostLikes:
        return l10n.mostLikes;
      case SortOption.leastLikes:
        return l10n.leastLikes;
      case SortOption.mostComments:
        return l10n.mostComments;
      case SortOption.leastComments:
        return l10n.leastComments;
      case SortOption.mostTicks:
        return l10n.mostTicks;
      case SortOption.leastTicks:
        return l10n.leastTicks;
    }
  }

  @Deprecated('Use getDisplayName(l10n) instead')
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
  String getDisplayName(AppLocalizations l10n) {
    switch (this) {
      case FilterState.all:
        return l10n.filterStateAll;
      case FilterState.only:
        return l10n.filterStateOnly;
      case FilterState.exclude:
        return l10n.filterStateExclude;
    }
  }

  @Deprecated('Use getDisplayName(l10n) instead')
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
