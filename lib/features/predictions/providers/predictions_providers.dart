import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../auth/providers/auth_providers.dart";
import "../../leagues/providers/leagues_providers.dart";
import "../data/firestore_predictions_service.dart";
import "../data/predictions_service.dart";
import "../domain/prediction.dart";

final predictionsServiceProvider = Provider<PredictionsService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirestorePredictionsService(firestore);
});

final predictionForRaceProvider = FutureProvider.family<Prediction?, String>((ref, raceId) async {
  final userId = ref.watch(authUserIdProvider).value;
  if (userId == null) {
    return null;
  }
  final service = ref.watch(predictionsServiceProvider);
  return service.getPrediction(userId: userId, raceId: raceId);
});

final predictionsForRaceProvider = StreamProvider.family<List<Prediction>, String>((ref, raceId) {
  final uid = ref.watch(authUserIdProvider).value;
  if (uid == null) {
    return Stream.value(const <Prediction>[]);
  }
  final service = ref.watch(predictionsServiceProvider);
  return service.watchPredictionsForRace(raceId: raceId);
});

class PredictionsController extends StateNotifier<AsyncValue<void>> {
  PredictionsController(this._ref, this._service) : super(const AsyncData(null));

  final Ref _ref;
  final PredictionsService _service;

  Future<void> save({
    required String raceId,
    required DateTime lockAtUtc,
    required String p1,
    required String p2,
    required String p3,
    required String fastestLap,
    required int? dnfCount,
  }) async {
    final userId = _ref.read(authUserIdProvider).value;
    if (userId == null) {
      throw StateError("User not authenticated.");
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return _service.savePrediction(
        userId: userId,
        input: SavePredictionInput(
          raceId: raceId,
          lockAtUtc: lockAtUtc,
          p1DriverCode: p1,
          p2DriverCode: p2,
          p3DriverCode: p3,
          fastestLapDriverCode: fastestLap,
          dnfCount: dnfCount,
        ),
      );
    });
  }
}

final predictionsControllerProvider =
    StateNotifierProvider<PredictionsController, AsyncValue<void>>((ref) {
  final service = ref.watch(predictionsServiceProvider);
  return PredictionsController(ref, service);
});
