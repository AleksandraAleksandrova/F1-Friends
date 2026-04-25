import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../../l10n/app_localizations.dart";
import "package:intl/intl.dart";
import "../../../core/utils/app_error_text.dart";

import "../../predictions/presentation/prediction_dialog.dart";
import "../../predictions/providers/predictions_providers.dart";
import "../domain/race_weekend.dart";
import "../providers/races_providers.dart";

class RacesScreen extends ConsumerWidget {
  const RacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final raceHubAsync = ref.watch(raceHubProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.racesTitle),
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.flag_circle_outlined,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.racesTitle,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(l10n.racesCurrentSeasonRounds),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: l10n.racesNextRace,
                child: hub.nextRace == null
                    ? Text(l10n.racesNoUpcoming)
                    : _RaceTile(race: hub.nextRace!),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: l10n.racesLastRace,
                child: hub.lastRace == null
                    ? Text(l10n.racesNoLast)
                    : _RaceTile(race: hub.lastRace!),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: l10n.racesCurrentSeasonRounds,
                child: hub.seasonRaces.isEmpty
                    ? Text(l10n.racesNoSeasonRaces)
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
            child: Text(l10n.racesFailedLoadApi(AppErrorText.describe(l10n, error))),
          ),
        ),
      ),
    );
  }

  static String formatUtc(BuildContext context, DateTime dt) {
    final local = dt.toLocal();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat("EEE, d MMM", locale).format(local);
    final time = DateFormat("HH:mm", locale).format(local);
    return "$date at $time";
  }

  static String formatUtcAround(BuildContext context, DateTime dt) {
    final rounded = _roundUpToFive(dt.toLocal());
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat("EEE, d MMM", locale).format(rounded);
    final time = DateFormat("HH:mm", locale).format(rounded);
    return "$date around $time";
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
    final l10n = AppLocalizations.of(context)!;
    final lockAt = PredictionDialog.lockAtUtc(race);
    final now = DateTime.now().toUtc();
    final isFinished = !now.isBefore(race.expectedEndTimeUtc);
    final isLocked = !isFinished && !now.isBefore(lockAt);
    final existingPredictionAsync = ref.watch(predictionForRaceProvider(race.id));

    final buttonLabel = isFinished
        ? l10n.racesFinished
        : isLocked
        ? l10n.racesLocked
        : existingPredictionAsync.maybeWhen(
            data: (p) => p == null ? l10n.racesPredict : l10n.commonUpdate,
            orElse: () => l10n.racesPredict,
          );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                child: Text(
                  "${race.round}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(
                width: 180,
                child: Text(
                  race.raceName,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              OutlinedButton(
                onPressed: (isLocked || isFinished)
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
                              SnackBar(content: Text(l10n.racesPredictionSaved)),
                            );
                          }
                        }
                      },
                child: Text(buttonLabel),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(RacesScreen.formatUtc(context, race.startTimeUtc)),
          const SizedBox(height: 2),
          Text(l10n.racesLock(RacesScreen.formatUtc(context, lockAt))),
        ],
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.speed,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: Theme.of(context).textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 14),
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(race.raceName, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(l10n.racesRoundSeason(race.round, race.seasonYear)),
        const SizedBox(height: 4),
        Text(l10n.racesRaceStart(RacesScreen.formatUtc(context, race.startTimeUtc))),
        Text(l10n.racesExpectedEnd(RacesScreen.formatUtcAround(context, race.expectedEndTimeUtc))),
        if (race.qualifyingStartUtc != null)
          Text(l10n.racesQualyStart(RacesScreen.formatUtc(context, race.qualifyingStartUtc!))),
      ],
    );
  }
}
