import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/constants/firestore_paths.dart";
import "../data/auth_service.dart";
import "../data/firebase_auth_service.dart";

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authServiceProvider = Provider<AuthService>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthService(firebaseAuth, FirebaseFirestore.instance);
});

final authUserIdProvider = StreamProvider<String?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges();
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  AuthController(this._authService, this._firestore, this._firebaseAuth)
      : super(const AsyncData(null));

  Future<void> signIn({required String identifier, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _authService.signInWithEmailPassword(email: identifier, password: password),
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final trimmed = username.trim();
      final usernameLower = trimmed.toLowerCase();
      final usernameIndexRef = _firestore.doc(FirestorePaths.usernameIndex(usernameLower));
      final existingUsername = await usernameIndexRef.get();
      final existingUid = (existingUsername.data()?["uid"] as String?)?.trim();
      if (existingUsername.exists && existingUid?.isNotEmpty == true) {
        throw StateError("Username is already taken.");
      }

      await _authService.registerWithEmailPassword(email: email, password: password);
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid != null) {
        try {
          final batch = _firestore.batch();
          batch.set(_firestore.collection(FirestorePaths.users).doc(uid), {
            "email": email.trim(),
            "username": trimmed,
            "usernameLower": usernameLower,
            "displayName": trimmed,
            "profileImageUrl": null,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          batch.set(usernameIndexRef, {
            "uid": uid,
            "email": email.trim(),
            "username": trimmed,
            "updatedAt": FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          await batch.commit();
        } catch (_) {
          await _firebaseAuth.currentUser?.delete();
          rethrow;
        }
      }
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_authService.signOut);
  }

  Future<void> sendPasswordResetEmail({required String identifier}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _authService.sendPasswordResetEmail(identifier: identifier),
    );
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(
    authService,
    FirebaseFirestore.instance,
    ref.watch(firebaseAuthProvider),
  );
});
