import "package:cloud_firestore/cloud_firestore.dart";

import "../../../core/constants/firestore_paths.dart";
import "../domain/prediction.dart";
import "predictions_service.dart";

class FirestorePredictionsService implements PredictionsService {
  FirestorePredictionsService(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<Prediction?> getPrediction({
    required String userId,
    required String raceId,
  }) async {
    final doc = await _firestore.doc(FirestorePaths.prediction(raceId, userId)).get();
    if (!doc.exists) {
      return null;
    }
    final data = doc.data()!;
    return Prediction.fromMap({
      "id": doc.id,
      ...data,
    });
  }

  @override
  Stream<List<Prediction>> watchPredictionsForRace({
    required String raceId,
  }) {
    return _firestore
        .collection(FirestorePaths.predictions)
        .where("raceId", isEqualTo: raceId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Prediction.fromMap({
          "id": doc.id,
          ...doc.data(),
        });
      }).toList();
    });
  }

  @override
  Future<void> savePrediction({
    required String userId,
    required SavePredictionInput input,
  }) async {
    final nowUtc = DateTime.now().toUtc();
    if (!nowUtc.isBefore(input.lockAtUtc)) {
      throw StateError("Predictions are locked for this race (qualifying has started).");
    }

    final p1 = input.p1DriverCode.trim().toUpperCase();
    final p2 = input.p2DriverCode.trim().toUpperCase();
    final p3 = input.p3DriverCode.trim().toUpperCase();
    final fl = input.fastestLapDriverCode.trim().toUpperCase();

    if (p1.isEmpty || p2.isEmpty || p3.isEmpty || fl.isEmpty) {
      throw StateError("All driver fields are required.");
    }
    if ({p1, p2, p3}.length != 3) {
      throw StateError("P1, P2, and P3 must be different drivers.");
    }
    if (input.dnfCount != null && input.dnfCount! < 0) {
      throw StateError("DNF count cannot be negative.");
    }

    final ref = _firestore.doc(FirestorePaths.prediction(input.raceId, userId));
    await ref.set({
      "userId": userId,
      "raceId": input.raceId,
      "lockAtUtc": input.lockAtUtc.toIso8601String(),
      "p1DriverCode": p1,
      "p2DriverCode": p2,
      "p3DriverCode": p3,
      "fastestLapDriverCode": fl,
      "dnfCount": input.dnfCount,
      "status": "submitted",
      "submittedAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
