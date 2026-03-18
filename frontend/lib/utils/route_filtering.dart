import '../models/route_models.dart';
import '../models/route_filter_models.dart';

List<Route> applyRouteFilters({
  required List<Route> routes,
  required Set<String> selectedWallSections,
  required Set<int> selectedLaneIds,
  required bool hasGradeRangeFilter,
  required int? selectedMinGradeIndex,
  required int? selectedMaxGradeIndex,
  required List<String> availableGrades,
  required String? selectedRouteSetter,
  required FilterState tickedFilter,
  required FilterState likedFilter,
  required FilterState warnedFilter,
  required FilterState projectFilter,
  required Set<int> userTickedRouteIds,
  required Set<int> userLikedRouteIds,
  required Set<int> userProjectRouteIds,
}) {
  List<Route> filteredRoutes = List<Route>.from(routes);

  if (selectedWallSections.isNotEmpty) {
    filteredRoutes = filteredRoutes
        .where((route) => selectedWallSections.contains(route.wallSection))
        .toList();
  }

  if (hasGradeRangeFilter &&
      selectedMinGradeIndex != null &&
      selectedMaxGradeIndex != null) {
    final minIndex = selectedMinGradeIndex;
    final maxIndex = selectedMaxGradeIndex;
    final gradeIndexMap = <String, int>{
      for (int i = 0; i < availableGrades.length; i++) availableGrades[i]: i,
    };

    filteredRoutes = filteredRoutes.where((route) {
      final gradeName = route.gradeName;
      if (gradeName == null) {
        return false;
      }
      final gradeIndex = gradeIndexMap[gradeName];
      if (gradeIndex == null) {
        return false;
      }
      return gradeIndex >= minIndex && gradeIndex <= maxIndex;
    }).toList();
  }

  if (selectedLaneIds.isNotEmpty) {
    filteredRoutes = filteredRoutes
        .where((route) => selectedLaneIds.contains(route.lane))
        .toList();
  }

  if (selectedRouteSetter != null) {
    filteredRoutes = filteredRoutes
        .where((route) => route.routeSetter == selectedRouteSetter)
        .toList();
  }

  filteredRoutes = _applyUserRouteIdFilter(
    routes: filteredRoutes,
    routeIds: userTickedRouteIds,
    filterState: tickedFilter,
  );

  filteredRoutes = _applyUserRouteIdFilter(
    routes: filteredRoutes,
    routeIds: userLikedRouteIds,
    filterState: likedFilter,
  );

  filteredRoutes = _applyWarnedFilter(
    routes: filteredRoutes,
    filterState: warnedFilter,
  );

  filteredRoutes = _applyUserRouteIdFilter(
    routes: filteredRoutes,
    routeIds: userProjectRouteIds,
    filterState: projectFilter,
  );

  return filteredRoutes;
}

List<Route> _applyUserRouteIdFilter({
  required List<Route> routes,
  required Set<int> routeIds,
  required FilterState filterState,
}) {
  switch (filterState) {
    case FilterState.all:
      return routes;
    case FilterState.only:
      return routes.where((route) => routeIds.contains(route.id)).toList();
    case FilterState.exclude:
      return routes.where((route) => !routeIds.contains(route.id)).toList();
  }
}

List<Route> _applyWarnedFilter({
  required List<Route> routes,
  required FilterState filterState,
}) {
  switch (filterState) {
    case FilterState.all:
      return routes;
    case FilterState.only:
      return routes.where((route) => route.warningsCount > 0).toList();
    case FilterState.exclude:
      return routes.where((route) => route.warningsCount == 0).toList();
  }
}
