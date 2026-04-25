import "../../predictions/domain/prediction.dart";
import "../../races/domain/race_result.dart";

class ScoringLogic {
  static int computePoints({
    required Prediction? prediction,
    required RaceResult result,
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
