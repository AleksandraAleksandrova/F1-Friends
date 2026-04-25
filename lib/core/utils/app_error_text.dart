import "../../l10n/app_localizations.dart";

class AppErrorText {
  static String describe(AppLocalizations l10n, Object error) {
    final raw = error.toString();

    if (raw.contains("User is not authenticated") || raw.contains("User not authenticated")) {
      return l10n.errorUserNotAuthenticated;
    }
    if (raw.contains("Username is already taken")) {
      return l10n.errorUsernameTaken;
    }
    if (raw.contains("Could not reserve a unique username")) {
      return l10n.errorUsernameReserveFailed;
    }
    if (raw.contains("League with this join code was not found")) {
      return l10n.errorLeagueJoinCodeNotFound;
    }
    if (raw.contains("Join code mapping is invalid")) {
      return l10n.errorLeagueJoinCodeInvalid;
    }
    if (raw.contains("League was not found")) {
      return l10n.errorLeagueNotFound;
    }
    if (raw.contains("Only the league admin can delete this league") ||
        raw.contains("Only league admin can delete this league")) {
      return l10n.errorLeagueDeleteAdminOnly;
    }
    if (raw.contains("Could not generate a unique join code")) {
      return l10n.errorJoinCodeGeneration;
    }
    if (raw.contains("Predictions are locked for this race")) {
      return l10n.errorPredictionsLocked;
    }
    if (raw.contains("All driver fields are required")) {
      return l10n.errorPredictionDriversRequired;
    }
    if (raw.contains("P1, P2, and P3 must be different")) {
      return l10n.errorPredictionPodiumDistinct;
    }
    if (raw.contains("DNF count cannot be negative")) {
      return l10n.errorPredictionDnfNegative;
    }
    if (raw.contains("F1 API request failed") || raw.contains("Unexpected F1 API response shape")) {
      return l10n.errorApiLoad;
    }
    if (raw.contains("F1 API request timed out")) {
      return l10n.errorApiLoad;
    }

    return l10n.errorGenericAction;
  }
}
