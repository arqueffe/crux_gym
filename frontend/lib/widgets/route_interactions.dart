import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/route_models.dart' as models;
import '../providers/route_provider.dart';
import '../providers/auth_provider.dart';

class RouteInteractions extends StatefulWidget {
  final models.Route route;

  const RouteInteractions({super.key, required this.route});

  @override
  State<RouteInteractions> createState() => _RouteInteractionsState();
}

class _RouteInteractionsState extends State<RouteInteractions> {
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
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    final isLiked = widget.route.likes?.any(
          (like) => like.userId == currentUser.id,
        ) ??
        false;

    if (mounted && _isLiked != isLiked) {
      setState(() {
        _isLiked = isLiked;
      });
    }
  }

  void _checkIfTicked() async {
    final routeProvider = context.read<RouteProvider>();
    final tickStatus = await routeProvider.getUserTickStatus(widget.route.id);
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

            // User info display
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.currentUser;
                if (user == null) return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          user.username[0].toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Logged in as:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            user.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
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
                    backgroundColor: _isLiked
                        ? Colors.red.shade50
                        : Theme.of(context).colorScheme.primaryContainer,
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
                    backgroundColor: _isTicked
                        ? Colors.green.shade50
                        : Theme.of(context).colorScheme.primaryContainer,
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
                  label: const Text('Report Issue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade50,
                    foregroundColor: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tick information if route is ticked
            if (_isTicked && _tickData != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'You completed this route!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    if (_tickData!['tick'] != null) ...[
                      const SizedBox(height: 8),
                      Text('Attempts: ${_tickData!['tick']['attempts']}'),
                      if (_tickData!['tick']['flash'] == true)
                        Text(
                          'FLASH! ⚡',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade600,
                          ),
                        ),
                      if (_tickData!['tick']['notes'] != null &&
                          _tickData!['tick']['notes'].toString().isNotEmpty)
                        Text('Notes: ${_tickData!['tick']['notes']}'),
                    ],
                  ],
                ),
              ),

            // Current user's like status
            if (_isLiked)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite, color: Colors.red.shade600, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'You liked this route',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleLike() async {
    final routeProvider = context.read<RouteProvider>();
    final success = await routeProvider.toggleLike(widget.route.id);

    if (!mounted) return; // Check if widget is still mounted

    if (success) {
      _checkIfLiked();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLiked ? 'Route unliked!' : 'Route liked!'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${routeProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showTickDialog() {
    if (_isTicked) {
      // Show untick confirmation
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remove Tick'),
          content: const Text(
              'Are you sure you want to remove your tick for this route?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _untickRoute();
              },
              child: const Text('Remove'),
            ),
          ],
        ),
      );
    } else {
      // Show tick dialog
      int attempts = 1;
      bool flash = false;
      String notes = '';

      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Tick Route'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('Attempts: '),
                    Expanded(
                      child: Slider(
                        value: attempts.toDouble(),
                        min: 1,
                        max: 20,
                        divisions: 19,
                        label: attempts.toString(),
                        onChanged: (value) {
                          setState(() {
                            attempts = value.round();
                          });
                        },
                      ),
                    ),
                    Text(attempts.toString()),
                  ],
                ),
                CheckboxListTile(
                  title: const Text('Flash (first try)'),
                  value: flash,
                  onChanged: (value) {
                    setState(() {
                      flash = value ?? false;
                      if (flash) attempts = 1;
                    });
                  },
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (value) => notes = value,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _tickRoute(attempts: attempts, flash: flash, notes: notes);
                },
                child: const Text('Tick'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _tickRoute(
      {int attempts = 1, bool flash = false, String? notes}) async {
    final routeProvider = context.read<RouteProvider>();
    final success = await routeProvider.toggleTick(
      widget.route.id,
      attempts: attempts,
      flash: flash,
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
    );

    if (!mounted) return; // Check if widget is still mounted

    if (success) {
      _checkIfTicked();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Route ticked! 🎉'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${routeProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _untickRoute() async {
    final routeProvider = context.read<RouteProvider>();
    final success = await routeProvider.toggleTick(widget.route.id);

    if (!mounted) return; // Check if widget is still mounted

    if (success) {
      _checkIfTicked();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tick removed'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${routeProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCommentDialog() {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: commentController,
          decoration: const InputDecoration(
            labelText: 'Your comment',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (commentController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _addComment(commentController.text.trim());
              }
            },
            child: const Text('Add Comment'),
          ),
        ],
      ),
    );
  }

  Future<void> _addComment(String content) async {
    final routeProvider = context.read<RouteProvider>();
    final success = await routeProvider.addComment(widget.route.id, content);

    if (!mounted) return; // Check if widget is still mounted

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment added!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${routeProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
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
      'V10',
      'V11',
      'V12'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Propose Grade'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Proposed Grade',
                  border: OutlineInputBorder(),
                ),
                value: selectedGrade,
                items: grades
                    .map((grade) => DropdownMenuItem(
                          value: grade,
                          child: Text(grade),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGrade = value;
                  });
                },
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
            TextButton(
              onPressed: selectedGrade == null
                  ? null
                  : () {
                      Navigator.pop(context);
                      _proposeGrade(
                        selectedGrade!,
                        reasoningController.text.trim().isEmpty
                            ? null
                            : reasoningController.text.trim(),
                      );
                    },
              child: const Text('Propose'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _proposeGrade(String proposedGrade, String? reasoning) async {
    final routeProvider = context.read<RouteProvider>();
    final success = await routeProvider.proposeGrade(
      widget.route.id,
      proposedGrade,
      reasoning,
    );

    if (!mounted) return; // Check if widget is still mounted

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grade proposal submitted!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${routeProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
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
      'other'
    ];

    final warningLabels = {
      'broken_hold': 'Broken Hold',
      'safety_issue': 'Safety Issue',
      'needs_cleaning': 'Needs Cleaning',
      'loose_hold': 'Loose Hold',
      'other': 'Other'
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Report Issue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Issue Type',
                  border: OutlineInputBorder(),
                ),
                value: selectedWarningType,
                items: warningTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(warningLabels[type] ?? type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedWarningType = value;
                  });
                },
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
            TextButton(
              onPressed: (selectedWarningType == null ||
                      descriptionController.text.trim().isEmpty)
                  ? null
                  : () {
                      Navigator.pop(context);
                      _addWarning(selectedWarningType!,
                          descriptionController.text.trim());
                    },
              child: const Text('Report'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addWarning(String warningType, String description) async {
    final routeProvider = context.read<RouteProvider>();
    final success = await routeProvider.addWarning(
      widget.route.id,
      warningType,
      description,
    );

    if (!mounted) return; // Check if widget is still mounted

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Issue reported!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${routeProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
