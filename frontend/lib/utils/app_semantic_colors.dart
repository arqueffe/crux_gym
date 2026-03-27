import 'package:flutter/material.dart';

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.neutralMuted,
  });

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;

  final Color neutralMuted;

  factory AppSemanticColors.light(ColorScheme scheme) {
    return AppSemanticColors(
      success: const Color(0xFF1B7F3A),
      onSuccess: Colors.white,
      successContainer: const Color(0xFFD7F4DD),
      onSuccessContainer: const Color(0xFF0A3A1B),
      warning: const Color(0xFFB86A00),
      onWarning: Colors.white,
      warningContainer: const Color(0xFFFFE8CB),
      onWarningContainer: const Color(0xFF472800),
      info: scheme.primary,
      onInfo: scheme.onPrimary,
      infoContainer: scheme.primaryContainer,
      onInfoContainer: scheme.onPrimaryContainer,
      neutralMuted: scheme.onSurfaceVariant,
    );
  }

  factory AppSemanticColors.dark(ColorScheme scheme) {
    return AppSemanticColors(
      success: const Color(0xFF7DDA96),
      onSuccess: const Color(0xFF083316),
      successContainer: const Color(0xFF184D2A),
      onSuccessContainer: const Color(0xFFC6F0D2),
      warning: const Color(0xFFFFB75A),
      onWarning: const Color(0xFF3C2200),
      warningContainer: const Color(0xFF5A390E),
      onWarningContainer: const Color(0xFFFFDFC0),
      info: scheme.primary,
      onInfo: scheme.onPrimary,
      infoContainer: scheme.primaryContainer,
      onInfoContainer: scheme.onPrimaryContainer,
      neutralMuted: scheme.onSurfaceVariant,
    );
  }

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? neutralMuted,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      neutralMuted: neutralMuted ?? this.neutralMuted,
    );
  }

  @override
  AppSemanticColors lerp(
    ThemeExtension<AppSemanticColors>? other,
    double t,
  ) {
    if (other is! AppSemanticColors) {
      return this;
    }

    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer:
          Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
      neutralMuted: Color.lerp(neutralMuted, other.neutralMuted, t)!,
    );
  }
}

extension AppSemanticColorsContext on BuildContext {
  AppSemanticColors get semanticColors {
    return Theme.of(this).extension<AppSemanticColors>()!;
  }
}
