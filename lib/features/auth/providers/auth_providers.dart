import "package:firebase_auth/firebase_auth.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data/auth_service.dart";
import "../data/firebase_auth_service.dart";

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authServiceProvider = Provider<AuthService>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthService(firebaseAuth);
});

final authUserIdProvider = StreamProvider<String?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges();
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;

  AuthController(this._authService) : super(const AsyncData(null));

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _authService.signInWithEmailPassword(email: email, password: password),
    );
  }

  Future<void> register({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _authService.registerWithEmailPassword(email: email, password: password),
    );
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
  return AuthController(authService);
});
