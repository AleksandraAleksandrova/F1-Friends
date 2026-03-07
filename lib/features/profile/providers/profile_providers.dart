import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:image_picker/image_picker.dart";

import "../../auth/providers/auth_providers.dart";
import "../../../core/constants/firestore_paths.dart";
import "../../leagues/providers/leagues_providers.dart";
import "../data/firestore_profile_service.dart";
import "../data/profile_service.dart";
import "../domain/app_user.dart";

final profileFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final profileStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final imagePickerProvider = Provider<ImagePicker>((ref) {
  return ImagePicker();
});

final profileServiceProvider = Provider<ProfileService>((ref) {
  return FirestoreProfileService(
    ref.watch(profileFirestoreProvider),
    ref.watch(profileStorageProvider),
    ref.watch(imagePickerProvider),
  );
});

final currentAppUserProvider = StreamProvider<AppUser?>((ref) {
  final uid = ref.watch(authUserIdProvider).value;
  if (uid == null) {
    return Stream.value(null);
  }
  return ref.watch(profileServiceProvider).watchUser(uid);
});

class ProfileStats {
  const ProfileStats({
    required this.joinedLeaguesCount,
    required this.createdLeaguesCount,
    required this.bestLeaderboardPlace,
  });

  final int joinedLeaguesCount;
  final int createdLeaguesCount;
  final int? bestLeaderboardPlace;
}

final profileStatsProvider = FutureProvider<ProfileStats>((ref) async {
  final uid = ref.watch(authUserIdProvider).value;
  if (uid == null) {
    return const ProfileStats(
      joinedLeaguesCount: 0,
      createdLeaguesCount: 0,
      bestLeaderboardPlace: null,
    );
  }

  final leagues = await ref.watch(userLeaguesProvider.future);
  final created = leagues.where((l) => l.adminUserId == uid).length;

  int? bestPlace;
  final firestore = ref.watch(profileFirestoreProvider);
  for (final league in leagues) {
    final membersSnap = await firestore
        .collection(FirestorePaths.leagues)
        .doc(league.id)
        .collection("members")
        .get();
    final members = membersSnap.docs
        .map((d) => d.data())
        .where((m) => (m["userId"] as String?)?.isNotEmpty ?? false)
        .toList();
    members.sort((a, b) {
      final aPoints = ((a["totalPoints"] as num?) ?? 0).toInt();
      final bPoints = ((b["totalPoints"] as num?) ?? 0).toInt();
      final byPoints = bPoints.compareTo(aPoints);
      if (byPoints != 0) {
        return byPoints;
      }
      final aUid = (a["userId"] as String?) ?? "";
      final bUid = (b["userId"] as String?) ?? "";
      return aUid.compareTo(bUid);
    });

    final place = members.indexWhere((m) => m["userId"] == uid);
    if (place == -1) {
      continue;
    }
    final rank = place + 1;
    if (bestPlace == null || rank < bestPlace) {
      bestPlace = rank;
    }
  }

  return ProfileStats(
    joinedLeaguesCount: leagues.length,
    createdLeaguesCount: created,
    bestLeaderboardPlace: bestPlace,
  );
});

class ProfileController extends StateNotifier<AsyncValue<void>> {
  ProfileController(this._service) : super(const AsyncData(null));

  final ProfileService _service;

  Future<void> ensureCurrentUserDoc() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.uid == null || user?.email == null) {
      return;
    }
    await _service.ensureUserDocument(uid: user!.uid, email: user.email!);
  }

  Future<void> updateUsername(String username) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError("User not authenticated.");
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.updateUsername(uid: uid, username: username));
  }

  Future<void> updateProfileImage(ImageSource source) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError("User not authenticated.");
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.updateProfileImage(uid: uid, source: source));
  }
}

final profileControllerProvider = StateNotifierProvider<ProfileController, AsyncValue<void>>((ref) {
  return ProfileController(ref.watch(profileServiceProvider));
});
