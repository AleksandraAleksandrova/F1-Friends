import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../home/presentation/home_screen.dart";
import "../providers/auth_providers.dart";

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginMode = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final controller = ref.read(authControllerProvider.notifier);

    if (_isLoginMode) {
      await controller.signIn(email: email, password: password);
    } else {
      await controller.register(email: email, password: password);
    }
  }

  String _humanizeError(Object error) {
    if (error is FirebaseAuthException) {
      return error.message ?? "Authentication failed.";
    }
    return "Unexpected error. Please try again.";
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authUserId = ref.watch(authUserIdProvider);

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_humanizeError(error))),
          );
        },
      );
    });

    return Scaffold(
      body: authUserId.when(
        data: (uid) {
          if (uid != null) {
            return KeyedSubtree(
              key: ValueKey(uid),
              child: const HomeScreen(),
            );
          }

          return DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF2F2), Color(0xFFF7F7FA)],
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "F1 Friends",
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _isLoginMode ? "Sign In" : "Create Account",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(labelText: "Email"),
                              validator: (value) {
                                final v = value?.trim() ?? "";
                                if (v.isEmpty || !v.contains("@")) {
                                  return "Enter a valid email";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(labelText: "Password"),
                              validator: (value) {
                                final v = value ?? "";
                                if (v.length < 6) {
                                  return "Password must be at least 6 characters";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: authState.isLoading ? null : _submit,
                                child: Text(_isLoginMode ? "Sign In" : "Register"),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : () => setState(() {
                                        _isLoginMode = !_isLoginMode;
                                      }),
                              child: Text(
                                _isLoginMode
                                    ? "Need an account? Register"
                                    : "Have an account? Sign In",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text("Auth state error: $error")),
      ),
    );
  }
}
