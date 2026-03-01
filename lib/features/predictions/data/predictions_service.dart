import "../domain/prediction.dart";

class SavePredictionInput {
  final String raceId;
  final DateTime lockAtUtc;
  final String p1DriverCode;
  final String p2DriverCode;
  final String p3DriverCode;
  final String fastestLapDriverCode;
  final int? dnfCount;

  const SavePredictionInput({
    required this.raceId,
    required this.lockAtUtc,
    required this.p1DriverCode,
    required this.p2DriverCode,
    required this.p3DriverCode,
    required this.fastestLapDriverCode,
    required this.dnfCount,
  });
}

abstract class PredictionsService {
  Future<Prediction?> getPrediction({
    required String userId,
    required String raceId,
  });

  Stream<List<Prediction>> watchPredictionsForRace({
    required String raceId,
  });

  Future<void> savePrediction({
    required String userId,
    required SavePredictionInput input,
  });
}
