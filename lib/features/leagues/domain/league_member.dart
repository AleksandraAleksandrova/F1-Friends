class LeagueMember {
  const LeagueMember({
    required this.userId,
    required this.role,
    required this.totalPoints,
  });

  final String userId;
  final String role;
  final int totalPoints;

  factory LeagueMember.fromMap(Map<String, dynamic> map) {
    return LeagueMember(
      userId: (map["userId"] as String?) ?? "",
      role: (map["role"] as String?) ?? "member",
      totalPoints: ((map["totalPoints"] as num?) ?? 0).toInt(),
    );
  }
}
