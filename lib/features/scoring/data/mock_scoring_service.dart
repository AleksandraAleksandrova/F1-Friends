import "package:cloud_firestore/cloud_firestore.dart";

import "../../../core/constants/firestore_paths.dart";
import "../../leagues/domain/league.dart";
import "../../predictions/domain/prediction.dart";
import "../../races/domain/race_result.dart";
import "../domain/scoring_logic.dart";
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
      final newRacePoints = ScoringLogic.computePoints(
        prediction: prediction,
        result: RaceResult(
          raceId: raceId,
          p1DriverCode: result.p1DriverCode,
          p2DriverCode: result.p2DriverCode,
          p3DriverCode: result.p3DriverCode,
          fastestLapDriverCode: result.fastestLapDriverCode,
          dnfCount: result.dnfCount,
        ),
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
}
