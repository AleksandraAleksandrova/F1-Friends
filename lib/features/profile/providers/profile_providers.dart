import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:image_picker/image_picker.dart";

import "../../auth/providers/auth_providers.dart";
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
