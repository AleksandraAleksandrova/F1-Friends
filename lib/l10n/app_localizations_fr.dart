// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'F1 Friends';

  @override
  String get authSignIn => 'Se connecter';

  @override
  String get authCreateAccount => 'Créer un compte';

  @override
  String get authNeedAccount => 'Pas de compte ? Inscrivez-vous';

  @override
  String get authHaveAccount => 'Vous avez un compte ? Connectez-vous';

  @override
  String get authEmailOrUsername => 'E-mail ou nom d\'utilisateur';

  @override
  String get authUsername => 'Nom d\'utilisateur';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authRegister => 'S\'inscrire';

  @override
  String get authEnterEmailOrUsername =>
      'Entrez un e-mail ou un nom d\'utilisateur';

  @override
  String get authEnterValidEmail => 'Entrez un e-mail valide';

  @override
  String get authUsernameValidation =>
      'Nom d\'utilisateur : 3+ caractères, lettres/chiffres/_ uniquement';

  @override
  String get authPasswordMin =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get authPasswordRule =>
      'Le mot de passe doit contenir au moins une lettre et un chiffre';

  @override
  String get authResetPassword => 'Réinitialiser le mot de passe';

  @override
  String get authAccountEmail => 'E-mail du compte';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonCreate => 'Créer';

  @override
  String get commonJoin => 'Rejoindre';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonUpdate => 'Mettre à jour';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonLoading => 'Chargement...';

  @override
  String get commonRefresh => 'Actualiser';

  @override
  String get commonUnknown => 'inconnu';

  @override
  String get commonSearchHint => 'Tapez pour filtrer (ex. max)';

  @override
  String get authSendLink => 'Envoyer le lien';

  @override
  String get authPasswordResetSent =>
      'Le lien de réinitialisation a été envoyé par e-mail.';

  @override
  String get authErrorInvalidCredentials =>
      'Identifiants invalides. Vérifiez votre nom d\'utilisateur/e-mail et votre mot de passe.';

  @override
  String get authErrorEmailExists => 'Cet e-mail est déjà enregistré.';

  @override
  String get authErrorTooManyRequests =>
      'Trop de tentatives. Veuillez patienter puis réessayer.';

  @override
  String get authErrorNetwork =>
      'Erreur réseau. Vérifiez votre connexion et réessayez.';

  @override
  String get authErrorInvalidEmail => 'Adresse e-mail invalide.';

  @override
  String get authErrorUsernameLoginUnavailable =>
      'La connexion par nom d\'utilisateur n\'est pas disponible tant que les règles Firestore ne sont pas publiées.';

  @override
  String get authErrorGeneric =>
      'Échec de l\'authentification. Veuillez réessayer.';

  @override
  String get authErrorUnexpected => 'Erreur inattendue. Veuillez réessayer.';

  @override
  String get errorUserNotAuthenticated =>
      'Vous devez vous reconnecter pour continuer.';

  @override
  String get errorUsernameTaken => 'Ce nom d\'utilisateur est déjà pris.';

  @override
  String get errorUsernameReserveFailed =>
      'Impossible de réserver un nom d\'utilisateur unique. Veuillez en essayer un autre.';

  @override
  String get errorLeagueJoinCodeNotFound =>
      'Aucune ligue n\'a été trouvée avec ce code.';

  @override
  String get errorLeagueJoinCodeInvalid =>
      'Le code de participation est invalide.';

  @override
  String get errorLeagueNotFound => 'La ligue est introuvable.';

  @override
  String get errorLeagueDeleteAdminOnly =>
      'Seul l\'administrateur de la ligue peut la supprimer.';

  @override
  String get errorJoinCodeGeneration =>
      'Impossible de générer un code de participation unique. Veuillez réessayer.';

  @override
  String get errorPredictionsLocked =>
      'Les prédictions sont verrouillées pour cette course.';

  @override
  String get errorPredictionDriversRequired =>
      'Tous les champs pilotes sont obligatoires.';

  @override
  String get errorPredictionPodiumDistinct =>
      'P1, P2 et P3 doivent être des pilotes différents.';

  @override
  String get errorPredictionDnfNegative =>
      'Le nombre de DNF ne peut pas être négatif.';

  @override
  String get errorApiLoad =>
      'Impossible de charger les données Formula 1 pour le moment. Veuillez réessayer.';

  @override
  String get errorGenericAction =>
      'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get homeNavLeagues => 'Ligues';

  @override
  String get homeNavRaces => 'Courses';

  @override
  String get homeNavProfile => 'Profil';

  @override
  String get leaguesTitle => 'Mes ligues';

  @override
  String get leaguesSubtitle => 'Affrontez vos amis dans des ligues privées';

  @override
  String get leaguesActiveSection => 'Ligues actives';

  @override
  String get leaguesPastSection => 'Ligues terminées';

  @override
  String get leaguesCreate => 'Créer une ligue';

  @override
  String get leaguesJoin => 'Rejoindre une ligue';

  @override
  String get leaguesEmpty =>
      'Aucune ligue pour le moment. Créez-en une ou rejoignez-en une avec un code.';

  @override
  String get leaguesAdmin => 'Admin';

  @override
  String get leaguesSeason => 'Saison';

  @override
  String get leaguesMembers => 'Membres';

  @override
  String leaguesFailedLoad(Object error) {
    return 'Échec du chargement des ligues : $error';
  }

  @override
  String get leaguesPermissionDenied =>
      'Permission Firestore refusée. Déployez firestore.rules puis redémarrez l\'application.';

  @override
  String get leaguesCreateDialogTitle => 'Créer une ligue';

  @override
  String get leaguesName => 'Nom de la ligue';

  @override
  String get leaguesNameValidation => 'Entrez au moins 3 caractères';

  @override
  String get leaguesSeasonYear => 'Année de la saison';

  @override
  String get leaguesInvalidYear => 'Année invalide';

  @override
  String get leaguesStartRound => 'Manche de début';

  @override
  String get leaguesEndRound => 'Manche de fin';

  @override
  String get leaguesStartPositive => 'La manche de début doit être positive';

  @override
  String get leaguesEndPositive => 'La manche de fin doit être positive';

  @override
  String leaguesStartMax(Object maxRound) {
    return 'La manche de début doit être <= $maxRound';
  }

  @override
  String leaguesEndMax(Object maxRound) {
    return 'La manche de fin doit être <= $maxRound';
  }

  @override
  String get leaguesEndAfterStart =>
      'La manche de fin doit être >= à la manche de début';

  @override
  String leaguesRoundsRange(Object maxRound) {
    return 'Les manches doivent être dans l\'intervalle 1..$maxRound.';
  }

  @override
  String get leaguesCreated => 'Ligue créée.';

  @override
  String get leaguesJoinDialogTitle => 'Rejoindre une ligue';

  @override
  String get leaguesJoinCode => 'Code de participation';

  @override
  String get leaguesJoinCodeValidation => 'Entrez un code valide';

  @override
  String get leaguesJoined => 'Ligue rejointe.';

  @override
  String get leaguesAlreadyJoined =>
      'Vous avez déjà rejoint cette ligue. Les doublons ne sont pas autorisés.';

  @override
  String get leagueDetailsTitle => 'Détails de la ligue';

  @override
  String get leagueDeleteTooltip => 'Supprimer la ligue';

  @override
  String get leagueDeleteTitle => 'Supprimer la ligue';

  @override
  String get leagueDeleteMessage =>
      'Cela supprimera définitivement la ligue et sa liste de membres.';

  @override
  String get leagueDeleted => 'Ligue supprimée.';

  @override
  String leagueDeleteFailed(Object error) {
    return 'Échec de la suppression de la ligue : $error';
  }

  @override
  String leagueLoadRacesFailed(Object error) {
    return 'Échec du chargement des courses : $error';
  }

  @override
  String leagueRoundsSeason(
      Object startRound, Object endRound, Object seasonYear) {
    return 'Manches $startRound-$endRound, saison $seasonYear';
  }

  @override
  String leagueMembersCount(Object count) {
    return 'Membres : $count';
  }

  @override
  String get leagueNoRaces =>
      'Aucune course trouvée dans cette plage de manches.';

  @override
  String get leagueRaceField => 'Course';

  @override
  String leaguePredictionsForRound(Object round) {
    return 'Prédictions pour M$round';
  }

  @override
  String get leagueEditMine => 'Modifier la mienne';

  @override
  String get leaguePredictionUpdated => 'Prédiction mise à jour.';

  @override
  String leagueLoadMembersFailed(Object error) {
    return 'Échec du chargement des membres : $error';
  }

  @override
  String leagueLoadPredictionsFailed(Object error) {
    return 'Échec du chargement des prédictions : $error';
  }

  @override
  String leagueYouWithName(Object name) {
    return 'Vous ($name)';
  }

  @override
  String leaguePoints(Object points) {
    return '$points pts';
  }

  @override
  String leagueRoundPoints(Object points) {
    return 'Manche : $points pts';
  }

  @override
  String get leagueOfficialPointsShown =>
      'Les points officiels de cette manche proviennent de l\'API Formula 1.';

  @override
  String get leagueNoPrediction => 'Aucune prédiction envoyée pour le moment.';

  @override
  String leaguePredictionSummary(
      Object p1, Object p2, Object p3, Object fl, Object dnf) {
    return 'P1 $p1 | P2 $p2 | P3 $p3 | MT $fl | DNF $dnf';
  }

  @override
  String get leagueMockApplyTitle => 'Appliquer un résultat fictif';

  @override
  String get leagueFastestLap => 'Meilleur tour';

  @override
  String get leagueDnfCount => 'Nombre de DNF';

  @override
  String get leagueSelectAllFields => 'Sélectionnez tous les champs requis.';

  @override
  String get leagueDistinctPodiumDrivers =>
      'P1, P2 et P3 doivent être des pilotes différents.';

  @override
  String get leagueDnfNonNegative =>
      'Le nombre de DNF doit être positif ou nul.';

  @override
  String get leagueMockApplied =>
      'Score fictif appliqué. Classement mis à jour.';

  @override
  String leagueMockApplyFailed(Object error) {
    return 'Échec de l\'application du résultat fictif : $error';
  }

  @override
  String get leagueMockReverted =>
      'Les points fictifs ont été annulés pour cette course.';

  @override
  String leagueMockRevertFailed(Object error) {
    return 'Échec de l\'annulation des points fictifs : $error';
  }

  @override
  String get leagueMockApplyButton => 'Appliquer un résultat fictif';

  @override
  String get leagueMockRevertButton => 'Annuler les points fictifs';

  @override
  String get leagueDemoTools => 'Outils de démo';

  @override
  String get leagueShowDemoTools => 'Afficher les outils de démo';

  @override
  String get leagueHideDemoTools => 'Masquer les outils de démo';

  @override
  String get racesTitle => 'Courses';

  @override
  String get racesNextRace => 'Prochaine course';

  @override
  String get racesLastRace => 'Dernière course';

  @override
  String get racesLatestResults => 'Derniers résultats';

  @override
  String get racesNearestCircuit => 'Circuit le plus proche';

  @override
  String get racesCurrentSeasonRounds => 'Manches de la saison en cours';

  @override
  String get racesNoUpcoming => 'Aucune prochaine course renvoyée par l\'API.';

  @override
  String get racesNoLast =>
      'Aucun détail de la dernière course renvoyé par l\'API.';

  @override
  String get racesNoResults => 'Aucune donnée de résultat disponible.';

  @override
  String get racesNearestCircuitUnavailable =>
      'Localisation indisponible ou coordonnées de circuit introuvables.';

  @override
  String get racesNoSeasonRaces =>
      'Aucune course trouvée pour la saison en cours.';

  @override
  String racesFailedLoadApi(Object error) {
    return 'Échec du chargement des données de course de l\'API : $error';
  }

  @override
  String get racesLocked => 'Verrouillé';

  @override
  String get racesFinished => 'Terminée';

  @override
  String get racesPredict => 'Prédire';

  @override
  String get racesPredictionSaved => 'Prédiction enregistrée.';

  @override
  String racesLock(Object date) {
    return 'Verrouillage : $date';
  }

  @override
  String racesRoundSeason(Object round, Object season) {
    return 'Manche $round, saison $season';
  }

  @override
  String racesRaceStart(Object date) {
    return 'Départ de la course : $date';
  }

  @override
  String racesExpectedEnd(Object date) {
    return 'Fin estimée : $date';
  }

  @override
  String racesQualyStart(Object date) {
    return 'Début des qualifications : $date';
  }

  @override
  String racesFastestLap(Object driver) {
    return 'Meilleur tour : $driver';
  }

  @override
  String racesDnfs(Object count) {
    return 'DNF : $count';
  }

  @override
  String racesNearestCircuitRace(Object race) {
    return 'Circuit prévu le plus proche cette saison : $race';
  }

  @override
  String racesNearestCircuitDistance(Object distanceKm) {
    return 'Distance approximative : $distanceKm km';
  }

  @override
  String predictionTitle(Object raceName) {
    return 'Prédiction : $raceName';
  }

  @override
  String get predictionP1Driver => 'Pilote P1';

  @override
  String get predictionP2Driver => 'Pilote P2';

  @override
  String get predictionP3Driver => 'Pilote P3';

  @override
  String get predictionFastestLapDriver => 'Pilote du meilleur tour';

  @override
  String get predictionDnfOptional => 'Nombre de DNF (optionnel)';

  @override
  String get predictionSelectAllDrivers =>
      'Veuillez sélectionner tous les pilotes requis.';

  @override
  String get predictionDnfInteger =>
      'Le nombre de DNF doit être un entier positif ou nul.';

  @override
  String get predictionPodiumDistinct =>
      'P1, P2 et P3 doivent être différents.';

  @override
  String get predictionLockedAfterQualy =>
      'Les prédictions sont verrouillées pour cette course (les qualifications sont terminées).';

  @override
  String get predictionPermissionDenied =>
      'Permissions Firestore refusées. Veuillez publier les dernières règles et redémarrer.';

  @override
  String get profileTitle => 'Profil';

  @override
  String profileFailedLoad(Object error) {
    return 'Échec du chargement du profil : $error';
  }

  @override
  String get profileChangePhoto => 'Changer la photo';

  @override
  String get profileChooseFromGallery => 'Choisir depuis la galerie';

  @override
  String get profileTakePhoto => 'Prendre une photo';

  @override
  String get profileUsername => 'Nom d\'utilisateur';

  @override
  String get profileEditUsername => 'Modifier le nom d\'utilisateur';

  @override
  String get profileUsernameHelper => 'Au moins 3 caractères';

  @override
  String get profileEmail => 'E-mail';

  @override
  String get profileMyOverview => 'Mon aperçu';

  @override
  String get profileLoadingStats => 'Chargement des statistiques...';

  @override
  String profileStatsUnavailable(Object error) {
    return 'Statistiques indisponibles : $error';
  }

  @override
  String profileJoinedLeagues(Object count) {
    return 'Ligues rejointes : $count';
  }

  @override
  String profileCreatedLeagues(Object count) {
    return 'Ligues créées : $count';
  }

  @override
  String profileBestLeaderboardPlace(Object place) {
    return 'Meilleure place au classement : $place';
  }

  @override
  String get profileBestLeaderboardPlaceNone =>
      'Meilleure place au classement : N/A';

  @override
  String get profileLanguage => 'Langue';

  @override
  String get profileSignOut => 'Se déconnecter';

  @override
  String get projectLoadingFailed =>
      'Impossible de charger cette section pour le moment.';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageItalian => 'Italien';

  @override
  String get languageBulgarian => 'Bulgare';

  @override
  String get notificationsChannelName => 'Rappels de prédiction';

  @override
  String get notificationsChannelDescription =>
      'Rappels pour envoyer les prédictions de course';

  @override
  String get notificationsDefaultTitle => 'F1 Friends';

  @override
  String get notificationsDefaultBody =>
      'Une nouvelle mise à jour est disponible.';

  @override
  String get notificationsStartupBody =>
      'Créez une ligue et invitez des amis à prédire la prochaine course !';
}
