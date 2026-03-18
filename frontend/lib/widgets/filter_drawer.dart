import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/route_filter_models.dart';
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
      initialValue: routeProvider.selectedSort,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.wallSection,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: Text(l10n.allSections),
              selected: routeProvider.selectedWallSections.isEmpty,
              onSelected: (_) =>
                  routeProvider.setWallSectionsFilter(<String>{}),
            ),
            ...routeProvider.wallSections.map(
              (section) => FilterChip(
                label: Text(section),
                selected: routeProvider.selectedWallSections.contains(section),
                onSelected: (_) =>
                    routeProvider.toggleWallSectionFilter(section),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGradeFilter(RouteProvider routeProvider, AppLocalizations l10n) {
    final availableGrades = routeProvider.availableGrades;

    if (availableGrades.isEmpty) {
      return Text(
        '${l10n.grade}: ${l10n.allGrades}',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      );
    }

    final maxIndex = availableGrades.length - 1;
    final minSelectedIndex = routeProvider.selectedMinGradeIndex ?? 0;
    final maxSelectedIndex = routeProvider.selectedMaxGradeIndex ?? maxIndex;
    final selectedMinGrade = availableGrades[minSelectedIndex];
    final selectedMaxGrade = availableGrades[maxSelectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.grade}: $selectedMinGrade - $selectedMaxGrade',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          min: 0,
          max: maxIndex.toDouble(),
          divisions: maxIndex > 0 ? maxIndex : null,
          values: RangeValues(
            minSelectedIndex.toDouble(),
            maxSelectedIndex.toDouble(),
          ),
          labels: RangeLabels(selectedMinGrade, selectedMaxGrade),
          onChanged: (values) {
            routeProvider.setGradeRangeFilter(
              values.start.round(),
              values.end.round(),
            );
          },
        ),
        if (routeProvider.hasGradeRangeFilter)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => routeProvider.setGradeRangeFilter(null, null),
              child: Text(l10n.allGrades),
            ),
          ),
      ],
    );
  }

  Widget _buildLaneFilter(RouteProvider routeProvider, AppLocalizations l10n) {
    final availableLanes = routeProvider.lanesWithRoutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.lane,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: Text(l10n.allLanes),
              selected: routeProvider.selectedLaneIds.isEmpty,
              onSelected: (_) => routeProvider.setLaneIdsFilter(<int>{}),
            ),
            ...availableLanes.map(
              (lane) => FilterChip(
                label: Text(l10n.laneLabel(lane.id)),
                selected: routeProvider.selectedLaneIds.contains(lane.id),
                onSelected: (_) => routeProvider.toggleLaneFilter(lane.id),
              ),
            ),
          ],
        ),
      ],
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
      initialValue: routeProvider.selectedRouteSetter,
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
