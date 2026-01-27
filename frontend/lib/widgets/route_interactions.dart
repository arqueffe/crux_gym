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
        _tickData = tickStatus; // Store the tick data
        _isTicked = tickStatus != null &&
            ((tickStatus['top_rope_send'] == true ||
                    tickStatus['top_rope_send'] == 1 ||
                    tickStatus['top_rope_send'] == '1') ||
                (tickStatus['lead_send'] == true ||
                    tickStatus['lead_send'] == 1 ||
                    tickStatus['lead_send'] == '1'));
        // Debug logging
        print('Debug - Route ${widget.route.id}:');
        print('  tickStatus: $tickStatus');
        print('  _isTicked: $_isTicked');
        print('  _tickData: $_tickData');
        if (tickStatus != null) {
          print(
              '  top_rope_send: ${tickStatus['top_rope_send']} (${tickStatus['top_rope_send'].runtimeType})');
          print(
              '  lead_send: ${tickStatus['lead_send']} (${tickStatus['lead_send'].runtimeType})');
        }
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

  // Helper methods to check send status
  bool _isTopRopeSent() {
    return _tickData != null &&
        (_tickData!['top_rope_send'] == true ||
            _tickData!['top_rope_send'] == 1 ||
            _tickData!['top_rope_send'] == '1');
  }

  bool _isLeadSent() {
    return _tickData != null &&
        (_tickData!['lead_send'] == true ||
            _tickData!['lead_send'] == 1 ||
            _tickData!['lead_send'] == '1');
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

              // Progress Tracking Section
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.progressTracking,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isLeadSent()
                                ? null
                                : () => _addAttemptOptimized(),
                            icon: Icon(
                              Icons.add_circle_outline,
                              size: 18,
                              color: _isLeadSent() ? Colors.grey : null,
                            ),
                            label: Text(
                              _isLeadSent()
                                  ? l10n.alreadySent
                                  : l10n.addAttempts,
                              style: TextStyle(
                                color: _isLeadSent() ? Colors.grey : null,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isLeadSent()
                                  ? Colors.grey.shade200
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _toggleTopRopeSend(),
                            icon: Icon(
                              _isTopRopeSent()
                                  ? Icons.check_circle
                                  : Icons.arrow_upward,
                              color: _isTopRopeSent() ? Colors.green : null,
                              size: 18,
                            ),
                            label: Text(_isTopRopeSent()
                                ? l10n.topRopeSent
                                : l10n.topRope),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isTopRopeSent()
                                  ? Colors.green.shade50
                                  : Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _toggleLeadSend(),
                            icon: Icon(
                              _isLeadSent()
                                  ? Icons.check_circle
                                  : Icons.vertical_align_top,
                              color: _isLeadSent() ? Colors.green : null,
                              size: 18,
                            ),
                            label:
                                Text(_isLeadSent() ? l10n.leadSent : l10n.lead),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isLeadSent()
                                  ? Colors.green.shade50
                                  : Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Social Actions Section
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 18,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.socialPlanning,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _toggleLike(),
                            icon: Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              color: _isLiked ? Colors.red : null,
                              size: 18,
                            ),
                            label: Text(_isLiked ? l10n.liked : l10n.like),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isLiked
                                  ? Colors.red.shade50
                                  : Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: (_isLeadSent() && !_isProject)
                                ? null
                                : () => _toggleProject(),
                            icon: Icon(
                              _isProject
                                  ? Icons.flag
                                  : (_isLeadSent()
                                      ? Icons.block
                                      : Icons.flag_outlined),
                              color: _isProject
                                  ? Colors.blue
                                  : (_isLeadSent() ? Colors.grey : null),
                              size: 18,
                            ),
                            label: Text(
                              _isProject
                                  ? l10n.project
                                  : (_isLeadSent()
                                      ? l10n.alreadySent
                                      : l10n.addProject),
                              style: TextStyle(
                                color: (_isLeadSent() && !_isProject)
                                    ? Colors.grey
                                    : null,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isProject
                                  ? Colors.blue.shade50
                                  : (_isLeadSent()
                                      ? Colors.grey.shade200
                                      : Theme.of(context)
                                          .colorScheme
                                          .primaryContainer),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Feedback Section
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 18,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.feedbackReporting,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _showNotesDialog(),
                            icon: const Icon(Icons.sticky_note_2_outlined,
                                size: 18),
                            label: Text(l10n.note),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showCommentDialog(),
                            icon: const Icon(Icons.comment, size: 18),
                            label: Text(l10n.comment),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showGradeProposalDialog(),
                            icon: const Icon(Icons.grade, size: 18),
                            label: Text(l10n.suggestGrade),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showWarningDialog(),
                            icon: const Icon(Icons.warning, size: 18),
                            label: Text(l10n.reportIssue),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade50,
                              foregroundColor: Colors.orange.shade700,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Progress information - always show, even without activity
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
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
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Attempts - Show separate counts if available
                        Column(
                          children: [
                            Icon(
                              Icons.repeat,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            // Show separate attempt counts if we have the data
                            if (_tickData != null &&
                                (_tickData!['top_rope_attempts'] != null ||
                                    _tickData!['lead_attempts'] != null))
                              Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.arrow_upward,
                                          size: 14, color: Colors.blue),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${_tickData!['top_rope_attempts'] ?? 0}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.trending_up,
                                          size: 14, color: Colors.green),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${_tickData!['lead_attempts'] ?? 0}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Total: ${_tickData?['attempts'] ?? 0}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              )
                            else
                              // Fallback to total attempts display
                              Text(
                                '${_tickData?['attempts'] ?? 0}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            Text(
                              l10n.attemptsLabel,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        // Top Rope Status
                        Column(
                          children: [
                            Icon(
                              _isTopRopeSent()
                                  ? Icons.check_circle
                                  : Icons.arrow_upward,
                              color: _isTopRopeSent()
                                  ? Colors.green
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.topRopeLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: _isTopRopeSent()
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _isTopRopeSent()
                                    ? Colors.green
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                              ),
                            ),
                            if (_tickData!['top_rope_flash'] == true ||
                                _tickData!['top_rope_flash'] == 1 ||
                                _tickData!['top_rope_flash'] == '1')
                              Text(
                                l10n.flashLabel,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        // Lead Status
                        Column(
                          children: [
                            Icon(
                              _isLeadSent()
                                  ? Icons.check_circle
                                  : Icons.vertical_align_top,
                              color: _isLeadSent()
                                  ? Colors.green
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.lead,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: _isLeadSent()
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _isLeadSent()
                                    ? Colors.green
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                              ),
                            ),
                            if (_tickData!['lead_flash'] == true ||
                                _tickData!['lead_flash'] == 1 ||
                                _tickData!['lead_flash'] == '1')
                              Text(
                                l10n.flashLabel,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    if (_tickData!['notes'] != null &&
                        _tickData!['notes'].toString().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.sticky_note_2_outlined,
                              size: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _tickData!['notes'].toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
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

  // Optimized attempt tracking that doesn't reload the entire page
  Future<void> _addAttemptOptimized() async {
    final l10n = AppLocalizations.of(context);
    // Check if user has already lead sent this route
    if (_isLeadSent()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.cannotAddAttempts,
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Show dialog to select attempt type
    if (!mounted) return;

    final attemptType = await showDialog<String>(
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

    if (attemptType == null) return;

    final routeProvider = context.read<RouteProvider>();
    try {
      await routeProvider.addAttemptsOptimized(widget.route.id, 1,
          notes: '', attemptType: attemptType);
      // Refresh only the tick data to get updated attempt count
      await _refreshTickData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.attemptAdded)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.failedToAddAttempt}: $e')),
        );
      }
    }
  }

  Future<void> _toggleTopRopeSend() async {
    final l10n = AppLocalizations.of(context);
    final routeProvider = context.read<RouteProvider>();

    if (_isTopRopeSent()) {
      // Remove the top rope send
      try {
        final success = await routeProvider.unmarkSendOptimized(
            widget.route.id, 'top_rope');
        if (success) {
          await _refreshTickData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.topRopeSendRemoved)),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.failedToRemoveTopRopeSend}: $e')),
          );
        }
      }
    } else {
      // Add the send
      try {
        await routeProvider.markSendOptimized(widget.route.id, 'top_rope');
        await _refreshTickData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.topRopeSendMarked)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.failedToMarkTopRopeSend}: $e')),
          );
        }
      }
    }
  }

  Future<void> _toggleLeadSend() async {
    final l10n = AppLocalizations.of(context);
    final routeProvider = context.read<RouteProvider>();

    if (_isLeadSent()) {
      // Remove the lead send
      try {
        final success =
            await routeProvider.unmarkSendOptimized(widget.route.id, 'lead');
        if (success) {
          await _refreshTickData();
          _checkIfProject(); // Also check project status as it may have changed
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.leadSendRemoved)),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.failedToRemoveLeadSend}: $e')),
          );
        }
      }
    } else {
      // Add the send
      try {
        await routeProvider.markSendOptimized(widget.route.id, 'lead');
        await _refreshTickData();
        _checkIfProject(); // Also check project status as it may have changed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.leadSendMarked)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.failedToMarkLeadSend}: $e')),
          );
        }
      }
    }
  }

  // Optimized method to refresh only tick data without full page reload
  Future<void> _refreshTickData() async {
    if (!mounted) return;
    final routeProvider = context.read<RouteProvider>();
    try {
      final tickStatus = await routeProvider.getUserTickStatus(widget.route.id);
      if (mounted) {
        setState(() {
          _tickData = tickStatus;
          _isTicked = tickStatus != null &&
              ((tickStatus['top_rope_send'] == true ||
                      tickStatus['top_rope_send'] == 1 ||
                      tickStatus['top_rope_send'] == '1') ||
                  (tickStatus['lead_send'] == true ||
                      tickStatus['lead_send'] == 1 ||
                      tickStatus['lead_send'] == '1'));
        });
      }
    } catch (e) {
      // Silently fail to avoid disrupting user experience
      print('Failed to refresh tick data: $e');
    }
  }

  Future<void> _toggleLike() async {
    final l10n = AppLocalizations.of(context);
    final routeProvider = context.read<RouteProvider>();
    final success = await routeProvider.toggleLikeOptimized(widget.route.id);

    if (!mounted) return; // Check if widget is still mounted

    if (success) {
      _checkIfLiked();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLiked ? l10n.routeUnliked : l10n.routeLiked),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.error}: ${routeProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleProject() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final routeProvider = context.read<RouteProvider>();

    bool success;
    if (_isProject) {
      success = await routeProvider.removeProjectOptimized(widget.route.id);
    } else {
      // Check if user has already lead sent this route
      if (_tickData != null &&
          ((_tickData!['lead_send'] == true) ||
              (_tickData!['lead_send'] == 1) ||
              (_tickData!['lead_send'] == '1'))) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.cannotMarkSentRoutesAsProjects,
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      success = await routeProvider.addProjectOptimized(widget.route.id);
    }

    if (!mounted) return; // Check if widget is still mounted

    if (success) {
      _checkIfProject();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isProject ? l10n.projectRemoved : l10n.routeAddedToProjects,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.error}: ${routeProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showNotesDialog() {
    final notesController = TextEditingController();

    // Pre-populate with existing notes if any
    if (_tickData != null && _tickData!['notes'] != null) {
      notesController.text = _tickData!['notes'].toString();
    }

    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(
              '${l10n.note} - ${widget.route.name == 'Unnamed' ? l10n.unnamed : widget.route.name}'),
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
              onPressed: () {
                Navigator.pop(context);
                _updateNotes(notesController.text.trim());
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateNotes(String notes) async {
    final l10n = AppLocalizations.of(context);
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);

    final success =
        await routeProvider.updateRouteNotes(widget.route.id, notes);

    if (success) {
      // Update local state immediately
      if (_tickData != null) {
        _tickData!['notes'] = notes;
      } else {
        _tickData = {
          'notes': notes,
          'attempts': 0,
          'top_rope_attempts': 0,
          'lead_attempts': 0,
          'top_rope_send': false,
          'lead_send': false,
          'top_rope_flash': false,
          'lead_flash': false,
        };
      }
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(notes.isEmpty ? 'Note removed' : 'Note saved'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.error}: ${routeProvider.error}'),
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
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                if (commentController.text.trim().isNotEmpty) {
                  Navigator.pop(context);
                  _addComment(commentController.text.trim());
                }
              },
              child: Text(l10n.addComment),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addComment(String content) async {
    final l10n = AppLocalizations.of(context);
    final routeProvider = context.read<RouteProvider>();
    final success =
        await routeProvider.addCommentOptimized(widget.route.id, content);

    if (!mounted) return; // Check if widget is still mounted

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.commentAdded),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.error}: ${routeProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showGradeProposalDialog() async {
    final l10n = AppLocalizations.of(context);
    try {
      final routeProvider = context.read<RouteProvider>();

      // Ensure grade definitions are loaded
      if (routeProvider.gradeDefinitions.isEmpty) {
        await routeProvider.loadGradeDefinitions();
      }

      // Check if user already has a proposal for this route
      final existingProposal = await routeProvider.getUserGradeProposal(
        widget.route.id,
      );

      // Debug logging
      print('Debug - Grade Proposal:');
      print('  existingProposal: $existingProposal');
      print('  existingProposal type: ${existingProposal.runtimeType}');
      if (existingProposal != null) {
        print('  proposedGrade: ${existingProposal.proposedGrade}');
        print('  reasoning: ${existingProposal.reasoning}');
      }

      // Get grades from route provider, sorted by difficulty order
      List<String> grades = [];

      if (routeProvider.gradeDefinitions.isNotEmpty) {
        grades = routeProvider.gradeDefinitions
            .where((gradeDefinition) => gradeDefinition['grade'] != null)
            .map((gradeDefinition) => gradeDefinition['grade'] as String)
            .toList()
          ..sort((a, b) {
            try {
              final aOrder = routeProvider.gradeDefinitions.firstWhere(
                    (g) => g['grade'] == a,
                  )['difficulty_order'] as int? ??
                  0;
              final bOrder = routeProvider.gradeDefinitions.firstWhere(
                    (g) => g['grade'] == b,
                  )['difficulty_order'] as int? ??
                  0;
              return aOrder.compareTo(bOrder);
            } catch (e) {
              // If there's any error in sorting, just compare strings
              return a.compareTo(b);
            }
          });
      }

      // If no grades from definitions, use the grades from route provider
      if (grades.isEmpty && routeProvider.grades.isNotEmpty) {
        grades = List.from(routeProvider.grades)..sort();
      }

      // Check if we have any valid grades
      if (grades.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${l10n.unableToLoadGrades} ${l10n.gradeDefinitions}: ${routeProvider.gradeDefinitions.length}, ${l10n.gradesList}: ${routeProvider.grades.length}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

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
                    ? l10n.updateGradeProposal
                    : l10n.proposeGrade,
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
                                  ? '${l10n.youAlreadyProposed} "${existingProposal.proposedGrade}". ${l10n.changeYourGradeAndUpdateReasoningBelow}'
                                  : '${l10n.youHadAPreviousProposalThatIsNoLongerValid} ${l10n.pleaseSelectANewGrade}.',
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
                    decoration: InputDecoration(
                      labelText: l10n.reasoningOptional,
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
                    existingProposal != null ? l10n.update : l10n.propose,
                  ),
                ),
              ],
            );
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorLoadingGradeProposalDialog}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _proposeGrade(String proposedGrade, String? reasoning) async {
    final l10n = AppLocalizations.of(context);
    final routeProvider = context.read<RouteProvider>();
    final success = await routeProvider.proposeGradeOptimized(
      widget.route.id,
      proposedGrade,
      reasoning,
    );

    if (!mounted) return; // Check if widget is still mounted

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.gradeProposalUpdated),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.error}: ${routeProvider.error}'),
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

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, dialogSetState) {
          final l10n = AppLocalizations.of(context);
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
                    dialogSetState(() {
                      selectedWarningType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  onChanged: (value) {
                    dialogSetState(
                        () {}); // Trigger rebuild to update button state
                  },
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
                        Navigator.pop(context);
                        _addWarning(
                          selectedWarningType ?? l10n.other,
                          descriptionController.text.trim(),
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

  Future<void> _addWarning(String warningType, String description) async {
    final l10n = AppLocalizations.of(context);
    final routeProvider = context.read<RouteProvider>();
    final success = await routeProvider.addWarningOptimized(
      widget.route.id,
      warningType,
      description,
    );

    if (!mounted) return; // Check if widget is still mounted

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.issueReported),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.error}: ${routeProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
