import 'package:flutter/material.dart';
import '../generated/l10n/app_localizations.dart';

// Weekly editing guide:
// 1) Edit weekly update text in lib/l10n/app_en.arb and app_fr.arb.
// 2) Keep the same keys and update values each week.
// 3) Bump currentAnnouncementVersion in
//    lib/services/weekly_announcement_service.dart so it auto-shows once again.

Future<void> showWeeklyUpdateDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final colorScheme = Theme.of(context).colorScheme;
  final announcementItems = <String>[
    l10n.weeklyUpdateAnnouncementRoutesLocking,
  ];
  final featuresItems = <String>[
    l10n.weeklyUpdateFeatureItemSendUndo,
    l10n.weeklyUpdateFeatureItemRouteCardSentIndicator,
    l10n.weeklyUpdateFeatureItemStatsDescriptions,
  ];
  final fixesItems = <String>[
    l10n.weeklyUpdateFixesItemStatsQuality,
    l10n.weeklyUpdateFixesItemNicknameSecurity,
    l10n.weeklyUpdateFixesItemPasswordAutofill,
    l10n.weeklyUpdateFixesItemDesktopDrag,
    l10n.weeklyUpdateFixesItemLocalizedErrors,
    l10n.weeklyUpdateFixesItemThemePolish,
    l10n.weeklyUpdateFixesItemBackendStability,
  ];

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      var showFixes = false;

      return StatefulBuilder(
        builder: (stateContext, setState) => Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.secondaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.weeklyUpdateTitle,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionCard(
                          icon: Icons.campaign,
                          title: l10n.weeklyUpdateAnnouncementsTitle,
                          child: Column(
                            children: announcementItems
                                .map((item) => _BulletRow(text: item))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SectionCard(
                          icon: Icons.rocket_launch_outlined,
                          title: l10n.weeklyUpdateFeaturesTitle,
                          child: Column(
                            children: featuresItems
                                .map((item) => _BulletRow(text: item))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SectionCard(
                          icon: Icons.bug_report_outlined,
                          title: l10n.weeklyUpdateFixesTitle,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    showFixes = !showFixes;
                                  });
                                },
                                icon: Icon(showFixes
                                    ? Icons.expand_less
                                    : Icons.expand_more),
                                label: Text(showFixes
                                    ? l10n.weeklyUpdateHideFixes
                                    : l10n.weeklyUpdateShowFixes),
                              ),
                              AnimatedCrossFade(
                                firstChild: const SizedBox.shrink(),
                                secondChild: Column(
                                  children: fixesItems
                                      .map((item) => _BulletRow(text: item))
                                      .toList(),
                                ),
                                crossFadeState: showFixes
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 180),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            l10n.weeklyUpdateFooterNote,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontStyle: FontStyle.italic,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.check_rounded),
                      label: Text(l10n.close),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
