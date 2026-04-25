// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'F1 Friends';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authCreateAccount => 'Create Account';

  @override
  String get authNeedAccount => 'Need an account? Register';

  @override
  String get authHaveAccount => 'Have an account? Sign In';

  @override
  String get authEmailOrUsername => 'Email or Username';

  @override
  String get authUsername => 'Username';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authRegister => 'Register';

  @override
  String get authEnterEmailOrUsername => 'Enter email or username';

  @override
  String get authEnterValidEmail => 'Enter a valid email';

  @override
  String get authUsernameValidation =>
      'Username: 3+ chars, letters/numbers/_ only';

  @override
  String get authPasswordMin => 'Password must be at least 6 characters';

  @override
  String get authPasswordRule =>
      'Password must include at least one letter and one number';

  @override
  String get authResetPassword => 'Reset Password';

  @override
  String get authAccountEmail => 'Account email';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonJoin => 'Join';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonUpdate => 'Update';

  @override
  String get commonSave => 'Save';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonUnknown => 'unknown';

  @override
  String get commonSearchHint => 'Type to filter (e.g. max)';

  @override
  String get authSendLink => 'Send Link';

  @override
  String get authPasswordResetSent => 'Password reset link sent to email.';

  @override
  String get authErrorInvalidCredentials =>
      'Invalid credentials. Please check your username/email and password.';

  @override
  String get authErrorEmailExists => 'This email is already registered.';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Please wait and try again.';

  @override
  String get authErrorNetwork =>
      'Network error. Check your connection and try again.';

  @override
  String get authErrorInvalidEmail => 'Invalid email address.';

  @override
  String get authErrorUsernameLoginUnavailable =>
      'Login by username is not available until Firestore rules are published.';

  @override
  String get authErrorGeneric => 'Authentication failed. Please try again.';

  @override
  String get authErrorUnexpected => 'Unexpected error. Please try again.';

  @override
  String get errorUserNotAuthenticated =>
      'You need to sign in again to continue.';

  @override
  String get errorUsernameTaken => 'Username is already taken.';

  @override
  String get errorUsernameReserveFailed =>
      'Could not reserve a unique username. Please try another one.';

  @override
  String get errorLeagueJoinCodeNotFound =>
      'League with this join code was not found.';

  @override
  String get errorLeagueJoinCodeInvalid => 'Join code mapping is invalid.';

  @override
  String get errorLeagueNotFound => 'League was not found.';

  @override
  String get errorLeagueDeleteAdminOnly =>
      'Only the league admin can delete this league.';

  @override
  String get errorJoinCodeGeneration =>
      'Could not generate a unique join code. Please retry.';

  @override
  String get errorPredictionsLocked => 'Predictions are locked for this race.';

  @override
  String get errorPredictionDriversRequired =>
      'All driver fields are required.';

  @override
  String get errorPredictionPodiumDistinct =>
      'P1, P2, and P3 must be different drivers.';

  @override
  String get errorPredictionDnfNegative => 'DNF count cannot be negative.';

  @override
  String get errorApiLoad =>
      'Could not load Formula 1 data right now. Please try again.';

  @override
  String get errorGenericAction => 'Something went wrong. Please try again.';

  @override
  String get homeNavLeagues => 'Leagues';

  @override
  String get homeNavRaces => 'Races';

  @override
  String get homeNavProfile => 'Profile';

  @override
  String get leaguesTitle => 'My Leagues';

  @override
  String get leaguesSubtitle => 'Compete with private friend leagues';

  @override
  String get leaguesCreate => 'Create League';

  @override
  String get leaguesJoin => 'Join League';

  @override
  String get leaguesEmpty => 'No leagues yet. Create one or join with a code.';

  @override
  String get leaguesAdmin => 'Admin';

  @override
  String get leaguesSeason => 'Season';

  @override
  String get leaguesMembers => 'Members';

  @override
  String leaguesFailedLoad(Object error) {
    return 'Failed to load leagues: $error';
  }

  @override
  String get leaguesPermissionDenied =>
      'Firestore permission denied. Deploy firestore.rules, then restart the app.';

  @override
  String get leaguesCreateDialogTitle => 'Create League';

  @override
  String get leaguesName => 'League name';

  @override
  String get leaguesNameValidation => 'Enter at least 3 characters';

  @override
  String get leaguesSeasonYear => 'Season year';

  @override
  String get leaguesInvalidYear => 'Invalid year';

  @override
  String get leaguesStartRound => 'Start round';

  @override
  String get leaguesEndRound => 'End round';

  @override
  String get leaguesStartPositive => 'Start round must be positive';

  @override
  String get leaguesEndPositive => 'End round must be positive';

  @override
  String leaguesStartMax(Object maxRound) {
    return 'Start round must be <= $maxRound';
  }

  @override
  String leaguesEndMax(Object maxRound) {
    return 'End round must be <= $maxRound';
  }

  @override
  String get leaguesEndAfterStart => 'End round must be >= start round';

  @override
  String leaguesRoundsRange(Object maxRound) {
    return 'Rounds must be in range 1..$maxRound.';
  }

  @override
  String get leaguesCreated => 'League created.';

  @override
  String get leaguesJoinDialogTitle => 'Join League';

  @override
  String get leaguesJoinCode => 'Join code';

  @override
  String get leaguesJoinCodeValidation => 'Enter a valid join code';

  @override
  String get leaguesJoined => 'Joined league.';

  @override
  String get leaguesAlreadyJoined =>
      'Already joined. Duplicate join is not allowed.';

  @override
  String get leagueDetailsTitle => 'League Details';

  @override
  String get leagueDeleteTooltip => 'Delete league';

  @override
  String get leagueDeleteTitle => 'Delete League';

  @override
  String get leagueDeleteMessage =>
      'This will permanently remove the league and its members list.';

  @override
  String get leagueDeleted => 'League deleted.';

  @override
  String leagueDeleteFailed(Object error) {
    return 'Failed to delete league: $error';
  }

  @override
  String leagueLoadRacesFailed(Object error) {
    return 'Failed to load races: $error';
  }

  @override
  String leagueRoundsSeason(
      Object startRound, Object endRound, Object seasonYear) {
    return 'Rounds $startRound-$endRound, Season $seasonYear';
  }

  @override
  String leagueMembersCount(Object count) {
    return 'Members: $count';
  }

  @override
  String get leagueNoRaces => 'No races found in this league range.';

  @override
  String get leagueRaceField => 'Race';

  @override
  String leaguePredictionsForRound(Object round) {
    return 'Predictions for R$round';
  }

  @override
  String get leagueEditMine => 'Edit Mine';

  @override
  String get leaguePredictionUpdated => 'Prediction updated.';

  @override
  String leagueLoadMembersFailed(Object error) {
    return 'Failed to load members: $error';
  }

  @override
  String leagueLoadPredictionsFailed(Object error) {
    return 'Failed to load predictions: $error';
  }

  @override
  String leagueYouWithName(Object name) {
    return 'You ($name)';
  }

  @override
  String leaguePoints(Object points) {
    return '$points pts';
  }

  @override
  String get leagueNoPrediction => 'No prediction submitted yet.';

  @override
  String leaguePredictionSummary(
      Object p1, Object p2, Object p3, Object fl, Object dnf) {
    return 'P1 $p1 | P2 $p2 | P3 $p3 | FL $fl | DNF $dnf';
  }

  @override
  String get leagueMockApplyTitle => 'Apply Mock Race Result';

  @override
  String get leagueFastestLap => 'Fastest lap';

  @override
  String get leagueDnfCount => 'DNF count';

  @override
  String get leagueSelectAllFields => 'Select all required fields.';

  @override
  String get leagueDistinctPodiumDrivers =>
      'P1, P2 and P3 must be different drivers.';

  @override
  String get leagueDnfNonNegative => 'DNF must be a non-negative number.';

  @override
  String get leagueMockApplied => 'Mock scoring applied. Leaderboard updated.';

  @override
  String leagueMockApplyFailed(Object error) {
    return 'Failed to apply mock result: $error';
  }

  @override
  String get leagueMockReverted => 'Mock points reverted for this race.';

  @override
  String leagueMockRevertFailed(Object error) {
    return 'Failed to revert mock points: $error';
  }

  @override
  String get leagueMockApplyButton => 'Apply Mock Result';

  @override
  String get leagueMockRevertButton => 'Revert Mock Points';

  @override
  String get leagueDemoTools => 'Demo tools';

  @override
  String get leagueShowDemoTools => 'Show demo tools';

  @override
  String get leagueHideDemoTools => 'Hide demo tools';

  @override
  String get racesTitle => 'Races';

  @override
  String get racesNextRace => 'Next Race';

  @override
  String get racesLastRace => 'Last Race';

  @override
  String get racesLatestResults => 'Latest Results';

  @override
  String get racesCurrentSeasonRounds => 'Current Season Rounds';

  @override
  String get racesNoUpcoming => 'No upcoming race returned by API.';

  @override
  String get racesNoLast => 'No last race details returned by API.';

  @override
  String get racesNoResults => 'No result data available.';

  @override
  String get racesNoSeasonRaces => 'No races found for current season.';

  @override
  String racesFailedLoadApi(Object error) {
    return 'Failed to load API race data: $error';
  }

  @override
  String get racesLocked => 'Locked';

  @override
  String get racesPredict => 'Predict';

  @override
  String get racesPredictionSaved => 'Prediction saved.';

  @override
  String racesLock(Object date) {
    return 'Lock: $date';
  }

  @override
  String racesRoundSeason(Object round, Object season) {
    return 'Round $round, Season $season';
  }

  @override
  String racesRaceStart(Object date) {
    return 'Race start: $date';
  }

  @override
  String racesExpectedEnd(Object date) {
    return 'Expected end: $date';
  }

  @override
  String racesQualyStart(Object date) {
    return 'Qualy start: $date';
  }

  @override
  String racesFastestLap(Object driver) {
    return 'Fastest lap: $driver';
  }

  @override
  String racesDnfs(Object count) {
    return 'DNFs: $count';
  }

  @override
  String predictionTitle(Object raceName) {
    return 'Prediction: $raceName';
  }

  @override
  String get predictionP1Driver => 'P1 driver';

  @override
  String get predictionP2Driver => 'P2 driver';

  @override
  String get predictionP3Driver => 'P3 driver';

  @override
  String get predictionFastestLapDriver => 'Fastest lap driver';

  @override
  String get predictionDnfOptional => 'DNF count (optional)';

  @override
  String get predictionSelectAllDrivers =>
      'Please select all required drivers.';

  @override
  String get predictionDnfInteger => 'DNF must be a non-negative integer.';

  @override
  String get predictionPodiumDistinct => 'P1, P2, and P3 must be different.';

  @override
  String get predictionLockedAfterQualy =>
      'Predictions are locked for this race (qualifying has ended).';

  @override
  String get predictionPermissionDenied =>
      'Firestore permissions denied. Please publish latest rules and restart.';

  @override
  String get profileTitle => 'Profile';

  @override
  String profileFailedLoad(Object error) {
    return 'Failed to load profile: $error';
  }

  @override
  String get profileChangePhoto => 'Change photo';

  @override
  String get profileChooseFromGallery => 'Choose from gallery';

  @override
  String get profileTakePhoto => 'Take photo';

  @override
  String get profileUsername => 'Username';

  @override
  String get profileEditUsername => 'Edit username';

  @override
  String get profileUsernameHelper => 'At least 3 characters';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileMyOverview => 'My Overview';

  @override
  String get profileLoadingStats => 'Loading stats...';

  @override
  String profileStatsUnavailable(Object error) {
    return 'Stats unavailable: $error';
  }

  @override
  String profileJoinedLeagues(Object count) {
    return 'Joined leagues: $count';
  }

  @override
  String profileCreatedLeagues(Object count) {
    return 'Created leagues: $count';
  }

  @override
  String profileBestLeaderboardPlace(Object place) {
    return 'Best leaderboard place: $place';
  }

  @override
  String get profileBestLeaderboardPlaceNone => 'Best leaderboard place: N/A';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get projectLoadingFailed => 'Could not load this section right now.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'French';

  @override
  String get languageItalian => 'Italian';

  @override
  String get notificationsChannelName => 'Prediction Reminders';

  @override
  String get notificationsChannelDescription =>
      'Reminders to submit race predictions';

  @override
  String get notificationsDefaultTitle => 'F1 Friends';

  @override
  String get notificationsDefaultBody => 'New update available.';

  @override
  String get notificationsStartupBody =>
      'Create a league and invite friends to predict next race!';
}
