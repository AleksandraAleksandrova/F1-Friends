import "package:cloud_firestore/cloud_firestore.dart";

import "../../../core/constants/firestore_paths.dart";
import "../../leagues/domain/league.dart";
import "../../predictions/domain/prediction.dart";
import "../domain/mock_race_result.dart";

class MockScoringService {
  MockScoringService(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> applyMockResult({
    required League league,
    required String raceId,
    required MockRaceResult result,
  }) async {
    final membersRef = _firestore.collection("${FirestorePaths.league(league.id)}/members");
    final memberSnap = await membersRef.get();
    final members = memberSnap.docs;
    if (members.isEmpty) {
      return;
    }

    final predictionsSnap = await _firestore
        .collection(FirestorePaths.predictions)
        .where("raceId", isEqualTo: raceId)
        .get();
    final predictionsByUser = <String, Prediction>{
      for (final d in predictionsSnap.docs)
        (d.data()["userId"] as String? ?? ""): Prediction.fromMap({"id": d.id, ...d.data()}),
    };

    final batch = _firestore.batch();
    for (final memberDoc in members) {
      final data = memberDoc.data();
      final userId = (data["userId"] as String?) ?? memberDoc.id;
      if (userId.isEmpty) {
        continue;
      }

      final prediction = predictionsByUser[userId];
      final newRacePoints = _computePoints(
        prediction: prediction,
        result: result,
        rules: league.scoringRules,
      );

      final racePoints = Map<String, dynamic>.from((data["racePoints"] as Map<String, dynamic>?) ?? const {});
      racePoints[raceId] = newRacePoints;
      final totalPoints = racePoints.values
          .map((v) => (v as num?)?.toInt() ?? 0)
          .fold<int>(0, (a, b) => a + b);

      batch.set(memberDoc.reference, {
        "racePoints": racePoints,
        "totalPoints": totalPoints,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<void> revertMockResult({
    required League league,
    required String raceId,
  }) async {
    final membersRef = _firestore.collection("${FirestorePaths.league(league.id)}/members");
    final memberSnap = await membersRef.get();
    final members = memberSnap.docs;
    if (members.isEmpty) {
      return;
    }

    final batch = _firestore.batch();
    for (final memberDoc in members) {
      final data = memberDoc.data();
      final racePoints = Map<String, dynamic>.from((data["racePoints"] as Map<String, dynamic>?) ?? const {});
      if (!racePoints.containsKey(raceId)) {
        continue;
      }
      racePoints.remove(raceId);

      final totalPoints = racePoints.values
          .map((v) => (v as num?)?.toInt() ?? 0)
          .fold<int>(0, (a, b) => a + b);

      batch.set(memberDoc.reference, {
        "racePoints": racePoints,
        "totalPoints": totalPoints,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  int _computePoints({
    required Prediction? prediction,
    required MockRaceResult result,
    required Map<String, int> rules,
  }) {
    if (prediction == null) {
      return 0;
    }

    var points = 0;
    if (prediction.p1DriverCode == result.p1DriverCode) {
      points += rules["pointsP1Exact"] ?? 10;
    }
    if (prediction.p2DriverCode == result.p2DriverCode) {
      points += rules["pointsP2Exact"] ?? 8;
    }
    if (prediction.p3DriverCode == result.p3DriverCode) {
      points += rules["pointsP3Exact"] ?? 6;
    }
    if (prediction.fastestLapDriverCode == result.fastestLapDriverCode) {
      points += rules["pointsFastestLapExact"] ?? 4;
    }
    if ((prediction.dnfCount ?? -1) == result.dnfCount) {
      points += rules["pointsDnfExact"] ?? 3;
    }
    if (prediction.p1DriverCode == result.p1DriverCode &&
        prediction.p2DriverCode == result.p2DriverCode &&
        prediction.p3DriverCode == result.p3DriverCode) {
      points += rules["pointsBonusAllPodiumExact"] ?? 5;
    }

    return points;
  }
}
