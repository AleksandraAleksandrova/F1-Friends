import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:http/http.dart" as http;

import "../data/f1_api_service.dart";
import "../data/http_f1_api_service.dart";

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
  final seasonYear = DateTime.now().year;

  final nextRaceFuture = api.fetchNextRace();
  final lastRaceFuture = api.fetchLastRaceDetails();
  final latestResultsFuture = api.fetchLatestRaceResults();
  final seasonRacesFuture = api.fetchRacesBySeason(seasonYear);

  final nextRace = await nextRaceFuture;
  final lastRace = await lastRaceFuture;
  final latestResults = await latestResultsFuture;
  final seasonRaces = await seasonRacesFuture;

  return RaceHubData(
    nextRace: nextRace,
    lastRace: lastRace,
    latestResults: latestResults,
    seasonRaces: seasonRaces,
  );
});
