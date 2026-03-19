class GradeUtils {
  static String? _extractGradeLabel(Map<String, dynamic> gradeDefinition) {
    final grade = gradeDefinition['grade']?.toString();
    if (grade != null && grade.trim().isNotEmpty) {
      return grade;
    }

    final frenchName = gradeDefinition['french_name']?.toString();
    if (frenchName != null && frenchName.trim().isNotEmpty) {
      return frenchName;
    }

    return null;
  }

  static String _normalizeGradeLabel(String grade) {
    return grade.trim().toLowerCase();
  }

  static int? _parseDifficultyOrder(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.round();
    }

    if (value is String) {
      final intValue = int.tryParse(value);
      if (intValue != null) {
        return intValue;
      }

      final doubleValue = double.tryParse(value);
      if (doubleValue != null) {
        return doubleValue.round();
      }
    }

    return null;
  }

  static Map<String, int> _buildGradeDifficultyMap(
    List<Map<String, dynamic>> gradeDefinitions,
  ) {
    final Map<String, int> gradeDifficultyMap = {};
    for (final gradeDefinition in gradeDefinitions) {
      final grade = _extractGradeLabel(gradeDefinition);
      final difficultyOrder = _parseDifficultyOrder(
        gradeDefinition['difficulty_order'],
      );

      if (grade != null && difficultyOrder != null) {
        gradeDifficultyMap[_normalizeGradeLabel(grade)] = difficultyOrder;
      }
    }

    return gradeDifficultyMap;
  }

  static double? calculateAverageProposedDifficulty(
    List<dynamic>? gradeProposals,
    List<Map<String, dynamic>> gradeDefinitions,
  ) {
    if (gradeProposals == null ||
        gradeProposals.isEmpty ||
        gradeDefinitions.isEmpty) {
      return null;
    }

    final gradeDifficultyMap = _buildGradeDifficultyMap(gradeDefinitions);
    if (gradeDifficultyMap.isEmpty) {
      return null;
    }

    double totalDifficulty = 0;
    int validProposalsCount = 0;

    for (final proposal in gradeProposals) {
      String? proposedGrade;

      try {
        if (proposal is Map<String, dynamic>) {
          final gradeValue = proposal['proposed_grade'];
          proposedGrade = gradeValue?.toString();
        } else if (proposal != null) {
          final dynamicProposal = proposal as dynamic;
          proposedGrade = dynamicProposal.proposedGrade?.toString();
        }
      } catch (e) {
        continue;
      }

      if (proposedGrade != null &&
          proposedGrade.isNotEmpty &&
          gradeDifficultyMap.containsKey(
            _normalizeGradeLabel(proposedGrade),
          )) {
        totalDifficulty +=
            gradeDifficultyMap[_normalizeGradeLabel(proposedGrade)]!;
        validProposalsCount++;
      }
    }

    if (validProposalsCount == 0) {
      return null;
    }

    return totalDifficulty / validProposalsCount;
  }

  static int compareAverageProposedToGrade(
    List<dynamic>? gradeProposals,
    String grade,
    List<Map<String, dynamic>> gradeDefinitions,
  ) {
    final averageDifficulty = calculateAverageProposedDifficulty(
      gradeProposals,
      gradeDefinitions,
    );
    if (averageDifficulty == null) {
      return 0;
    }

    final baseDifficulty = getGradeDifficulty(grade, gradeDefinitions);
    if (averageDifficulty > baseDifficulty) {
      return 1;
    }
    if (averageDifficulty < baseDifficulty) {
      return -1;
    }
    return 0;
  }

  /// Calculate the average proposed grade using grade definitions from the backend
  static String? calculateAverageProposedGrade(
    List<dynamic>? gradeProposals,
    List<Map<String, dynamic>> gradeDefinitions,
  ) {
    if (gradeProposals == null ||
        gradeProposals.isEmpty ||
        gradeDefinitions.isEmpty) {
      return null;
    }

    // Create a map of grade to difficulty order for quick lookup
    final gradeDifficultyMap = _buildGradeDifficultyMap(gradeDefinitions);

    double totalDifficulty = 0;
    int validProposalsCount = 0;

    // Sum up the difficulty orders of all valid proposed grades
    for (final proposal in gradeProposals) {
      String? proposedGrade;

      try {
        if (proposal is Map<String, dynamic>) {
          final gradeValue = proposal['proposed_grade'];
          proposedGrade = gradeValue?.toString();
        } else if (proposal != null) {
          // Assuming proposal has a proposedGrade property
          final dynamicProposal = proposal as dynamic;
          proposedGrade = dynamicProposal.proposedGrade?.toString();
        }
      } catch (e) {
        // Skip this proposal if we can't extract the grade
        continue;
      }

      if (proposedGrade != null &&
          proposedGrade.isNotEmpty &&
          gradeDifficultyMap.containsKey(
            _normalizeGradeLabel(proposedGrade),
          )) {
        totalDifficulty +=
            gradeDifficultyMap[_normalizeGradeLabel(proposedGrade)]!;
        validProposalsCount++;
      }
    }

    if (validProposalsCount == 0) return null;

    // Calculate average difficulty order
    final averageDifficulty = (totalDifficulty / validProposalsCount).round();

    // Find the grade with the closest difficulty order to the average
    String? closestGrade;
    int closestDifference = double.maxFinite.toInt();

    for (final gradeDefinition in gradeDefinitions) {
      final grade = _extractGradeLabel(gradeDefinition);
      final difficulty = _parseDifficultyOrder(
        gradeDefinition['difficulty_order'],
      );

      if (grade != null && difficulty != null) {
        final gradeStr = grade;
        final difference = (difficulty - averageDifficulty).abs();

        if (difference < closestDifference) {
          closestDifference = difference;
          closestGrade = gradeStr;
        }
      }
    }

    return closestGrade;
  }

  /// Get the difficulty order for a specific grade
  static int getGradeDifficulty(
    String grade,
    List<Map<String, dynamic>> gradeDefinitions,
  ) {
    final normalizedTarget = _normalizeGradeLabel(grade);

    for (final gradeDefinition in gradeDefinitions) {
      final gradeValue = _extractGradeLabel(gradeDefinition);
      final difficultyOrder = _parseDifficultyOrder(
        gradeDefinition['difficulty_order'],
      );

      if (gradeValue != null &&
          difficultyOrder != null &&
          _normalizeGradeLabel(gradeValue) == normalizedTarget) {
        return difficultyOrder;
      }
    }
    return 0; // Default for unknown grades
  }

  /// Compare two grades based on their difficulty order
  static int compareGrades(
    String gradeA,
    String gradeB,
    List<Map<String, dynamic>> gradeDefinitions,
  ) {
    final difficultyA = getGradeDifficulty(gradeA, gradeDefinitions);
    final difficultyB = getGradeDifficulty(gradeB, gradeDefinitions);
    return difficultyA.compareTo(difficultyB);
  }
}
