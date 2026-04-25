import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../../l10n/app_localizations.dart";
import "../../../core/utils/app_error_text.dart";

import "../../auth/providers/auth_providers.dart";
import "../../../core/widgets/searchable_select_field.dart";
import "../domain/league.dart";
import "../domain/league_member.dart";
import "../../predictions/domain/prediction.dart";
import "../../predictions/presentation/prediction_dialog.dart";
import "../../predictions/providers/predictions_providers.dart";
import "../../races/data/f1_api_service.dart";
import "../../races/domain/race_result.dart";
import "../../races/domain/race_weekend.dart";
import "../../races/providers/races_providers.dart";
import "../../scoring/domain/mock_race_result.dart";
import "../../scoring/domain/scoring_logic.dart";
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
  bool _showDemoTools = false;

  Future<MockRaceResult?> _showMockResultDialog(
    BuildContext context,
    List<F1Driver> drivers,
  ) {
    final l10n = AppLocalizations.of(context)!;
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
              title: Text(l10n.leagueMockApplyTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _driverSearchField(
                      label: "P1",
                      value: p1,
                      drivers: p1Options,
                      onSelected: (v) => setLocalState(() => p1 = v),
                    ),
                    const SizedBox(height: 8),
                    _driverSearchField(
                      label: "P2",
                      value: p2,
                      drivers: p2Options,
                      onSelected: (v) => setLocalState(() => p2 = v),
                    ),
                    const SizedBox(height: 8),
                    _driverSearchField(
                      label: "P3",
                      value: p3,
                      drivers: p3Options,
                      onSelected: (v) => setLocalState(() => p3 = v),
                    ),
                    const SizedBox(height: 8),
                    _driverSearchField(
                      label: l10n.leagueFastestLap,
                      value: fastestLap,
                      drivers: drivers,
                      onSelected: (v) => setLocalState(() => fastestLap = v),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: dnfController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(labelText: l10n.leagueDnfCount),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.commonCancel),
                ),
                FilledButton(
                  onPressed: () {
                    final dnf = int.tryParse(dnfController.text);
                    if (p1 == null || p2 == null || p3 == null || fastestLap == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.leagueSelectAllFields)),
                      );
                      return;
                    }
                    if ({p1, p2, p3}.length != 3) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.leagueDistinctPodiumDrivers)),
                      );
                      return;
                    }
                    if (dnf == null || dnf < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.leagueDnfNonNegative)),
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
                  child: Text(l10n.commonCreate),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        dnfController.dispose();
      });
    });
  }

  Widget _driverSearchField({
    required String label,
    required String? value,
    required List<F1Driver> drivers,
    required ValueChanged<String?> onSelected,
  }) {
    return SearchableSelectField(
      width: 320,
      label: label,
      hintText: null,
      selectedValue: value,
      onChanged: onSelected,
      items: drivers
          .map((d) => SearchableSelectItem(value: d.shortName, label: d.displayLabel))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = widget.league;
    final membersAsync = ref.watch(leagueMembersProvider(league.id));
    final currentUid = ref.watch(authUserIdProvider).value;
    final isAdmin = currentUid == league.adminUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.leagueDetailsTitle),
        actions: [
          if (isAdmin)
            IconButton(
              tooltip: l10n.leagueDeleteTooltip,
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.leagueDeleteTitle),
                    content: Text(l10n.leagueDeleteMessage),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(l10n.commonCancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(l10n.commonDelete),
                      ),
                    ],
                  ),
                );
                if (confirm != true) {
                  return;
                }
                try {
                  await ref.read(leaguesControllerProvider.notifier).deleteLeague(leagueId: league.id);
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.leagueDeleted)),
                  );
                } catch (e) {
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.leagueDeleteFailed(AppErrorText.describe(l10n, e)))),
                  );
                }
              },
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final racesAsync = ref.watch(racesBySeasonProvider(league.seasonYear));

          return racesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.leagueLoadRacesFailed(AppErrorText.describe(l10n, e)))),
            data: (seasonRaces) {
              final leagueRaces = seasonRaces
                  .where((r) => r.round >= league.startRound && r.round <= league.endRound)
                  .toList()
                ..sort((a, b) => a.round.compareTo(b.round));

              final effectiveSelectedRaceId = leagueRaces.any((r) => r.id == _selectedRaceId)
                  ? _selectedRaceId
                  : (leagueRaces.isNotEmpty ? leagueRaces.first.id : null);

              final selectedRace = leagueRaces.firstWhereOrNull((r) => r.id == effectiveSelectedRaceId);
              final predictionsAsync = selectedRace == null
                  ? const AsyncValue<List<Prediction>>.data(<Prediction>[])
                  : ref.watch(predictionsForRaceProvider(selectedRace.id));
              final officialResultAsync = selectedRace == null
                  ? const AsyncValue<RaceResult?>.data(null)
                  : ref.watch(officialRaceResultProvider(selectedRace));

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.emoji_events_outlined,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(league.name, style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _LeagueBadge(
                                      icon: Icons.flag_outlined,
                                      label: "R${league.startRound}-R${league.endRound}",
                                    ),
                                    _LeagueBadge(
                                      icon: Icons.calendar_today_outlined,
                                      label: "${league.seasonYear}",
                                    ),
                                    _LeagueBadge(
                                      icon: Icons.groups_2_outlined,
                                      label: l10n.leagueMembersCount(league.memberCount),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (leagueRaces.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Center(
                        child: _EmptyStateCard(
                          icon: Icons.flag_outlined,
                          message: l10n.leagueNoRaces,
                        ),
                      ),
                    )
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: DropdownButtonFormField<String>(
                          key: ValueKey(effectiveSelectedRaceId ?? "no-race"),
                          initialValue: effectiveSelectedRaceId,
                          decoration: InputDecoration(labelText: l10n.leagueRaceField),
                          isExpanded: true,
                          items: leagueRaces
                              .map(
                                (race) => DropdownMenuItem<String>(
                                  value: race.id,
                                  child: Text("R${race.round} - ${race.raceName}"),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() => _selectedRaceId = value),
                        ),
                      ),
                    ),
                  if (selectedRace != null) ...[
                    const SizedBox(height: 12),
                    _PredictionsHeaderCard(
                      race: selectedRace,
                      onEditMine: () async {
                        final saved = await PredictionDialog.show(
                          context: context,
                          ref: ref,
                          race: selectedRace,
                        );
                        if (!mounted || !saved) {
                          return;
                        }
                        ref.invalidate(predictionsForRaceProvider(selectedRace.id));
                        ref.invalidate(predictionForRaceProvider(selectedRace.id));
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.leaguePredictionUpdated)),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    membersAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(l10n.leagueLoadMembersFailed(AppErrorText.describe(l10n, e))),
                        ),
                      ),
                      data: (members) {
                        return predictionsAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (e, _) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(l10n.leagueLoadPredictionsFailed(AppErrorText.describe(l10n, e))),
                            ),
                          ),
                          data: (predictions) {
                            final byUser = {for (final p in predictions) p.userId: p};
                            if (members.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: _EmptyStateCard(
                                    icon: Icons.groups_outlined,
                                    message: l10n.leagueMembersCount(0),
                                  ),
                                ),
                              );
                            }

                            final officialResult = officialResultAsync.valueOrNull;
                            final isFinishedRace =
                                !DateTime.now().toUtc().isBefore(selectedRace.expectedEndTimeUtc);

                            return Column(
                              children: [
                                if (isFinishedRace && officialResult != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        l10n.leagueOfficialPointsShown,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ),
                                  ),
                                for (var index = 0; index < members.length; index++) ...[
                                  if (index > 0) const SizedBox(height: 8),
                                  _MemberPredictionCard(
                                    index: index,
                                    member: members[index],
                                    prediction: byUser[members[index].userId],
                                    currentUid: currentUid,
                                    officialRoundPoints: officialResult == null
                                        ? null
                                        : ScoringLogic.computePoints(
                                            prediction: byUser[members[index].userId],
                                            result: officialResult,
                                            rules: league.scoringRules,
                                          ),
                                    selectedRaceId: selectedRace.id,
                                  ),
                                ],
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    if (isAdmin)
                      _DemoToolsCard(
                        league: league,
                        race: selectedRace,
                        showDemoTools: _showDemoTools,
                        onToggle: () => setState(() => _showDemoTools = !_showDemoTools),
                      ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _LeagueBadge extends StatelessWidget {
  const _LeagueBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _PredictionsHeaderCard extends StatelessWidget {
  const _PredictionsHeaderCard({
    required this.race,
    required this.onEditMine,
  });

  final RaceWeekend race;
  final Future<void> Function() onEditMine;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now().toUtc();
    final isFinished = !now.isBefore(race.expectedEndTimeUtc);
    final isLocked = !isFinished && !now.isBefore(PredictionDialog.lockAtUtc(race));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 260,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.leaguePredictionsForRound(race.round),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    race.raceName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (isFinished)
              _LeagueBadge(
                icon: Icons.flag_circle_outlined,
                label: l10n.racesFinished,
              )
            else if (isLocked)
              _LeagueBadge(
                icon: Icons.lock_outline,
                label: l10n.racesLocked,
              )
            else
              FilledButton.tonal(
                onPressed: onEditMine,
                child: Text(l10n.leagueEditMine),
              ),
          ],
        ),
      ),
    );
  }
}

