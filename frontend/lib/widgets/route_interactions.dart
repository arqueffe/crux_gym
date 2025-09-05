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
  bool _isProject = false;
  Map<String, dynamic>? _tickData;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
    _checkIfTicked();
    _checkIfProject();
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
    if (!mounted) return;
    final routeProvider = context.read<RouteProvider>();
    final tickStatus = await routeProvider.getUserTickStatus(widget.route.id);
    if (mounted) {
      setState(() {
        _tickData = tickStatus?['tick'];
        // Consider as "ticked" if there are any attempts or sends
        _isTicked = _tickData != null &&
            ((_tickData!['attempts'] ?? 0) > 0 ||
                (_tickData!['top_rope_send'] ?? false) ||
                (_tickData!['lead_send'] ?? false));
      });
    }
  }

  void _checkIfProject() async {
    if (!mounted) return;
    final routeProvider = context.read<RouteProvider>();
    final projectStatus = await routeProvider.getProjectStatus(widget.route.id);
    if (mounted) {
      setState(() {
        _isProject = projectStatus?['is_project'] ?? false;
      });
    }
  }

  @override
  void didUpdateWidget(RouteInteractions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.route.id != widget.route.id) {
      _checkIfLiked();
      _checkIfTicked();
      _checkIfProject();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: Card(
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
                      label: Text(_isLiked ? 'Liked' : 'Like'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLiked
                            ? Colors.red.shade50
                            : Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showTickDialog(),
                      icon: Icon(
                        _isTicked
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                        color: _isTicked ? Colors.green : null,
                      ),
                      label: Text(_isTicked ? 'Progress' : 'Track'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isTicked
                            ? Colors.green.shade50
                            : Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _toggleProject(),
                      icon: Icon(
                        _isProject ? Icons.flag : Icons.flag_outlined,
                        color: _isProject ? Colors.blue : null,
                      ),
                      label: Text(_isProject ? 'Project' : 'Set Project'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isProject
                            ? Colors.blue.shade50
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

                // Tick information if route has progress
                if (_isTicked && _tickData != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1)
                          : Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.05),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.trending_up,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Your Progress',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Attempts: ${_tickData!['attempts'] ?? 0}'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _tickData!['top_rope_send'] == true
                                  ? Icons.check
                                  : Icons.close,
                              color: _tickData!['top_rope_send'] == true
                                  ? Colors.green
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            const Text('Top Rope'),
                            if (_tickData!['top_rope_flash'] == true)
                              const Text(' (Flash)',
                                  style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _tickData!['lead_send'] == true
                                  ? Icons.check
                                  : Icons.close,
                              color: _tickData!['lead_send'] == true
                                  ? Colors.green
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            const Text('Lead'),
                            if (_tickData!['lead_flash'] == true)
                              const Text(' (Flash)',
                                  style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (_tickData!['notes'] != null &&
                            _tickData!['notes'].toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Notes: ${_tickData!['notes']}',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ));
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

  Future<void> _toggleProject() async {
    if (!mounted) return;
    final routeProvider = context.read<RouteProvider>();

    bool success;
    if (_isProject) {
      success = await routeProvider.removeProject(widget.route.id);
    } else {
      // Check if user has already lead sent this route
      if (_tickData != null && (_tickData!['lead_send'] ?? false)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Cannot mark sent routes as projects. You have already lead sent this route.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      success = await routeProvider.addProject(widget.route.id);
    }

    if (!mounted) return; // Check if widget is still mounted

    if (success) {
      _checkIfProject();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isProject ? 'Project removed!' : 'Route added to projects!'),
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
      // Show detailed tick information and options
      _showTickManagementDialog();
    } else {
      // Show new tick dialog with multiple options
      _showNewTickDialog();
    }
  }

  void _showTickManagementDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Manage Tick'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current tick information
                if (_tickData != null) ...[
                  const Text('Current Progress:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Attempts: ${_tickData!['attempts'] ?? 0}'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                          _tickData!['top_rope_send'] == true
                              ? Icons.check
                              : Icons.close,
                          color: _tickData!['top_rope_send'] == true
                              ? Colors.green
                              : Colors.red,
                          size: 16),
                      const SizedBox(width: 4),
                      const Text('Top Rope Send'),
                      if (_tickData!['top_rope_flash'] == true)
                        const Text(' (Flash)',
                            style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                          _tickData!['lead_send'] == true
                              ? Icons.check
                              : Icons.close,
                          color: _tickData!['lead_send'] == true
                              ? Colors.green
                              : Colors.red,
                          size: 16),
                      const SizedBox(width: 4),
                      const Text('Lead Send'),
                      if (_tickData!['lead_flash'] == true)
                        const Text(' (Flash)',
                            style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (_tickData!['notes'] != null &&
                      _tickData!['notes'].isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text('Notes:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(_tickData!['notes']),
                  ],
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showAddProgressDialog();
              },
              child: const Text('Add Progress'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showRemoveTickDialog();
              },
              child: const Text('Remove Tick',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewTickDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Track Progress'),
        content: const Text('What would you like to track for this route?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddAttemptsDialog();
            },
            child: const Text('Add Attempts'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showMarkSendDialog();
            },
            child: const Text('Mark Send'),
          ),
        ],
      ),
    );
  }

  void _showAddAttemptsDialog() {
    int attempts = 1;
    // Pre-populate with existing notes if available
    String notes = _tickData?['notes']?.toString() ?? '';
    final notesController = TextEditingController(text: notes);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Attempts'),
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
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  border: const OutlineInputBorder(),
                  helperText: _tickData?['notes'] != null &&
                          _tickData!['notes'].toString().isNotEmpty
                      ? 'Your previous notes are loaded. You can edit or add to them.'
                      : 'Add notes about your attempts',
                  suffixIcon: _tickData?['notes'] != null &&
                          _tickData!['notes'].toString().isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: 'Add entry below existing notes',
                          onPressed: () {
                            final currentNotes = notesController.text;
                            final newEntry =
                                '\n\n--- ${DateTime.now().toString().split('.')[0]} ---\n';
                            notesController.text = currentNotes + newEntry;
                            notesController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: notesController.text.length),
                            );
                          },
                        )
                      : null,
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
                _addAttempts(
                    attempts: attempts, notes: notesController.text.trim());
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMarkSendDialog() {
    String sendType = 'top_rope';
    // Pre-populate with existing notes if available
    String notes = _tickData?['notes']?.toString() ?? '';
    final notesController = TextEditingController(text: notes);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Mark Send'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Send Type:'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: sendType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'top_rope', child: Text('Top Rope')),
                  DropdownMenuItem(value: 'lead', child: Text('Lead')),
                ],
                onChanged: (value) {
                  setState(() {
                    sendType = value ?? 'top_rope';
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  border: const OutlineInputBorder(),
                  helperText: _tickData?['notes'] != null &&
                          _tickData!['notes'].toString().isNotEmpty
                      ? 'Your previous notes are loaded. You can edit or add to them.'
                      : 'Add notes about this send',
                  suffixIcon: _tickData?['notes'] != null &&
                          _tickData!['notes'].toString().isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: 'Add entry below existing notes',
                          onPressed: () {
                            final currentNotes = notesController.text;
                            final newEntry =
                                '\n\n--- ${DateTime.now().toString().split('.')[0]} ---\n';
                            notesController.text = currentNotes + newEntry;
                            notesController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: notesController.text.length),
                            );
                          },
                        )
                      : null,
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
                _markSend(
                    sendType: sendType, notes: notesController.text.trim());
              },
              child: const Text('Mark Send'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProgressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Progress'),
        content: const Text('What would you like to add?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddAttemptsDialog();
            },
            child: const Text('Add Attempts'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showMarkSendDialog();
            },
            child: const Text('Mark Send'),
          ),
        ],
      ),
    );
  }

  void _showRemoveTickDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Tick'),
        content: const Text(
            'Are you sure you want to remove all progress for this route?'),
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
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _addAttempts({int attempts = 1, String? notes}) async {
    final routeProvider = context.read<RouteProvider>();
    try {
      await routeProvider.addAttempts(widget.route.id, attempts, notes: notes);
      _checkIfTicked();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Added $attempts attempt${attempts == 1 ? '' : 's'}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add attempts: $e')),
        );
      }
    }
  }

  Future<void> _markSend({required String sendType, String? notes}) async {
    final routeProvider = context.read<RouteProvider>();
    try {
      await routeProvider.markSend(widget.route.id, sendType, notes: notes);
      if (mounted) {
        _checkIfTicked();
        _checkIfProject(); // Also check project status as it may have changed
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Marked ${sendType.replaceAll('_', ' ')} send!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark send: $e')),
        );
      }
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

  Future<void> _showGradeProposalDialog() async {
    final routeProvider = context.read<RouteProvider>();

    // Ensure grade definitions are loaded
    if (routeProvider.gradeDefinitions.isEmpty) {
      await routeProvider.loadGradeDefinitions();
    }

    // Check if user already has a proposal for this route
    final existingProposal =
        await routeProvider.getUserGradeProposal(widget.route.id);

    // Get grades from route provider, sorted by difficulty order
    final grades = routeProvider.gradeDefinitions
        .map((gradeDefinition) => gradeDefinition['grade'] as String)
        .toList()
      ..sort((a, b) {
        final aOrder = routeProvider.gradeDefinitions
            .firstWhere((g) => g['grade'] == a)['difficulty_order'] as int;
        final bOrder = routeProvider.gradeDefinitions
            .firstWhere((g) => g['grade'] == b)['difficulty_order'] as int;
        return aOrder.compareTo(bOrder);
      });

    // Set selected grade, ensuring it exists in the grades list
    String? selectedGrade = existingProposal?.proposedGrade;
    if (selectedGrade != null && !grades.contains(selectedGrade)) {
      // If the existing grade is not in our list, don't pre-select it
      selectedGrade = null;
    }

    final reasoningController = TextEditingController(
      text: existingProposal?.reasoning ?? '',
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existingProposal != null
                ? 'Update Grade Proposal'
                : 'Propose Grade'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (existingProposal != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedGrade != null
                                ? 'You already proposed "${existingProposal.proposedGrade}". You can change your grade and update your reasoning below.'
                                : 'You had a previous proposal that is no longer valid. Please select a new grade.',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Proposed Grade',
                    border: const OutlineInputBorder(),
                    helperText: existingProposal != null
                        ? 'You can change your proposed grade'
                        : 'Select a grade to propose',
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
                  isExpanded: true,
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
                child: Text(existingProposal != null ? 'Update' : 'Propose'),
              ),
            ],
          );
        },
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
          content: Text('Grade proposal updated!'),
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
