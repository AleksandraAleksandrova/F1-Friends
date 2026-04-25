// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'F1 Friends';

  @override
  String get authSignIn => 'Accedi';

  @override
  String get authCreateAccount => 'Crea account';

  @override
  String get authNeedAccount => 'Non hai un account? Registrati';

  @override
  String get authHaveAccount => 'Hai già un account? Accedi';

  @override
  String get authEmailOrUsername => 'Email o nome utente';

  @override
  String get authUsername => 'Nome utente';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authForgotPassword => 'Password dimenticata?';

  @override
  String get authRegister => 'Registrati';

  @override
  String get authEnterEmailOrUsername => 'Inserisci email o nome utente';

  @override
  String get authEnterValidEmail => 'Inserisci un\'email valida';

  @override
  String get authUsernameValidation =>
      'Nome utente: almeno 3 caratteri, solo lettere/numeri/_';

  @override
  String get authPasswordMin => 'La password deve contenere almeno 6 caratteri';

  @override
  String get authPasswordRule =>
      'La password deve includere almeno una lettera e un numero';

  @override
  String get authResetPassword => 'Reimposta password';

  @override
  String get authAccountEmail => 'Email dell\'account';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonCreate => 'Crea';

  @override
  String get commonJoin => 'Partecipa';

  @override
  String get commonDelete => 'Elimina';

  @override
  String get commonUpdate => 'Aggiorna';

  @override
  String get commonSave => 'Salva';

  @override
  String get commonEdit => 'Modifica';

  @override
  String get commonLoading => 'Caricamento...';

  @override
  String get commonRefresh => 'Aggiorna';

  @override
  String get commonUnknown => 'sconosciuto';

  @override
  String get commonSearchHint => 'Scrivi per filtrare (es. max)';

  @override
  String get authSendLink => 'Invia link';

  @override
  String get authPasswordResetSent =>
      'Link per reimpostare la password inviato via email.';

  @override
  String get authErrorInvalidCredentials =>
      'Credenziali non valide. Controlla nome utente/email e password.';

  @override
  String get authErrorEmailExists => 'Questa email è già registrata.';

  @override
  String get authErrorTooManyRequests => 'Troppi tentativi. Attendi e riprova.';

  @override
  String get authErrorNetwork =>
      'Errore di rete. Controlla la connessione e riprova.';

  @override
  String get authErrorInvalidEmail => 'Indirizzo email non valido.';

  @override
  String get authErrorUsernameLoginUnavailable =>
      'L\'accesso con nome utente non è disponibile finché le regole Firestore non sono pubblicate.';

  @override
  String get authErrorGeneric => 'Autenticazione non riuscita. Riprova.';

  @override
  String get authErrorUnexpected => 'Errore imprevisto. Riprova.';

  @override
  String get errorUserNotAuthenticated =>
      'Devi accedere di nuovo per continuare.';

  @override
  String get errorUsernameTaken => 'Il nome utente è già in uso.';

  @override
  String get errorUsernameReserveFailed =>
      'Impossibile riservare un nome utente univoco. Prova con un altro.';

  @override
  String get errorLeagueJoinCodeNotFound =>
      'Nessuna lega trovata con questo codice.';

  @override
  String get errorLeagueJoinCodeInvalid =>
      'La mappatura del codice di accesso non è valida.';

  @override
  String get errorLeagueNotFound => 'Lega non trovata.';

  @override
  String get errorLeagueDeleteAdminOnly =>
      'Solo l\'amministratore della lega può eliminarla.';

  @override
  String get errorJoinCodeGeneration =>
      'Impossibile generare un codice di accesso univoco. Riprova.';

  @override
  String get errorPredictionsLocked =>
      'Le previsioni sono bloccate per questa gara.';

  @override
  String get errorPredictionDriversRequired =>
      'Tutti i campi pilota sono obbligatori.';

  @override
  String get errorPredictionPodiumDistinct =>
      'P1, P2 e P3 devono essere piloti diversi.';

  @override
  String get errorPredictionDnfNegative =>
      'Il numero di ritiri non può essere negativo.';

  @override
  String get errorApiLoad =>
      'Impossibile caricare i dati di Formula 1 in questo momento. Riprova.';

  @override
  String get errorGenericAction => 'Qualcosa è andato storto. Riprova.';

  @override
  String get homeNavLeagues => 'Leghe';

  @override
  String get homeNavRaces => 'Gare';

  @override
  String get homeNavProfile => 'Profilo';

  @override
  String get leaguesTitle => 'Le mie leghe';

  @override
  String get leaguesSubtitle => 'Competi con i tuoi amici in leghe private';

  @override
  String get leaguesCreate => 'Crea lega';

  @override
  String get leaguesJoin => 'Partecipa a una lega';

  @override
  String get leaguesEmpty =>
      'Nessuna lega per ora. Creane una o entra con un codice.';

  @override
  String get leaguesAdmin => 'Admin';

  @override
  String get leaguesSeason => 'Stagione';

  @override
  String get leaguesMembers => 'Membri';

  @override
  String leaguesFailedLoad(Object error) {
    return 'Impossibile caricare le leghe: $error';
  }

  @override
  String get leaguesPermissionDenied =>
      'Permesso Firestore negato. Pubblica firestore.rules e riavvia l\'app.';

  @override
  String get leaguesCreateDialogTitle => 'Crea lega';

  @override
  String get leaguesName => 'Nome lega';

  @override
  String get leaguesNameValidation => 'Inserisci almeno 3 caratteri';

  @override
  String get leaguesSeasonYear => 'Anno stagione';

  @override
  String get leaguesInvalidYear => 'Anno non valido';

  @override
  String get leaguesStartRound => 'Round iniziale';

  @override
  String get leaguesEndRound => 'Round finale';

  @override
  String get leaguesStartPositive => 'Il round iniziale deve essere positivo';

  @override
  String get leaguesEndPositive => 'Il round finale deve essere positivo';

  @override
  String leaguesStartMax(Object maxRound) {
    return 'Il round iniziale deve essere <= $maxRound';
  }

  @override
  String leaguesEndMax(Object maxRound) {
    return 'Il round finale deve essere <= $maxRound';
  }

  @override
  String get leaguesEndAfterStart =>
      'Il round finale deve essere >= del round iniziale';

  @override
  String leaguesRoundsRange(Object maxRound) {
    return 'I round devono essere compresi tra 1 e $maxRound.';
  }

  @override
  String get leaguesCreated => 'Lega creata.';

  @override
  String get leaguesJoinDialogTitle => 'Partecipa a una lega';

  @override
  String get leaguesJoinCode => 'Codice di accesso';

  @override
  String get leaguesJoinCodeValidation => 'Inserisci un codice valido';

  @override
  String get leaguesJoined => 'Sei entrato nella lega.';

  @override
  String get leaguesAlreadyJoined =>
      'Sei già in questa lega. I duplicati non sono consentiti.';

  @override
  String get leagueDetailsTitle => 'Dettagli lega';

  @override
  String get leagueDeleteTooltip => 'Elimina lega';

  @override
  String get leagueDeleteTitle => 'Elimina lega';

  @override
  String get leagueDeleteMessage =>
      'Questo rimuoverà definitivamente la lega e l\'elenco membri.';

  @override
  String get leagueDeleted => 'Lega eliminata.';

  @override
  String leagueDeleteFailed(Object error) {
    return 'Impossibile eliminare la lega: $error';
  }

  @override
  String leagueLoadRacesFailed(Object error) {
    return 'Impossibile caricare le gare: $error';
  }

  @override
  String leagueRoundsSeason(
      Object startRound, Object endRound, Object seasonYear) {
    return 'Round $startRound-$endRound, stagione $seasonYear';
  }

  @override
  String leagueMembersCount(Object count) {
    return 'Membri: $count';
  }

  @override
  String get leagueNoRaces =>
      'Nessuna gara trovata nell\'intervallo di questa lega.';

  @override
  String get leagueRaceField => 'Gara';

  @override
  String leaguePredictionsForRound(Object round) {
    return 'Pronostici per R$round';
  }

  @override
  String get leagueEditMine => 'Modifica il mio';

  @override
  String get leaguePredictionUpdated => 'Pronostico aggiornato.';

  @override
  String leagueLoadMembersFailed(Object error) {
    return 'Impossibile caricare i membri: $error';
  }

  @override
  String leagueLoadPredictionsFailed(Object error) {
    return 'Impossibile caricare i pronostici: $error';
  }

  @override
  String leagueYouWithName(Object name) {
    return 'Tu ($name)';
  }

  @override
  String leaguePoints(Object points) {
    return '$points pt';
  }

  @override
  String get leagueNoPrediction => 'Nessun pronostico inviato.';

  @override
  String leaguePredictionSummary(
      Object p1, Object p2, Object p3, Object fl, Object dnf) {
    return 'P1 $p1 | P2 $p2 | P3 $p3 | FL $fl | DNF $dnf';
  }

  @override
  String get leagueMockApplyTitle => 'Applica risultato fittizio';

  @override
  String get leagueFastestLap => 'Giro veloce';

  @override
  String get leagueDnfCount => 'Numero ritiri';

  @override
  String get leagueSelectAllFields => 'Seleziona tutti i campi richiesti.';

  @override
  String get leagueDistinctPodiumDrivers =>
      'P1, P2 e P3 devono essere piloti diversi.';

  @override
  String get leagueDnfNonNegative =>
      'Il numero di ritiri deve essere zero o positivo.';

  @override
  String get leagueMockApplied =>
      'Punteggio fittizio applicato. Classifica aggiornata.';

  @override
  String leagueMockApplyFailed(Object error) {
    return 'Impossibile applicare il risultato fittizio: $error';
  }

  @override
  String get leagueMockReverted => 'Punti fittizi annullati per questa gara.';

  @override
  String leagueMockRevertFailed(Object error) {
    return 'Impossibile annullare i punti fittizi: $error';
  }

  @override
  String get leagueMockApplyButton => 'Applica risultato fittizio';

  @override
  String get leagueMockRevertButton => 'Annulla punti fittizi';

  @override
  String get leagueDemoTools => 'Strumenti demo';

  @override
  String get leagueShowDemoTools => 'Mostra strumenti demo';

  @override
  String get leagueHideDemoTools => 'Nascondi strumenti demo';

  @override
  String get racesTitle => 'Gare';

  @override
  String get racesNextRace => 'Prossima gara';

  @override
  String get racesLastRace => 'Ultima gara';

  @override
  String get racesLatestResults => 'Ultimi risultati';

  @override
  String get racesCurrentSeasonRounds => 'Round della stagione corrente';

  @override
  String get racesNoUpcoming => 'Nessuna prossima gara restituita dall\'API.';

  @override
  String get racesNoLast =>
      'Nessun dettaglio dell\'ultima gara restituito dall\'API.';

  @override
  String get racesNoResults => 'Nessun dato risultato disponibile.';

  @override
  String get racesNoSeasonRaces =>
      'Nessuna gara trovata per la stagione corrente.';

  @override
  String racesFailedLoadApi(Object error) {
    return 'Impossibile caricare i dati gara dall\'API: $error';
  }

  @override
  String get racesLocked => 'Bloccato';

  @override
  String get racesFinished => 'Terminata';

  @override
  String get racesPredict => 'Pronostica';

  @override
  String get racesPredictionSaved => 'Pronostico salvato.';

  @override
  String racesLock(Object date) {
    return 'Blocco: $date';
  }

  @override
  String racesRoundSeason(Object round, Object season) {
    return 'Round $round, stagione $season';
  }

  @override
  String racesRaceStart(Object date) {
    return 'Inizio gara: $date';
  }

  @override
  String racesExpectedEnd(Object date) {
    return 'Fine prevista: $date';
  }

  @override
  String racesQualyStart(Object date) {
    return 'Inizio qualifiche: $date';
  }

  @override
  String racesFastestLap(Object driver) {
    return 'Giro veloce: $driver';
  }

  @override
  String racesDnfs(Object count) {
    return 'Ritiri: $count';
  }

  @override
  String predictionTitle(Object raceName) {
    return 'Pronostico: $raceName';
  }

  @override
  String get predictionP1Driver => 'Pilota P1';

  @override
  String get predictionP2Driver => 'Pilota P2';

  @override
  String get predictionP3Driver => 'Pilota P3';

  @override
  String get predictionFastestLapDriver => 'Pilota giro veloce';

  @override
  String get predictionDnfOptional => 'Numero ritiri (opzionale)';

  @override
  String get predictionSelectAllDrivers =>
      'Seleziona tutti i piloti richiesti.';

  @override
  String get predictionDnfInteger =>
      'Il numero di ritiri deve essere un intero non negativo.';

  @override
  String get predictionPodiumDistinct => 'P1, P2 e P3 devono essere diversi.';

  @override
  String get predictionLockedAfterQualy =>
      'I pronostici sono bloccati per questa gara (qualifiche concluse).';

  @override
  String get predictionPermissionDenied =>
      'Permessi Firestore negati. Pubblica le regole più recenti e riavvia.';

  @override
  String get profileTitle => 'Profilo';

  @override
  String profileFailedLoad(Object error) {
    return 'Impossibile caricare il profilo: $error';
  }

  @override
  String get profileChangePhoto => 'Cambia foto';

  @override
  String get profileChooseFromGallery => 'Scegli dalla galleria';

  @override
  String get profileTakePhoto => 'Scatta foto';

  @override
  String get profileUsername => 'Nome utente';

  @override
  String get profileEditUsername => 'Modifica nome utente';

  @override
  String get profileUsernameHelper => 'Almeno 3 caratteri';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileMyOverview => 'La mia panoramica';

  @override
  String get profileLoadingStats => 'Caricamento statistiche...';

  @override
  String profileStatsUnavailable(Object error) {
    return 'Statistiche non disponibili: $error';
  }

  @override
  String profileJoinedLeagues(Object count) {
    return 'Leghe a cui partecipi: $count';
  }

  @override
  String profileCreatedLeagues(Object count) {
    return 'Leghe create: $count';
  }

  @override
  String profileBestLeaderboardPlace(Object place) {
    return 'Miglior posizione in classifica: $place';
  }

  @override
  String get profileBestLeaderboardPlaceNone =>
      'Miglior posizione in classifica: N/D';

  @override
  String get profileLanguage => 'Lingua';

  @override
  String get profileSignOut => 'Esci';

  @override
  String get projectLoadingFailed =>
      'Impossibile caricare questa sezione in questo momento.';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageFrench => 'Francese';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get notificationsChannelName => 'Promemoria pronostici';

  @override
  String get notificationsChannelDescription =>
      'Promemoria per inviare i pronostici di gara';

  @override
  String get notificationsDefaultTitle => 'F1 Friends';

  @override
  String get notificationsDefaultBody =>
      'È disponibile un nuovo aggiornamento.';

  @override
  String get notificationsStartupBody =>
      'Crea una lega e invita i tuoi amici a pronosticare la prossima gara!';
}
