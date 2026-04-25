import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:http/http.dart" as http;

import "../data/f1_api_service.dart";
import "../domain/race_result.dart";
import "../data/http_f1_api_service.dart";
import "../domain/race_weekend.dart";

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final f1ApiServiceProvider = Provider<F1ApiService>((ref) {
  final client = ref.watch(httpClientProvider);
  return HttpF1ApiService(client);
});

final raceHubProvider = FutureProvider<RaceHubData>((ref) async {
  final api = ref.watch(f1ApiServiceProvider);
  final seasonYear = await _resolveBestSeasonYear(api);

  final nextRace = await _safeCall(() => api.fetchNextRace());
  final lastRace = await _safeCall(() => api.fetchLastRaceDetails());
  final latestResults = await _safeCall(() => api.fetchLatestRaceResults());
  final seasonRaces = await _safeCall(() => api.fetchRacesBySeason(seasonYear)) ?? const <RaceWeekend>[];

  return RaceHubData(
    nextRace: nextRace,
    lastRace: lastRace,
    latestResults: latestResults,
    seasonRaces: seasonRaces,
  );
});

final currentDriversProvider = FutureProvider<List<F1Driver>>((ref) async {
  final api = ref.watch(f1ApiServiceProvider);
  return api.fetchCurrentDrivers();
});

final racesBySeasonProvider = FutureProvider.family<List<RaceWeekend>, int>((ref, seasonYear) async {
  final api = ref.watch(f1ApiServiceProvider);
  return api.fetchRacesBySeason(seasonYear);
});

final officialRaceResultProvider = FutureProvider.family<RaceResult?, RaceWeekend>((ref, race) async {
  final api = ref.watch(f1ApiServiceProvider);
  return api.fetchRaceResultForRound(
    seasonYear: race.seasonYear,
    round: race.round,
    raceId: race.id,
  );
});

Future<T?> _safeCall<T>(Future<T> Function() action) async {
  try {
    return await action();
  } catch (_) {
    return null;
  }
}

Future<int> _resolveBestSeasonYear(F1ApiService api) async {
  final currentYear = DateTime.now().year;
  final candidateYears = <int>[
    currentYear,
    currentYear - 1,
    currentYear + 1,
  ];

  for (final year in candidateYears) {
    try {
      final races = await api.fetchRacesBySeason(year);
      if (races.isNotEmpty) {
        return year;
      }
    } catch (_) {
      // Try the next season candidate.
    }
  }

  return currentYear;
}
