import "../domain/league.dart";

class ScoringRulesInput {
  final int pointsP1Exact;
  final int pointsP2Exact;
  final int pointsP3Exact;
  final int pointsFastestLapExact;
  final int pointsDnfExact;
  final int pointsBonusAllPodiumExact;

  const ScoringRulesInput({
    required this.pointsP1Exact,
    required this.pointsP2Exact,
    required this.pointsP3Exact,
    required this.pointsFastestLapExact,
    required this.pointsDnfExact,
    required this.pointsBonusAllPodiumExact,
  });

  Map<String, dynamic> toMap() {
    return {
      "pointsP1Exact": pointsP1Exact,
      "pointsP2Exact": pointsP2Exact,
      "pointsP3Exact": pointsP3Exact,
      "pointsFastestLapExact": pointsFastestLapExact,
      "pointsDnfExact": pointsDnfExact,
      "pointsBonusAllPodiumExact": pointsBonusAllPodiumExact,
    };
  }
}

class CreateLeagueInput {
  final String name;
  final int seasonYear;
  final int startRound;
  final int endRound;
  final ScoringRulesInput scoringRules;

  const CreateLeagueInput({
    required this.name,
    required this.seasonYear,
    required this.startRound,
    required this.endRound,
    required this.scoringRules,
  });
}

class JoinLeagueResult {
  final String leagueId;
  final bool joined;

  const JoinLeagueResult({
    required this.leagueId,
    required this.joined,
  });
}

abstract class LeaguesService {
  Stream<List<League>> watchUserLeagues(String userId);

  Future<String> createLeague({
    required String userId,
    required CreateLeagueInput input,
  });

  Future<JoinLeagueResult> joinLeagueByCode({
    required String userId,
    required String joinCode,
  });

  Future<void> deleteLeague({
    required String userId,
    required String leagueId,
  });
}
