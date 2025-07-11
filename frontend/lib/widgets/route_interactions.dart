import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/route_models.dart' as models;
import '../providers/route_provider.dart';

class RouteInteractions extends StatefulWidget {
  final models.Route route;

  const RouteInteractions({super.key, required this.route});

  @override
  State<RouteInteractions> createState() => _RouteInteractionsState();
}

class _RouteInteractionsState extends State<RouteInteractions> {
  final _userNameController = TextEditingController(text: 'Anonymous User');
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  void _checkIfLiked() {
    _isLiked = widget.route.likes?.any(
          (like) => like.userName == _userNameController.text,
        ) ??
        false;
  }

  @override
  void didUpdateWidget(RouteInteractions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.route.id != widget.route.id) {
      _checkIfLiked();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interactions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // User Name Input
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _toggleLike(),
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : null,
                  ),
                  label: Text(_isLiked ? 'Unlike' : 'Like'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLiked ? Colors.red[50] : null,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCommentDialog(),
                  icon: const Icon(Icons.comment),
                  label: const Text('Comment'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showGradeProposalDialog(),
                  icon: const Icon(Icons.grade),
                  label: const Text('Propose Grade'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showWarningDialog(),
                  icon: const Icon(Icons.warning),
                  label: const Text('Report Warning'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[50],
                    foregroundColor: Colors.orange[800],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleLike() async {
    if (_userNameController.text.trim().isEmpty) {
      _showSnackBar('Please enter your name');
      return;
    }

    final routeProvider = context.read<RouteProvider>();
    final success = await routeProvider.toggleLike(
      widget.route.id,
      _userNameController.text.trim(),
    );

    if (success) {
      setState(() {
        _isLiked = !_isLiked;
      });
      _showSnackBar(_isLiked ? 'Route liked!' : 'Route unliked!');
    } else {
      _showSnackBar('Failed to toggle like');
    }
  }

  void _showCommentDialog() {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Your comment',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _submitComment(commentController.text),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _submitComment(String content) async {
    if (_userNameController.text.trim().isEmpty || content.trim().isEmpty) {
      _showSnackBar('Please enter your name and comment');
      return;
    }

    Navigator.pop(context);

    final routeProvider = context.read<RouteProvider>();
    final success = await routeProvider.addComment(
      widget.route.id,
      _userNameController.text.trim(),
      content.trim(),
    );

    if (success) {
      _showSnackBar('Comment added!');
    } else {
      _showSnackBar('Failed to add comment');
    }
  }

  void _showGradeProposalDialog() {
    String? selectedGrade;
    final reasoningController = TextEditingController();
    final grades = [
      'V0',
      'V1',
      'V2',
      'V3',
      'V4',
      'V5',
      'V6',
      'V7',
      'V8',
      'V9',
      'V10'
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Propose Grade'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Proposed Grade',
                border: OutlineInputBorder(),
              ),
              items: grades
                  .map((grade) => DropdownMenuItem(
                        value: grade,
                        child: Text(grade),
                      ))
                  .toList(),
              onChanged: (value) => selectedGrade = value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasoningController,
              decoration: const InputDecoration(
                labelText: 'Reasoning (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                _submitGradeProposal(selectedGrade, reasoningController.text),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _submitGradeProposal(String? grade, String reasoning) async {
    if (_userNameController.text.trim().isEmpty || grade == null) {
      _showSnackBar('Please enter your name and select a grade');
      return;
    }

    Navigator.pop(context);

    final routeProvider = context.read<RouteProvider>();
    final success = await routeProvider.proposeGrade(
      widget.route.id,
      _userNameController.text.trim(),
      grade,
      reasoning.trim().isEmpty ? null : reasoning.trim(),
    );

    if (success) {
      _showSnackBar('Grade proposal submitted!');
    } else {
      _showSnackBar('Failed to submit grade proposal');
    }
  }

  void _showWarningDialog() {
    String? selectedWarningType;
    final descriptionController = TextEditingController();
    final warningTypes = [
      'broken_hold',
      'safety_issue',
      'needs_cleaning',
      'loose_hold',
      'sharp_hold',
      'other'
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Warning'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Warning Type',
                border: OutlineInputBorder(),
              ),
              items: warningTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.replaceAll('_', ' ').toUpperCase()),
                      ))
                  .toList(),
              onChanged: (value) => selectedWarningType = value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                _submitWarning(selectedWarningType, descriptionController.text),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _submitWarning(String? warningType, String description) async {
    if (_userNameController.text.trim().isEmpty ||
        warningType == null ||
        description.trim().isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    Navigator.pop(context);

    final routeProvider = context.read<RouteProvider>();
    final success = await routeProvider.addWarning(
      widget.route.id,
      _userNameController.text.trim(),
      warningType,
      description.trim(),
    );

    if (success) {
      _showSnackBar('Warning reported!');
    } else {
      _showSnackBar('Failed to report warning');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }
}
