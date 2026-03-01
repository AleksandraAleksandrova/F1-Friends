import "package:cloud_firestore/cloud_firestore.dart";

class Prediction {
  final String id;
  final String userId;
  final String raceId;
  final String p1DriverCode;
  final String p2DriverCode;
  final String p3DriverCode;
  final String fastestLapDriverCode;
  final int? dnfCount;
  final DateTime? submittedAt;
  final String status;

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
    required this.status,
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
      "submittedAt": submittedAt?.toUtc().toIso8601String(),
      "status": status,
    };
  }

  factory Prediction.fromMap(Map<String, dynamic> map) {
    final submitted = map["submittedAt"];
    DateTime? submittedAt;
    if (submitted is Timestamp) {
      submittedAt = submitted.toDate().toUtc();
    } else if (submitted is String) {
      submittedAt = DateTime.tryParse(submitted)?.toUtc();
    }

    return Prediction(
      id: map["id"] as String,
      userId: map["userId"] as String,
      raceId: map["raceId"] as String,
      p1DriverCode: (map["p1DriverCode"] as String).toUpperCase(),
      p2DriverCode: (map["p2DriverCode"] as String).toUpperCase(),
      p3DriverCode: (map["p3DriverCode"] as String).toUpperCase(),
      fastestLapDriverCode: (map["fastestLapDriverCode"] as String).toUpperCase(),
      dnfCount: (map["dnfCount"] as num?)?.toInt(),
      submittedAt: submittedAt,
      status: (map["status"] as String?) ?? "submitted",
    );
  }
}
