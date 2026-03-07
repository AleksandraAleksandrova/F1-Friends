class FirestorePaths {
  static const users = "users";
  static const usernames = "usernames";
  static const leagues = "leagues";
  static const leagueJoinCodes = "leagueJoinCodes";
  static const races = "races";
  static const predictions = "predictions";
  static const raceResults = "raceResults";
  static const leagueScores = "leagueScores";
  static const notifications = "notifications";
  static const jobs = "jobs";

  static String user(String uid) => "$users/$uid";
  static String usernameIndex(String usernameLower) => "$usernames/$usernameLower";
  static String league(String leagueId) => "$leagues/$leagueId";
  static String leagueJoinCode(String joinCode) => "$leagueJoinCodes/$joinCode";
  static String race(String raceId) => "$races/$raceId";
  static String leagueMember(String leagueId, String uid) => "$leagues/$leagueId/members/$uid";
  static String prediction(String raceId, String uid) => "$predictions/${raceId}_$uid";
}
