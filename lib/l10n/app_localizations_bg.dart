// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bulgarian (`bg`).
class AppLocalizationsBg extends AppLocalizations {
  AppLocalizationsBg([String locale = 'bg']) : super(locale);

  @override
  String get appTitle => 'F1 Friends';

  @override
  String get authSignIn => 'Вход';

  @override
  String get authCreateAccount => 'Създаване на акаунт';

  @override
  String get authNeedAccount => 'Нямате акаунт? Регистрирайте се';

  @override
  String get authHaveAccount => 'Имате акаунт? Влезте';

  @override
  String get authEmailOrUsername => 'Имейл или потребителско име';

  @override
  String get authUsername => 'Потребителско име';

  @override
  String get authEmail => 'Имейл';

  @override
  String get authPassword => 'Парола';

  @override
  String get authForgotPassword => 'Забравена парола?';

  @override
  String get authRegister => 'Регистрация';

  @override
  String get authEnterEmailOrUsername => 'Въведете имейл или потребителско име';

  @override
  String get authEnterValidEmail => 'Въведете валиден имейл';

  @override
  String get authUsernameValidation =>
      'Потребителско име: поне 3 символа, само букви/цифри/_';

  @override
  String get authPasswordMin => 'Паролата трябва да е поне 6 символа';

  @override
  String get authPasswordRule =>
      'Паролата трябва да съдържа поне една буква и една цифра';

  @override
  String get authResetPassword => 'Нулиране на парола';

  @override
  String get authAccountEmail => 'Имейл на акаунта';

  @override
  String get commonCancel => 'Отказ';

  @override
  String get commonCreate => 'Създай';

  @override
  String get commonJoin => 'Присъедини се';

  @override
  String get commonDelete => 'Изтрий';

  @override
  String get commonUpdate => 'Обнови';

  @override
  String get commonSave => 'Запази';

  @override
  String get commonEdit => 'Редактирай';

  @override
  String get commonLoading => 'Зареждане...';

  @override
  String get commonRefresh => 'Опресни';

  @override
  String get commonUnknown => 'неизвестно';

  @override
  String get commonSearchHint => 'Пишете за филтриране (напр. max)';

  @override
  String get authSendLink => 'Изпрати линк';

  @override
  String get authPasswordResetSent =>
      'Изпратен е линк за нулиране на паролата.';

  @override
  String get authErrorInvalidCredentials =>
      'Невалидни данни. Проверете потребителското име/имейла и паролата.';

  @override
  String get authErrorEmailExists => 'Този имейл вече е регистриран.';

  @override
  String get authErrorTooManyRequests =>
      'Твърде много опити. Изчакайте и опитайте отново.';

  @override
  String get authErrorNetwork =>
      'Мрежова грешка. Проверете връзката и опитайте отново.';

  @override
  String get authErrorInvalidEmail => 'Невалиден имейл адрес.';

  @override
  String get authErrorUsernameLoginUnavailable =>
      'Входът с потребителско име не е наличен, докато не публикувате Firestore правилата.';

  @override
  String get authErrorGeneric => 'Неуспешна автентикация. Опитайте отново.';

  @override
  String get authErrorUnexpected => 'Неочаквана грешка. Опитайте отново.';

  @override
  String get errorUserNotAuthenticated =>
      'Трябва да влезете отново, за да продължите.';

  @override
  String get errorUsernameTaken => 'Потребителското име вече е заето.';

  @override
  String get errorUsernameReserveFailed =>
      'Не можа да се запази уникално потребителско име. Опитайте друго.';

  @override
  String get errorLeagueJoinCodeNotFound => 'Не е намерена лига с този код.';

  @override
  String get errorLeagueJoinCodeInvalid =>
      'Кодът за присъединяване е невалиден.';

  @override
  String get errorLeagueNotFound => 'Лигата не беше намерена.';

  @override
  String get errorLeagueDeleteAdminOnly =>
      'Само администраторът на лигата може да я изтрие.';

  @override
  String get errorJoinCodeGeneration =>
      'Неуспешно генериране на уникален код. Опитайте отново.';

  @override
  String get errorPredictionsLocked =>
      'Прогнозите са заключени за това състезание.';

