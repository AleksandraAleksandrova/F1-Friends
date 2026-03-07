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
    required String email,
  }) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
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
      final uid = usernameDoc.data()?["uid"] as String?;
      if (uid != null && uid.isNotEmpty) {
        final userDoc = await _firestore.doc(FirestorePaths.user(uid)).get();
        final userEmail = userDoc.data()?["email"] as String?;
        if (userEmail != null && userEmail.trim().isNotEmpty) {
          return userEmail.trim();
        }
      }
    }

    final byLower = await _firestore
        .collection(FirestorePaths.users)
        .where("usernameLower", isEqualTo: normalized)
        .limit(1)
        .get();
    if (byLower.docs.isNotEmpty) {
      final email = byLower.docs.first.data()["email"] as String?;
      if (email != null && email.isNotEmpty) {
        return email;
      }
    }

    final byExact = await _firestore
        .collection(FirestorePaths.users)
        .where("username", isEqualTo: identifier.trim())
        .limit(1)
        .get();
    if (byExact.docs.isNotEmpty) {
      final email = byExact.docs.first.data()["email"] as String?;
      if (email != null && email.isNotEmpty) {
        return email;
      }
    }

    // Fallback for legacy user documents without usernameLower.
    final allUsers = await _firestore
        .collection(FirestorePaths.users)
        .limit(500)
        .get();
    for (final doc in allUsers.docs) {
      final data = doc.data();
      final username = (data["username"] as String?)?.trim().toLowerCase();
      final email = (data["email"] as String?)?.trim();
      if (username == normalized && email != null && email.isNotEmpty) {
        return email;
      }
    }

    throw StateError("Invalid credentials. Please check your username/email and password.");
  }
}
