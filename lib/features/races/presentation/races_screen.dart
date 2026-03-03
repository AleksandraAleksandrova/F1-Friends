import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../predictions/presentation/prediction_dialog.dart";
import "../../predictions/providers/predictions_providers.dart";
import "../data/f1_api_service.dart";
import "../domain/race_weekend.dart";
import "../providers/races_providers.dart";

class RacesScreen extends ConsumerWidget {
  const RacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final raceHubAsync = ref.watch(raceHubProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Races"),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(raceHubProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: raceHubAsync.when(
        data: (hub) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionCard(
                title: "Next Race",
                child: hub.nextRace == null
                    ? const Text("No upcoming race returned by API.")
                    : _RaceTile(race: hub.nextRace!),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: "Last Race",
                child: hub.lastRace == null
                    ? const Text("No last race details returned by API.")
                    : _RaceTile(race: hub.lastRace!),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: "Latest Results",
                child: hub.latestResults == null
                    ? const Text("No result data available.")
                    : _LatestResultsView(summary: hub.latestResults!),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: "Current Season Rounds",
                child: hub.seasonRaces.isEmpty
                    ? const Text("No races found for current season.")
                    : Column(
                        children: hub.seasonRaces
                            .map((race) => _RacePredictionRow(race: race))
                            .toList(),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text("Failed to load API race data: $error"),
          ),
        ),
      ),
    );
  }

  static String formatUtc(DateTime dt) {
    return "${dt.toIso8601String().replaceFirst(".000", "")} UTC";
  }
}

class _RacePredictionRow extends ConsumerWidget {
  const _RacePredictionRow({required this.race});

  final RaceWeekend race;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockAt = PredictionDialog.lockAtUtc(race);
    final isLocked = !DateTime.now().toUtc().isBefore(lockAt);
    final lockSource = race.qualifyingStartUtc != null
        ? "qualy end (estimated)"
        : "race start";
    final existingPredictionAsync = ref.watch(predictionForRaceProvider(race.id));

    final buttonLabel = isLocked
        ? "Locked"
        : existingPredictionAsync.maybeWhen(
            data: (p) => p == null ? "Predict" : "Update",
            orElse: () => "Predict",
          );

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 14,
        child: Text("${race.round}"),
      ),
      title: Text(race.raceName),
      subtitle: Text(
        "${RacesScreen.formatUtc(race.startTimeUtc)}\n"
        "Lock: ${RacesScreen.formatUtc(lockAt)} ($lockSource)",
      ),
      isThreeLine: true,
      trailing: OutlinedButton(
        onPressed: isLocked
            ? null
            : () async {
                final saved = await PredictionDialog.show(
                  context: context,
                  ref: ref,
                  race: race,
                );
                if (saved) {
                  ref.invalidate(predictionForRaceProvider(race.id));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Prediction saved.")),
                    );
                  }
                }
              },
        child: Text(buttonLabel),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.speed, size: 18),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _RaceTile extends StatelessWidget {
  const _RaceTile({required this.race});

  final RaceWeekend race;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(race.raceName, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text("Round ${race.round}, Season ${race.seasonYear}"),
        const SizedBox(height: 4),
        Text("Race start: ${RacesScreen.formatUtc(race.startTimeUtc)}"),
        Text("Expected end: ${RacesScreen.formatUtc(race.expectedEndTimeUtc)}"),
        if (race.qualifyingStartUtc != null)
          Text("Qualy start: ${RacesScreen.formatUtc(race.qualifyingStartUtc!)}"),
      ],
    );
  }
}

class _LatestResultsView extends StatelessWidget {
  const _LatestResultsView({required this.summary});

  final LatestRaceSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(summary.raceName, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text("Round ${summary.round} (${summary.seasonYear})"),
        const SizedBox(height: 8),
        ...summary.podium.map((entry) {
          return Text("${entry.position}. ${entry.shortName}  ${entry.fullName}");
        }),
        const SizedBox(height: 8),
        Text("Fastest lap driverId: ${summary.fastestLapDriverId ?? "n/a"}"),
        Text("DNFs: ${summary.dnfCount ?? 0}"),
      ],
    );
  }
}
