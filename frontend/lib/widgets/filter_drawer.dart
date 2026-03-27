import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/route_filter_models.dart';
import '../providers/route_provider.dart';
import '../generated/l10n/app_localizations.dart';
import '../utils/app_semantic_colors.dart';

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
                    _buildSectionHeader(context, l10n.sortBy),
                    const SizedBox(height: 8),
                    _buildSortDropdown(context, routeProvider, l10n),
                    const SizedBox(height: 24),

                    // Basic filters section
                    _buildSectionHeader(context, l10n.basicFilters),
                    const SizedBox(height: 8),
                    _buildWallSectionFilter(context, routeProvider, l10n),
                    const SizedBox(height: 16),
                    _buildGradeFilter(context, routeProvider, l10n),
                    const SizedBox(height: 16),
                    _buildLaneFilter(context, routeProvider, l10n),
                    const SizedBox(height: 16),
                    _buildRouteSetterFilter(routeProvider, l10n),
                    const SizedBox(height: 24),

                    // User interaction filters
                    _buildSectionHeader(context, l10n.userInteractions),
                    const SizedBox(height: 12),
                    _buildTickedFilter(context, routeProvider, l10n),
                    const SizedBox(height: 16),
                    _buildLikedFilter(context, routeProvider, l10n),
                    const SizedBox(height: 16),
                    _buildWarnedFilter(context, routeProvider, l10n),
                    const SizedBox(height: 16),
                    _buildProjectFilter(context, routeProvider, l10n),
                    const SizedBox(height: 32),

                    // Clear filters button
                    if (routeProvider.hasActiveFilters) ...[
                      ElevatedButton.icon(
                        onPressed: () => routeProvider.clearAllFilters(),
                        icon: const Icon(Icons.clear_all),
                        label: Text(l10n.clearAllFilters),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.errorContainer,
                          foregroundColor:
                              Theme.of(context).colorScheme.onErrorContainer,
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
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

  Widget _buildWallSectionFilter(BuildContext context,
      RouteProvider routeProvider, AppLocalizations l10n) {
    final semantic = context.semanticColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.wallSection,
          style: TextStyle(
            fontSize: 16,
            color: semantic.neutralMuted,
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

  Widget _buildGradeFilter(BuildContext context, RouteProvider routeProvider,
      AppLocalizations l10n) {
    final semantic = context.semanticColors;
    final availableGrades = routeProvider.availableGrades;

    if (availableGrades.isEmpty) {
      return Text(
        '${l10n.grade}: ${l10n.allGrades}',
        style: TextStyle(
          fontSize: 16,
          color: semantic.neutralMuted,
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
            color: semantic.neutralMuted,
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

  Widget _buildLaneFilter(BuildContext context, RouteProvider routeProvider,
      AppLocalizations l10n) {
    final semantic = context.semanticColors;
    final availableLanes = routeProvider.lanesWithRoutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.lane,
          style: TextStyle(
            fontSize: 16,
            color: semantic.neutralMuted,
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

  Widget _buildTickedFilter(BuildContext context, RouteProvider routeProvider,
      AppLocalizations l10n) {
    return _buildThreeStageFilter(
      context,
      l10n.tickedRoutes,
      routeProvider.tickedFilter,
      (state) => routeProvider.setTickedFilter(state),
      l10n,
    );
  }

  Widget _buildLikedFilter(BuildContext context, RouteProvider routeProvider,
      AppLocalizations l10n) {
    return _buildThreeStageFilter(
      context,
      l10n.likedRoutes,
      routeProvider.likedFilter,
      (state) => routeProvider.setLikedFilter(state),
      l10n,
    );
  }

  Widget _buildWarnedFilter(BuildContext context, RouteProvider routeProvider,
      AppLocalizations l10n) {
    return _buildThreeStageFilter(
      context,
      l10n.warnedRoutes,
      routeProvider.warnedFilter,
      (state) => routeProvider.setWarnedFilter(state),
      l10n,
    );
  }

  Widget _buildProjectFilter(BuildContext context, RouteProvider routeProvider,
      AppLocalizations l10n) {
    return _buildThreeStageFilter(
      context,
      l10n.projectRoutes,
      routeProvider.projectFilter,
      (state) => routeProvider.setProjectFilter(state),
      l10n,
    );
  }

  Color _filterStateColor(BuildContext context, FilterState state) {
    final semantic = context.semanticColors;
    switch (state) {
      case FilterState.all:
        return semantic.neutralMuted;
      case FilterState.only:
        return semantic.success;
      case FilterState.exclude:
        return Theme.of(context).colorScheme.error;
    }
  }

  Widget _buildThreeStageFilter(
    BuildContext context,
    String label,
    FilterState currentState,
    Function(FilterState) onChanged,
    AppLocalizations l10n,
  ) {
    final semantic = context.semanticColors;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: semantic.neutralMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: FilterState.values.map((state) {
              final stateColor = _filterStateColor(context, state);
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
                      color: isSelected ? stateColor : Colors.transparent,
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
                                color: scheme.outlineVariant,
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
                          color: isSelected ? scheme.surface : stateColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          state.getDisplayName(l10n),
                          style: TextStyle(
                            color: isSelected ? scheme.surface : stateColor,
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
}
