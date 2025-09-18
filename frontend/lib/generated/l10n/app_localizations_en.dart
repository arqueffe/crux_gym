// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Climbing Gym Routes';

  @override
  String get navRoutes => 'Routes';

  @override
  String get navProfile => 'Profile';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get add => 'Add';

  @override
  String get update => 'Update';

  @override
  String get remove => 'Remove';

  @override
  String get search => 'Search';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmTitle => 'Logout';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to logout?';

  @override
  String get username => 'Username (for login)';

  @override
  String get nickname => 'Nickname (public display name)';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get pleaseEnterUsername => 'Please enter your username';

  @override
  String get pleaseEnterNickname => 'Please enter your nickname';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get usernameMinLength => 'Username must be at least 3 characters';

  @override
  String get nicknameLength => 'Nickname must be 3-20 characters';

  @override
  String get nicknameFormat => 'Only letters, numbers, and underscores';

  @override
  String get emailInvalid => 'Please enter a valid email address';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get signInButton => 'Sign In';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get switchToRegister => 'Don\'t have an account? Sign up';

  @override
  String get switchToLogin => 'Already have an account? Sign in';

  @override
  String get initializing => 'Initializing...';

  @override
  String get profileTitle => 'Profile';

  @override
  String get editNickname => 'Edit Nickname';

  @override
  String get editNicknameTooltip => 'Edit nickname';

  @override
  String get nicknameUpdated => 'Nickname updated';

  @override
  String get updateFailed => 'Update failed';

  @override
  String memberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get darkMode => 'Dark mode';

  @override
  String get languageSettings => 'Language';

  @override
  String get appSettings => 'App Settings';

  @override
  String get account => 'Account';

  @override
  String get performanceTab => 'Performance';

  @override
  String get routesTab => 'Routes';

  @override
  String get settingsTab => 'Settings';

  @override
  String get ticksTab => 'Ticks';

  @override
  String get likesTab => 'Likes';

  @override
  String get projectsTab => 'Projects';

  @override
  String get inProgressTab => 'In Progress';

  @override
  String get noTicksFound => 'No lead sends found';

  @override
  String get noTicksDescription => 'Complete some routes in lead to see them here';

  @override
  String get noInProgressFound => 'No routes in progress';

  @override
  String get noInProgressDescription => 'Start attempting some routes to see them here';

  @override
  String get noLikesFound => 'No liked routes found';

  @override
  String get noLikesDescription => 'Like some routes to see them here';

  @override
  String get noProjectsFound => 'No projects found';

  @override
  String get noProjectsDescription => 'Mark routes as projects to track your goals';

  @override
  String get gradeBreakdown => 'Grade Breakdown';

  @override
  String get hardestGrade => 'Hardest Grade';

  @override
  String get totalTicks => 'Total Sends';

  @override
  String get totalAttempts => 'Avg. Attempts';

  @override
  String get topRopeFlash => 'TR Flash';

  @override
  String get leadFlash => 'Lead Flash';

  @override
  String get flashRate => 'Flash Rate';

  @override
  String get averageAttempts => 'Avg. Attempts';

  @override
  String get trAverageAttempts => 'TR Avg. Attempts';

  @override
  String get leadAverageAttempts => 'Lead Avg. Attempts';

  @override
  String get routeTitle => 'Route Details';

  @override
  String get addRoute => 'Add Route';

  @override
  String get routeName => 'Route Name';

  @override
  String get routeNameRequired => 'Route name is required';

  @override
  String get routeNameHelper => 'Give your route a memorable name';

  @override
  String get grade => 'Grade';

  @override
  String get gradeRequired => 'Grade is required';

  @override
  String get gradeHelper => 'Select the difficulty grade';

  @override
  String get routeSetter => 'Route Setter';

  @override
  String get routeSetterRequired => 'Route setter name is required';

  @override
  String get routeSetterHelper => 'Name of the person who set this route';

  @override
  String get wallSection => 'Wall Section';

  @override
  String get wallSectionRequired => 'Wall section is required';

  @override
  String get wallSectionHelper => 'Which section of the climbing wall';

  @override
  String get lane => 'Lane';

  @override
  String get laneRequired => 'Lane is required';

  @override
  String get laneHelper => 'Lane number on the wall';

  @override
  String laneNumber(int number) {
    return 'Lane $number';
  }

  @override
  String get holdColor => 'Hold Color';

  @override
  String get holdColorHelper => 'Color of the route holds (optional)';

  @override
  String get noSpecificColor => 'No specific color';

  @override
  String get routeDescription => 'Description';

  @override
  String get routeDescriptionHelper => 'Additional details about the route (optional)';

  @override
  String setBy(String setter) {
    return 'Set by $setter';
  }

  @override
  String get unknownRoute => 'Unknown Route';

  @override
  String get addNewRoute => 'Add New Route';

  @override
  String get routeInformation => 'Route Information';

  @override
  String get createRoute => 'Create Route';

  @override
  String get creatingRoute => 'Creating Route...';

  @override
  String get routeCreatedSuccess => 'Route created successfully!';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get enterCreativeName => 'Enter a creative name for the route';

  @override
  String get selectDifficultyGrade => 'Select the difficulty grade';

  @override
  String get nameOfPersonWhoSet => 'Name of the person who set this route';

  @override
  String get locationOfRouteInGym => 'Location of the route in the gym';

  @override
  String get selectLaneNumber => 'Select the lane number for this route';

  @override
  String get colorOfRouteHolds => 'Color of the route holds (optional)';

  @override
  String get optionalDescriptionRoute => 'Optional description of the route style or features';

  @override
  String get markSend => 'Mark Send';

  @override
  String get addProgress => 'Add Progress';

  @override
  String get addAttempts => 'Add Attempts';

  @override
  String get selectAttemptType => 'What type of attempt?';

  @override
  String get reportIssue => 'Report Issue';

  @override
  String get sendType => 'Send Type:';

  @override
  String get topRope => 'Top Rope';

  @override
  String get lead => 'Lead';

  @override
  String get notes => 'Notes:';

  @override
  String get notesHelper => 'Add any notes about your send (optional)';

  @override
  String get addTimestamp => 'Add timestamp';

  @override
  String attempts(int count) {
    return 'Attempts:';
  }

  @override
  String attemptsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'attempts',
      one: 'attempt',
    );
    return '$count $_temp0';
  }

  @override
  String get attemptsHelper => 'How many attempts did it take?';

  @override
  String get issueType => 'Issue Type';

  @override
  String get brokenHold => 'Broken Hold';

  @override
  String get safetyIssue => 'Safety Issue';

  @override
  String get needsCleaning => 'Needs Cleaning';

  @override
  String get looseHold => 'Loose Hold';

  @override
  String get other => 'Other';

  @override
  String get issueDescription => 'Description';

  @override
  String get issueDescriptionHelper => 'Describe the issue';

  @override
  String get submitReport => 'Submit Report';

  @override
  String get projectRoute => 'Add to Projects';

  @override
  String get removeProject => 'Remove from Projects';

  @override
  String get likeRoute => 'Like';

  @override
  String get unlikeRoute => 'Unlike';

  @override
  String get progressTracking => 'Progress Tracking';

  @override
  String get socialPlanning => 'Social & Planning';

  @override
  String get feedbackReporting => 'Feedback & Reporting';

  @override
  String get alreadySent => 'Already Sent';

  @override
  String get cannotAddAttempts => 'Cannot add attempts to routes you have already lead sent.';

  @override
  String get attemptsLabel => 'Attempts';

  @override
  String get topRopeLabel => 'Top Rope';

  @override
  String get flashLabel => 'Flash!';

  @override
  String get liked => 'Liked';

  @override
  String get like => 'Like';

  @override
  String get project => 'Project';

  @override
  String get addProject => 'Add Project';

  @override
  String get topRopeSent => 'Top Rope Sent';

  @override
  String get leadSent => 'Lead Sent';

  @override
  String get suggestGrade => 'Suggest Grade';

  @override
  String get issueTypeOptional => 'Issue Type (Optional)';

  @override
  String get topRopeShort => 'TR';

  @override
  String get leadShort => 'Lead';

  @override
  String get flash => '⚡';

  @override
  String get filterAll => 'All Time';

  @override
  String get filterThisWeek => 'This Week';

  @override
  String get filterThisMonth => 'This Month';

  @override
  String get filterThisYear => 'This Year';

  @override
  String get filterLast3Months => 'Last 3 Months';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageChinese => '中文';

  @override
  String get colorRed => 'Red';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorYellow => 'Yellow';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorBlack => 'Black';

  @override
  String get colorWhite => 'White';

  @override
  String get colorGray => 'Gray';

  @override
  String get colorBrown => 'Brown';

  @override
  String get interactions => 'Interactions';

  @override
  String get yourProgress => 'Your Progress';

  @override
  String get removeTick => 'Remove Tick';

  @override
  String get addNotesAttempts => 'Add notes about your attempts';

  @override
  String get addEntryBelowNotes => 'Add entry below existing notes';

  @override
  String get addNotesSend => 'Add notes about this send';

  @override
  String markedSend(String sendType) {
    return 'Marked $sendType send!';
  }

  @override
  String get yourComment => 'Your comment';

  @override
  String get proposedGrade => 'Proposed Grade';

  @override
  String get selectGradeToPropose => 'Select a grade to propose';

  @override
  String get changeProposedGrade => 'You can change your proposed grade';

  @override
  String get attemptAdded => 'Attempt added!';

  @override
  String get failedToAddAttempt => 'Failed to add attempt';

  @override
  String get topRopeSendRemoved => 'Top rope send removed!';

  @override
  String get failedToRemoveTopRopeSend => 'Failed to remove top rope send';

  @override
  String get topRopeSendMarked => 'Top rope send marked!';

  @override
  String get failedToMarkTopRopeSend => 'Failed to mark top rope send';

  @override
  String get leadSendRemoved => 'Lead send removed!';

  @override
  String get failedToRemoveLeadSend => 'Failed to remove lead send';

  @override
  String get leadSendMarked => 'Lead send marked!';

  @override
  String get failedToMarkLeadSend => 'Failed to mark lead send';

  @override
  String get routeUnliked => 'Route unliked!';

  @override
  String get routeLiked => 'Route liked!';

  @override
  String get cannotMarkSentRoutesAsProjects => 'Cannot mark sent routes as projects';

  @override
  String get projectRemoved => 'Project removed!';

  @override
  String get routeAddedToProjects => 'Route added to projects!';

  @override
  String get commentAdded => 'Comment added!';

  @override
  String get gradeProposalUpdated => 'Grade proposal updated!';

  @override
  String get issueReported => 'Issue reported!';

  @override
  String get unableToLoadGrades => 'Unable to load grades';

  @override
  String get gradeDefinitions => 'Grade definitions';

  @override
  String get gradesList => 'Grades list';

  @override
  String get updateGradeProposal => 'Update Grade Proposal';

  @override
  String get youAlreadyProposed => 'You already proposed';

  @override
  String get changeYourGradeAndUpdateReasoningBelow => 'Change your grade and update reasoning below';

  @override
  String get youHadAPreviousProposalThatIsNoLongerValid => 'You had a previous proposal that is no longer valid';

  @override
  String get pleaseSelectANewGrade => 'Please select a new grade';

  @override
  String get reasoningOptional => 'Reasoning (Optional)';

  @override
  String get errorLoadingGradeProposalDialog => 'Error loading grade proposal dialog';

  @override
  String get overhangWall => 'Overhang';

  @override
  String get slabWall => 'Slab';

  @override
  String get steepWall => 'Steep';

  @override
  String get verticalWall => 'Vertical';

  @override
  String get prowWall => 'Prow';

  @override
  String get dihedralWall => 'Dièdre';

  @override
  String get routeNotFound => 'Route not found';

  @override
  String laneLabel(int number) {
    return 'Lane $number';
  }

  @override
  String communitySuggested(String grade, int count) {
    return 'Community suggested: $grade (avg of $count proposals)';
  }

  @override
  String get comments => 'Comments';

  @override
  String get gradeProposals => 'Grade Proposals';

  @override
  String get warnings => 'Warnings';

  @override
  String get filters => 'Filters';

  @override
  String get clearAll => 'Clear All';

  @override
  String get noRoutesFound => 'No routes found';

  @override
  String get adjustFiltersOrAddRoute => 'Try adjusting your filters or add a new route';

  @override
  String get unknown => 'Unknown';

  @override
  String get progress => 'Progress';

  @override
  String get track => 'Track';

  @override
  String get note => 'Note';

  @override
  String get comment => 'Comment';

  @override
  String get proposeGrade => 'Propose Grade';

  @override
  String get manageTick => 'Manage Tick';

  @override
  String get leadSend => 'Lead Send';

  @override
  String get trackProgress => 'Track Progress';

  @override
  String get tickRemoved => 'Tick removed';

  @override
  String get addComment => 'Add Comment';

  @override
  String get filtersAndSorting => 'Filters & Sorting';

  @override
  String get sortBy => 'Sort By';

  @override
  String get basicFilters => 'Basic Filters';

  @override
  String get userInteractions => 'User Interactions';

  @override
  String get clearAllFilters => 'Clear All Filters';

  @override
  String get sortby => 'Sort by';

  @override
  String get allSections => 'All Sections';

  @override
  String get allGrades => 'All Grades';

  @override
  String get allLanes => 'All Lanes';

  @override
  String get allRouteSetters => 'All Route Setters';

  @override
  String get tickedRoutes => 'Ticked Routes';

  @override
  String get likedRoutes => 'Liked Routes';

  @override
  String get warnedRoutes => 'Warned Routes';

  @override
  String get projectRoutes => 'Project Routes';

  @override
  String get newestFirst => 'Newest First';

  @override
  String get oldestFirst => 'Oldest First';

  @override
  String get nameAZ => 'Name (A-Z)';

  @override
  String get nameZA => 'Name (Z-A)';

  @override
  String get gradeEasyToHard => 'Grade (Easy to Hard)';

  @override
  String get gradeHardToEasy => 'Grade (Hard to Easy)';

  @override
  String get mostLikes => 'Most Likes';

  @override
  String get leastLikes => 'Least Likes';

  @override
  String get mostComments => 'Most Comments';

  @override
  String get leastComments => 'Least Comments';

  @override
  String get mostTicks => 'Most Ticks';

  @override
  String get leastTicks => 'Least Ticks';

  @override
  String get filterStateAll => 'All';

  @override
  String get filterStateOnly => 'Only';

  @override
  String get filterStateExclude => 'Exclude';

  @override
  String get noPerformanceData => 'No performance data available';

  @override
  String get performanceSummary => 'Performance Summary';

  @override
  String get trFlash => 'TR Flash';

  @override
  String get allTimeStats => 'All-Time Stats';

  @override
  String get totalLikesGiven => 'Total Likes Given';

  @override
  String get commentsPosted => 'Comments Posted';

  @override
  String get wallSectionsClimbed => 'Wall Sections Climbed';

  @override
  String get gradesAchieved => 'Grades Achieved';

  @override
  String get noGradeData => 'No grade data available';

  @override
  String get completed => 'Completed';

  @override
  String get flashed => 'Flashed';

  @override
  String get detailedStatistics => 'Detailed Statistics';

  @override
  String get routesCompleted => 'Routes Completed:';

  @override
  String get flashes => 'Flashes';

  @override
  String get totalAttemptsColon => 'Total Attempts:';

  @override
  String gradeStatistics(String grade) {
    return '$grade Statistics';
  }

  @override
  String get added => 'Added';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get weekAgo => '1 week ago';

  @override
  String weeksAgo(int count) {
    return '$count weeks ago';
  }

  @override
  String get monthAgo => '1 month ago';

  @override
  String monthsAgo(int count) {
    return '$count months ago';
  }

  @override
  String get report => 'Report';

  @override
  String get propose => 'Propose';
}
