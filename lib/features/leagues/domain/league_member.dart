class LeagueMember {
  const LeagueMember({
    required this.userId,
    required this.role,
    required this.totalPoints,
    required this.racePoints,
  });

  final String userId;
  final String role;
  final int totalPoints;
  final Map<String, int> racePoints;

  factory LeagueMember.fromMap(Map<String, dynamic> map) {
    final rawRacePoints = (map["racePoints"] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    return LeagueMember(
      userId: (map["userId"] as String?) ?? "",
      role: (map["role"] as String?) ?? "member",
      totalPoints: ((map["totalPoints"] as num?) ?? 0).toInt(),
      racePoints: {
        for (final entry in rawRacePoints.entries) entry.key: (entry.value as num?)?.toInt() ?? 0,
      },
    );
  }
}
