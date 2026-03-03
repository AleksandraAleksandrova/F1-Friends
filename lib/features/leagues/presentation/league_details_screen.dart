import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../auth/providers/auth_providers.dart";
import "../domain/league.dart";
import "../../predictions/domain/prediction.dart";
import "../../predictions/presentation/prediction_dialog.dart";
import "../../predictions/providers/predictions_providers.dart";
import "../../races/data/f1_api_service.dart";
import "../../races/domain/race_weekend.dart";
import "../../races/providers/races_providers.dart";
import "../../scoring/domain/mock_race_result.dart";
import "../../scoring/providers/mock_scoring_providers.dart";
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

  Future<MockRaceResult?> _showMockResultDialog(
    BuildContext context,
    List<F1Driver> drivers,
  ) {
    String? p1;
    String? p2;
    String? p3;
    String? fastestLap;
    final dnfController = TextEditingController(text: "0");

    return showDialog<MockRaceResult>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            final p1Options = drivers.where((d) => d.shortName != p2 && d.shortName != p3).toList();
            final p2Options = drivers.where((d) => d.shortName != p1 && d.shortName != p3).toList();
            final p3Options = drivers.where((d) => d.shortName != p1 && d.shortName != p2).toList();

            return AlertDialog(
              title: const Text("Apply Mock Race Result"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownMenu<String>(
                      width: 320,
                      hintText: "Type driver (e.g. char)",
                      label: const Text("P1"),
                      initialSelection: p1,
                      enableFilter: true,
                      enableSearch: true,
                      onSelected: (v) => setLocalState(() => p1 = v),
                      dropdownMenuEntries: p1Options
                          .map((d) => DropdownMenuEntry(value: d.shortName, label: d.displayLabel))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    DropdownMenu<String>(
                      width: 320,
                      hintText: "Type driver",
                      label: const Text("P2"),
                      initialSelection: p2,
                      enableFilter: true,
                      enableSearch: true,
                      onSelected: (v) => setLocalState(() => p2 = v),
                      dropdownMenuEntries: p2Options
                          .map((d) => DropdownMenuEntry(value: d.shortName, label: d.displayLabel))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    DropdownMenu<String>(
                      width: 320,
                      hintText: "Type driver",
                      label: const Text("P3"),
                      initialSelection: p3,
                      enableFilter: true,
                      enableSearch: true,
                      onSelected: (v) => setLocalState(() => p3 = v),
                      dropdownMenuEntries: p3Options
                          .map((d) => DropdownMenuEntry(value: d.shortName, label: d.displayLabel))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    DropdownMenu<String>(
                      width: 320,
                      hintText: "Type driver",
                      label: const Text("Fastest lap"),
                      initialSelection: fastestLap,
                      enableFilter: true,
                      enableSearch: true,
                      onSelected: (v) => setLocalState(() => fastestLap = v),
                      dropdownMenuEntries: drivers
                          .map((d) => DropdownMenuEntry(value: d.shortName, label: d.displayLabel))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: dnfController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "DNF count"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  onPressed: () {
                    final dnf = int.tryParse(dnfController.text);
                    if (p1 == null || p2 == null || p3 == null || fastestLap == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Select all required fields.")),
                      );
                      return;
                    }
                    if ({p1, p2, p3}.length != 3) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("P1, P2 and P3 must be different drivers.")),
                      );
                      return;
                    }
                    if (dnf == null || dnf < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("DNF must be a non-negative number.")),
                      );
                      return;
                    }
                    Navigator.of(context).pop(
                      MockRaceResult(
                        p1DriverCode: p1!,
                        p2DriverCode: p2!,
                        p3DriverCode: p3!,
                        fastestLapDriverCode: fastestLap!,
                        dnfCount: dnf,
                      ),
                    );
                  },
                  child: const Text("Apply"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final league = widget.league;
    final membersAsync = ref.watch(leagueMembersProvider(league.id));
    final currentUid = ref.watch(authUserIdProvider).value;

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
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(league.name, style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 4),
                            Text("Rounds ${league.startRound}-${league.endRound}, Season ${league.seasonYear}"),
                            const SizedBox(height: 4),
                            Text("Members: ${league.memberCount}"),
                          ],
                        ),
                      ),
                    ),
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
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "Predictions for R${selectedRace.round}",
                            style: Theme.of(context).textTheme.titleMedium,
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
                          FilledButton(
                              onPressed: () async {
                                try {
                                  final drivers = await ref.read(currentDriversProvider.future);
                                  if (!mounted) {
                                    return;
                                  }
                                  final mockResult = await _showMockResultDialog(this.context, drivers);
                                  if (mockResult == null) {
                                    return;
                                  }
                                  await ref.read(mockScoringServiceProvider).applyMockResult(
                                        league: league,
                                        raceId: selectedRace.id,
                                        result: mockResult,
                                      );
                                  ref.invalidate(leagueMembersProvider(league.id));
                                  if (!mounted) {
                                    return;
                                  }
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Mock scoring applied. Leaderboard updated."),
                                    ),
                                  );
                                } catch (e) {
                                  if (!mounted) {
                                    return;
                                  }
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    SnackBar(content: Text("Failed to apply mock result: $e")),
                                  );
                                }
                              },
                              child: const Text("Apply Mock Result"),
                            ),
                          OutlinedButton(
                              onPressed: () async {
                                try {
                                  await ref.read(mockScoringServiceProvider).revertMockResult(
                                        league: league,
                                        raceId: selectedRace.id,
                                      );
                                  ref.invalidate(leagueMembersProvider(league.id));
                                  if (!mounted) {
                                    return;
                                  }
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Mock points reverted for this race."),
                                    ),
                                  );
                                } catch (e) {
                                  if (!mounted) {
                                    return;
                                  }
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    SnackBar(content: Text("Failed to revert mock points: $e")),
                                  );
                                }
                              },
                              child: const Text("Revert Mock Points"),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: membersAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text("Failed to load members: $e")),
                          data: (members) {
                            return predictionsAsync.when(
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (e, _) => Center(child: Text("Failed to load predictions: $e")),
                              data: (predictions) {
                                final byUser = {for (final p in predictions) p.userId: p};

                                return ListView.separated(
                                  itemCount: members.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final member = members[index];
                                    final uid = member.userId;
                                    final usernameAsync = ref.watch(usernameByUserIdProvider(uid));
                                    final displayName = usernameAsync.maybeWhen(
                                      data: (name) => name,
                                      orElse: () => (uid.length > 6 ? uid.substring(0, 6) : uid),
                                    );
                                    final p = byUser[uid];
                                    final mine = uid == currentUid;
                                    return Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "${index + 1}. ${mine ? "You ($displayName)" : displayName}",
                                                    style: Theme.of(context).textTheme.titleSmall,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                                    borderRadius: BorderRadius.circular(999),
                                                  ),
                                                  child: Text("${member.totalPoints} pts"),
                                                ),
                                              ],
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
