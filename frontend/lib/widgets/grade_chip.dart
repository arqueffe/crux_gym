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

  static double _contrastRatio(Color fg, Color bg) {
    final fgLum = fg.computeLuminance();
    final bgLum = bg.computeLuminance();
    final lighter = fgLum > bgLum ? fgLum : bgLum;
    final darker = fgLum > bgLum ? bgLum : fgLum;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Picks the most legible text color (black or white) for the chip background.
  static Color getTextColor(Color backgroundColor) {
    const dark = Colors.black;
    const light = Colors.white;
    final darkContrast = _contrastRatio(dark, backgroundColor);
    final lightContrast = _contrastRatio(light, backgroundColor);
    return darkContrast >= lightContrast ? dark : light;
  }

  static Color _getTextColor(Color backgroundColor) {
    return getTextColor(backgroundColor);
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
        border: Border.all(
          color: textColor == Colors.white
              ? Colors.white.withValues(alpha: 0.35)
              : Colors.black.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
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
          color: textColor == Colors.white
              ? Colors.white.withValues(alpha: 0.45)
              : Colors.black.withValues(alpha: 0.2),
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
