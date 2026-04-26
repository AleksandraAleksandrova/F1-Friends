import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "../../../l10n/app_localizations.dart";
import "../../../core/utils/app_error_text.dart";

import "league_details_screen.dart";
import "../domain/league.dart";
import "../providers/leagues_providers.dart";
import "../../races/providers/races_providers.dart";
import "../../races/domain/race_weekend.dart";

class LeaguesScreen extends ConsumerWidget {
  const LeaguesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final leaguesAsync = ref.watch(userLeaguesProvider);
    final raceHubAsync = ref.watch(raceHubProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.leaguesTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.groups_rounded,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.leaguesTitle,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 2),
                              Text(l10n.leaguesSubtitle),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton.icon(
                          onPressed: () => _showCreateLeagueDialog(context, ref),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.leaguesCreate),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () => _showJoinLeagueDialog(context, ref),
                          icon: const Icon(Icons.group_add),
                          label: Text(l10n.leaguesJoin),
                        ),
                      ],
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
                    return Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.emoji_flags_outlined,
                                size: 42,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.leaguesEmpty,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return raceHubAsync.when(
                    data: (hub) => _buildSectionedLeaguesList(
                      context,
                      ref,
                      leagues,
                      l10n,
                      hubSeasonYear: hub.seasonRaces.isNotEmpty ? hub.seasonRaces.first.seasonYear : DateTime.now().year,
                      latestFinishedRound: _latestFinishedRound(hub.seasonRaces),
                    ),
                    loading: () => _buildLeagueSplitLoading(context, l10n),
                    error: (_, __) => _buildSectionedLeaguesList(
                      context,
                      ref,
                      leagues,
                      l10n,
                      hubSeasonYear: DateTime.now().year,
                      latestFinishedRound: 0,
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text(l10n.leaguesFailedLoad(_friendlyError(error, l10n)))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _friendlyError(Object error, AppLocalizations l10n) {
    if (error is FirebaseException && error.code == "permission-denied") {
      return l10n.leaguesPermissionDenied;
    }
    if (error is StateError) {
      return AppErrorText.describe(l10n, error);
    }
    return AppErrorText.describe(l10n, error);
  }

  List<Widget> _buildLeagueCards(
    BuildContext context,
    WidgetRef ref,
    List<League> leagues,
    AppLocalizations l10n,
  ) {
    return [
      for (var index = 0; index < leagues.length; index++) ...[
        if (index > 0) const SizedBox(height: 10),
        _LeagueCard(league: leagues[index]),
      ],
    ];
  }

  Widget _buildSectionedLeaguesList(
    BuildContext context,
    WidgetRef ref,
    List<League> leagues,
    AppLocalizations l10n, {
    required int hubSeasonYear,
    required int latestFinishedRound,
  }) {
    bool isPastLeague(League league) {
      if (league.seasonYear < hubSeasonYear) {
        return true;
      }
      if (league.seasonYear > hubSeasonYear) {
        return false;
      }
      return league.endRound <= latestFinishedRound;
    }

    final activeLeagues = leagues.where((league) => !isPastLeague(league)).toList()
      ..sort((a, b) {
        final seasonCompare = b.seasonYear.compareTo(a.seasonYear);
        if (seasonCompare != 0) {
          return seasonCompare;
        }
        return a.endRound.compareTo(b.endRound);
      });
    final pastLeagues = leagues.where(isPastLeague).toList()
      ..sort((a, b) {
        final seasonCompare = b.seasonYear.compareTo(a.seasonYear);
        if (seasonCompare != 0) {
          return seasonCompare;
        }
        return b.endRound.compareTo(a.endRound);
      });

    return ListView(
      children: [
        if (activeLeagues.isNotEmpty) ...[
          Text(
            l10n.leaguesActiveSection,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ..._buildLeagueCards(context, ref, activeLeagues, l10n),
        ],
        if (pastLeagues.isNotEmpty) ...[
          if (activeLeagues.isNotEmpty) const SizedBox(height: 18),
          Text(
            l10n.leaguesPastSection,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ..._buildLeagueCards(context, ref, pastLeagues, l10n),
        ],
      ],
    );
  }

  Widget _buildLeagueSplitLoading(BuildContext context, AppLocalizations l10n) {
    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "${l10n.commonLoading} ${l10n.leaguesTitle.toLowerCase()}...",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int _latestFinishedRound(List<RaceWeekend> seasonRaces) {
    final now = DateTime.now().toUtc();
    var latestFinishedRound = 0;
    for (final race in seasonRaces) {
      if (!now.isBefore(race.expectedEndTimeUtc) && race.round > latestFinishedRound) {
        latestFinishedRound = race.round;
      }
    }
    return latestFinishedRound;
  }


  Future<void> _showCreateLeagueDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
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
        var isSubmitting = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.leaguesCreateDialogTitle),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: l10n.leaguesName),
                        validator: (value) => (value == null || value.trim().length < 3)
                            ? l10n.leaguesNameValidation
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: seasonController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.leaguesSeasonYear),
                        validator: (value) => int.tryParse(value ?? "") == null ? l10n.leaguesInvalidYear : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: startRoundController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.leaguesStartRound),
                        validator: (value) {
                          final start = int.tryParse(value ?? "");
                          if (start == null || start < 1) {
                            return l10n.leaguesStartPositive;
                          }
                          if (start > maxRound) {
                            return l10n.leaguesStartMax(maxRound);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: endRoundController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.leaguesEndRound),
                        validator: (value) {
                          final end = int.tryParse(value ?? "");
                          final start = int.tryParse(startRoundController.text);
                          if (end == null || end < 1) {
                            return l10n.leaguesEndPositive;
                          }
                          if (end > maxRound) {
                            return l10n.leaguesEndMax(maxRound);
                          }
                          if (start != null && end < start) {
                            return l10n.leaguesEndAfterStart;
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
                  onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                  child: Text(l10n.commonCancel),
                ),
                FilledButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }
                          final startRound = int.parse(startRoundController.text);
                          final endRound = int.parse(endRoundController.text);
                          if (startRound < 1 || endRound < 1 || startRound > maxRound || endRound > maxRound) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.leaguesRoundsRange(maxRound))),
                            );
                            return;
                          }
                          if (endRound < startRound) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.leaguesEndAfterStart)),
                            );
                            return;
                          }

                          setState(() => isSubmitting = true);
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
                              setState(() => isSubmitting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(_friendlyError(error, l10n))),
                              );
                            }
                          }
                        },
                  child: Text(l10n.commonCreate),
                ),
              ],
            );
          },
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      nameController.dispose();
      seasonController.dispose();
      startRoundController.dispose();
      endRoundController.dispose();
    });

    if (context.mounted && submitted == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.leaguesCreated)),
      );
    }
  }

  Future<void> _showJoinLeagueDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController();

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) {
        var isSubmitting = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.leaguesJoinDialogTitle),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(labelText: l10n.leaguesJoinCode),
                  validator: (value) => (value == null || value.trim().length < 4)
                      ? l10n.leaguesJoinCodeValidation
                      : null,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                  child: Text(l10n.commonCancel),
                ),
                FilledButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }
                          setState(() => isSubmitting = true);
                          try {
                            final result = await ref.read(leaguesControllerProvider.notifier).joinLeagueByCode(
                                  joinCode: codeController.text.trim(),
                                );
                            if (context.mounted) {
                              Navigator.of(context).pop(result.joined);
                            }
                          } catch (error) {
                            if (context.mounted) {
                              setState(() => isSubmitting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(_friendlyError(error, l10n))),
                              );
                            }
                          }
                        },
                  child: Text(l10n.commonJoin),
                ),
              ],
            );
          },
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      codeController.dispose();
    });

    if (context.mounted && submitted == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.leaguesJoined)),
      );
    }
    if (context.mounted && submitted == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.leaguesAlreadyJoined)),
      );
    }
  }
}

class _LeagueCard extends ConsumerWidget {
  const _LeagueCard({required this.league});

  final League league;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final adminNameAsync = ref.watch(usernameByUserIdProvider(league.adminUserId));
    final adminDisplay = adminNameAsync.maybeWhen(
      data: (name) => name,
      orElse: () => (league.adminUserId.length > 6
          ? league.adminUserId.substring(0, 6)
          : league.adminUserId),
    );
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LeagueDetailsScreen(league: league),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      league.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Chip(label: Text(league.joinCode)),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _LeagueMetaChip(
                    icon: Icons.verified_user_outlined,
                    label: "${l10n.leaguesAdmin} $adminDisplay",
                  ),
                  _LeagueMetaChip(
                    icon: Icons.calendar_month_outlined,
                    label: "${l10n.leaguesSeason} ${league.seasonYear}",
                  ),
                  _LeagueMetaChip(
                    icon: Icons.flag_outlined,
                    label: "R${league.startRound}-R${league.endRound}",
                  ),
                  _LeagueMetaChip(
                    icon: Icons.groups_2_outlined,
                    label: "${l10n.leaguesMembers} ${league.memberCount}",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeagueMetaChip extends StatelessWidget {
  const _LeagueMetaChip({
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


