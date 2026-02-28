class Prediction {
  final String id;
  final String userId;
  final String raceId;
  final String p1DriverCode;
  final String p2DriverCode;
  final String p3DriverCode;
  final String fastestLapDriverCode;
  final int? dnfCount;
  final DateTime submittedAt;

  const Prediction({
    required this.id,
    required this.userId,
    required this.raceId,
    required this.p1DriverCode,
    required this.p2DriverCode,
    required this.p3DriverCode,
    required this.fastestLapDriverCode,
    required this.dnfCount,
    required this.submittedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "userId": userId,
      "raceId": raceId,
      "p1DriverCode": p1DriverCode,
      "p2DriverCode": p2DriverCode,
      "p3DriverCode": p3DriverCode,
      "fastestLapDriverCode": fastestLapDriverCode,
      "dnfCount": dnfCount,
      "submittedAt": submittedAt.toUtc().toIso8601String(),
    };
  }
}
