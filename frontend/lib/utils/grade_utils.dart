class GradeUtils {
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
    final Map<String, int> gradeDifficultyMap = {};
    for (final gradeDefinition in gradeDefinitions) {
      gradeDifficultyMap[gradeDefinition['grade'] as String] =
          gradeDefinition['difficulty_order'] as int;
    }

    double totalDifficulty = 0;
    int validProposalsCount = 0;

    // Sum up the difficulty orders of all valid proposed grades
    for (final proposal in gradeProposals) {
      final proposedGrade = proposal is Map<String, dynamic>
          ? proposal['proposed_grade'] as String?
          : proposal.proposedGrade as String?;

      if (proposedGrade != null &&
          gradeDifficultyMap.containsKey(proposedGrade)) {
        totalDifficulty += gradeDifficultyMap[proposedGrade]!;
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
      final grade = gradeDefinition['grade'] as String;
      final difficulty = gradeDefinition['difficulty_order'] as int;
      final difference = (difficulty - averageDifficulty).abs();

      if (difference < closestDifference) {
        closestDifference = difference;
        closestGrade = grade;
      }
    }

    return closestGrade;
  }

  /// Get the difficulty order for a specific grade
  static int getGradeDifficulty(
    String grade,
    List<Map<String, dynamic>> gradeDefinitions,
  ) {
    for (final gradeDefinition in gradeDefinitions) {
      if (gradeDefinition['grade'] == grade) {
        return gradeDefinition['difficulty_order'] as int;
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
