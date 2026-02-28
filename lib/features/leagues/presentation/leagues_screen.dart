import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:cloud_firestore/cloud_firestore.dart";

import "../providers/leagues_providers.dart";

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
          children: [
            Row(
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
                    label: const Text("Join Code"),
                  ),
                ),
              ],
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
                      return Card(
                        child: ListTile(
                          title: Text(league.name),
                          subtitle: Text(
                            "Season ${league.seasonYear} | R${league.startRound}-R${league.endRound} | Members ${league.memberCount}",
                          ),
                          trailing: Text(league.joinCode),
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
    return error.toString();
  }

  Future<void> _showCreateLeagueDialog(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final seasonController = TextEditingController(text: DateTime.now().year.toString());
    final startRoundController = TextEditingController(text: "1");
    final endRoundController = TextEditingController(text: "5");

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
                  TextFormField(
                    controller: seasonController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Season year"),
                    validator: (value) => int.tryParse(value ?? "") == null ? "Invalid year" : null,
                  ),
                  TextFormField(
                    controller: startRoundController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Start round"),
                    validator: (value) => int.tryParse(value ?? "") == null ? "Invalid round" : null,
                  ),
                  TextFormField(
                    controller: endRoundController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "End round"),
                    validator: (value) => int.tryParse(value ?? "") == null ? "Invalid round" : null,
                  ),
                ],
              ),
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
                final startRound = int.parse(startRoundController.text);
                final endRound = int.parse(endRoundController.text);
                if (startRound > endRound) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Start round must be <= end round.")),
                  );
                  return;
                }

                await ref.read(leaguesControllerProvider.notifier).createLeague(
                      name: nameController.text.trim(),
                      seasonYear: int.parse(seasonController.text),
                      startRound: startRound,
                      endRound: endRound,
                    );
                if (context.mounted) {
                  Navigator.of(context).pop(true);
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

    nameController.dispose();
    seasonController.dispose();
    startRoundController.dispose();
    endRoundController.dispose();
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
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                final result = await ref.read(leaguesControllerProvider.notifier).joinLeagueByCode(
                      joinCode: codeController.text.trim(),
                    );
                if (context.mounted) {
                  Navigator.of(context).pop(result.joined);
                }
              },
              child: const Text("Join"),
            ),
          ],
        );
      },
    );

    if (context.mounted && submitted != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(submitted ? "Joined league." : "You are already a member.")),
      );
    }

    codeController.dispose();
  }
}
