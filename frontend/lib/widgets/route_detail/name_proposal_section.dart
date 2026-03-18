import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n/app_localizations.dart';
import '../../models/route_models.dart' as models;
import '../../providers/route_provider.dart';

class NameProposalSection extends StatefulWidget {
  final models.Route route;

  const NameProposalSection({super.key, required this.route});

  @override
  State<NameProposalSection> createState() => _NameProposalSectionState();
}

class _NameProposalSectionState extends State<NameProposalSection> {
  List<models.NameProposal> _proposals = [];
  Map<String, dynamic>? _userAction;
  bool _isLoading = true;
  bool _isSubmitting = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProposals();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProposals() async {
    setState(() => _isLoading = true);
    try {
      final routeProvider = context.read<RouteProvider>();
      final proposals =
          await routeProvider.apiService.getRouteNameProposals(widget.route.id);
      final userAction = await routeProvider.apiService
          .getUserNameProposalAction(widget.route.id);

      if (mounted) {
        setState(() {
          _proposals = proposals;
          _userAction = userAction;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorLoadingProposals(e.toString()))),
        );
      }
    }
  }

  Future<void> _submitProposal() async {
    final l10n = AppLocalizations.of(context);
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterName)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmProposalTitle),
        content: Text(l10n.confirmProposalMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    try {
      if (!mounted) return;
      final routeProvider = context.read<RouteProvider>();
      await routeProvider.apiService.proposeRouteName(
        widget.route.id,
        _nameController.text.trim(),
      );

      if (mounted) {
        _nameController.clear();
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.nameProposedSuccess)),
        );
        await _loadProposals();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).error}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _voteForProposal(models.NameProposal proposal) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmVoteTitle),
        content: Text(l10n.confirmVoteMessage(proposal.proposedName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    try {
      if (!mounted) return;
      final routeProvider = context.read<RouteProvider>();
      await routeProvider.apiService
          .voteForNameProposal(widget.route.id, proposal.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.voteRecordedSuccess)),
        );
        await _loadProposals();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).error}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Theme.of(context)
          .colorScheme
          .secondaryContainer
          .withValues(alpha: 0.85),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline),
                const SizedBox(width: 8),
                Text(
                  l10n.proposeAName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.unnamedRouteDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              if (_userAction?['has_proposed'] == true) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.youProposed(
                            _userAction!['proposal']['proposed_name'],
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (_userAction?['has_voted'] == true) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.how_to_vote, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.youVotedFor(
                            _userAction!['voted_for']['proposed_name'],
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: l10n.yourProposedName,
                          border: const OutlineInputBorder(),
                          hintText: l10n.enterCreativeNameProposal,
                        ),
                        enabled: !_isSubmitting,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitProposal,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.proposeButton),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.proposalWarning,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[800],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              if (_proposals.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  l10n.proposedNames(_proposals.length),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ..._proposals.map(
                  (proposal) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  proposal.proposedName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.byUser(proposal.userName),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.thumb_up, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${proposal.voteCount}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (_userAction?['has_proposed'] != true &&
                                  _userAction?['has_voted'] != true) ...[
                                const SizedBox(height: 4),
                                TextButton(
                                  onPressed: _isSubmitting
                                      ? null
                                      : () => _voteForProposal(proposal),
                                  child: Text(l10n.voteButton),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
