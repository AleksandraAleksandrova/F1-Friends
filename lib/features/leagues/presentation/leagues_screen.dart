import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:cloud_firestore/cloud_firestore.dart";

import "league_details_screen.dart";
import "../providers/leagues_providers.dart";
import "../../races/providers/races_providers.dart";

class LeaguesScreen extends ConsumerWidget {
  const LeaguesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaguesAsync = ref.watch(userLeaguesProvider);
    final actionState = ref.watch(leaguesControllerProvider);

    ref.listen<AsyncValue<void>>(leaguesControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_friendlyError(error))),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text("My Leagues")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Compete with private friend leagues",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: actionState.isLoading
                            ? null
                            : () => _showCreateLeagueDialog(context, ref),
                        icon: const Icon(Icons.add),
                        label: const Text("Create League"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: actionState.isLoading
                            ? null
                            : () => _showJoinLeagueDialog(context, ref),
                        icon: const Icon(Icons.group_add),
                        label: const Text("Join League"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: leaguesAsync.when(
                data: (leagues) {
                  if (leagues.isEmpty) {
                    return const Center(
                      child: Text("No leagues yet. Create one or join with a code."),
                    );
                  }
                  return ListView.separated(
                    itemCount: leagues.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final league = leagues[index];
                      final adminNameAsync = ref.watch(usernameByUserIdProvider(league.adminUserId));
                      final adminDisplay = adminNameAsync.maybeWhen(
                        data: (name) => name,
                        orElse: () => (league.adminUserId.length > 6
                            ? league.adminUserId.substring(0, 6)
                            : league.adminUserId),
                      );
                      return Card(
                        child: ListTile(
                          title: Text(league.name),
                          subtitle: Text(
                            "Admin $adminDisplay | Season ${league.seasonYear} | "
                            "R${league.startRound}-R${league.endRound} | Members ${league.memberCount}",
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(league.joinCode),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LeagueDetailsScreen(league: league),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text("Failed to load leagues: ${_friendlyError(error)}")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _friendlyError(Object error) {
    if (error is FirebaseException && error.code == "permission-denied") {
      return "Firestore permission denied. Deploy firestore.rules, then restart the app.";
    }
    if (error is StateError) {
      return error.message;
    }
    return error.toString();
  }

  Future<void> _showCreateLeagueDialog(BuildContext context, WidgetRef ref) async {
    final currentSeasonYear = DateTime.now().year;
    var maxRound = 24;
    var nextRound = 1;
    try {
      final seasonRaces = await ref.read(racesBySeasonProvider(currentSeasonYear).future);
      if (seasonRaces.isNotEmpty) {
        final sorted = [...seasonRaces]..sort((a, b) => a.round.compareTo(b.round));
        maxRound = sorted.last.round;
        final now = DateTime.now().toUtc();
        final next = sorted.where((r) => r.startTimeUtc.isAfter(now)).toList();
        nextRound = next.isNotEmpty ? next.first.round : sorted.last.round;
      }
    } catch (_) {
      // Keep safe defaults when race API fetch fails.
    }
    if (!context.mounted) {
      return;
    }

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final seasonController = TextEditingController(text: currentSeasonYear.toString());
    final startRoundController = TextEditingController(text: "$nextRound");
    final endRoundController = TextEditingController(text: "$maxRound");

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create League"),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "League name"),
                    validator: (value) => (value == null || value.trim().length < 3)
                        ? "Enter at least 3 characters"
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: seasonController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Season year"),
                    validator: (value) => int.tryParse(value ?? "") == null ? "Invalid year" : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: startRoundController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Start round"),
                    validator: (value) {
                      final start = int.tryParse(value ?? "");
                      if (start == null || start < 1) {
                        return "Start round must be positive";
                      }
                      if (start > maxRound) {
                        return "Start round must be <= $maxRound";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: endRoundController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "End round"),
                    validator: (value) {
                      final end = int.tryParse(value ?? "");
                      final start = int.tryParse(startRoundController.text);
                      if (end == null || end < 1) {
                        return "End round must be positive";
                      }
                      if (end > maxRound) {
                        return "End round must be <= $maxRound";
                      }
                      if (start != null && end < start) {
                        return "End round must be >= start round";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                final startRound = int.parse(startRoundController.text);
                final endRound = int.parse(endRoundController.text);
                if (startRound < 1 || endRound < 1 || startRound > maxRound || endRound > maxRound) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Rounds must be in range 1..$maxRound.")),
                  );
                  return;
                }
                if (endRound < startRound) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("End round must be >= start round.")),
                  );
                  return;
                }

                try {
                  await ref.read(leaguesControllerProvider.notifier).createLeague(
                        name: nameController.text.trim(),
                        seasonYear: int.parse(seasonController.text),
                        startRound: startRound,
                        endRound: endRound,
                      );
                  if (context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_friendlyError(error))),
                    );
                  }
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );

    if (context.mounted && submitted == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("League created.")),
      );
    }

    // Keep controllers undisposed here because dialog lifecycle/rebuild timing
    // caused use-after-dispose assertions in error paths.
  }

  Future<void> _showJoinLeagueDialog(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController();

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Join League"),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: "Join code"),
              validator: (value) => (value == null || value.trim().length < 4)
                  ? "Enter a valid join code"
                  : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                try {
                  final result = await ref.read(leaguesControllerProvider.notifier).joinLeagueByCode(
                        joinCode: codeController.text.trim(),
                      );
                  if (context.mounted) {
                    Navigator.of(context).pop(result.joined);
                  }
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_friendlyError(error))),
                    );
                  }
                }
              },
              child: const Text("Join"),
            ),
          ],
        );
      },
    );

    if (context.mounted && submitted == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Joined league.")),
      );
    }
    if (context.mounted && submitted == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Already joined. Duplicate join is not allowed.")),
      );
    }

    // Keep controller undisposed here for the same dialog timing reason.
  }
}