  @override
  String get errorPredictionDriversRequired =>
      'Всички полета за пилоти са задължителни.';

  @override
  String get errorPredictionPodiumDistinct =>
      'P1, P2 и P3 трябва да са различни пилоти.';

  @override
  String get errorPredictionDnfNegative =>
      'Броят на отпадналите не може да е отрицателен.';

  @override
  String get errorApiLoad =>
      'В момента данните за Формула 1 не могат да бъдат заредени. Опитайте отново.';

  @override
  String get errorGenericAction => 'Нещо се обърка. Опитайте отново.';

  @override
  String get homeNavLeagues => 'Лиги';

  @override
  String get homeNavRaces => 'Състезания';

  @override
  String get homeNavProfile => 'Профил';

  @override
  String get leaguesTitle => 'Моите лиги';

  @override
  String get leaguesSubtitle => 'Състезавайте се в частни приятелски лиги';

  @override
  String get leaguesCreate => 'Създай лига';

  @override
  String get leaguesJoin => 'Присъедини се към лига';

  @override
  String get leaguesEmpty =>
      'Все още няма лиги. Създайте лига или се присъединете с код.';

  @override
  String get leaguesAdmin => 'Админ';

  @override
  String get leaguesSeason => 'Сезон';

  @override
  String get leaguesMembers => 'Участници';

  @override
  String leaguesFailedLoad(Object error) {
    return 'Неуспешно зареждане на лигите: $error';
  }

  @override
  String get leaguesPermissionDenied =>
      'Достъпът до Firestore е отказан. Публикувайте firestore.rules и рестартирайте приложението.';

  @override
  String get leaguesCreateDialogTitle => 'Създай лига';

  @override
  String get leaguesName => 'Име на лигата';

  @override
  String get leaguesNameValidation => 'Въведете поне 3 символа';

  @override
  String get leaguesSeasonYear => 'Година на сезона';

  @override
  String get leaguesInvalidYear => 'Невалидна година';

  @override
  String get leaguesStartRound => 'Начален кръг';

  @override
  String get leaguesEndRound => 'Краен кръг';

  @override
  String get leaguesStartPositive => 'Началният кръг трябва да е положителен';

  @override
  String get leaguesEndPositive => 'Крайният кръг трябва да е положителен';

  @override
  String leaguesStartMax(Object maxRound) {
    return 'Началният кръг трябва да е <= $maxRound';
  }

  @override
  String leaguesEndMax(Object maxRound) {
    return 'Крайният кръг трябва да е <= $maxRound';
  }

  @override
  String get leaguesEndAfterStart => 'Крайният кръг трябва да е >= началния';

  @override
  String leaguesRoundsRange(Object maxRound) {
    return 'Кръговете трябва да са в диапазона 1..$maxRound.';
  }

  @override
  String get leaguesCreated => 'Лигата е създадена.';

  @override
  String get leaguesJoinDialogTitle => 'Присъединяване към лига';

  @override
  String get leaguesJoinCode => 'Код за присъединяване';

  @override
  String get leaguesJoinCodeValidation => 'Въведете валиден код';

  @override
  String get leaguesJoined => 'Успешно се присъединихте към лигата.';

  @override
  String get leaguesAlreadyJoined =>
      'Вече сте в тази лига. Повторно присъединяване не е позволено.';

  @override
  String get leagueDetailsTitle => 'Детайли за лига';

  @override
  String get leagueDeleteTooltip => 'Изтрий лигата';

  @override
  String get leagueDeleteTitle => 'Изтриване на лига';

  @override
  String get leagueDeleteMessage =>
      'Това ще премахне завинаги лигата и списъка с участници.';

  @override
  String get leagueDeleted => 'Лигата е изтрита.';

  @override
  String leagueDeleteFailed(Object error) {
    return 'Неуспешно изтриване на лигата: $error';
  }

  @override
  String leagueLoadRacesFailed(Object error) {
    return 'Неуспешно зареждане на състезанията: $error';
  }

  @override
  String leagueRoundsSeason(
      Object startRound, Object endRound, Object seasonYear) {
    return 'Кръгове $startRound-$endRound, сезон $seasonYear';
  }

  @override
  String leagueMembersCount(Object count) {
    return 'Участници: $count';
  }

