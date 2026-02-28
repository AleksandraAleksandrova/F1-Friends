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
    };
  }

  factory League.fromMap(Map<String, dynamic> map) {
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
    );
  }
}
