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
      final grade = gradeDefinition['grade'];
      final difficultyOrder = gradeDefinition['difficulty_order'];

      if (grade != null && difficultyOrder != null) {
        gradeDifficultyMap[grade as String] = difficultyOrder as int;
      }
    }

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
      final grade = gradeDefinition['grade'];
      final difficulty = gradeDefinition['difficulty_order'];

      if (grade != null && difficulty != null) {
        final gradeStr = grade as String;
        final difficultyInt = difficulty as int;
        final difference = (difficultyInt - averageDifficulty).abs();

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
    for (final gradeDefinition in gradeDefinitions) {
      final gradeValue = gradeDefinition['grade'];
      final difficultyOrder = gradeDefinition['difficulty_order'];

      if (gradeValue != null &&
          difficultyOrder != null &&
          gradeValue == grade) {
        return difficultyOrder as int;
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
