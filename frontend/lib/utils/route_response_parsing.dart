int? parseRouteIdFromItem(dynamic item) {
  if (item is! Map) {
    return null;
  }

  final dynamic rawRouteId = item['route_id'] ?? item['routeId'];
  if (rawRouteId is int) {
    return rawRouteId;
  }
  if (rawRouteId is String) {
    return int.tryParse(rawRouteId);
  }

  return null;
}

bool parseDynamicBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == '1' || normalized == 'true';
  }
  return false;
}

Set<int> extractRouteIds(List<dynamic> items) {
  final routeIds = <int>{};

  for (final item in items) {
    final routeId = parseRouteIdFromItem(item);
    if (routeId != null) {
      routeIds.add(routeId);
    }
  }

  return routeIds;
}

Set<int> extractLeadSentTickRouteIds(List<dynamic> items) {
  final routeIds = <int>{};

  for (final item in items) {
    if (item is! Map) {
      continue;
    }

    final bool leadSend = parseDynamicBool(item['lead_send']);
    if (!leadSend) {
      continue;
    }

    final routeId = parseRouteIdFromItem(item);
    if (routeId != null) {
      routeIds.add(routeId);
    }
  }

  return routeIds;
}