class _DemoToolsCard extends ConsumerWidget {
  const _DemoToolsCard({
    required this.league,
    required this.race,
    required this.showDemoTools,
    required this.onToggle,
  });

  final League league;
  final RaceWeekend race;
  final bool showDemoTools;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 180,
                  child: Text(
                    l10n.leagueDemoTools,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onToggle,
                  icon: Icon(showDemoTools ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  label: Text(showDemoTools ? l10n.leagueHideDemoTools : l10n.leagueShowDemoTools),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton(
                        onPressed: () async {
                          try {
                            final drivers = await ref.read(currentDriversProvider.future);
                            if (!context.mounted) {
                              return;
                            }
                            final state = context.findAncestorStateOfType<_LeagueDetailsScreenState>();
                            final mockResult = await state?._showMockResultDialog(context, drivers);
                            if (mockResult == null) {
                              return;
                            }
                            await ref.read(mockScoringServiceProvider).applyMockResult(
                                  league: league,
                                  raceId: race.id,
                                  result: mockResult,
                                );
                            ref.invalidate(leagueMembersProvider(league.id));
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.leagueMockApplied)),
                            );
                          } catch (e) {
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.leagueMockApplyFailed(AppErrorText.describe(l10n, e)),
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(l10n.leagueMockApplyButton),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          try {
                            await ref.read(mockScoringServiceProvider).revertMockResult(
                                  league: league,
                                  raceId: race.id,
                                );
                            ref.invalidate(leagueMembersProvider(league.id));
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.leagueMockReverted)),
                            );
                          } catch (e) {
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.leagueMockRevertFailed(AppErrorText.describe(l10n, e)),
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(l10n.leagueMockRevertButton),
                      ),
                    ],
                  ),
                ),
              ),
              crossFadeState: showDemoTools ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
            ),
          ],
        ),
      ),
    );
  }
}

