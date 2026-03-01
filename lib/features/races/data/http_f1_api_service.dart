import "dart:convert";

import "package:http/http.dart" as http;

import "../domain/race_result.dart";
import "../domain/race_weekend.dart";
import "f1_api_service.dart";

class HttpF1ApiService implements F1ApiService {
  HttpF1ApiService(this._client);

  final http.Client _client;
  static const _base = "https://f1api.dev/api";

  @override
  Future<RaceWeekend?> fetchNextRace() async {
    final jsonMap = await _getJson("$_base/current/next");
    final race = _extractSingleRaceFromRaceArrayResponse(jsonMap);
    if (race == null) {
      return null;
    }
    return _toRaceWeekend(race, (jsonMap["season"] as num?)?.toInt());
  }

  @override
  Future<RaceWeekend?> fetchLastRaceDetails() async {
    final jsonMap = await _getJson("$_base/current/last");
    final race = _extractSingleRaceFromRaceArrayResponse(jsonMap);
    if (race == null) {
      return null;
    }
    return _toRaceWeekend(race, (jsonMap["season"] as num?)?.toInt());
  }

  @override
  Future<LatestRaceSummary?> fetchLatestRaceResults() async {
    final jsonMap = await _getJson("$_base/current/last/race");
    final race = jsonMap["races"];
    if (race is! Map<String, dynamic>) {
      return null;
    }

    final season = (jsonMap["season"] as num?)?.toInt() ?? DateTime.now().year;
    final round = (race["round"] as num?)?.toInt() ?? 0;
    final raceName = (race["raceName"] as String?) ?? "Unknown race";
    final raceDate = race["date"] as String?;
    final raceTime = race["time"] as String?;
    final raceStartUtc = _parseDateTimeUtc(raceDate, raceTime) ?? DateTime.now().toUtc();

    final results = (race["results"] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    final top3 = results
        .where((r) => ((r["position"] as num?)?.toInt() ?? 999) <= 3)
        .toList()
      ..sort((a, b) => ((a["position"] as num?)?.toInt() ?? 999).compareTo((b["position"] as num?)?.toInt() ?? 999));

    final podium = top3.map((entry) {
      final driver = (entry["driver"] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
      final name = (driver["name"] as String?) ?? "";
      final surname = (driver["surname"] as String?) ?? "";
      return PodiumEntry(
        position: (entry["position"] as num?)?.toInt() ?? 0,
        driverId: (driver["driverId"] as String?) ?? "",
        shortName: (driver["shortName"] as String?) ?? "",
        fullName: "$name $surname".trim(),
      );
    }).toList();

    String? fastestLapDriverId;
    int dnfCount = 0;
    for (final row in results) {
      final fastLap = row["fastLap"];
      if (fastLap is String && fastLap.isNotEmpty) {
        final driver = (row["driver"] as Map?)?.cast<String, dynamic>();
        fastestLapDriverId = driver?["driverId"] as String?;
      }
      final retired = row["retired"];
      if (retired != null && retired.toString().trim().isNotEmpty) {
        dnfCount += 1;
      }
    }

    return LatestRaceSummary(
      seasonYear: season,
      round: round,
      raceName: raceName,
      raceStartUtc: raceStartUtc,
      podium: podium,
      fastestLapDriverId: fastestLapDriverId,
      dnfCount: dnfCount,
    );
  }

  @override
  Future<List<RaceWeekend>> fetchRacesBySeason(int year) async {
    final jsonMap = await _getJson("$_base/$year");
    final races = (jsonMap["races"] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return races
        .map((race) => _toRaceWeekend(race, year))
        .whereType<RaceWeekend>()
        .toList()
      ..sort((a, b) => a.round.compareTo(b.round));
  }

  @override
  Future<RaceResult?> fetchLatestRaceResultForScoring() async {
    final summary = await fetchLatestRaceResults();
    if (summary == null || summary.podium.length < 3) {
      return null;
    }
    return RaceResult(
      raceId: "${summary.seasonYear}_${summary.round}",
      p1DriverCode: summary.podium[0].shortName,
      p2DriverCode: summary.podium[1].shortName,
      p3DriverCode: summary.podium[2].shortName,
      fastestLapDriverCode: summary.fastestLapDriverId ?? "",
      dnfCount: summary.dnfCount,
    );
  }

  @override
  Future<List<F1Driver>> fetchCurrentDrivers() async {
    final jsonMap = await _getJson("$_base/current/drivers");
    final drivers = (jsonMap["drivers"] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    final mapped = drivers
        .map(
          (d) => F1Driver(
            driverId: (d["driverId"] as String?) ?? "",
            shortName: ((d["shortName"] as String?) ?? "").toUpperCase(),
            name: (d["name"] as String?) ?? "",
            surname: (d["surname"] as String?) ?? "",
            teamId: (d["teamId"] as String?) ?? "",
          ),
        )
        .where((d) => d.shortName.isNotEmpty)
        .toList()
      ..sort((a, b) => a.shortName.compareTo(b.shortName));
    return mapped;
  }

  Future<Map<String, dynamic>> _getJson(String url) async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError("F1 API request failed (${response.statusCode}) for $url");
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw StateError("Unexpected F1 API response shape.");
    }
    return decoded;
  }

  Map<String, dynamic>? _extractSingleRaceFromRaceArrayResponse(Map<String, dynamic> jsonMap) {
    final raceArray = jsonMap["race"];
    if (raceArray is! List || raceArray.isEmpty) {
      return null;
    }
    final first = raceArray.first;
    if (first is! Map<String, dynamic>) {
      return null;
    }
    return first;
  }

  RaceWeekend? _toRaceWeekend(Map<String, dynamic> race, int? seasonYearFromResponse) {
    final schedule = (race["schedule"] as Map?)?.cast<String, dynamic>();
    final raceSchedule = (schedule?["race"] as Map?)?.cast<String, dynamic>();
    final date = raceSchedule?["date"] as String?;
    final time = raceSchedule?["time"] as String?;
    final startTimeUtc = _parseDateTimeUtc(date, time);
    if (startTimeUtc == null) {
      return null;
    }

    return RaceWeekend(
      id: (race["raceId"] as String?) ?? "unknown_race",
      seasonYear: seasonYearFromResponse ?? DateTime.now().year,
      round: (race["round"] as num?)?.toInt() ?? 0,
      raceName: (race["raceName"] as String?) ?? "Unknown race",
      startTimeUtc: startTimeUtc,
      numberOfLaps: (race["laps"] as num?)?.toInt() ?? 0,
      qualifyingStartUtc: _parseDateTimeUtc(
        (schedule?["qualy"] as Map?)?["date"] as String?,
        (schedule?["qualy"] as Map?)?["time"] as String?,
      ),
    );
  }

  DateTime? _parseDateTimeUtc(String? date, String? time) {
    if (date == null || time == null || date.isEmpty || time.isEmpty) {
      return null;
    }
    return DateTime.tryParse("${date}T$time")?.toUtc();
  }
}
