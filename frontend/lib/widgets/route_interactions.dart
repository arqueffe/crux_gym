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
  bool _isTicked = false;
  Map<String, dynamic>? _tickData;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
    _checkIfTicked();
  }

  void _checkIfLiked() {
    final isLiked = widget.route.likes?.any(
          (like) => like.userName == _userNameController.text.trim(),
        ) ??
        false;

    if (_isLiked != isLiked) {
      setState(() {
        _isLiked = isLiked;
      });
    }
  }

  void _checkIfTicked() async {
    final routeProvider = context.read<RouteProvider>();
    final tickStatus = await routeProvider.getUserTickStatus(
      widget.route.id,
      _userNameController.text,
    );
    if (mounted) {
      setState(() {
        _isTicked = tickStatus?['ticked'] ?? false;
        _tickData = tickStatus?['tick'];
      });
    }
  }

  @override
  void didUpdateWidget(RouteInteractions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.route.id != widget.route.id) {
      _checkIfLiked();
      _checkIfTicked();
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
              onChanged: (value) {
                _checkIfLiked();
                _checkIfTicked();
              },
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
                  onPressed: () => _showTickDialog(),
                  icon: Icon(
                    _isTicked ? Icons.check_circle : Icons.check_circle_outline,
                    color: _isTicked ? Colors.green : null,
                  ),
                  label: Text(_isTicked ? 'Ticked' : 'Tick'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTicked ? Colors.green[50] : null,
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
    final wasLiked = _isLiked;
    final success = await routeProvider.toggleLike(
      widget.route.id,
      _userNameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      // Get the updated route from the provider and check like status
      models.Route? updatedRoute;
      try {
        updatedRoute = routeProvider.selectedRoute ??
            routeProvider.routes.firstWhere((r) => r.id == widget.route.id);
      } catch (e) {
        // If we can't find the updated route, fall back to the original
        updatedRoute = widget.route;
      }

      final isNowLiked = updatedRoute.likes?.any(
              (like) => like.userName == _userNameController.text.trim()) ??
          false;

      setState(() {
        _isLiked = isNowLiked;
      });
      _showSnackBar(!wasLiked ? 'Route liked!' : 'Route unliked!');
    } else {
      _showSnackBar('Failed to toggle like');
    }
  }

  void _showTickDialog() {
    if (_isTicked) {
      // If already ticked, show option to untick
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Untick Route'),
          content: const Text(
              'Are you sure you want to remove your tick for this route?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _toggleTick();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Untick'),
            ),
          ],
        ),
      );
    } else {
      // Show tick dialog with options
      int attempts = 1;
      bool flash = false;
      final notesController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Tick Route'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('Attempts: '),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: attempts,
                      items: List.generate(10, (i) => i + 1)
                          .map((i) => DropdownMenuItem(
                                value: i,
                                child: Text('$i'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          attempts = value!;
                          flash = attempts == 1;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Flash (first attempt)'),
                  value: flash,
                  onChanged: (value) {
                    setDialogState(() {
                      flash = value!;
                      if (flash) attempts = 1;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _submitTick(attempts, flash, notesController.text);
                },
                child: const Text('Tick'),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _toggleTick() async {
    if (_userNameController.text.trim().isEmpty) {
      _showSnackBar('Please enter your name');
      return;
    }

    final routeProvider = context.read<RouteProvider>();
    final success = await routeProvider.toggleTick(
      widget.route.id,
      _userNameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _isTicked = !_isTicked;
        if (!_isTicked) _tickData = null;
      });
      _showSnackBar(_isTicked ? 'Route ticked!' : 'Tick removed!');
      if (_isTicked) {
        _checkIfTicked(); // Refresh tick data
      }
    } else {
      _showSnackBar('Failed to toggle tick');
    }
  }

  void _submitTick(int attempts, bool flash, String notes) async {
    if (_userNameController.text.trim().isEmpty) {
      _showSnackBar('Please enter your name');
      return;
    }

    final routeProvider = context.read<RouteProvider>();
    final success = await routeProvider.toggleTick(
      widget.route.id,
      _userNameController.text.trim(),
      attempts: attempts,
      flash: flash,
      notes: notes.trim().isEmpty ? null : notes.trim(),
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _isTicked = true;
      });
      _showSnackBar('Route ticked!');
      _checkIfTicked(); // Refresh tick data
    } else {
      _showSnackBar('Failed to tick route');
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

    if (!mounted) return;

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

    if (!mounted) return;

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

    if (!mounted) return;

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
