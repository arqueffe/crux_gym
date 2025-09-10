import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generated/l10n/app_localizations.dart';
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

  void _checkIfLiked() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    final routeProvider = context.read<RouteProvider>();

    final isLiked = await routeProvider.getUserLikeStatus(widget.route.id);

    if (mounted && _isLiked != isLiked) {
      setState(() {
        _isLiked = isLiked;
      });
    }
  }

  // {id: 2, user_id: 1, route_id: 4, attempts: 1, top_rope_send: 1, lead_send: 0, top_rope_flash: 0, lead_flash: 0, flash: 0, notes: , created_at: 2025-09-10 13:50:52, updated_at: 2025-09-10 13:50:52}

  void _checkIfTicked() async {
    if (!mounted) return;
    final routeProvider = context.read<RouteProvider>();
    final tickStatus = await routeProvider.getUserTickStatus(widget.route.id);
    if (mounted) {
      setState(() {
        _isTicked = tickStatus != null &&
            ((tickStatus['top_rope_send'] ?? false) ||
                (tickStatus['lead_send'] ?? false));
      });
    }
  }

  void _checkIfProject() async {
    if (!mounted) return;
    final routeProvider = context.read<RouteProvider>();
    final projectsStatus = await routeProvider.getUserProjects();
    if (mounted) {
      setState(() {
        _isProject =
            projectsStatus.any((project) => project.routeId == widget.route.id);
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
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.interactions,
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
                    label: Text(_isLiked ? l10n.unlikeRoute : l10n.likeRoute),
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
                    label: Text(_isTicked ? l10n.progress : l10n.track),
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
                    label: Text(
                      _isProject ? l10n.removeProject : l10n.projectRoute,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isProject
                          ? Colors.blue.shade50
                          : Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showCommentDialog(),
                    icon: const Icon(Icons.comment),
                    label: Text(l10n.comment),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showGradeProposalDialog(),
                    icon: const Icon(Icons.grade),
                    label: Text(l10n.proposeGrade),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showWarningDialog(),
                    icon: const Icon(Icons.warning),
                    label: Text(l10n.reportIssue),
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
                        ? Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1)
                        : Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.05),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.yourProgress,
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
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(l10n.topRope),
                          if (_tickData!['top_rope_flash'] == true)
                            const Text(
                              ' (Flash)',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(l10n.lead),
                          if (_tickData!['lead_flash'] == true)
                            const Text(
                              ' (Flash)',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                'Cannot mark sent routes as projects. You have already lead sent this route.',
              ),
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
            _isProject ? 'Project removed!' : 'Route added to projects!',
          ),
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
        builder: (context, setState) {
          final l10n = AppLocalizations.of(context);
          return AlertDialog(
            title: Text(l10n.manageTick),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current tick information
                  if (_tickData != null) ...[
                    const Text(
                      'Current Progress:', // Add to ARB
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.attempts}: ${_tickData!['attempts'] ?? 0}',
                    ),
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
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text('${l10n.topRope} Send'), // Will fix this later
                        if (_tickData!['top_rope_flash'] == true)
                          const Text(
                            ' (Flash)',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(l10n.leadSend),
                        if (_tickData!['lead_flash'] == true)
                          const Text(
                            ' (Flash)',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    if (_tickData!['notes'] != null &&
                        _tickData!['notes'].isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Notes:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                child: Text(l10n.close),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showAddProgressDialog();
                },
                child: Text(l10n.addProgress),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showRemoveTickDialog();
                },
                child: Text(
                  l10n.removeTick,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showNewTickDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.trackProgress),
          content: const Text('What would you like to track for this route?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showAddAttemptsDialog();
              },
              child: Text(l10n.addAttempts),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showMarkSendDialog();
              },
              child: Text(l10n.markSend),
            ),
          ],
        );
      },
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
        builder: (context, setState) {
          final l10n = AppLocalizations.of(context);
          return AlertDialog(
            title: Text(l10n.addAttempts),
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
                        : l10n.addNotesAttempts,
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
                                TextPosition(
                                  offset: notesController.text.length,
                                ),
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
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _addAttempts(
                    attempts: attempts,
                    notes: notesController.text.trim(),
                  );
                },
                child: Text(l10n.add),
              ),
            ],
          );
        },
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
        builder: (context, setState) {
          final l10n = AppLocalizations.of(context);
          return AlertDialog(
            title: Text(l10n.markSend),
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
                  items: [
                    DropdownMenuItem(
                      value: 'top_rope',
                      child: Text(l10n.topRope),
                    ),
                    DropdownMenuItem(value: 'lead', child: Text(l10n.lead)),
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
                        : l10n.addNotesSend,
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
                                TextPosition(
                                  offset: notesController.text.length,
                                ),
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
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _markSend(
                    sendType: sendType,
                    notes: notesController.text.trim(),
                  );
                },
                child: Text(l10n.markSend),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddProgressDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.addProgress),
          content: const Text('What would you like to add?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showAddAttemptsDialog();
              },
              child: Text(l10n.addAttempts),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showMarkSendDialog();
              },
              child: Text(l10n.markSend),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveTickDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.removeTick),
          content: const Text(
            'Are you sure you want to remove all progress for this route?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _untickRoute();
              },
              child: Text(
                l10n.remove,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
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
            content: Text('Added $attempts attempt${attempts == 1 ? '' : 's'}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add attempts: $e')));
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
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.markedSend(sendType.replaceAll('_', ' '))),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to mark send: $e')));
      }
    }
  }

  Future<void> _untickRoute() async {
    final routeProvider = context.read<RouteProvider>();
    final success = await routeProvider.toggleTick(widget.route.id);

    if (!mounted) return; // Check if widget is still mounted

    if (success) {
      _checkIfTicked();
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.tickRemoved),
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

  void _showCommentDialog() {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
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
        );
      },
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
    final existingProposal = await routeProvider.getUserGradeProposal(
      widget.route.id,
    );

    // Get grades from route provider, sorted by difficulty order
    final grades = routeProvider.gradeDefinitions
        .map((gradeDefinition) => gradeDefinition['grade'] as String)
        .toList()
      ..sort((a, b) {
        final aOrder = routeProvider.gradeDefinitions.firstWhere(
          (g) => g['grade'] == a,
        )['difficulty_order'] as int;
        final bOrder = routeProvider.gradeDefinitions.firstWhere(
          (g) => g['grade'] == b,
        )['difficulty_order'] as int;
        return aOrder.compareTo(bOrder);
      });

    // Set selected grade, ensuring it exists in the grades list
    String? selectedGrade = existingProposal?.proposedGrade;
    if (!grades.contains(selectedGrade)) {
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
          final l10n = AppLocalizations.of(context);
          return AlertDialog(
            title: Text(
              existingProposal != null
                  ? 'Update Grade Proposal'
                  : 'Propose Grade',
            ),
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
                        Icon(
                          Icons.info,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
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
                    labelText: l10n.proposedGrade,
                    border: const OutlineInputBorder(),
                    helperText: existingProposal != null
                        ? l10n.changeProposedGrade
                        : l10n.selectGradeToPropose,
                  ),
                  value: selectedGrade,
                  items: grades
                      .map(
                        (grade) => DropdownMenuItem(
                          value: grade,
                          child: Text(grade),
                        ),
                      )
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
                child: Text(
                  existingProposal != null ? 'Update' : 'Propose',
                ),
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
      'other',
    ];

    final warningLabels = {
      'broken_hold': 'Broken Hold',
      'safety_issue': 'Safety Issue',
      'needs_cleaning': 'Needs Cleaning',
      'loose_hold': 'Loose Hold',
      'other': 'Other',
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
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(warningLabels[type] ?? type),
                      ),
                    )
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
                      _addWarning(
                        selectedWarningType!,
                        descriptionController.text.trim(),
                      );
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
