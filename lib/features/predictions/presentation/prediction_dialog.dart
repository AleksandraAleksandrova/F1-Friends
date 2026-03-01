import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

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

    final formKey = GlobalKey<FormState>();
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
                  title: Text("Prediction: ${race.raceName}"),
                  content: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _driverDropdown(
                            label: "P1 driver",
                            value: p1,
                            drivers: drivers,
                            excludedShortNames: {
                              if (p2 != null) p2!,
                              if (p3 != null) p3!,
                            },
                            onChanged: (v) => setState(() => p1 = v),
                          ),
                          _driverDropdown(
                            label: "P2 driver",
                            value: p2,
                            drivers: drivers,
                            excludedShortNames: {
                              if (p1 != null) p1!,
                              if (p3 != null) p3!,
                            },
                            onChanged: (v) => setState(() => p2 = v),
                          ),
                          _driverDropdown(
                            label: "P3 driver",
                            value: p3,
                            drivers: drivers,
                            excludedShortNames: {
                              if (p1 != null) p1!,
                              if (p2 != null) p2!,
                            },
                            onChanged: (v) => setState(() => p3 = v),
                          ),
                          _driverDropdown(
                            label: "Fastest lap driver",
                            value: fl,
                            drivers: drivers,
                            excludedShortNames: const <String>{},
                            onChanged: (v) => setState(() => fl = v),
                          ),
                          TextFormField(
                            controller: dnfController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "DNF count (optional)"),
                            validator: (value) {
                              final v = value?.trim() ?? "";
                              if (v.isEmpty) {
                                return null;
                              }
                              final parsed = int.tryParse(v);
                              if (parsed == null || parsed < 0) {
                                return "DNF must be a non-negative integer";
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
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text("Cancel"),
                    ),
                    FilledButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        if (p1 == null || p2 == null || p3 == null || fl == null) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(content: Text("Please select all required drivers.")),
                          );
                          return;
                        }
                        if ({p1, p2, p3}.length != 3) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(content: Text("P1, P2, and P3 must be different.")),
                          );
                          return;
                        }

                        try {
                          final lockAt = lockAtUtc(race);
                          if (!DateTime.now().toUtc().isBefore(lockAt)) {
                            throw StateError("Predictions are locked for this race (qualifying has ended)."
                                );
                          }
                          await ref.read(predictionsControllerProvider.notifier).save(
                                raceId: race.id,
                                lockAtUtc: lockAt,
                                p1: p1!,
                                p2: p2!,
                                p3: p3!,
                                fastestLap: fl!,
                                dnfCount: dnfController.text.trim().isEmpty
                                    ? null
                                    : int.parse(dnfController.text.trim()),
                              );
                          ref.invalidate(predictionForRaceProvider(race.id));
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop(true);
                          }
                        } catch (error) {
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(content: Text(_friendlyError(error))),
                            );
                          }
                        }
                      },
                      child: Text(existing == null ? "Save" : "Update"),
                    ),
                  ],
                );
              },
            );
          },
        ) ??
        false;

    return saved;
  }

  static String _friendlyError(Object error) {
    if (error is FirebaseException && error.code == "permission-denied") {
      return "Firestore permissions denied. Please publish latest rules and restart.";
    }
    if (error is StateError) {
      return error.message;
    }
    return error.toString();
  }

  static String? _toExistingOrNull(String? shortName, List<F1Driver> drivers) {
    if (shortName == null) {
      return null;
    }
    final upper = shortName.toUpperCase();
    final exists = drivers.any((d) => d.shortName == upper);
    return exists ? upper : null;
  }

  static DropdownButtonFormField<String> _driverDropdown({
    required String label,
    required String? value,
    required List<F1Driver> drivers,
    required Set<String> excludedShortNames,
    required ValueChanged<String?> onChanged,
  }) {
    final items = drivers
        .where((d) => d.shortName == value || !excludedShortNames.contains(d.shortName))
        .map(
          (d) => DropdownMenuItem<String>(
            value: d.shortName,
            child: Text(d.displayLabel),
          ),
        )
        .toList();

    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: items,
      onChanged: onChanged,
      validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
      isExpanded: true,
    );
  }
}
