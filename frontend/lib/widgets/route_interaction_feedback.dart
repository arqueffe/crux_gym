import 'dart:async';

import 'package:flutter/material.dart';
import '../utils/app_semantic_colors.dart';

void showRouteInteractionSuccess(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
  Color? backgroundColor,
  String? actionLabel,
  Future<void> Function()? onAction,
  bool showDurationProgress = false,
}) {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final semantic = context.semanticColors;
  final colorScheme = Theme.of(context).colorScheme;
  final snackBarBackground = backgroundColor ?? semantic.successContainer;
  final foregroundColor = backgroundColor == null
      ? semantic.onSuccessContainer
      : colorScheme.onInverseSurface;
  scaffoldMessenger.hideCurrentSnackBar();

  final snackBarContent = showDurationProgress
      ? _RouteInteractionSnackBarContent(
          message: message,
          duration: duration,
          foregroundColor: foregroundColor,
        )
      : Text(
          message,
          style: TextStyle(color: foregroundColor),
        );

  final controller = scaffoldMessenger.showSnackBar(
    SnackBar(
      content: snackBarContent,
      duration: duration,
      backgroundColor: snackBarBackground,
      action: actionLabel != null && onAction != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: foregroundColor,
              onPressed: () {
                scaffoldMessenger.hideCurrentSnackBar();
                unawaited(onAction());
              },
            )
          : null,
    ),
  );

  if (actionLabel != null && onAction != null) {
    // Ensure action snackbars still dismiss after duration on platforms
    // where accessibility settings keep them visible indefinitely.
    Timer(duration, controller.close);
  }
}

void showRouteInteractionError(BuildContext context, String message) {
  final colorScheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: colorScheme.onErrorContainer),
      ),
      backgroundColor: colorScheme.errorContainer,
    ),
  );
}

class _RouteInteractionSnackBarContent extends StatelessWidget {
  const _RouteInteractionSnackBarContent({
    required this.message,
    required this.duration,
    required this.foregroundColor,
  });

  final String message;
  final Duration duration;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: TextStyle(color: foregroundColor),
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 1, end: 0),
          duration: duration,
          builder: (context, value, _) {
            return LinearProgressIndicator(
              value: value,
              minHeight: 3,
              backgroundColor: foregroundColor.withValues(alpha: 0.22),
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            );
          },
        ),
      ],
    );
  }
}
