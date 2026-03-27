import 'dart:async';

import 'package:flutter/material.dart';

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
  scaffoldMessenger.hideCurrentSnackBar();

  final snackBarContent = showDurationProgress
      ? _RouteInteractionSnackBarContent(
          message: message,
          duration: duration,
        )
      : Text(message);

  final controller = scaffoldMessenger.showSnackBar(
    SnackBar(
      content: snackBarContent,
      duration: duration,
      backgroundColor: backgroundColor,
      action: actionLabel != null && onAction != null
          ? SnackBarAction(
              label: actionLabel,
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
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}

class _RouteInteractionSnackBarContent extends StatelessWidget {
  const _RouteInteractionSnackBarContent({
    required this.message,
    required this.duration,
  });

  final String message;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 1, end: 0),
          duration: duration,
          builder: (context, value, _) {
            return LinearProgressIndicator(
              value: value,
              minHeight: 3,
              backgroundColor: Colors.white.withAlpha(70),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            );
          },
        ),
      ],
    );
  }
}