  @override
  String get leagueNoRaces =>
      'Няма състезания в избрания диапазон на тази лига.';

  @override
  String get leagueRaceField => 'Състезание';

  @override
  String leaguePredictionsForRound(Object round) {
    return 'Прогнози за R$round';
  }

  @override
  String get leagueEditMine => 'Редактирай моята';

  @override
  String get leaguePredictionUpdated => 'Прогнозата е обновена.';

  @override
  String leagueLoadMembersFailed(Object error) {
    return 'Неуспешно зареждане на участниците: $error';
  }

  @override
  String leagueLoadPredictionsFailed(Object error) {
    return 'Неуспешно зареждане на прогнозите: $error';
  }

  @override
  String leagueYouWithName(Object name) {
    return 'Вие ($name)';
  }

  @override
  String leaguePoints(Object points) {
    return '$points т.';
  }

  @override
  String leagueRoundPoints(Object points) {
    return 'Кръг: $points т.';
  }

  @override
  String get leagueOfficialPointsShown =>
      'Показани са официалните точки за кръга от API на Формула 1.';

  @override
  String get leagueNoPrediction => 'Все още няма подадена прогноза.';

  @override
  String leaguePredictionSummary(
      Object p1, Object p2, Object p3, Object fl, Object dnf) {
    return 'P1 $p1 | P2 $p2 | P3 $p3 | FL $fl | DNF $dnf';
  }

  @override
  String get leagueMockApplyTitle => 'Прилагане на тестов резултат';

  @override
  String get leagueFastestLap => 'Най-бърза обиколка';

  @override
  String get leagueDnfCount => 'Брой отпаднали';

  @override
  String get leagueSelectAllFields => 'Изберете всички задължителни полета.';

  @override
  String get leagueDistinctPodiumDrivers =>
      'P1, P2 и P3 трябва да са различни пилоти.';

  @override
  String get leagueDnfNonNegative =>
      'Броят на отпадналите трябва да е неотрицателен.';

  @override
  String get leagueMockApplied =>
      'Тестовото точкуване е приложено. Класирането е обновено.';

  @override
  String leagueMockApplyFailed(Object error) {
    return 'Неуспешно прилагане на тестов резултат: $error';
  }

  @override
  String get leagueMockReverted =>
      'Тестовите точки за това състезание са премахнати.';

  @override
  String leagueMockRevertFailed(Object error) {
    return 'Неуспешно премахване на тестовите точки: $error';
  }

  @override
  String get leagueMockApplyButton => 'Приложи тестов резултат';

  @override
  String get leagueMockRevertButton => 'Премахни тестовите точки';

  @override
  String get leagueDemoTools => 'Демо инструменти';

  @override
  String get leagueShowDemoTools => 'Покажи демо инструментите';

  @override
  String get leagueHideDemoTools => 'Скрий демо инструментите';

  @override
  String get racesTitle => 'Състезания';

  @override
  String get racesNextRace => 'Следващо състезание';

  @override
  String get racesLastRace => 'Последно състезание';

  @override
  String get racesLatestResults => 'Последни резултати';

  @override
  String get racesNearestCircuit => 'Най-близка писта';

  @override
  String get racesCurrentSeasonRounds => 'Кръгове от текущия сезон';

  @override
  String get racesNoUpcoming =>
      'API не върна информация за предстоящо състезание.';

  @override
  String get racesNoLast => 'API не върна детайли за последното състезание.';

  @override
  String get racesNoResults => 'Няма налични резултати.';

  @override
  String get racesNearestCircuitUnavailable =>
      'Локацията не е налична или няма координати за пистата.';

  @override
  String get racesNoSeasonRaces => 'Няма намерени състезания за текущия сезон.';

  @override
  String racesFailedLoadApi(Object error) {
    return 'Неуспешно зареждане на данни за състезанията от API: $error';
  }

  @override
  String get racesLocked => 'Заключено';

  @override
  String get racesFinished => 'Приключило';

  @override
  String get racesPredict => 'Прогнозирай';

  @override
  String get racesPredictionSaved => 'Прогнозата е запазена.';

  @override
  String racesLock(Object date) {
    return 'Заключване: $date';
  }

