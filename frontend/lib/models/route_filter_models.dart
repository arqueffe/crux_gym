import 'package:flutter/material.dart';

import '../generated/l10n/app_localizations.dart';

enum SortOption {
  newest,
  oldest,
  nameAZ,
  nameZA,
  gradeAsc,
  gradeDesc,
  mostLikes,
  leastLikes,
  mostComments,
  leastComments,
  mostTicks,
  leastTicks,
}

extension SortOptionExtension on SortOption {
  String getDisplayName(AppLocalizations l10n) {
    switch (this) {
      case SortOption.newest:
        return l10n.newestFirst;
      case SortOption.oldest:
        return l10n.oldestFirst;
      case SortOption.nameAZ:
        return l10n.nameAZ;
      case SortOption.nameZA:
        return l10n.nameZA;
      case SortOption.gradeAsc:
        return l10n.gradeEasyToHard;
      case SortOption.gradeDesc:
        return l10n.gradeHardToEasy;
      case SortOption.mostLikes:
        return l10n.mostLikes;
      case SortOption.leastLikes:
        return l10n.leastLikes;
      case SortOption.mostComments:
        return l10n.mostComments;
      case SortOption.leastComments:
        return l10n.leastComments;
      case SortOption.mostTicks:
        return l10n.mostTicks;
      case SortOption.leastTicks:
        return l10n.leastTicks;
    }
  }

  @Deprecated('Use getDisplayName(l10n) instead')
  String get displayName {
    switch (this) {
      case SortOption.newest:
        return 'Newest First';
      case SortOption.oldest:
        return 'Oldest First';
      case SortOption.nameAZ:
        return 'Name (A-Z)';
      case SortOption.nameZA:
        return 'Name (Z-A)';
      case SortOption.gradeAsc:
        return 'Grade (Easy to Hard)';
      case SortOption.gradeDesc:
        return 'Grade (Hard to Easy)';
      case SortOption.mostLikes:
        return 'Most Likes';
      case SortOption.leastLikes:
        return 'Least Likes';
      case SortOption.mostComments:
        return 'Most Comments';
      case SortOption.leastComments:
        return 'Least Comments';
      case SortOption.mostTicks:
        return 'Most Ticks';
      case SortOption.leastTicks:
        return 'Least Ticks';
    }
  }
}

enum FilterState {
  all,
  only,
  exclude,
}

extension FilterStateExtension on FilterState {
  String getDisplayName(AppLocalizations l10n) {
    switch (this) {
      case FilterState.all:
        return l10n.filterStateAll;
      case FilterState.only:
        return l10n.filterStateOnly;
      case FilterState.exclude:
        return l10n.filterStateExclude;
    }
  }

  @Deprecated('Use getDisplayName(l10n) instead')
  String get displayName {
    switch (this) {
      case FilterState.all:
        return 'All';
      case FilterState.only:
        return 'Only';
      case FilterState.exclude:
        return 'Exclude';
    }
  }

  IconData get icon {
    switch (this) {
      case FilterState.all:
        return Icons.remove;
      case FilterState.only:
        return Icons.check;
      case FilterState.exclude:
        return Icons.close;
    }
  }

  Color get color {
    switch (this) {
      case FilterState.all:
        return Colors.grey;
      case FilterState.only:
        return Colors.green;
      case FilterState.exclude:
        return Colors.red;
    }
  }
}
