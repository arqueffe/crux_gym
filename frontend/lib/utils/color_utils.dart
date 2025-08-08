import 'package:flutter/material.dart';

class ColorUtils {
  /// Parse a hex color string into a Flutter Color object
  static Color parseHexColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.grey;
    try {
      // Remove the # if present
      final hex = hexColor.replaceAll('#', '');
      // Parse the hex string to integer
      final int colorValue = int.parse(hex, radix: 16);
      // Create Color with full opacity (0xFF prefix)
      return Color(0xFF000000 | colorValue);
    } catch (e) {
      // Return grey if parsing fails
      return Colors.grey;
    }
  }

  /// Get grade color from backend data with fallback to default colors
  static Color getGradeColor(String grade, Map<String, String>? gradeColors) {
    // Try to get color from the backend data first
    final backendColor = gradeColors?[grade];
    if (backendColor != null) {
      return parseHexColor(backendColor);
    }

    // Fallback to default colors if backend data is not available
    if (grade.startsWith('3') || grade.startsWith('4')) return Colors.green;
    if (grade.startsWith('5')) return Colors.yellow.shade700;
    if (grade.startsWith('6')) return Colors.orange;
    if (grade.startsWith('7')) return Colors.red;
    if (grade.startsWith('8') || grade.startsWith('9')) return Colors.purple;
    return Colors.grey;
  }

  /// Get hold color from color name with fallback
  static Color getHoldColor(String? colorName, String? colorHex) {
    // Prefer hex code if available
    if (colorHex != null && colorHex.isNotEmpty) {
      return parseHexColor(colorHex);
    }

    // Fallback to name-based parsing
    if (colorName == null) return Colors.grey;
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'cyan':
        return Colors.cyan;
      case 'teal':
        return Colors.teal;
      case 'lime':
        return Colors.lime;
      case 'indigo':
        return Colors.indigo;
      case 'brown':
        return Colors.brown;
      case 'amber':
        return Colors.amber;
      case 'gray':
      case 'grey':
        return Colors.grey;
      case 'maroon':
        return Colors.red.shade800;
      case 'navy':
        return Colors.blue.shade900;
      case 'olive':
        return Colors.brown.shade600;
      case 'magenta':
        return Colors.purpleAccent;
      default:
        return Colors.grey;
    }
  }
}