  @override
  String racesRoundSeason(Object round, Object season) {
    return 'Кръг $round, сезон $season';
  }

  @override
  String racesRaceStart(Object date) {
    return 'Старт на състезанието: $date';
  }

  @override
  String racesExpectedEnd(Object date) {
    return 'Очакван край: $date';
  }

  @override
  String racesQualyStart(Object date) {
    return 'Старт на квалификацията: $date';
  }

  @override
  String racesFastestLap(Object driver) {
    return 'Най-бърза обиколка: $driver';
  }

  @override
  String racesDnfs(Object count) {
    return 'Отпаднали: $count';
  }

  @override
  String racesNearestCircuitRace(Object race) {
    return 'Най-близката писта в календара този сезон: $race';
  }

  @override
  String racesNearestCircuitDistance(Object distanceKm) {
    return 'Приблизително разстояние: $distanceKm км';
  }

  @override
  String predictionTitle(Object raceName) {
    return 'Прогноза: $raceName';
  }

  @override
  String get predictionP1Driver => 'Пилот за P1';

  @override
  String get predictionP2Driver => 'Пилот за P2';

  @override
  String get predictionP3Driver => 'Пилот за P3';

  @override
  String get predictionFastestLapDriver => 'Пилот за най-бърза обиколка';

  @override
  String get predictionDnfOptional => 'Брой отпаднали (по избор)';

  @override
  String get predictionSelectAllDrivers =>
      'Моля, изберете всички задължителни пилоти.';

  @override
  String get predictionDnfInteger =>
      'Броят на отпадналите трябва да е неотрицателно цяло число.';

  @override
  String get predictionPodiumDistinct => 'P1, P2 и P3 трябва да са различни.';

  @override
  String get predictionLockedAfterQualy =>
      'Прогнозите са заключени за това състезание (квалификацията е приключила).';

  @override
  String get predictionPermissionDenied =>
      'Достъпът до Firestore е отказан. Публикувайте последните правила и рестартирайте приложението.';

  @override
  String get profileTitle => 'Профил';

  @override
  String profileFailedLoad(Object error) {
    return 'Неуспешно зареждане на профила: $error';
  }

  @override
  String get profileChangePhoto => 'Промени снимката';

  @override
  String get profileChooseFromGallery => 'Избери от галерия';

  @override
  String get profileTakePhoto => 'Направи снимка';

  @override
  String get profileUsername => 'Потребителско име';

  @override
  String get profileEditUsername => 'Редактирай потребителско име';

  @override
  String get profileUsernameHelper => 'Поне 3 символа';

  @override
  String get profileEmail => 'Имейл';

  @override
  String get profileMyOverview => 'Моят преглед';

  @override
  String get profileLoadingStats => 'Зареждане на статистика...';

  @override
  String profileStatsUnavailable(Object error) {
    return 'Статистиката не е налична: $error';
  }

  @override
  String profileJoinedLeagues(Object count) {
    return 'Участия в лиги: $count';
  }

  @override
  String profileCreatedLeagues(Object count) {
    return 'Създадени лиги: $count';
  }

  @override
  String profileBestLeaderboardPlace(Object place) {
    return 'Най-добро място в класиране: $place';
  }

  @override
  String get profileBestLeaderboardPlaceNone =>
      'Най-добро място в класиране: Няма';

  @override
  String get profileLanguage => 'Език';

  @override
  String get profileSignOut => 'Изход';

  @override
  String get projectLoadingFailed =>
      'Тази секция не може да бъде заредена в момента.';

  @override
  String get languageEnglish => 'Английски';

  @override
  String get languageFrench => 'Френски';

  @override
  String get languageItalian => 'Италиански';

  @override
  String get languageBulgarian => 'Български';

  @override
  String get notificationsChannelName => 'Напомняния за прогнози';

  @override
  String get notificationsChannelDescription =>
      'Напомняния за подаване на прогнози за състезания';

  @override
  String get notificationsDefaultTitle => 'F1 Friends';

  @override
  String get notificationsDefaultBody => 'Налична е нова актуализация.';

  @override
  String get notificationsStartupBody =>
      'Създайте лига и поканете приятели да прогнозират следващото състезание!';
}
