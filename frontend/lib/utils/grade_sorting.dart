double gradeOrderValue(
  String grade, {
  List<Map<String, dynamic>> gradeDefinitions = const [],
}) {
  final normalizedGrade = grade.trim();
  final parsedFrench = _parseFrenchGradeOrder(normalizedGrade);
  final definitionOrder =
      _extractDefinitionOrder(normalizedGrade, gradeDefinitions);

  // Keep backend-defined ordering as the primary source when present,
  // but use parsed grade detail (e.g. 6b+) as a tie-breaker.
  if (definitionOrder != null) {
    final tieBreaker = parsedFrench ?? 0.0;
    return definitionOrder * 1000.0 + tieBreaker / 1000.0;
  }

  if (parsedFrench != null) {
    return parsedFrench;
  }

  return 0.0;
}

double? _extractDefinitionOrder(
  String grade,
  List<Map<String, dynamic>> gradeDefinitions,
) {
  for (final definition in gradeDefinitions) {
    final frenchName = definition['french_name']?.toString().trim();
    if (frenchName == null || frenchName.toLowerCase() != grade.toLowerCase()) {
      continue;
    }

    final dynamic preferredValue =
        definition['difficulty_order'] ?? definition['value'];

    if (preferredValue is num) {
      return preferredValue.toDouble();
    }

    if (preferredValue is String) {
      return double.tryParse(preferredValue);
    }
  }

  return null;
}

double? _parseFrenchGradeOrder(String grade) {
  final normalized = grade.trim().toLowerCase().replaceAll(' ', '');

  if (normalized.startsWith('v')) {
    final vValue = int.tryParse(normalized.substring(1));
    return vValue != null ? 10000.0 + (vValue * 10.0) : null;
  }

  final match = RegExp(r'^(\d+)([abc])?(\+)?$').firstMatch(normalized);
  if (match == null) {
    return null;
  }

  final base = int.tryParse(match.group(1) ?? '') ?? 0;
  final letter = match.group(2);
  final plus = match.group(3) != null;

  int letterOffset;
  switch (letter) {
    case 'a':
      letterOffset = 0;
      break;
    case 'b':
      letterOffset = 10;
      break;
    case 'c':
      letterOffset = 20;
      break;
    default:
      letterOffset = 0;
  }

  final plusOffset = plus ? 5 : 0;
  return base * 100.0 + letterOffset + plusOffset;
}
