import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('it')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'F1 Friends'**
  String get appTitle;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccount;

  /// No description provided for @authNeedAccount.
  ///
  /// In en, this message translates to:
  /// **'Need an account? Register'**
  String get authNeedAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Have an account? Sign In'**
  String get authHaveAccount;

  /// No description provided for @authEmailOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Email or Username'**
  String get authEmailOrUsername;

  /// No description provided for @authUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsername;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegister;

  /// No description provided for @authEnterEmailOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter email or username'**
  String get authEnterEmailOrUsername;

  /// No description provided for @authEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get authEnterValidEmail;

  /// No description provided for @authUsernameValidation.
  ///
  /// In en, this message translates to:
  /// **'Username: 3+ chars, letters/numbers/_ only'**
  String get authUsernameValidation;

  /// No description provided for @authPasswordMin.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get authPasswordMin;

  /// No description provided for @authPasswordRule.
  ///
  /// In en, this message translates to:
  /// **'Password must include at least one letter and one number'**
  String get authPasswordRule;

  /// No description provided for @authResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authResetPassword;

  /// No description provided for @authAccountEmail.
  ///
  /// In en, this message translates to:
  /// **'Account email'**
  String get authAccountEmail;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @commonJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get commonJoin;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get commonUpdate;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @commonUnknown.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get commonUnknown;

  /// No description provided for @commonSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Type to filter (e.g. max)'**
  String get commonSearchHint;

  /// No description provided for @authSendLink.
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get authSendLink;

  /// No description provided for @authPasswordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to email.'**
  String get authPasswordResetSent;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials. Please check your username/email and password.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorEmailExists.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered.'**
  String get authErrorEmailExists;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait and try again.'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection and try again.'**
  String get authErrorNetwork;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address.'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorUsernameLoginUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Login by username is not available until Firestore rules are published.'**
  String get authErrorUsernameLoginUnavailable;

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get authErrorGeneric;

  /// No description provided for @authErrorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error. Please try again.'**
  String get authErrorUnexpected;

  /// No description provided for @errorUserNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'You need to sign in again to continue.'**
  String get errorUserNotAuthenticated;

  /// No description provided for @errorUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'Username is already taken.'**
  String get errorUsernameTaken;

  /// No description provided for @errorUsernameReserveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not reserve a unique username. Please try another one.'**
  String get errorUsernameReserveFailed;

  /// No description provided for @errorLeagueJoinCodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'League with this join code was not found.'**
  String get errorLeagueJoinCodeNotFound;

  /// No description provided for @errorLeagueJoinCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Join code mapping is invalid.'**
  String get errorLeagueJoinCodeInvalid;

  /// No description provided for @errorLeagueNotFound.
  ///
  /// In en, this message translates to:
  /// **'League was not found.'**
  String get errorLeagueNotFound;

  /// No description provided for @errorLeagueDeleteAdminOnly.
  ///
  /// In en, this message translates to:
  /// **'Only the league admin can delete this league.'**
  String get errorLeagueDeleteAdminOnly;

  /// No description provided for @errorJoinCodeGeneration.
  ///
  /// In en, this message translates to:
  /// **'Could not generate a unique join code. Please retry.'**
  String get errorJoinCodeGeneration;

  /// No description provided for @errorPredictionsLocked.
  ///
  /// In en, this message translates to:
  /// **'Predictions are locked for this race.'**
  String get errorPredictionsLocked;

  /// No description provided for @errorPredictionDriversRequired.
  ///
  /// In en, this message translates to:
  /// **'All driver fields are required.'**
  String get errorPredictionDriversRequired;

  /// No description provided for @errorPredictionPodiumDistinct.
  ///
  /// In en, this message translates to:
  /// **'P1, P2, and P3 must be different drivers.'**
  String get errorPredictionPodiumDistinct;

  /// No description provided for @errorPredictionDnfNegative.
  ///
  /// In en, this message translates to:
  /// **'DNF count cannot be negative.'**
  String get errorPredictionDnfNegative;

  /// No description provided for @errorApiLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load Formula 1 data right now. Please try again.'**
  String get errorApiLoad;

  /// No description provided for @errorGenericAction.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGenericAction;

  /// No description provided for @homeNavLeagues.
  ///
  /// In en, this message translates to:
  /// **'Leagues'**
  String get homeNavLeagues;

  /// No description provided for @homeNavRaces.
  ///
  /// In en, this message translates to:
  /// **'Races'**
  String get homeNavRaces;

  /// No description provided for @homeNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get homeNavProfile;

  /// No description provided for @leaguesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Leagues'**
  String get leaguesTitle;

  /// No description provided for @leaguesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compete with private friend leagues'**
  String get leaguesSubtitle;

  /// No description provided for @leaguesCreate.
  ///
  /// In en, this message translates to:
  /// **'Create League'**
  String get leaguesCreate;

  /// No description provided for @leaguesJoin.
  ///
  /// In en, this message translates to:
  /// **'Join League'**
  String get leaguesJoin;

  /// No description provided for @leaguesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No leagues yet. Create one or join with a code.'**
  String get leaguesEmpty;

  /// No description provided for @leaguesAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get leaguesAdmin;

  /// No description provided for @leaguesSeason.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get leaguesSeason;

  /// No description provided for @leaguesMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get leaguesMembers;

  /// No description provided for @leaguesFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load leagues: {error}'**
  String leaguesFailedLoad(Object error);

  /// No description provided for @leaguesPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Firestore permission denied. Deploy firestore.rules, then restart the app.'**
  String get leaguesPermissionDenied;

  /// No description provided for @leaguesCreateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Create League'**
  String get leaguesCreateDialogTitle;

  /// No description provided for @leaguesName.
  ///
  /// In en, this message translates to:
  /// **'League name'**
  String get leaguesName;

  /// No description provided for @leaguesNameValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter at least 3 characters'**
  String get leaguesNameValidation;

  /// No description provided for @leaguesSeasonYear.
  ///
  /// In en, this message translates to:
  /// **'Season year'**
  String get leaguesSeasonYear;

  /// No description provided for @leaguesInvalidYear.
  ///
  /// In en, this message translates to:
  /// **'Invalid year'**
  String get leaguesInvalidYear;

  /// No description provided for @leaguesStartRound.
  ///
  /// In en, this message translates to:
  /// **'Start round'**
  String get leaguesStartRound;

  /// No description provided for @leaguesEndRound.
  ///
  /// In en, this message translates to:
  /// **'End round'**
  String get leaguesEndRound;

  /// No description provided for @leaguesStartPositive.
  ///
  /// In en, this message translates to:
  /// **'Start round must be positive'**
  String get leaguesStartPositive;

  /// No description provided for @leaguesEndPositive.
  ///
  /// In en, this message translates to:
  /// **'End round must be positive'**
  String get leaguesEndPositive;

  /// No description provided for @leaguesStartMax.
  ///
  /// In en, this message translates to:
  /// **'Start round must be <= {maxRound}'**
  String leaguesStartMax(Object maxRound);

  /// No description provided for @leaguesEndMax.
  ///
  /// In en, this message translates to:
  /// **'End round must be <= {maxRound}'**
  String leaguesEndMax(Object maxRound);

  /// No description provided for @leaguesEndAfterStart.
  ///
  /// In en, this message translates to:
  /// **'End round must be >= start round'**
  String get leaguesEndAfterStart;

  /// No description provided for @leaguesRoundsRange.
  ///
  /// In en, this message translates to:
  /// **'Rounds must be in range 1..{maxRound}.'**
  String leaguesRoundsRange(Object maxRound);

  /// No description provided for @leaguesCreated.
  ///
  /// In en, this message translates to:
  /// **'League created.'**
  String get leaguesCreated;

  /// No description provided for @leaguesJoinDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Join League'**
  String get leaguesJoinDialogTitle;

  /// No description provided for @leaguesJoinCode.
  ///
  /// In en, this message translates to:
  /// **'Join code'**
  String get leaguesJoinCode;

  /// No description provided for @leaguesJoinCodeValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid join code'**
  String get leaguesJoinCodeValidation;

  /// No description provided for @leaguesJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined league.'**
  String get leaguesJoined;

  /// No description provided for @leaguesAlreadyJoined.
  ///
  /// In en, this message translates to:
  /// **'Already joined. Duplicate join is not allowed.'**
  String get leaguesAlreadyJoined;

  /// No description provided for @leagueDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'League Details'**
  String get leagueDetailsTitle;

  /// No description provided for @leagueDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete league'**
  String get leagueDeleteTooltip;

  /// No description provided for @leagueDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete League'**
  String get leagueDeleteTitle;

  /// No description provided for @leagueDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove the league and its members list.'**
  String get leagueDeleteMessage;

  /// No description provided for @leagueDeleted.
  ///
  /// In en, this message translates to:
  /// **'League deleted.'**
  String get leagueDeleted;

  /// No description provided for @leagueDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete league: {error}'**
  String leagueDeleteFailed(Object error);

  /// No description provided for @leagueLoadRacesFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load races: {error}'**
  String leagueLoadRacesFailed(Object error);

  /// No description provided for @leagueRoundsSeason.
  ///
  /// In en, this message translates to:
  /// **'Rounds {startRound}-{endRound}, Season {seasonYear}'**
  String leagueRoundsSeason(
      Object startRound, Object endRound, Object seasonYear);

  /// No description provided for @leagueMembersCount.
  ///
  /// In en, this message translates to:
  /// **'Members: {count}'**
  String leagueMembersCount(Object count);

  /// No description provided for @leagueNoRaces.
  ///
  /// In en, this message translates to:
  /// **'No races found in this league range.'**
  String get leagueNoRaces;

  /// No description provided for @leagueRaceField.
  ///
  /// In en, this message translates to:
  /// **'Race'**
  String get leagueRaceField;

  /// No description provided for @leaguePredictionsForRound.
  ///
  /// In en, this message translates to:
  /// **'Predictions for R{round}'**
  String leaguePredictionsForRound(Object round);

  /// No description provided for @leagueEditMine.
  ///
  /// In en, this message translates to:
  /// **'Edit Mine'**
  String get leagueEditMine;

  /// No description provided for @leaguePredictionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Prediction updated.'**
  String get leaguePredictionUpdated;

  /// No description provided for @leagueLoadMembersFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load members: {error}'**
  String leagueLoadMembersFailed(Object error);

  /// No description provided for @leagueLoadPredictionsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load predictions: {error}'**
  String leagueLoadPredictionsFailed(Object error);

  /// No description provided for @leagueYouWithName.
  ///
  /// In en, this message translates to:
  /// **'You ({name})'**
  String leagueYouWithName(Object name);

  /// No description provided for @leaguePoints.
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String leaguePoints(Object points);

  /// No description provided for @leagueNoPrediction.
  ///
  /// In en, this message translates to:
  /// **'No prediction submitted yet.'**
  String get leagueNoPrediction;

  /// No description provided for @leaguePredictionSummary.
  ///
  /// In en, this message translates to:
  /// **'P1 {p1} | P2 {p2} | P3 {p3} | FL {fl} | DNF {dnf}'**
  String leaguePredictionSummary(
      Object p1, Object p2, Object p3, Object fl, Object dnf);

  /// No description provided for @leagueMockApplyTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply Mock Race Result'**
  String get leagueMockApplyTitle;

  /// No description provided for @leagueFastestLap.
  ///
  /// In en, this message translates to:
  /// **'Fastest lap'**
  String get leagueFastestLap;

  /// No description provided for @leagueDnfCount.
  ///
  /// In en, this message translates to:
  /// **'DNF count'**
  String get leagueDnfCount;

  /// No description provided for @leagueSelectAllFields.
  ///
  /// In en, this message translates to:
  /// **'Select all required fields.'**
  String get leagueSelectAllFields;

  /// No description provided for @leagueDistinctPodiumDrivers.
  ///
  /// In en, this message translates to:
  /// **'P1, P2 and P3 must be different drivers.'**
  String get leagueDistinctPodiumDrivers;

  /// No description provided for @leagueDnfNonNegative.
  ///
  /// In en, this message translates to:
  /// **'DNF must be a non-negative number.'**
  String get leagueDnfNonNegative;

  /// No description provided for @leagueMockApplied.
  ///
  /// In en, this message translates to:
  /// **'Mock scoring applied. Leaderboard updated.'**
  String get leagueMockApplied;

  /// No description provided for @leagueMockApplyFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to apply mock result: {error}'**
  String leagueMockApplyFailed(Object error);

  /// No description provided for @leagueMockReverted.
  ///
  /// In en, this message translates to:
  /// **'Mock points reverted for this race.'**
  String get leagueMockReverted;

  /// No description provided for @leagueMockRevertFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to revert mock points: {error}'**
  String leagueMockRevertFailed(Object error);

  /// No description provided for @leagueMockApplyButton.
  ///
  /// In en, this message translates to:
  /// **'Apply Mock Result'**
  String get leagueMockApplyButton;

  /// No description provided for @leagueMockRevertButton.
  ///
  /// In en, this message translates to:
  /// **'Revert Mock Points'**
  String get leagueMockRevertButton;

  /// No description provided for @leagueDemoTools.
  ///
  /// In en, this message translates to:
  /// **'Demo tools'**
  String get leagueDemoTools;

  /// No description provided for @leagueShowDemoTools.
  ///
  /// In en, this message translates to:
  /// **'Show demo tools'**
  String get leagueShowDemoTools;

  /// No description provided for @leagueHideDemoTools.
  ///
  /// In en, this message translates to:
  /// **'Hide demo tools'**
  String get leagueHideDemoTools;

  /// No description provided for @racesTitle.
  ///
  /// In en, this message translates to:
  /// **'Races'**
  String get racesTitle;

  /// No description provided for @racesNextRace.
  ///
  /// In en, this message translates to:
  /// **'Next Race'**
  String get racesNextRace;

  /// No description provided for @racesLastRace.
  ///
  /// In en, this message translates to:
  /// **'Last Race'**
  String get racesLastRace;

  /// No description provided for @racesLatestResults.
  ///
  /// In en, this message translates to:
  /// **'Latest Results'**
  String get racesLatestResults;

  /// No description provided for @racesCurrentSeasonRounds.
  ///
  /// In en, this message translates to:
  /// **'Current Season Rounds'**
  String get racesCurrentSeasonRounds;

  /// No description provided for @racesNoUpcoming.
  ///
  /// In en, this message translates to:
  /// **'No upcoming race returned by API.'**
  String get racesNoUpcoming;

  /// No description provided for @racesNoLast.
  ///
  /// In en, this message translates to:
  /// **'No last race details returned by API.'**
  String get racesNoLast;

  /// No description provided for @racesNoResults.
  ///
  /// In en, this message translates to:
  /// **'No result data available.'**
  String get racesNoResults;

  /// No description provided for @racesNoSeasonRaces.
  ///
  /// In en, this message translates to:
  /// **'No races found for current season.'**
  String get racesNoSeasonRaces;

  /// No description provided for @racesFailedLoadApi.
  ///
  /// In en, this message translates to:
  /// **'Failed to load API race data: {error}'**
  String racesFailedLoadApi(Object error);

  /// No description provided for @racesLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get racesLocked;

  /// No description provided for @racesFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get racesFinished;

  /// No description provided for @racesPredict.
  ///
  /// In en, this message translates to:
  /// **'Predict'**
  String get racesPredict;

  /// No description provided for @racesPredictionSaved.
  ///
  /// In en, this message translates to:
  /// **'Prediction saved.'**
  String get racesPredictionSaved;

  /// No description provided for @racesLock.
  ///
  /// In en, this message translates to:
  /// **'Lock: {date}'**
  String racesLock(Object date);

  /// No description provided for @racesRoundSeason.
  ///
  /// In en, this message translates to:
  /// **'Round {round}, Season {season}'**
  String racesRoundSeason(Object round, Object season);

  /// No description provided for @racesRaceStart.
  ///
  /// In en, this message translates to:
  /// **'Race start: {date}'**
  String racesRaceStart(Object date);

  /// No description provided for @racesExpectedEnd.
  ///
  /// In en, this message translates to:
  /// **'Expected end: {date}'**
  String racesExpectedEnd(Object date);

  /// No description provided for @racesQualyStart.
  ///
  /// In en, this message translates to:
  /// **'Qualy start: {date}'**
  String racesQualyStart(Object date);

  /// No description provided for @racesFastestLap.
  ///
  /// In en, this message translates to:
  /// **'Fastest lap: {driver}'**
  String racesFastestLap(Object driver);

  /// No description provided for @racesDnfs.
  ///
  /// In en, this message translates to:
  /// **'DNFs: {count}'**
  String racesDnfs(Object count);

  /// No description provided for @predictionTitle.
  ///
  /// In en, this message translates to:
  /// **'Prediction: {raceName}'**
  String predictionTitle(Object raceName);

  /// No description provided for @predictionP1Driver.
  ///
  /// In en, this message translates to:
  /// **'P1 driver'**
  String get predictionP1Driver;

  /// No description provided for @predictionP2Driver.
  ///
  /// In en, this message translates to:
  /// **'P2 driver'**
  String get predictionP2Driver;

  /// No description provided for @predictionP3Driver.
  ///
  /// In en, this message translates to:
  /// **'P3 driver'**
  String get predictionP3Driver;

  /// No description provided for @predictionFastestLapDriver.
  ///
  /// In en, this message translates to:
  /// **'Fastest lap driver'**
  String get predictionFastestLapDriver;

  /// No description provided for @predictionDnfOptional.
  ///
  /// In en, this message translates to:
  /// **'DNF count (optional)'**
  String get predictionDnfOptional;

  /// No description provided for @predictionSelectAllDrivers.
  ///
  /// In en, this message translates to:
  /// **'Please select all required drivers.'**
  String get predictionSelectAllDrivers;

  /// No description provided for @predictionDnfInteger.
  ///
  /// In en, this message translates to:
  /// **'DNF must be a non-negative integer.'**
  String get predictionDnfInteger;

  /// No description provided for @predictionPodiumDistinct.
  ///
  /// In en, this message translates to:
  /// **'P1, P2, and P3 must be different.'**
  String get predictionPodiumDistinct;

  /// No description provided for @predictionLockedAfterQualy.
  ///
  /// In en, this message translates to:
  /// **'Predictions are locked for this race (qualifying has ended).'**
  String get predictionLockedAfterQualy;

  /// No description provided for @predictionPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Firestore permissions denied. Please publish latest rules and restart.'**
  String get predictionPermissionDenied;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile: {error}'**
  String profileFailedLoad(Object error);

  /// No description provided for @profileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get profileChangePhoto;

  /// No description provided for @profileChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get profileChooseFromGallery;

  /// No description provided for @profileTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get profileTakePhoto;

  /// No description provided for @profileUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get profileUsername;

  /// No description provided for @profileEditUsername.
  ///
  /// In en, this message translates to:
  /// **'Edit username'**
  String get profileEditUsername;

  /// No description provided for @profileUsernameHelper.
  ///
  /// In en, this message translates to:
  /// **'At least 3 characters'**
  String get profileUsernameHelper;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profileMyOverview.
  ///
  /// In en, this message translates to:
  /// **'My Overview'**
  String get profileMyOverview;

  /// No description provided for @profileLoadingStats.
  ///
  /// In en, this message translates to:
  /// **'Loading stats...'**
  String get profileLoadingStats;

  /// No description provided for @profileStatsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Stats unavailable: {error}'**
  String profileStatsUnavailable(Object error);

  /// No description provided for @profileJoinedLeagues.
  ///
  /// In en, this message translates to:
  /// **'Joined leagues: {count}'**
  String profileJoinedLeagues(Object count);

  /// No description provided for @profileCreatedLeagues.
  ///
  /// In en, this message translates to:
  /// **'Created leagues: {count}'**
  String profileCreatedLeagues(Object count);

  /// No description provided for @profileBestLeaderboardPlace.
  ///
  /// In en, this message translates to:
  /// **'Best leaderboard place: {place}'**
  String profileBestLeaderboardPlace(Object place);

  /// No description provided for @profileBestLeaderboardPlaceNone.
  ///
  /// In en, this message translates to:
  /// **'Best leaderboard place: N/A'**
  String get profileBestLeaderboardPlaceNone;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// No description provided for @projectLoadingFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load this section right now.'**
  String get projectLoadingFailed;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languageItalian;

  /// No description provided for @notificationsChannelName.
  ///
  /// In en, this message translates to:
  /// **'Prediction Reminders'**
  String get notificationsChannelName;

  /// No description provided for @notificationsChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminders to submit race predictions'**
  String get notificationsChannelDescription;

  /// No description provided for @notificationsDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'F1 Friends'**
  String get notificationsDefaultTitle;

  /// No description provided for @notificationsDefaultBody.
  ///
  /// In en, this message translates to:
  /// **'New update available.'**
  String get notificationsDefaultBody;

  /// No description provided for @notificationsStartupBody.
  ///
  /// In en, this message translates to:
  /// **'Create a league and invite friends to predict next race!'**
  String get notificationsStartupBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
