import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Climbing Gym Routes'**
  String get appTitle;

  /// No description provided for @navRoutes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get navRoutes;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginTitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmMessage;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username (for login)'**
  String get username;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname (public display name)'**
  String get nickname;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get pleaseEnterUsername;

  /// No description provided for @pleaseEnterNickname.
  ///
  /// In en, this message translates to:
  /// **'Please enter your nickname'**
  String get pleaseEnterNickname;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @usernameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameMinLength;

  /// No description provided for @nicknameLength.
  ///
  /// In en, this message translates to:
  /// **'Nickname must be 3-20 characters'**
  String get nicknameLength;

  /// No description provided for @nicknameFormat.
  ///
  /// In en, this message translates to:
  /// **'Only letters, numbers, and underscores'**
  String get nicknameFormat;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get emailInvalid;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @switchToRegister.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get switchToRegister;

  /// No description provided for @switchToLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get switchToLogin;

  /// No description provided for @initializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializing;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @editNickname.
  ///
  /// In en, this message translates to:
  /// **'Edit Nickname'**
  String get editNickname;

  /// No description provided for @editNicknameTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit nickname'**
  String get editNicknameTooltip;

  /// No description provided for @nicknameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Nickname updated'**
  String get nicknameUpdated;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get updateFailed;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String memberSince(String date);

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSettings;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @performanceTab.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performanceTab;

  /// No description provided for @routesTab.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get routesTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @ticksTab.
  ///
  /// In en, this message translates to:
  /// **'Ticks'**
  String get ticksTab;

  /// No description provided for @likesTab.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get likesTab;

  /// No description provided for @projectsTab.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projectsTab;

  /// No description provided for @noTicksFound.
  ///
  /// In en, this message translates to:
  /// **'No ticks found'**
  String get noTicksFound;

  /// No description provided for @noTicksDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete some routes to see them here'**
  String get noTicksDescription;

  /// No description provided for @noLikesFound.
  ///
  /// In en, this message translates to:
  /// **'No liked routes found'**
  String get noLikesFound;

  /// No description provided for @noLikesDescription.
  ///
  /// In en, this message translates to:
  /// **'Like some routes to see them here'**
  String get noLikesDescription;

  /// No description provided for @noProjectsFound.
  ///
  /// In en, this message translates to:
  /// **'No projects found'**
  String get noProjectsFound;

  /// No description provided for @noProjectsDescription.
  ///
  /// In en, this message translates to:
  /// **'Mark routes as projects to track your goals'**
  String get noProjectsDescription;

  /// No description provided for @gradeBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Grade Breakdown'**
  String get gradeBreakdown;

  /// No description provided for @hardestGrade.
  ///
  /// In en, this message translates to:
  /// **'Hardest Grade'**
  String get hardestGrade;

  /// No description provided for @totalTicks.
  ///
  /// In en, this message translates to:
  /// **'Total Sends'**
  String get totalTicks;

  /// No description provided for @totalAttempts.
  ///
  /// In en, this message translates to:
  /// **'Avg. Attempts'**
  String get totalAttempts;

  /// No description provided for @topRopeFlash.
  ///
  /// In en, this message translates to:
  /// **'TR Flash'**
  String get topRopeFlash;

  /// No description provided for @leadFlash.
  ///
  /// In en, this message translates to:
  /// **'Lead Flash'**
  String get leadFlash;

  /// No description provided for @flashRate.
  ///
  /// In en, this message translates to:
  /// **'Flash Rate'**
  String get flashRate;

  /// No description provided for @averageAttempts.
  ///
  /// In en, this message translates to:
  /// **'Avg. Attempts'**
  String get averageAttempts;

  /// No description provided for @routeTitle.
  ///
  /// In en, this message translates to:
  /// **'Route Details'**
  String get routeTitle;

  /// No description provided for @addRoute.
  ///
  /// In en, this message translates to:
  /// **'Add Route'**
  String get addRoute;

  /// No description provided for @routeName.
  ///
  /// In en, this message translates to:
  /// **'Route Name'**
  String get routeName;

  /// No description provided for @routeNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Route name is required'**
  String get routeNameRequired;

  /// No description provided for @routeNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Give your route a memorable name'**
  String get routeNameHelper;

  /// No description provided for @grade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get grade;

  /// No description provided for @gradeRequired.
  ///
  /// In en, this message translates to:
  /// **'Grade is required'**
  String get gradeRequired;

  /// No description provided for @gradeHelper.
  ///
  /// In en, this message translates to:
  /// **'Select the difficulty grade'**
  String get gradeHelper;

  /// No description provided for @routeSetter.
  ///
  /// In en, this message translates to:
  /// **'Route Setter'**
  String get routeSetter;

  /// No description provided for @routeSetterRequired.
  ///
  /// In en, this message translates to:
  /// **'Route setter name is required'**
  String get routeSetterRequired;

  /// No description provided for @routeSetterHelper.
  ///
  /// In en, this message translates to:
  /// **'Name of the person who set this route'**
  String get routeSetterHelper;

  /// No description provided for @wallSection.
  ///
  /// In en, this message translates to:
  /// **'Wall Section'**
  String get wallSection;

  /// No description provided for @wallSectionRequired.
  ///
  /// In en, this message translates to:
  /// **'Wall section is required'**
  String get wallSectionRequired;

  /// No description provided for @wallSectionHelper.
  ///
  /// In en, this message translates to:
  /// **'Which section of the climbing wall'**
  String get wallSectionHelper;

  /// No description provided for @lane.
  ///
  /// In en, this message translates to:
  /// **'Lane'**
  String get lane;

  /// No description provided for @laneRequired.
  ///
  /// In en, this message translates to:
  /// **'Lane is required'**
  String get laneRequired;

  /// No description provided for @laneHelper.
  ///
  /// In en, this message translates to:
  /// **'Lane number on the wall'**
  String get laneHelper;

  /// No description provided for @laneNumber.
  ///
  /// In en, this message translates to:
  /// **'Lane {number}'**
  String laneNumber(int number);

  /// No description provided for @holdColor.
  ///
  /// In en, this message translates to:
  /// **'Hold Color'**
  String get holdColor;

  /// No description provided for @holdColorHelper.
  ///
  /// In en, this message translates to:
  /// **'Color of the route holds (optional)'**
  String get holdColorHelper;

  /// No description provided for @noSpecificColor.
  ///
  /// In en, this message translates to:
  /// **'No specific color'**
  String get noSpecificColor;

  /// No description provided for @routeDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get routeDescription;

  /// No description provided for @routeDescriptionHelper.
  ///
  /// In en, this message translates to:
  /// **'Additional details about the route (optional)'**
  String get routeDescriptionHelper;

  /// No description provided for @setBy.
  ///
  /// In en, this message translates to:
  /// **'Set by {setter}'**
  String setBy(String setter);

  /// No description provided for @unknownRoute.
  ///
  /// In en, this message translates to:
  /// **'Unknown Route'**
  String get unknownRoute;

  /// No description provided for @addNewRoute.
  ///
  /// In en, this message translates to:
  /// **'Add New Route'**
  String get addNewRoute;

  /// No description provided for @routeInformation.
  ///
  /// In en, this message translates to:
  /// **'Route Information'**
  String get routeInformation;

  /// No description provided for @createRoute.
  ///
  /// In en, this message translates to:
  /// **'Create Route'**
  String get createRoute;

  /// No description provided for @creatingRoute.
  ///
  /// In en, this message translates to:
  /// **'Creating Route...'**
  String get creatingRoute;

  /// No description provided for @routeCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Route created successfully!'**
  String get routeCreatedSuccess;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @enterCreativeName.
  ///
  /// In en, this message translates to:
  /// **'Enter a creative name for the route'**
  String get enterCreativeName;

  /// No description provided for @selectDifficultyGrade.
  ///
  /// In en, this message translates to:
  /// **'Select the difficulty grade'**
  String get selectDifficultyGrade;

  /// No description provided for @nameOfPersonWhoSet.
  ///
  /// In en, this message translates to:
  /// **'Name of the person who set this route'**
  String get nameOfPersonWhoSet;

  /// No description provided for @locationOfRouteInGym.
  ///
  /// In en, this message translates to:
  /// **'Location of the route in the gym'**
  String get locationOfRouteInGym;

  /// No description provided for @selectLaneNumber.
  ///
  /// In en, this message translates to:
  /// **'Select the lane number for this route'**
  String get selectLaneNumber;

  /// No description provided for @colorOfRouteHolds.
  ///
  /// In en, this message translates to:
  /// **'Color of the route holds (optional)'**
  String get colorOfRouteHolds;

  /// No description provided for @optionalDescriptionRoute.
  ///
  /// In en, this message translates to:
  /// **'Optional description of the route style or features'**
  String get optionalDescriptionRoute;

  /// No description provided for @markSend.
  ///
  /// In en, this message translates to:
  /// **'Mark Send'**
  String get markSend;

  /// No description provided for @addProgress.
  ///
  /// In en, this message translates to:
  /// **'Add Progress'**
  String get addProgress;

  /// No description provided for @addAttempts.
  ///
  /// In en, this message translates to:
  /// **'Add Attempts'**
  String get addAttempts;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// No description provided for @sendType.
  ///
  /// In en, this message translates to:
  /// **'Send Type:'**
  String get sendType;

  /// No description provided for @topRope.
  ///
  /// In en, this message translates to:
  /// **'Top Rope'**
  String get topRope;

  /// No description provided for @lead.
  ///
  /// In en, this message translates to:
  /// **'Lead'**
  String get lead;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes:'**
  String get notes;

  /// No description provided for @notesHelper.
  ///
  /// In en, this message translates to:
  /// **'Add any notes about your send (optional)'**
  String get notesHelper;

  /// No description provided for @addTimestamp.
  ///
  /// In en, this message translates to:
  /// **'Add timestamp'**
  String get addTimestamp;

  /// No description provided for @attempts.
  ///
  /// In en, this message translates to:
  /// **'Attempts:'**
  String attempts(int count);

  /// No description provided for @attemptsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{attempt} other{attempts}}'**
  String attemptsCount(num count);

  /// No description provided for @attemptsHelper.
  ///
  /// In en, this message translates to:
  /// **'How many attempts did it take?'**
  String get attemptsHelper;

  /// No description provided for @issueType.
  ///
  /// In en, this message translates to:
  /// **'Issue Type'**
  String get issueType;

  /// No description provided for @brokenHold.
  ///
  /// In en, this message translates to:
  /// **'Broken Hold'**
  String get brokenHold;

  /// No description provided for @safetyIssue.
  ///
  /// In en, this message translates to:
  /// **'Safety Issue'**
  String get safetyIssue;

  /// No description provided for @needsCleaning.
  ///
  /// In en, this message translates to:
  /// **'Needs Cleaning'**
  String get needsCleaning;

  /// No description provided for @looseHold.
  ///
  /// In en, this message translates to:
  /// **'Loose Hold'**
  String get looseHold;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @issueDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get issueDescription;

  /// No description provided for @issueDescriptionHelper.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue'**
  String get issueDescriptionHelper;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// No description provided for @projectRoute.
  ///
  /// In en, this message translates to:
  /// **'Add to Projects'**
  String get projectRoute;

  /// No description provided for @removeProject.
  ///
  /// In en, this message translates to:
  /// **'Remove from Projects'**
  String get removeProject;

  /// No description provided for @likeRoute.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get likeRoute;

  /// No description provided for @unlikeRoute.
  ///
  /// In en, this message translates to:
  /// **'Unlike'**
  String get unlikeRoute;

  /// No description provided for @progressTracking.
  ///
  /// In en, this message translates to:
  /// **'Progress Tracking'**
  String get progressTracking;

  /// No description provided for @socialPlanning.
  ///
  /// In en, this message translates to:
  /// **'Social & Planning'**
  String get socialPlanning;

  /// No description provided for @feedbackReporting.
  ///
  /// In en, this message translates to:
  /// **'Feedback & Reporting'**
  String get feedbackReporting;

  /// No description provided for @alreadySent.
  ///
  /// In en, this message translates to:
  /// **'Already Sent'**
  String get alreadySent;

  /// No description provided for @cannotAddAttempts.
  ///
  /// In en, this message translates to:
  /// **'Cannot add attempts to routes you have already lead sent.'**
  String get cannotAddAttempts;

  /// No description provided for @attemptsLabel.
  ///
  /// In en, this message translates to:
  /// **'Attempts'**
  String get attemptsLabel;

  /// No description provided for @topRopeLabel.
  ///
  /// In en, this message translates to:
  /// **'Top Rope'**
  String get topRopeLabel;

  /// No description provided for @flashLabel.
  ///
  /// In en, this message translates to:
  /// **'Flash!'**
  String get flashLabel;

  /// No description provided for @liked.
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get liked;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project;

  /// No description provided for @addProject.
  ///
  /// In en, this message translates to:
  /// **'Add Project'**
  String get addProject;

  /// No description provided for @topRopeSent.
  ///
  /// In en, this message translates to:
  /// **'Top Rope Sent'**
  String get topRopeSent;

  /// No description provided for @leadSent.
  ///
  /// In en, this message translates to:
  /// **'Lead Sent'**
  String get leadSent;

  /// No description provided for @suggestGrade.
  ///
  /// In en, this message translates to:
  /// **'Suggest Grade'**
  String get suggestGrade;

  /// No description provided for @issueTypeOptional.
  ///
  /// In en, this message translates to:
  /// **'Issue Type (Optional)'**
  String get issueTypeOptional;

  /// No description provided for @topRopeShort.
  ///
  /// In en, this message translates to:
  /// **'TR'**
  String get topRopeShort;

  /// No description provided for @leadShort.
  ///
  /// In en, this message translates to:
  /// **'Lead'**
  String get leadShort;

  /// No description provided for @flash.
  ///
  /// In en, this message translates to:
  /// **'⚡'**
  String get flash;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get filterAll;

  /// No description provided for @filterThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get filterThisWeek;

  /// No description provided for @filterThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get filterThisMonth;

  /// No description provided for @filterThisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get filterThisYear;

  /// No description provided for @filterLast3Months.
  ///
  /// In en, this message translates to:
  /// **'Last 3 Months'**
  String get filterLast3Months;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get languageItalian;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @colorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorRed;

  /// No description provided for @colorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get colorYellow;

  /// No description provided for @colorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// No description provided for @colorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorPurple;

  /// No description provided for @colorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorPink;

  /// No description provided for @colorBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get colorBlack;

  /// No description provided for @colorWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorWhite;

  /// No description provided for @colorGray.
  ///
  /// In en, this message translates to:
  /// **'Gray'**
  String get colorGray;

  /// No description provided for @colorBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get colorBrown;

  /// No description provided for @interactions.
  ///
  /// In en, this message translates to:
  /// **'Interactions'**
  String get interactions;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// No description provided for @removeTick.
  ///
  /// In en, this message translates to:
  /// **'Remove Tick'**
  String get removeTick;

  /// No description provided for @addNotesAttempts.
  ///
  /// In en, this message translates to:
  /// **'Add notes about your attempts'**
  String get addNotesAttempts;

  /// No description provided for @addEntryBelowNotes.
  ///
  /// In en, this message translates to:
  /// **'Add entry below existing notes'**
  String get addEntryBelowNotes;

  /// No description provided for @addNotesSend.
  ///
  /// In en, this message translates to:
  /// **'Add notes about this send'**
  String get addNotesSend;

  /// No description provided for @markedSend.
  ///
  /// In en, this message translates to:
  /// **'Marked {sendType} send!'**
  String markedSend(String sendType);

  /// No description provided for @yourComment.
  ///
  /// In en, this message translates to:
  /// **'Your comment'**
  String get yourComment;

  /// No description provided for @proposedGrade.
  ///
  /// In en, this message translates to:
  /// **'Proposed Grade'**
  String get proposedGrade;

  /// No description provided for @selectGradeToPropose.
  ///
  /// In en, this message translates to:
  /// **'Select a grade to propose'**
  String get selectGradeToPropose;

  /// No description provided for @changeProposedGrade.
  ///
  /// In en, this message translates to:
  /// **'You can change your proposed grade'**
  String get changeProposedGrade;

  /// No description provided for @attemptAdded.
  ///
  /// In en, this message translates to:
  /// **'Attempt added!'**
  String get attemptAdded;

  /// No description provided for @failedToAddAttempt.
  ///
  /// In en, this message translates to:
  /// **'Failed to add attempt'**
  String get failedToAddAttempt;

  /// No description provided for @topRopeSendRemoved.
  ///
  /// In en, this message translates to:
  /// **'Top rope send removed!'**
  String get topRopeSendRemoved;

  /// No description provided for @failedToRemoveTopRopeSend.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove top rope send'**
  String get failedToRemoveTopRopeSend;

  /// No description provided for @topRopeSendMarked.
  ///
  /// In en, this message translates to:
  /// **'Top rope send marked!'**
  String get topRopeSendMarked;

  /// No description provided for @failedToMarkTopRopeSend.
  ///
  /// In en, this message translates to:
  /// **'Failed to mark top rope send'**
  String get failedToMarkTopRopeSend;

  /// No description provided for @leadSendRemoved.
  ///
  /// In en, this message translates to:
  /// **'Lead send removed!'**
  String get leadSendRemoved;

  /// No description provided for @failedToRemoveLeadSend.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove lead send'**
  String get failedToRemoveLeadSend;

  /// No description provided for @leadSendMarked.
  ///
  /// In en, this message translates to:
  /// **'Lead send marked!'**
  String get leadSendMarked;

  /// No description provided for @failedToMarkLeadSend.
  ///
  /// In en, this message translates to:
  /// **'Failed to mark lead send'**
  String get failedToMarkLeadSend;

  /// No description provided for @routeUnliked.
  ///
  /// In en, this message translates to:
  /// **'Route unliked!'**
  String get routeUnliked;

  /// No description provided for @routeLiked.
  ///
  /// In en, this message translates to:
  /// **'Route liked!'**
  String get routeLiked;

  /// No description provided for @cannotMarkSentRoutesAsProjects.
  ///
  /// In en, this message translates to:
  /// **'Cannot mark sent routes as projects'**
  String get cannotMarkSentRoutesAsProjects;

  /// No description provided for @projectRemoved.
  ///
  /// In en, this message translates to:
  /// **'Project removed!'**
  String get projectRemoved;

  /// No description provided for @routeAddedToProjects.
  ///
  /// In en, this message translates to:
  /// **'Route added to projects!'**
  String get routeAddedToProjects;

  /// No description provided for @commentAdded.
  ///
  /// In en, this message translates to:
  /// **'Comment added!'**
  String get commentAdded;

  /// No description provided for @gradeProposalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Grade proposal updated!'**
  String get gradeProposalUpdated;

  /// No description provided for @issueReported.
  ///
  /// In en, this message translates to:
  /// **'Issue reported!'**
  String get issueReported;

  /// No description provided for @unableToLoadGrades.
  ///
  /// In en, this message translates to:
  /// **'Unable to load grades'**
  String get unableToLoadGrades;

  /// No description provided for @gradeDefinitions.
  ///
  /// In en, this message translates to:
  /// **'Grade definitions'**
  String get gradeDefinitions;

  /// No description provided for @gradesList.
  ///
  /// In en, this message translates to:
  /// **'Grades list'**
  String get gradesList;

  /// No description provided for @updateGradeProposal.
  ///
  /// In en, this message translates to:
  /// **'Update Grade Proposal'**
  String get updateGradeProposal;

  /// No description provided for @youAlreadyProposed.
  ///
  /// In en, this message translates to:
  /// **'You already proposed'**
  String get youAlreadyProposed;

  /// No description provided for @changeYourGradeAndUpdateReasoningBelow.
  ///
  /// In en, this message translates to:
  /// **'Change your grade and update reasoning below'**
  String get changeYourGradeAndUpdateReasoningBelow;

  /// No description provided for @youHadAPreviousProposalThatIsNoLongerValid.
  ///
  /// In en, this message translates to:
  /// **'You had a previous proposal that is no longer valid'**
  String get youHadAPreviousProposalThatIsNoLongerValid;

  /// No description provided for @pleaseSelectANewGrade.
  ///
  /// In en, this message translates to:
  /// **'Please select a new grade'**
  String get pleaseSelectANewGrade;

  /// No description provided for @reasoningOptional.
  ///
  /// In en, this message translates to:
  /// **'Reasoning (Optional)'**
  String get reasoningOptional;

  /// No description provided for @errorLoadingGradeProposalDialog.
  ///
  /// In en, this message translates to:
  /// **'Error loading grade proposal dialog'**
  String get errorLoadingGradeProposalDialog;

  /// No description provided for @overhangWall.
  ///
  /// In en, this message translates to:
  /// **'Overhang Wall'**
  String get overhangWall;

  /// No description provided for @slabWall.
  ///
  /// In en, this message translates to:
  /// **'Slab Wall'**
  String get slabWall;

  /// No description provided for @steepWall.
  ///
  /// In en, this message translates to:
  /// **'Steep Wall'**
  String get steepWall;

  /// No description provided for @verticalWall.
  ///
  /// In en, this message translates to:
  /// **'Vertical Wall'**
  String get verticalWall;

  /// No description provided for @caveSection.
  ///
  /// In en, this message translates to:
  /// **'Cave Section'**
  String get caveSection;

  /// No description provided for @roofSection.
  ///
  /// In en, this message translates to:
  /// **'Roof Section'**
  String get roofSection;

  /// No description provided for @routeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Route not found'**
  String get routeNotFound;

  /// No description provided for @laneLabel.
  ///
  /// In en, this message translates to:
  /// **'Lane {number}'**
  String laneLabel(int number);

  /// No description provided for @communitySuggested.
  ///
  /// In en, this message translates to:
  /// **'Community suggested: {grade} (avg of {count} proposals)'**
  String communitySuggested(String grade, int count);

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @gradeProposals.
  ///
  /// In en, this message translates to:
  /// **'Grade Proposals'**
  String get gradeProposals;

  /// No description provided for @warnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get warnings;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @noRoutesFound.
  ///
  /// In en, this message translates to:
  /// **'No routes found'**
  String get noRoutesFound;

  /// No description provided for @adjustFiltersOrAddRoute.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or add a new route'**
  String get adjustFiltersOrAddRoute;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @proposeGrade.
  ///
  /// In en, this message translates to:
  /// **'Propose Grade'**
  String get proposeGrade;

  /// No description provided for @manageTick.
  ///
  /// In en, this message translates to:
  /// **'Manage Tick'**
  String get manageTick;

  /// No description provided for @leadSend.
  ///
  /// In en, this message translates to:
  /// **'Lead Send'**
  String get leadSend;

  /// No description provided for @trackProgress.
  ///
  /// In en, this message translates to:
  /// **'Track Progress'**
  String get trackProgress;

  /// No description provided for @tickRemoved.
  ///
  /// In en, this message translates to:
  /// **'Tick removed'**
  String get tickRemoved;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add Comment'**
  String get addComment;

  /// No description provided for @filtersAndSorting.
  ///
  /// In en, this message translates to:
  /// **'Filters & Sorting'**
  String get filtersAndSorting;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @basicFilters.
  ///
  /// In en, this message translates to:
  /// **'Basic Filters'**
  String get basicFilters;

  /// No description provided for @userInteractions.
  ///
  /// In en, this message translates to:
  /// **'User Interactions'**
  String get userInteractions;

  /// No description provided for @clearAllFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear All Filters'**
  String get clearAllFilters;

  /// No description provided for @sortby.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortby;

  /// No description provided for @allSections.
  ///
  /// In en, this message translates to:
  /// **'All Sections'**
  String get allSections;

  /// No description provided for @allGrades.
  ///
  /// In en, this message translates to:
  /// **'All Grades'**
  String get allGrades;

  /// No description provided for @allLanes.
  ///
  /// In en, this message translates to:
  /// **'All Lanes'**
  String get allLanes;

  /// No description provided for @allRouteSetters.
  ///
  /// In en, this message translates to:
  /// **'All Route Setters'**
  String get allRouteSetters;

  /// No description provided for @tickedRoutes.
  ///
  /// In en, this message translates to:
  /// **'Ticked Routes'**
  String get tickedRoutes;

  /// No description provided for @likedRoutes.
  ///
  /// In en, this message translates to:
  /// **'Liked Routes'**
  String get likedRoutes;

  /// No description provided for @warnedRoutes.
  ///
  /// In en, this message translates to:
  /// **'Warned Routes'**
  String get warnedRoutes;

  /// No description provided for @projectRoutes.
  ///
  /// In en, this message translates to:
  /// **'Project Routes'**
  String get projectRoutes;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get newestFirst;

  /// No description provided for @oldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get oldestFirst;

  /// No description provided for @nameAZ.
  ///
  /// In en, this message translates to:
  /// **'Name (A-Z)'**
  String get nameAZ;

  /// No description provided for @nameZA.
  ///
  /// In en, this message translates to:
  /// **'Name (Z-A)'**
  String get nameZA;

  /// No description provided for @gradeEasyToHard.
  ///
  /// In en, this message translates to:
  /// **'Grade (Easy to Hard)'**
  String get gradeEasyToHard;

  /// No description provided for @gradeHardToEasy.
  ///
  /// In en, this message translates to:
  /// **'Grade (Hard to Easy)'**
  String get gradeHardToEasy;

  /// No description provided for @mostLikes.
  ///
  /// In en, this message translates to:
  /// **'Most Likes'**
  String get mostLikes;

  /// No description provided for @leastLikes.
  ///
  /// In en, this message translates to:
  /// **'Least Likes'**
  String get leastLikes;

  /// No description provided for @mostComments.
  ///
  /// In en, this message translates to:
  /// **'Most Comments'**
  String get mostComments;

  /// No description provided for @leastComments.
  ///
  /// In en, this message translates to:
  /// **'Least Comments'**
  String get leastComments;

  /// No description provided for @mostTicks.
  ///
  /// In en, this message translates to:
  /// **'Most Ticks'**
  String get mostTicks;

  /// No description provided for @leastTicks.
  ///
  /// In en, this message translates to:
  /// **'Least Ticks'**
  String get leastTicks;

  /// No description provided for @filterStateAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterStateAll;

  /// No description provided for @filterStateOnly.
  ///
  /// In en, this message translates to:
  /// **'Only'**
  String get filterStateOnly;

  /// No description provided for @filterStateExclude.
  ///
  /// In en, this message translates to:
  /// **'Exclude'**
  String get filterStateExclude;

  /// No description provided for @noPerformanceData.
  ///
  /// In en, this message translates to:
  /// **'No performance data available'**
  String get noPerformanceData;

  /// No description provided for @performanceSummary.
  ///
  /// In en, this message translates to:
  /// **'Performance Summary'**
  String get performanceSummary;

  /// No description provided for @trFlash.
  ///
  /// In en, this message translates to:
  /// **'TR Flash'**
  String get trFlash;

  /// No description provided for @allTimeStats.
  ///
  /// In en, this message translates to:
  /// **'All-Time Stats'**
  String get allTimeStats;

  /// No description provided for @totalLikesGiven.
  ///
  /// In en, this message translates to:
  /// **'Total Likes Given'**
  String get totalLikesGiven;

  /// No description provided for @commentsPosted.
  ///
  /// In en, this message translates to:
  /// **'Comments Posted'**
  String get commentsPosted;

  /// No description provided for @wallSectionsClimbed.
  ///
  /// In en, this message translates to:
  /// **'Wall Sections Climbed'**
  String get wallSectionsClimbed;

  /// No description provided for @gradesAchieved.
  ///
  /// In en, this message translates to:
  /// **'Grades Achieved'**
  String get gradesAchieved;

  /// No description provided for @noGradeData.
  ///
  /// In en, this message translates to:
  /// **'No grade data available'**
  String get noGradeData;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @flashed.
  ///
  /// In en, this message translates to:
  /// **'Flashed'**
  String get flashed;

  /// No description provided for @detailedStatistics.
  ///
  /// In en, this message translates to:
  /// **'Detailed Statistics'**
  String get detailedStatistics;

  /// No description provided for @routesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Routes Completed:'**
  String get routesCompleted;

  /// No description provided for @flashes.
  ///
  /// In en, this message translates to:
  /// **'Flashes'**
  String get flashes;

  /// No description provided for @totalAttemptsColon.
  ///
  /// In en, this message translates to:
  /// **'Total Attempts:'**
  String get totalAttemptsColon;

  /// No description provided for @gradeStatistics.
  ///
  /// In en, this message translates to:
  /// **'{grade} Statistics'**
  String gradeStatistics(String grade);

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @weekAgo.
  ///
  /// In en, this message translates to:
  /// **'1 week ago'**
  String get weekAgo;

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks ago'**
  String weeksAgo(int count);

  /// No description provided for @monthAgo.
  ///
  /// In en, this message translates to:
  /// **'1 month ago'**
  String get monthAgo;

  /// No description provided for @monthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} months ago'**
  String monthsAgo(int count);

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @propose.
  ///
  /// In en, this message translates to:
  /// **'Propose'**
  String get propose;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
