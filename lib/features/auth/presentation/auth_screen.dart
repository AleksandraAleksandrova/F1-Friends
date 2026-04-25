import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../../l10n/app_localizations.dart";

import "../../home/presentation/home_screen.dart";
import "../providers/auth_providers.dart";

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginMode = true;
  String? _authError;

  @override
  void dispose() {
    _identifierController.dispose();
    _registerEmailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _authError = null);

    final identifier = _isLoginMode
        ? _identifierController.text.trim()
        : _registerEmailController.text.trim();
    final password = _passwordController.text;
    final controller = ref.read(authControllerProvider.notifier);

    if (_isLoginMode) {
      await controller.signIn(identifier: identifier, password: password);
    } else {
      await controller.register(
        email: identifier,
        password: password,
        username: _usernameController.text.trim(),
      );
    }
  }

  String _humanizeError(AppLocalizations l10n, Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case "invalid-credential":
        case "wrong-password":
        case "user-not-found":
          return l10n.authErrorInvalidCredentials;
        case "email-already-in-use":
          return l10n.authErrorEmailExists;
        case "too-many-requests":
          return l10n.authErrorTooManyRequests;
        case "network-request-failed":
          return l10n.authErrorNetwork;
        case "invalid-email":
          return l10n.authErrorInvalidEmail;
        default:
          return l10n.authErrorGeneric;
      }
    }
    if (error is FirebaseException) {
      if (error.code == "permission-denied") {
        return l10n.authErrorUsernameLoginUnavailable;
      }
      return l10n.authErrorGeneric;
    }
    if (error is StateError) {
      return error.message;
    }
    return l10n.authErrorUnexpected;
  }

  bool _isValidEmail(String v) {
    final email = v.trim();
    if (email.length < 3) {
      return false;
    }
    const pattern = r"^[^@\s]+@[^@\s]+\.[^@\s]+$";
    return RegExp(pattern).hasMatch(email);
  }

  bool _isValidUsername(String v) {
    final username = v.trim();
    if (username.length < 3) {
      return false;
    }
    return RegExp(r"^[A-Za-z0-9_]+$").hasMatch(username);
  }

  Future<void> _showResetPasswordDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final emailController = TextEditingController(
      text: _isLoginMode ? _identifierController.text.trim() : _registerEmailController.text.trim(),
    );
    final formKey = GlobalKey<FormState>();

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.authResetPassword),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: l10n.authEmailOrUsername),
            validator: (value) {
              final v = value?.trim() ?? "";
              if (v.length < 3) {
                return l10n.authEnterEmailOrUsername;
              }
              if (!v.contains("@") && !_isValidUsername(v)) {
                return l10n.authEnterEmailOrUsername;
              }
              if (v.contains("@") && !_isValidEmail(v)) {
                return l10n.authEnterValidEmail;
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) {
                return;
              }
              try {
                await ref.read(authControllerProvider.notifier).sendPasswordResetEmail(
                      identifier: emailController.text.trim(),
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
                  SnackBar(content: Text(_humanizeError(l10n, error))),
                );
              }
            },
            child: Text(l10n.authSendLink),
          ),
        ],
      ),
    );

    if (submitted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authPasswordResetSent)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);
    final authUserId = ref.watch(authUserIdProvider);

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => setState(() => _authError = _humanizeError(l10n, error)),
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
                              l10n.appTitle,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _isLoginMode ? l10n.authSignIn : l10n.authCreateAccount,
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
                            if (_isLoginMode)
                              TextFormField(
                                controller: _identifierController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(labelText: l10n.authEmailOrUsername),
                                validator: (value) {
                                  final v = value?.trim() ?? "";
                                  if (v.length < 3) {
                                    return l10n.authEnterEmailOrUsername;
                                  }
                                  return null;
                                },
                              )
                            else ...[
                              TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(labelText: l10n.authUsername),
                                validator: (value) {
                                  if (!_isValidUsername(value ?? "")) {
                                    return l10n.authUsernameValidation;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _registerEmailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(labelText: l10n.authEmail),
                                validator: (value) {
                                  final v = value ?? "";
                                  if (!_isValidEmail(v)) {
                                    return l10n.authEnterValidEmail;
                                  }
                                  return null;
                                },
                              ),
                            ],
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(labelText: l10n.authPassword),
                              validator: (value) {
                                final v = value ?? "";
                                if (v.length < 6) {
                                  return l10n.authPasswordMin;
                                }
                                if (!_isLoginMode &&
                                    (!RegExp(r"[A-Za-z]").hasMatch(v) ||
                                        !RegExp(r"\d").hasMatch(v))) {
                                  return l10n.authPasswordRule;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: authState.isLoading ? null : _submit,
                                child: Text(_isLoginMode ? l10n.authSignIn : l10n.authRegister),
                              ),
                            ),
                            if (_isLoginMode)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: authState.isLoading ? null : _showResetPasswordDialog,
                                  child: Text(l10n.authForgotPassword),
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
                                    ? l10n.authNeedAccount
                                    : l10n.authHaveAccount,
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
        error: (error, _) => Center(child: Text(_humanizeError(l10n, error))),
      ),
    );
  }
}
