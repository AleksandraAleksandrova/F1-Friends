import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:image_picker/image_picker.dart";

import "../../auth/providers/auth_providers.dart";
import "../providers/profile_providers.dart";

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _usernameController = TextEditingController();
  String? _seededUserId;
  bool _editingUsername = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final appUserAsync = ref.watch(currentAppUserProvider);
    final statsAsync = ref.watch(profileStatsProvider);
    final user = FirebaseAuth.instance.currentUser;

    ref.listen<AsyncValue<void>>(profileControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: appUserAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text("Failed to load profile: $error")),
          data: (appUser) {
            if (appUser != null && _seededUserId != appUser.id) {
              _seededUserId = appUser.id;
              _usernameController.text = appUser.username;
              _usernameController.selection =
                  TextSelection.collapsed(offset: _usernameController.text.length);
            }
            final fallbackName = ((user?.uid ?? "").length >= 6)
                ? (user!.uid.substring(0, 6))
                : (user?.uid ?? "driver");
            final currentName = (appUser?.username.trim().isNotEmpty ?? false)
                ? appUser!.username.trim()
                : fallbackName;

            final topCard = Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundImage: (appUser?.profileImageUrl?.isNotEmpty ?? false)
                              ? NetworkImage(appUser!.profileImageUrl!)
                              : null,
                          child: (appUser?.profileImageUrl?.isNotEmpty ?? false)
                              ? null
                              : const Icon(Icons.person, size: 44),
                        ),
                        PopupMenuButton<ImageSource>(
                          enabled: !profileState.isLoading,
                          tooltip: "Change photo",
                          onSelected: (source) =>
                              ref.read(profileControllerProvider.notifier).updateProfileImage(source),
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: ImageSource.gallery,
                              child: Text("Choose from gallery"),
                            ),
                            PopupMenuItem(
                              value: ImageSource.camera,
                              child: Text("Take photo"),
                            ),
                          ],
                          child: const CircleAvatar(
                            radius: 16,
                            child: Icon(Icons.camera_alt, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (!_editingUsername)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Username",
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: profileState.isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          _editingUsername = true;
                                          _usernameController.text = currentName;
                                          _usernameController.selection = TextSelection.collapsed(
                                            offset: _usernameController.text.length,
                                          );
                                        });
                                      },
                                icon: const Icon(Icons.edit),
                                tooltip: "Edit username",
                              ),
                            ],
                          ),
                          Text(
                            currentName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      )
                    else ...[
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: "Username",
                          helperText: "At least 3 characters",
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: profileState.isLoading
                                  ? null
                                  : () => setState(() => _editingUsername = false),
                              child: const Text("Cancel"),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              onPressed: profileState.isLoading
                                  ? null
                                  : () async {
                                      await ref
                                          .read(profileControllerProvider.notifier)
                                          .updateUsername(_usernameController.text);
                                      if (!mounted) {
                                        return;
                                      }
                                      setState(() => _editingUsername = false);
                                    },
                              child: const Text("Save"),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Email",
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? "unknown",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );

            final statsCard = Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "My Overview",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    statsAsync.when(
                      loading: () => const Text("Loading stats..."),
                      error: (e, _) => Text("Stats unavailable: $e"),
                      data: (stats) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Joined leagues: ${stats.joinedLeaguesCount}"),
                          Text("Created leagues: ${stats.createdLeaguesCount}"),
                          Text(
                            "Best leaderboard place: "
                            "${stats.bestLeaderboardPlace == null ? "N/A" : "#${stats.bestLeaderboardPlace}"}",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );

            return ListView(
              children: [
                topCard,
                const SizedBox(height: 20),
                statsCard,
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: authState.isLoading
                      ? null
                      : () => ref.read(authControllerProvider.notifier).signOut(),
                  child: const Text("Sign Out"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
