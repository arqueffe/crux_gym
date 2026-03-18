import '../generated/l10n/app_localizations.dart';

String formatRelativeDate(
  DateTime date,
  AppLocalizations l10n, {
  bool includeMonths = false,
}) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays == 0) {
    return l10n.today;
  }
  if (difference.inDays == 1) {
    return l10n.yesterday;
  }
  if (difference.inDays < 7) {
    return l10n.daysAgo(difference.inDays);
  }
  if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return weeks == 1 ? l10n.weekAgo : l10n.weeksAgo(weeks);
  }
  if (includeMonths && difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return months == 1 ? l10n.monthAgo : l10n.monthsAgo(months);
  }

  return '${date.day}/${date.month}/${date.year}';
}
