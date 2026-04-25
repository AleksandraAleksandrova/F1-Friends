import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

import "../../../core/constants/firestore_paths.dart";
import "auth_service.dart";

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthService(this._firebaseAuth, this._firestore);

  @override
  Stream<String?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((user) => user?.uid);
  }

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final resolvedEmail = await _resolveEmail(email.trim());
    await _firebaseAuth.signInWithEmailAndPassword(
      email: resolvedEmail,
      password: password,
    );
  }

  @override
  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String identifier,
  }) async {
    final resolvedEmail = await _resolveEmail(identifier.trim());
    await _firebaseAuth.sendPasswordResetEmail(email: resolvedEmail);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String> _resolveEmail(String identifier) async {
    if (identifier.contains("@")) {
      return identifier;
    }
    final normalized = identifier.trim().toLowerCase();

    // Primary deterministic lookup.
    final usernameDoc = await _firestore.doc(FirestorePaths.usernameIndex(normalized)).get();
    if (usernameDoc.exists) {
      final email = usernameDoc.data()?["email"] as String?;
      if (email != null && email.trim().isNotEmpty) {
        return email.trim();
      }
    }

    throw StateError("Invalid credentials. Please check your username/email and password.");
  }
}
