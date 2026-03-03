class League {
  final String id;
  final String name;
  final String joinCode;
  final String adminUserId;
  final int seasonYear;
  final int startRound;
  final int endRound;
  final bool scoringLocked;
  final int memberCount;
  final Map<String, int> scoringRules;

  const League({
    required this.id,
    required this.name,
    required this.joinCode,
    required this.adminUserId,
    required this.seasonYear,
    required this.startRound,
    required this.endRound,
    required this.scoringLocked,
    required this.memberCount,
    required this.scoringRules,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "joinCode": joinCode,
      "adminUserId": adminUserId,
      "seasonYear": seasonYear,
      "startRound": startRound,
      "endRound": endRound,
      "scoringLocked": scoringLocked,
      "memberCount": memberCount,
      "scoringRules": scoringRules,
    };
  }

  factory League.fromMap(Map<String, dynamic> map) {
    final rawRules = (map["scoringRules"] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    return League(
      id: map["id"] as String,
      name: map["name"] as String,
      joinCode: map["joinCode"] as String,
      adminUserId: map["adminUserId"] as String,
      seasonYear: (map["seasonYear"] as num).toInt(),
      startRound: (map["startRound"] as num).toInt(),
      endRound: (map["endRound"] as num).toInt(),
      scoringLocked: map["scoringLocked"] as bool,
      memberCount: ((map["memberCount"] as num?) ?? 0).toInt(),
      scoringRules: {
        "pointsP1Exact": ((rawRules["pointsP1Exact"] as num?) ?? 10).toInt(),
        "pointsP2Exact": ((rawRules["pointsP2Exact"] as num?) ?? 8).toInt(),
        "pointsP3Exact": ((rawRules["pointsP3Exact"] as num?) ?? 6).toInt(),
        "pointsFastestLapExact": ((rawRules["pointsFastestLapExact"] as num?) ?? 4).toInt(),
        "pointsDnfExact": ((rawRules["pointsDnfExact"] as num?) ?? 3).toInt(),
        "pointsBonusAllPodiumExact": ((rawRules["pointsBonusAllPodiumExact"] as num?) ?? 5).toInt(),
      },
    );
  }
}
