import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../auth/providers/auth_providers.dart";
import "../domain/league.dart";
import "../../predictions/domain/prediction.dart";
import "../../predictions/presentation/prediction_dialog.dart";
import "../../predictions/providers/predictions_providers.dart";
import "../../races/domain/race_weekend.dart";
import "../../races/providers/races_providers.dart";
import "../providers/leagues_providers.dart";

class LeagueDetailsScreen extends ConsumerStatefulWidget {
  const LeagueDetailsScreen({
    required this.league,
    super.key,
  });

  final League league;

  @override
  ConsumerState<LeagueDetailsScreen> createState() => _LeagueDetailsScreenState();
}

class _LeagueDetailsScreenState extends ConsumerState<LeagueDetailsScreen> {
  String? _selectedRaceId;

  @override
  Widget build(BuildContext context) {
    final league = widget.league;
    final memberIdsAsync = ref.watch(leagueMemberIdsProvider(league.id));

    return Scaffold(
      appBar: AppBar(title: const Text("League Details")),
      body: Builder(
        builder: (context) {
          final racesAsync = ref.watch(racesBySeasonProvider(league.seasonYear));

          return racesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Failed to load races: $e")),
            data: (seasonRaces) {
              final leagueRaces = seasonRaces
                  .where((r) => r.round >= league.startRound && r.round <= league.endRound)
                  .toList()
                ..sort((a, b) => a.round.compareTo(b.round));

              if (leagueRaces.isNotEmpty &&
                  (_selectedRaceId == null || !leagueRaces.any((r) => r.id == _selectedRaceId))) {
                _selectedRaceId = leagueRaces.first.id;
              }

              final RaceWeekend? selectedRace = leagueRaces.firstWhereOrNull((r) => r.id == _selectedRaceId);
              final predictionsAsync = selectedRace == null
                  ? const AsyncValue<List<Prediction>>.data(<Prediction>[])
                  : ref.watch(predictionsForRaceProvider(selectedRace.id));

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(league.name, style: Theme.of(context).textTheme.titleLarge),
                    Text("Rounds ${league.startRound}-${league.endRound}, Season ${league.seasonYear}"),
                    const SizedBox(height: 12),
                    if (leagueRaces.isEmpty)
                      const Text("No races found in this league range.")
                    else
                      DropdownButtonFormField<String>(
                        initialValue: _selectedRaceId,
                        decoration: const InputDecoration(labelText: "Race"),
                        isExpanded: true,
                        items: leagueRaces
                            .map((race) => DropdownMenuItem<String>(
                                  value: race.id,
                                  child: Text(
                                    "R${race.round} - ${race.raceName}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        selectedItemBuilder: (context) {
                          return leagueRaces
                              .map(
                                (race) => Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "R${race.round} - ${race.raceName}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList();
                        },
                        onChanged: (value) => setState(() => _selectedRaceId = value),
                      ),
                    const SizedBox(height: 12),
                    if (selectedRace != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Predictions for R${selectedRace.round}",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          FilledButton.tonal(
                            onPressed: () async {
                              final saved = await PredictionDialog.show(
                                context: context,
                                ref: ref,
                                race: selectedRace,
                              );
                              if (!mounted) {
                                return;
                              }
                              if (saved) {
                                ref.invalidate(predictionsForRaceProvider(selectedRace.id));
                                ref.invalidate(predictionForRaceProvider(selectedRace.id));
                                if (!context.mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Prediction updated.")),
                                );
                              }
                            },
                            child: const Text("Edit Mine"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: memberIdsAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text("Failed to load members: $e")),
                          data: (memberIds) {
                            return predictionsAsync.when(
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (e, _) => Center(child: Text("Failed to load predictions: $e")),
                              data: (predictions) {
                                final byUser = {for (final p in predictions) p.userId: p};
                                final currentUid = ref.watch(authUserIdProvider).value;

                                return ListView.separated(
                                  itemCount: memberIds.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final uid = memberIds[index];
                                    final p = byUser[uid];
                                    final mine = uid == currentUid;
                                    return Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              mine ? "You ($uid)" : uid,
                                              style: Theme.of(context).textTheme.titleSmall,
                                            ),
                                            const SizedBox(height: 6),
                                            if (p == null)
                                              const Text("No prediction submitted yet.")
                                            else
                                              Text(
                                                "P1 ${p.p1DriverCode} | P2 ${p.p2DriverCode} | "
                                                "P3 ${p.p3DriverCode} | FL ${p.fastestLapDriverCode} | "
                                                "DNF ${p.dnfCount ?? "-"}",
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final value in this) {
      if (test(value)) {
        return value;
      }
    }
    return null;
  }
}
