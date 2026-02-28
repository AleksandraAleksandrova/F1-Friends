import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../auth/providers/auth_providers.dart";

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email: ${user?.email ?? "unknown"}"),
            const SizedBox(height: 8),
            Text("User ID: ${user?.uid ?? "unknown"}"),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: authState.isLoading
                  ? null
                  : () => ref.read(authControllerProvider.notifier).signOut(),
              child: const Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}
