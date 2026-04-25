import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:image_picker/image_picker.dart";
import "../../../l10n/app_localizations.dart";
import "../../../core/utils/app_error_text.dart";

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
  ProviderSubscription<AsyncValue<void>>? _profileSubscription;

  @override
  void initState() {
    super.initState();
    _profileSubscription = ref.listenManual<AsyncValue<void>>(
      profileControllerProvider,
      (previous, next) {
        final l10n = AppLocalizations.of(context);
        if (!mounted || l10n == null) {
          return;
        }
        next.whenOrNull(
          error: (error, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppErrorText.describe(l10n, error))),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _profileSubscription?.close();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final appUserAsync = ref.watch(currentAppUserProvider);
    final statsAsync = ref.watch(profileStatsProvider);
    final currentUid = ref.watch(authUserIdProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: appUserAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              l10n.profileFailedLoad(AppErrorText.describe(l10n, error)),
              textAlign: TextAlign.center,
            ),
          ),
          data: (appUser) {
            if (appUser != null && _seededUserId != appUser.id) {
              _seededUserId = appUser.id;
              _usernameController.text = appUser.username;
              _usernameController.selection =
                  TextSelection.collapsed(offset: _usernameController.text.length);
            }
            final fallbackName = ((currentUid ?? "").length >= 6)
                ? currentUid!.substring(0, 6)
                : (currentUid ?? "driver");
            final currentName = (appUser?.username.trim().isNotEmpty ?? false)
                ? appUser!.username.trim()
                : fallbackName;

            final topCard = Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                              tooltip: l10n.profileChangePhoto,
                              onSelected: (source) =>
                                  ref.read(profileControllerProvider.notifier).updateProfileImage(source),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: ImageSource.gallery,
                                  child: Text(l10n.profileChooseFromGallery),
                                ),
                                PopupMenuItem(
                                  value: ImageSource.camera,
                                  child: Text(l10n.profileTakePhoto),
                                ),
                              ],
                              child: const CircleAvatar(
                                radius: 16,
                                child: Icon(Icons.camera_alt, size: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!_editingUsername)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          l10n.profileUsername,
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
                                          tooltip: l10n.profileEditUsername,
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
                                  decoration: InputDecoration(
                                    labelText: l10n.profileUsername,
                                    helperText: l10n.profileUsernameHelper,
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
                                        child: Text(l10n.commonCancel),
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
                                        child: Text(l10n.commonSave),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 10),
                              Text(
                                l10n.profileEmail,
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                appUser?.email.isNotEmpty == true
                                    ? appUser!.email
                                    : l10n.commonUnknown,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
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
                      l10n.profileMyOverview,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    statsAsync.when(
                      loading: () => Text(l10n.profileLoadingStats),
                      error: (e, _) => Text(
                        l10n.profileStatsUnavailable(AppErrorText.describe(l10n, e)),
                      ),
                      data: (stats) => Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _StatTile(
                            label: l10n.profileJoinedLeagues(stats.joinedLeaguesCount),
                            icon: Icons.groups_2_outlined,
                          ),
                          _StatTile(
                            label: l10n.profileCreatedLeagues(stats.createdLeaguesCount),
                            icon: Icons.add_chart_outlined,
                          ),
                          _StatTile(
                            label: stats.bestLeaderboardPlace == null
                                ? l10n.profileBestLeaderboardPlaceNone
                                : l10n.profileBestLeaderboardPlace("#${stats.bestLeaderboardPlace}"),
                            icon: Icons.emoji_events_outlined,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );

            final settingsCard = Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profileLanguage,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      key: ValueKey(appUser?.preferredLanguageCode ?? "en"),
                      initialValue: switch (appUser?.preferredLanguageCode) {
                        "fr" => "fr",
                        "it" => "it",
                        "bg" => "bg",
                        _ => "en",
                      },
                      decoration: InputDecoration(labelText: l10n.profileLanguage),
                      items: [
                        DropdownMenuItem(value: "en", child: Text(l10n.languageEnglish)),
                        DropdownMenuItem(value: "fr", child: Text(l10n.languageFrench)),
                        DropdownMenuItem(value: "it", child: Text(l10n.languageItalian)),
                        DropdownMenuItem(value: "bg", child: Text(l10n.languageBulgarian)),
                      ],
                      onChanged: profileState.isLoading
                          ? null
                          : (value) {
                              if (value == null) {
                                return;
                              }
                              ref.read(profileControllerProvider.notifier).updatePreferredLanguage(value);
                            },
                    ),
                  ],
                ),
              ),
            );

            return ListView(
              children: [
                topCard,
                const SizedBox(height: 16),
                statsCard,
                const SizedBox(height: 16),
                settingsCard,
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: authState.isLoading
                      ? null
                      : () => ref.read(authControllerProvider.notifier).signOut(),
                  child: Text(l10n.profileSignOut),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
