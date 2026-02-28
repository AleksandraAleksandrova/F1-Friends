abstract class AuthService {
  Stream<String?> authStateChanges();

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
