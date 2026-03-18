import 'package:flutter/material.dart';

import '../generated/l10n/app_localizations.dart';

class RouteWarningInput {
  final String warningType;
  final String description;

  const RouteWarningInput({
    required this.warningType,
    required this.description,
  });
}

Future<String?> showAttemptTypeDialog(
  BuildContext context,
  AppLocalizations l10n,
) {
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.addAttempts),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.selectAttemptType),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop('top_rope'),
                  icon: const Icon(Icons.arrow_upward),
                  label: Text(l10n.topRope),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop('lead'),
                  icon: const Icon(Icons.trending_up),
                  label: Text(l10n.lead),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    ),
  );
}

Future<String?> showRouteNotesDialog(
  BuildContext context, {
  required AppLocalizations l10n,
  required String routeDisplayName,
  required String initialNotes,
}) {
  final notesController = TextEditingController(text: initialNotes);

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('${l10n.note} - $routeDisplayName'),
      content: TextField(
        controller: notesController,
        decoration: InputDecoration(
          labelText: l10n.notes,
          border: const OutlineInputBorder(),
          helperText: 'Personal notes for this route',
        ),
        maxLines: 4,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, notesController.text.trim()),
          child: Text(l10n.save),
        ),
      ],
    ),
  );
}

Future<String?> showRouteCommentDialog(
  BuildContext context,
  AppLocalizations l10n,
) {
  final commentController = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.addComment),
      content: TextField(
        controller: commentController,
        decoration: InputDecoration(
          labelText: l10n.yourComment,
          border: const OutlineInputBorder(),
        ),
        maxLines: 4,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            final content = commentController.text.trim();
            if (content.isNotEmpty) {
              Navigator.pop(context, content);
            }
          },
          child: Text(l10n.addComment),
        ),
      ],
    ),
  );
}

Future<RouteWarningInput?> showRouteWarningDialog(
  BuildContext context,
  AppLocalizations l10n,
) {
  String? selectedWarningType;
  final descriptionController = TextEditingController();

  const warningTypes = [
    'broken_hold',
    'safety_issue',
    'needs_cleaning',
    'loose_hold',
    'other',
  ];

  return showDialog<RouteWarningInput>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, dialogSetState) {
        final warningLabels = {
          'broken_hold': l10n.brokenHold,
          'safety_issue': l10n.safetyIssue,
          'needs_cleaning': l10n.needsCleaning,
          'loose_hold': l10n.looseHold,
          'other': l10n.other,
        };

        return AlertDialog(
          title: Text(l10n.reportIssue),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: l10n.issueTypeOptional,
                  border: const OutlineInputBorder(),
                ),
                initialValue: selectedWarningType,
                items: warningTypes
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(warningLabels[type] ?? type),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  dialogSetState(() {
                    selectedWarningType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                onChanged: (_) => dialogSetState(() {}),
                decoration: InputDecoration(
                  labelText: l10n.issueDescription,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: descriptionController.text.trim().isEmpty
                  ? null
                  : () {
                      Navigator.pop(
                        context,
                        RouteWarningInput(
                          warningType: selectedWarningType ?? l10n.other,
                          description: descriptionController.text.trim(),
                        ),
                      );
                    },
              child: Text(l10n.report),
            ),
          ],
        );
      },
    ),
  );
}
