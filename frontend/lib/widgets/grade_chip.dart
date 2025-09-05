import 'package:flutter/material.dart';
import '../utils/color_utils.dart';

class GradeChip extends StatelessWidget {
  final String grade;
  final String? gradeColorHex;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final BorderRadius? borderRadius;
  final Widget? icon;

  const GradeChip({
    super.key,
    required this.grade,
    this.gradeColorHex,
    this.padding,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.icon,
  });

  /// Determines if the text should be dark based on the background color luminance
  static bool _shouldUseDarkText(Color backgroundColor) {
    // Calculate luminance using the relative luminance formula
    final double luminance = backgroundColor.computeLuminance();
    // Use dark text on light backgrounds (luminance > 0.5)
    return luminance > 0.5;
  }

  /// Gets the appropriate text color based on the background color
  static Color getTextColor(Color backgroundColor) {
    return _shouldUseDarkText(backgroundColor) ? Colors.black : Colors.white;
  }

  /// Gets the appropriate text color based on the background color
  static Color _getTextColor(Color backgroundColor) {
    return _shouldUseDarkText(backgroundColor) ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = gradeColorHex != null
        ? ColorUtils.parseHexColor(gradeColorHex!)
        : Colors.grey;

    final textColor = _getTextColor(backgroundColor);

    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(color: textColor),
              child: icon!,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            grade,
            style: TextStyle(
              color: textColor,
              fontWeight: fontWeight ?? FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

/// A variant of GradeChip specifically for average proposed grades
class AverageGradeChip extends StatelessWidget {
  final String grade;
  final String? gradeColorHex;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final BorderRadius? borderRadius;

  const AverageGradeChip({
    super.key,
    required this.grade,
    this.gradeColorHex,
    this.padding,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = gradeColorHex != null
        ? ColorUtils.parseHexColor(gradeColorHex!)
        : Colors.grey;

    final textColor = GradeChip._getTextColor(backgroundColor);

    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people,
            color: textColor,
            size: fontSize != null ? fontSize! * 0.8 : 12,
          ),
          const SizedBox(width: 4),
          Text(
            grade,
            style: TextStyle(
              color: textColor,
              fontWeight: fontWeight ?? FontWeight.bold,
              fontSize: fontSize ?? 12,
            ),
          ),
        ],
      ),
    );
  }
}
