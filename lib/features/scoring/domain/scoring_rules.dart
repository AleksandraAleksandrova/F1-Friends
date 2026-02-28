class ScoringRules {
  final int pointsP1Exact;
  final int pointsP2Exact;
  final int pointsP3Exact;
  final int pointsFastestLapExact;
  final int pointsDnfExact;
  final int pointsBonusAllPodiumExact;

  const ScoringRules({
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