class _PredictionToken extends StatelessWidget {
  const _PredictionToken({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _MemberPredictionCard extends ConsumerWidget {
  const _MemberPredictionCard({
    required this.index,
    required this.member,
    required this.prediction,
    required this.currentUid,
    required this.officialRoundPoints,
    required this.selectedRaceId,
  });

  final int index;
  final LeagueMember member;
  final Prediction? prediction;
  final String? currentUid;
  final int? officialRoundPoints;
  final String? selectedRaceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final uid = member.userId;
    final usernameAsync = ref.watch(usernameByUserIdProvider(uid));
    final displayName = usernameAsync.maybeWhen(
      data: (name) => name,
      orElse: () => (uid.length > 6 ? uid.substring(0, 6) : uid),
    );
    final mine = uid == currentUid;
    final storedRoundPoints = selectedRaceId == null ? null : member.racePoints[selectedRaceId!];
    final shownRoundPoints = storedRoundPoints ?? officialRoundPoints;
    final shownTotalPoints = storedRoundPoints == null && officialRoundPoints != null
        ? member.totalPoints + officialRoundPoints!
        : member.totalPoints;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  child: Text(
                    "${index + 1}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    mine ? l10n.leagueYouWithName(displayName) : displayName,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Chip(label: Text(l10n.leaguePoints(shownTotalPoints))),
                    if (shownRoundPoints != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          l10n.leagueRoundPoints(shownRoundPoints),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (prediction == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(l10n.leagueNoPrediction),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PredictionToken(label: "P1 ${prediction!.p1DriverCode}"),
                  _PredictionToken(label: "P2 ${prediction!.p2DriverCode}"),
                  _PredictionToken(label: "P3 ${prediction!.p3DriverCode}"),
                  _PredictionToken(label: "FL ${prediction!.fastestLapDriverCode}"),
                  _PredictionToken(label: "DNF ${prediction!.dnfCount ?? "-"}"),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
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
