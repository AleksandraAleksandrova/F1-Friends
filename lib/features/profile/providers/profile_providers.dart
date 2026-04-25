import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:image_picker/image_picker.dart";
import "package:flutter/material.dart";

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
  final firestore = ref.watch(profileFirestoreProvider);
  final places = await Future.wait(
    leagues.map((league) async {
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
        return null;
      }
      return place + 1;
    }),
  );
  final validPlaces = places.whereType<int>().toList();
  final bestPlace = validPlaces.isEmpty
      ? null
      : validPlaces.reduce((best, current) => current < best ? current : best);

  return ProfileStats(
    joinedLeaguesCount: leagues.length,
    createdLeaguesCount: created,
    bestLeaderboardPlace: bestPlace,
  );
});

class ProfileController extends StateNotifier<AsyncValue<void>> {
  ProfileController(this._ref, this._service) : super(const AsyncData(null));

  final Ref _ref;
  final ProfileService _service;

  User? get _currentUser => _ref.read(firebaseAuthProvider).currentUser;

  Future<void> ensureCurrentUserDoc() async {
    final user = _currentUser;
    if (user?.uid == null || user?.email == null) {
      return;
    }
    await _service.ensureUserDocument(uid: user!.uid, email: user.email!);
  }

  Future<void> updateUsername(String username) async {
    final uid = _currentUser?.uid;
    if (uid == null) {
      throw StateError("User not authenticated.");
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.updateUsername(uid: uid, username: username));
  }

  Future<void> updateProfileImage(ImageSource source) async {
    final uid = _currentUser?.uid;
    if (uid == null) {
      throw StateError("User not authenticated.");
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.updateProfileImage(uid: uid, source: source));
  }

  Future<void> updatePreferredLanguage(String languageCode) async {
    final uid = _currentUser?.uid;
    if (uid == null) {
      throw StateError("User not authenticated.");
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _service.updatePreferredLanguage(uid: uid, languageCode: languageCode),
    );
  }
}

final profileControllerProvider = StateNotifierProvider<ProfileController, AsyncValue<void>>((ref) {
  return ProfileController(ref, ref.watch(profileServiceProvider));
});

final appLocaleProvider = Provider<Locale?>((ref) {
  final user = ref.watch(currentAppUserProvider).value;
  final code = user?.preferredLanguageCode?.trim().toLowerCase();
  if (code == "en" || code == "fr" || code == "it" || code == "bg") {
    return Locale(code!);
  }
  return null;
});
