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

  AuthController(this._authService, this._firestore) : super(const AsyncData(null));

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
      await _authService.registerWithEmailPassword(email: email, password: password);
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final trimmed = username.trim();
        final usernameLower = trimmed.toLowerCase();
        await _firestore.collection("users").doc(uid).set({
          "email": email.trim(),
          "username": trimmed,
          "usernameLower": usernameLower,
          "displayName": trimmed,
          "profileImageUrl": null,
          "joinedLeagueIds": <String>[],
          "createdAt": FieldValue.serverTimestamp(),
          "updatedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        await _firestore.doc(FirestorePaths.usernameIndex(usernameLower)).set({
          "uid": uid,
          "email": email.trim(),
          "username": trimmed,
          "updatedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_authService.signOut);
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _authService.sendPasswordResetEmail(email: email),
    );
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService, FirebaseFirestore.instance);
});
