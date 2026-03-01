import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/constants/firestore_paths.dart";
import "../../auth/providers/auth_providers.dart";
import "../data/firestore_leagues_service.dart";
import "../data/leagues_service.dart";
import "../domain/league.dart";

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final leaguesServiceProvider = Provider<LeaguesService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirestoreLeaguesService(firestore);
});

final userLeaguesProvider = StreamProvider<List<League>>((ref) {
  final userId = ref.watch(authUserIdProvider).value;
  if (userId == null) {
    return Stream.value(const <League>[]);
  }
  final leaguesService = ref.watch(leaguesServiceProvider);
  return leaguesService.watchUserLeagues(userId);
});

class LeaguesController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  final LeaguesService _leaguesService;

  LeaguesController(this._ref, this._leaguesService) : super(const AsyncData(null));

  Future<String> createLeague({
    required String name,
    required int seasonYear,
    required int startRound,
    required int endRound,
  }) async {
    final userId = _ref.read(authUserIdProvider).value;
    if (userId == null) {
      throw StateError("User is not authenticated.");
    }

    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      return _leaguesService.createLeague(
        userId: userId,
        input: CreateLeagueInput(
          name: name,
          seasonYear: seasonYear,
          startRound: startRound,
          endRound: endRound,
          scoringRules: FirestoreLeaguesService.defaultScoringRules,
        ),
      );
    });
    state = result.when(
      data: (_) => const AsyncData(null),
      error: (error, stackTrace) => AsyncError(error, stackTrace),
      loading: () => const AsyncLoading(),
    );
    return result.requireValue;
  }

  Future<JoinLeagueResult> joinLeagueByCode({required String joinCode}) async {
    final userId = _ref.read(authUserIdProvider).value;
    if (userId == null) {
      throw StateError("User is not authenticated.");
    }

    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      return _leaguesService.joinLeagueByCode(
        userId: userId,
        joinCode: joinCode,
      );
    });
    state = result.when(
      data: (_) => const AsyncData(null),
      error: (error, stackTrace) => AsyncError(error, stackTrace),
      loading: () => const AsyncLoading(),
    );
    return result.requireValue;
  }
}

final leaguesControllerProvider = StateNotifierProvider<LeaguesController, AsyncValue<void>>((ref) {
  final leaguesService = ref.watch(leaguesServiceProvider);
  return LeaguesController(ref, leaguesService);
});

final leagueByIdProvider = StreamProvider.family<League?, String>((ref, leagueId) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return firestore.doc(FirestorePaths.league(leagueId)).snapshots().map((snap) {
    if (!snap.exists) {
      return null;
    }
    return League.fromMap({"id": snap.id, ...snap.data()!});
  });
});

final leagueMemberIdsProvider = StreamProvider.family<List<String>, String>((ref, leagueId) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return firestore
      .collection(FirestorePaths.leagues)
      .doc(leagueId)
      .collection("members")
      .snapshots()
      .map((snap) {
    return snap.docs
        .map((d) => (d.data()["userId"] as String?) ?? "")
        .where((id) => id.isNotEmpty)
        .toList();
  });
});
