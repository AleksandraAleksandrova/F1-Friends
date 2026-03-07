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
  String? _authError;

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
    setState(() => _authError = null);

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
      switch (error.code) {
        case "invalid-credential":
        case "wrong-password":
        case "user-not-found":
          return "Invalid credentials. Please check your email and password.";
        case "email-already-in-use":
          return "This email is already registered.";
        case "too-many-requests":
          return "Too many attempts. Please wait and try again.";
        case "network-request-failed":
          return "Network error. Check your connection and try again.";
        case "invalid-email":
          return "Invalid email address.";
        default:
          return "Authentication failed. Please try again.";
      }
    }
    return "Unexpected error. Please try again.";
  }

  bool _isValidEmail(String v) {
    final email = v.trim();
    if (email.length < 3) {
      return false;
    }
    const pattern = r"^[^@\s]+@[^@\s]+\.[^@\s]+$";
    return RegExp(pattern).hasMatch(email);
  }

  Future<void> _showResetPasswordDialog() async {
    final emailController = TextEditingController(text: _emailController.text.trim());
    final formKey = GlobalKey<FormState>();

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: "Account email"),
            validator: (value) => _isValidEmail(value ?? "") ? null : "Enter a valid email",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) {
                return;
              }
              try {
                await ref.read(authControllerProvider.notifier).sendPasswordResetEmail(
                      email: emailController.text.trim(),
                    );
                if (!context.mounted) {
                  return;
                }
                Navigator.of(context).pop(true);
              } catch (error) {
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_humanizeError(error))),
                );
              }
            },
            child: const Text("Send Link"),
          ),
        ],
      ),
    );

    if (submitted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset link sent to email.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authUserId = ref.watch(authUserIdProvider);

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => setState(() => _authError = _humanizeError(error)),
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
                            if (_authError != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _authError!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(labelText: "Email"),
                              validator: (value) {
                                final v = value ?? "";
                                if (!_isValidEmail(v)) {
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
                                if (!_isLoginMode &&
                                    (!RegExp(r"[A-Za-z]").hasMatch(v) ||
                                        !RegExp(r"\d").hasMatch(v))) {
                                  return "Password must include at least one letter and one number";
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
                            if (_isLoginMode)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: authState.isLoading ? null : _showResetPasswordDialog,
                                  child: const Text("Forgot password?"),
                                ),
                              ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : () => setState(() {
                                        _isLoginMode = !_isLoginMode;
                                        _authError = null;
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
