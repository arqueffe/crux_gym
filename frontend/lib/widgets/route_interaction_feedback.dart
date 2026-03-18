import 'package:flutter/material.dart';

void showRouteInteractionSuccess(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
  Color? backgroundColor,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      backgroundColor: backgroundColor,
    ),
  );
}

void showRouteInteractionError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}
