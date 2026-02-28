class FirestorePaths {
  static const users = "users";
  static const leagues = "leagues";
  static const races = "races";
  static const predictions = "predictions";
  static const raceResults = "raceResults";
  static const leagueScores = "leagueScores";
  static const notifications = "notifications";
  static const jobs = "jobs";

  static String user(String uid) => "$users/$uid";
  static String league(String leagueId) => "$leagues/$leagueId";
  static String race(String raceId) => "$races/$raceId";
  static String leagueMember(String leagueId, String uid) => "$leagues/$leagueId/members/$uid";
}
