import "dart:io";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:image_picker/image_picker.dart";

import "../../../core/constants/firestore_paths.dart";
import "../domain/app_user.dart";
import "profile_service.dart";

class FirestoreProfileService implements ProfileService {
  FirestoreProfileService(
    this._firestore,
    this._storage,
    this._picker,
  );

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final ImagePicker _picker;

  @override
  Stream<AppUser?> watchUser(String uid) {
    return _firestore.doc(FirestorePaths.user(uid)).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return AppUser.fromMap({"id": doc.id, ...doc.data()!});
    });
  }

  @override
  Future<void> ensureUserDocument({
    required String uid,
    required String email,
  }) async {
    final ref = _firestore.doc(FirestorePaths.user(uid));
    final snapshot = await ref.get();
    if (snapshot.exists) {
      return;
    }

    final username = email.split("@").first;
    await ref.set({
      "email": email,
      "username": username,
      "displayName": username,
      "profileImageUrl": null,
      "joinedLeagueIds": <String>[],
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateUsername({
    required String uid,
    required String username,
  }) async {
    final trimmed = username.trim();
    if (trimmed.length < 3) {
      throw StateError("Username must be at least 3 characters.");
    }
    await _firestore.doc(FirestorePaths.user(uid)).set({
      "username": trimmed,
      "displayName": trimmed,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateProfileImage({
    required String uid,
    required ImageSource source,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1080,
    );
    if (picked == null) {
      return;
    }

    final file = File(picked.path);
    final ref = _storage.ref("profile_images/$uid.jpg");
    await ref.putFile(file);
    final downloadUrl = await ref.getDownloadURL();

    await _firestore.doc(FirestorePaths.user(uid)).set({
      "profileImageUrl": downloadUrl,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
