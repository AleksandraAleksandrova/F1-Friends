import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../../l10n/app_localizations.dart";
import "../../../core/utils/app_error_text.dart";

import "../../../core/widgets/searchable_select_field.dart";
import "../../races/data/f1_api_service.dart";
import "../../races/domain/race_weekend.dart";
import "../../races/providers/races_providers.dart";
import "../providers/predictions_providers.dart";

class PredictionDialog {
  static const Duration estimatedQualyDuration = Duration(minutes: 75);

  static DateTime lockAtUtc(RaceWeekend race) {
    if (race.qualifyingStartUtc != null) {
      return race.qualifyingStartUtc!.add(estimatedQualyDuration);
    }
    return race.startTimeUtc;
  }

  static Future<bool> show({
    required BuildContext context,
    required WidgetRef ref,
    required RaceWeekend race,
  }) async {
    final existing = await ref.read(predictionForRaceProvider(race.id).future);
    final drivers = await ref.read(currentDriversProvider.future);
    if (!context.mounted) {
      return false;
    }
    final l10n = AppLocalizations.of(context)!;

    final dnfController = TextEditingController(text: existing?.dnfCount?.toString() ?? "");
    String? p1 = _toExistingOrNull(existing?.p1DriverCode, drivers);
    String? p2 = _toExistingOrNull(existing?.p2DriverCode, drivers);
    String? p3 = _toExistingOrNull(existing?.p3DriverCode, drivers);
    String? fl = _toExistingOrNull(existing?.fastestLapDriverCode, drivers);

    final saved = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text(l10n.predictionTitle(race.raceName)),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _driverDropdown(
                          label: l10n.predictionP1Driver,
                          value: p1,
                          drivers: drivers,
                          excludedShortNames: {
                            if (p2 != null) p2!,
                            if (p3 != null) p3!,
                          },
                          onChanged: (v) => setState(() => p1 = v),
                        ),
                        const SizedBox(height: 10),
                        _driverDropdown(
                          label: l10n.predictionP2Driver,
                          value: p2,
                          drivers: drivers,
                          excludedShortNames: {
                            if (p1 != null) p1!,
                            if (p3 != null) p3!,
                          },
                          onChanged: (v) => setState(() => p2 = v),
                        ),
                        const SizedBox(height: 10),
                        _driverDropdown(
                          label: l10n.predictionP3Driver,
                          value: p3,
                          drivers: drivers,
                          excludedShortNames: {
                            if (p1 != null) p1!,
                            if (p2 != null) p2!,
                          },
                          onChanged: (v) => setState(() => p3 = v),
                        ),
                        const SizedBox(height: 10),
                        _driverDropdown(
                          label: l10n.predictionFastestLapDriver,
                          value: fl,
                          drivers: drivers,
                          excludedShortNames: const <String>{},
                          onChanged: (v) => setState(() => fl = v),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: dnfController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(labelText: l10n.predictionDnfOptional),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: Text(l10n.commonCancel),
                    ),
                    FilledButton(
                      onPressed: () async {
                        if (p1 == null || p2 == null || p3 == null || fl == null) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text(l10n.predictionSelectAllDrivers)),
                          );
                          return;
                        }
                        final rawDnf = dnfController.text.trim();
                        final parsedDnf = rawDnf.isEmpty ? null : int.tryParse(rawDnf);
                        if (parsedDnf == null && rawDnf.isNotEmpty) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text(l10n.predictionDnfInteger)),
                          );
                          return;
                        }
                        if (parsedDnf != null && parsedDnf < 0) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text(l10n.predictionDnfInteger)),
                          );
                          return;
                        }
                        if ({p1, p2, p3}.length != 3) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text(l10n.predictionPodiumDistinct)),
                          );
                          return;
                        }

                        try {
                          final lockAt = lockAtUtc(race);
                          if (!DateTime.now().toUtc().isBefore(lockAt)) {
                            throw StateError(l10n.predictionLockedAfterQualy);
                          }
                          await ref.read(predictionsControllerProvider.notifier).save(
                                raceId: race.id,
                                lockAtUtc: lockAt,
                                p1: p1!,
                                p2: p2!,
                                p3: p3!,
                                fastestLap: fl!,
                                dnfCount: parsedDnf,
                              );
                          ref.invalidate(predictionForRaceProvider(race.id));
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop(true);
                          }
                        } catch (error) {
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(content: Text(_friendlyError(l10n, error))),
                            );
                          }
                        }
                      },
                      child: Text(existing == null ? l10n.commonSave : l10n.commonUpdate),
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
        }) ??
        false;

    return saved;
  }

  static String _friendlyError(AppLocalizations l10n, Object error) {
    if (error is FirebaseException && error.code == "permission-denied") {
      return l10n.predictionPermissionDenied;
    }
    if (error is StateError) {
      return error.message;
    }
    return AppErrorText.describe(l10n, error);
  }

  static String? _toExistingOrNull(String? shortName, List<F1Driver> drivers) {
    if (shortName == null) {
      return null;
    }
    final upper = shortName.toUpperCase();
    final exists = drivers.any((d) => d.shortName == upper);
    return exists ? upper : null;
  }

  static SearchableSelectField _driverDropdown({
    required String label,
    required String? value,
    required List<F1Driver> drivers,
    required Set<String> excludedShortNames,
    required ValueChanged<String?> onChanged,
  }) {
    final entries = drivers
        .where((d) => d.shortName == value || !excludedShortNames.contains(d.shortName))
        .map((d) => SearchableSelectItem(value: d.shortName, label: d.displayLabel))
        .toList();

    return SearchableSelectField(
      width: 320,
      label: label,
      hintText: null,
      selectedValue: value,
      onChanged: onChanged,
      items: entries,
    );
  }
}
