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

  String _normalizeUsername(String input) {
    final cleaned = input
        .trim()
        .replaceAll(RegExp(r"[^A-Za-z0-9_]"), "_")
        .replaceAll(RegExp(r"_+"), "_")
        .replaceAll(RegExp(r"^_+|_+$"), "");
    return cleaned;
  }

  List<String> _usernameCandidates({
    required String preferred,
    required String uid,
  }) {
    final normalized = _normalizeUsername(preferred);
    final base = normalized.isEmpty ? "driver" : normalized;
    final suffix4 = uid.length >= 4 ? uid.substring(0, 4).toLowerCase() : uid.toLowerCase();
    final suffix6 = uid.length >= 6 ? uid.substring(0, 6).toLowerCase() : uid.toLowerCase();

    final candidates = <String>{
      base.length >= 3 ? base : "${base}_$suffix4",
      "${base}_$suffix4",
      "${base}_$suffix6",
    };
    return candidates.where((value) => value.trim().length >= 3).toList();
  }

  Future<String> _pickAvailableUsername({
    required String uid,
    required String preferred,
  }) async {
    for (final candidate in _usernameCandidates(preferred: preferred, uid: uid)) {
      final doc = await _firestore.doc(FirestorePaths.usernameIndex(candidate.toLowerCase())).get();
      if (!doc.exists) {
        return candidate;
      }
      final ownerUid = (doc.data()?["uid"] as String?)?.trim();
      if (ownerUid == uid) {
        return candidate;
      }
    }
    throw StateError("Could not reserve a unique username. Please try another one.");
  }

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
      final data = snapshot.data()!;
      final existingEmail = (data["email"] as String?)?.trim();
      final existingUsername = (data["username"] as String?)?.trim();
      final safeEmail = (existingEmail?.isNotEmpty ?? false) ? existingEmail! : email;
      final preferredUsername = (existingUsername?.isNotEmpty ?? false)
          ? existingUsername!
          : safeEmail.split("@").first;
      final safeUsername = await _pickAvailableUsername(
        uid: uid,
        preferred: preferredUsername,
      );
      final lower = safeUsername.toLowerCase();
      final oldLower = (data["usernameLower"] as String?)?.trim().toLowerCase();

      final batch = _firestore.batch();
      batch.set(ref, {
        "email": safeEmail,
        "username": safeUsername,
        "usernameLower": lower,
        "displayName": safeUsername,
        "preferredLanguageCode": (data["preferredLanguageCode"] as String?) ?? "en",
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      batch.set(_firestore.doc(FirestorePaths.usernameIndex(lower)), {
        "uid": uid,
        "email": safeEmail,
        "username": safeUsername,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (oldLower != null && oldLower.isNotEmpty && oldLower != lower) {
        batch.delete(_firestore.doc(FirestorePaths.usernameIndex(oldLower)));
      }
      await batch.commit();
      return;
    }

    final username = await _pickAvailableUsername(
      uid: uid,
      preferred: email.split("@").first,
    );
    final lower = username.toLowerCase();
    final batch = _firestore.batch();
    batch.set(ref, {
      "email": email,
      "username": username,
      "usernameLower": lower,
      "displayName": username,
      "profileImageUrl": null,
      "preferredLanguageCode": "en",
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    batch.set(_firestore.doc(FirestorePaths.usernameIndex(lower)), {
      "uid": uid,
      "email": email,
      "username": username,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();
  }

  @override
  Future<void> updateUsername({
    required String uid,
    required String username,
  }) async {
    final trimmed = _normalizeUsername(username);
    if (trimmed.length < 3) {
      throw StateError("Username must be at least 3 characters.");
    }
    final userRef = _firestore.doc(FirestorePaths.user(uid));
    final newLower = trimmed.toLowerCase();
    final newIndexRef = _firestore.doc(FirestorePaths.usernameIndex(newLower));

    await _firestore.runTransaction((tx) async {
      final userSnap = await tx.get(userRef);
      final data = userSnap.data();
      final oldLower = (data?["usernameLower"] as String?)?.trim().toLowerCase();
      final email = (data?["email"] as String?)?.trim();
      final newIndexSnap = await tx.get(newIndexRef);
      final ownerUid = (newIndexSnap.data()?["uid"] as String?)?.trim();

      if (newIndexSnap.exists && ownerUid != uid) {
        throw StateError("Username is already taken.");
      }

      tx.set(userRef, {
        "username": trimmed,
        "usernameLower": newLower,
        "displayName": trimmed,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      tx.set(newIndexRef, {
        "uid": uid,
        "email": email,
        "username": trimmed,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (oldLower != null && oldLower.isNotEmpty && oldLower != newLower) {
        tx.delete(_firestore.doc(FirestorePaths.usernameIndex(oldLower)));
      }
    });
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

  @override
  Future<void> updatePreferredLanguage({
    required String uid,
    required String languageCode,
  }) async {
    await _firestore.doc(FirestorePaths.user(uid)).set({
      "preferredLanguageCode": languageCode,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
