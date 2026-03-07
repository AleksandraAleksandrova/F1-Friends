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
    const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    final local = dt.toLocal();
    final weekday = weekdays[local.weekday - 1];
    final month = months[local.month - 1];
    final hh = local.hour.toString().padLeft(2, "0");
    final mm = local.minute.toString().padLeft(2, "0");
    return "$weekday, ${local.day} $month at $hh:$mm";
  }

  static String formatUtcAround(DateTime dt) {
    final rounded = _roundUpToFive(dt.toLocal());
    const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    final weekday = weekdays[rounded.weekday - 1];
    final month = months[rounded.month - 1];
    final hh = rounded.hour.toString().padLeft(2, "0");
    final mm = rounded.minute.toString().padLeft(2, "0");
    return "$weekday, ${rounded.day} $month around $hh:$mm";
  }

  static DateTime _roundUpToFive(DateTime dt) {
    final minute = dt.minute;
    final remainder = minute % 5;
    final roundedMinute = remainder == 0 ? minute : minute + (5 - remainder);
    final carryHour = roundedMinute >= 60 ? 1 : 0;
    final safeMinute = roundedMinute % 60;
    return DateTime(
      dt.year,
      dt.month,
      dt.day,
      dt.hour + carryHour,
      safeMinute,
    );
  }
}

class _RacePredictionRow extends ConsumerWidget {
  const _RacePredictionRow({required this.race});

  final RaceWeekend race;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockAt = PredictionDialog.lockAtUtc(race);
    final isLocked = !DateTime.now().toUtc().isBefore(lockAt);
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
        "Lock: ${RacesScreen.formatUtc(lockAt)}",
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
        Text("Expected end: ${RacesScreen.formatUtcAround(race.expectedEndTimeUtc)}"),
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
        Text("Fastest lap: ${_driverLabel(summary.fastestLapDriverId)}"),
        Text("DNFs: ${summary.dnfCount ?? 0}"),
      ],
    );
  }

  String _driverLabel(String? id) {
    if (id == null || id.isEmpty) {
      return "n/a";
    }
    final pretty = id
        .split("_")
        .map((p) => p.isEmpty ? p : "${p[0].toUpperCase()}${p.substring(1)}")
        .join(" ");
    return pretty;
  }
}
