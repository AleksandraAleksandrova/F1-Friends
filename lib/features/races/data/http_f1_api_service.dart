import "dart:async";
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
    final seasonYear = DateTime.now().year;
    final races = await fetchRacesBySeason(seasonYear);
    final now = DateTime.now().toUtc();
    for (final race in races) {
      if (race.startTimeUtc.isAfter(now)) {
        return race;
      }
    }
    return races.isEmpty ? null : races.first;
  }

  @override
  Future<RaceWeekend?> fetchLastRaceDetails() async {
    final seasonYear = DateTime.now().year;
    final races = await fetchRacesBySeason(seasonYear);
    final now = DateTime.now().toUtc();

    RaceWeekend? latestPastRace;
    for (final race in races) {
      if (!race.startTimeUtc.isAfter(now)) {
        latestPastRace = race;
      }
    }
    return latestPastRace ?? (races.isEmpty ? null : races.last);
  }

  @override
  Future<LatestRaceSummary?> fetchLatestRaceResults() async {
    try {
      final jsonMap = await _getJson("$_base/current/last/race");
      return _latestRaceSummaryFromCurrentLastRace(jsonMap);
    } catch (_) {
      final lastRace = await fetchLastRaceDetails();
      if (lastRace == null) {
        return null;
      }
      try {
        final jsonMap = await _getJson("$_base/${lastRace.seasonYear}/${lastRace.round}/race");
        return _latestRaceSummaryFromRoundRace(
          jsonMap: jsonMap,
          fallbackSeasonYear: lastRace.seasonYear,
          fallbackRound: lastRace.round,
          fallbackRace: lastRace,
        );
      } catch (_) {
        return null;
      }
    }
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
  Future<RaceResult?> fetchRaceResultForRound({
    required int seasonYear,
    required int round,
    required String raceId,
  }) async {
    try {
      final jsonMap = await _getJson("$_base/$seasonYear/$round/race");
      final summary = _latestRaceSummaryFromRoundRace(
        jsonMap: jsonMap,
        fallbackSeasonYear: seasonYear,
        fallbackRound: round,
        fallbackRace: null,
      );
      if (summary == null || summary.podium.length < 3) {
        return null;
      }
      return RaceResult(
        raceId: raceId,
        p1DriverCode: summary.podium[0].shortName,
        p2DriverCode: summary.podium[1].shortName,
        p3DriverCode: summary.podium[2].shortName,
        fastestLapDriverCode: summary.fastestLapDriverId ?? "",
        dnfCount: summary.dnfCount,
      );
    } catch (_) {
      return null;
    }
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
    Object? lastError;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final response = await _client.get(Uri.parse(url)).timeout(const Duration(seconds: 12));
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw StateError("F1 API request failed (${response.statusCode}) for $url");
        }
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw StateError("Unexpected F1 API response shape.");
        }
        return decoded;
      } catch (error) {
        lastError = error;
      }
    }

    if (lastError is TimeoutException) {
      throw StateError("F1 API request timed out.");
    }
    if (lastError != null) {
      throw lastError;
    }
    throw StateError("F1 API request failed.");
  }

  RaceWeekend? _toRaceWeekend(Map<String, dynamic> race, int? seasonYearFromResponse) {
    final schedule = (race["schedule"] as Map?)?.cast<String, dynamic>();
    final raceSchedule = (schedule?["race"] as Map?)?.cast<String, dynamic>();
    final circuit = (race["circuit"] as Map?)?.cast<String, dynamic>();
    final date = raceSchedule?["date"] as String?;
    final time = raceSchedule?["time"] as String?;
    final startTimeUtc = _parseDateTimeUtc(date, time);
    if (startTimeUtc == null) {
      return null;
    }

    return RaceWeekend(
      id: (race["raceId"] as String?) ?? "unknown_race",
      seasonYear: seasonYearFromResponse ?? DateTime.now().year,
      round: _asInt(race["round"]) ?? 0,
      raceName: (race["raceName"] as String?) ?? "Unknown race",
      circuitId: (circuit?["circuitId"] as String?) ?? "",
      circuitName: (circuit?["circuitName"] as String?) ?? "",
      country: (circuit?["country"] as String?) ?? "",
      city: (circuit?["city"] as String?) ?? "",
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

  LatestRaceSummary? _latestRaceSummaryFromCurrentLastRace(Map<String, dynamic> jsonMap) {
    final race = jsonMap["races"];
    if (race is! Map<String, dynamic>) {
      return null;
    }
    return _latestRaceSummaryFromRaceMap(
      race,
      fallbackSeasonYear: _asInt(jsonMap["season"]) ?? DateTime.now().year,
      fallbackRound: _asInt(race["round"]) ?? 0,
      fallbackRace: null,
    );
  }

  LatestRaceSummary? _latestRaceSummaryFromRoundRace({
    required Map<String, dynamic> jsonMap,
    required int fallbackSeasonYear,
    required int fallbackRound,
    required RaceWeekend? fallbackRace,
  }) {
    final race = jsonMap["races"] ?? jsonMap["race"];
    if (race is! Map<String, dynamic>) {
      return null;
    }
    return _latestRaceSummaryFromRaceMap(
      race,
      fallbackSeasonYear: fallbackSeasonYear,
      fallbackRound: fallbackRound,
      fallbackRace: fallbackRace,
    );
  }

  LatestRaceSummary? _latestRaceSummaryFromRaceMap(
    Map<String, dynamic> race, {
    required int fallbackSeasonYear,
    required int fallbackRound,
    required RaceWeekend? fallbackRace,
  }) {
    final results = (race["results"] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    if (results.isEmpty) {
      return null;
    }

    final season = _asInt(race["season"]) ?? fallbackSeasonYear;
    final round = _asInt(race["round"]) ?? fallbackRound;
    final raceName = (race["raceName"] as String?) ?? fallbackRace?.raceName ?? "Unknown race";

    final raceDate = race["date"] as String?;
    final raceTime = race["time"] as String?;
    final raceStartUtc = _parseDateTimeUtc(raceDate, raceTime) ?? fallbackRace?.startTimeUtc ?? DateTime.now().toUtc();

    final top3 = results
        .where((r) => (_asInt(r["position"]) ?? 999) <= 3)
        .toList()
      ..sort((a, b) => (_asInt(a["position"]) ?? 999).compareTo(_asInt(b["position"]) ?? 999));

    final podium = top3.map((entry) {
      final driver = (entry["driver"] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
      final name = (driver["name"] as String?) ?? "";
      final surname = (driver["surname"] as String?) ?? "";
      return PodiumEntry(
        position: _asInt(entry["position"]) ?? 0,
        driverId: (driver["driverId"] as String?) ?? "",
        shortName: ((driver["shortName"] as String?) ?? "").toUpperCase(),
        fullName: "$name $surname".trim(),
      );
    }).toList();

    String? fastestLapDriverCode;
    Duration? bestFastLapDuration;
    int dnfCount = 0;
    for (final row in results) {
      final fastLap = row["fastLap"];
      final fastLapDuration = _parseLapDuration(fastLap as String?);
      if (fastLapDuration != null &&
          (bestFastLapDuration == null || fastLapDuration < bestFastLapDuration)) {
        bestFastLapDuration = fastLapDuration;
        final driver = (row["driver"] as Map?)?.cast<String, dynamic>();
        fastestLapDriverCode = (driver?["shortName"] as String?)?.toUpperCase();
      }
      final retired = row["retired"];
      if (retired != null && retired.toString().trim().isNotEmpty) {
        dnfCount += 1;
      }
    }

    fastestLapDriverCode ??= _resolveFastestLapDriverCode(race, results);

    return LatestRaceSummary(
      seasonYear: season,
      round: round,
      raceName: raceName,
      raceStartUtc: raceStartUtc,
      podium: podium,
      fastestLapDriverId: fastestLapDriverCode,
      dnfCount: dnfCount,
    );
  }

  String? _resolveFastestLapDriverCode(
    Map<String, dynamic> race,
    List<Map<String, dynamic>> results,
  ) {
    final fastLap = (race["fast_lap"] as Map?)?.cast<String, dynamic>();
    final fastestLapDriverId = fastLap?["fast_lap_driver_id"] as String?;
    if (fastestLapDriverId == null || fastestLapDriverId.isEmpty) {
      return null;
    }

    for (final row in results) {
      final driver = (row["driver"] as Map?)?.cast<String, dynamic>();
      if ((driver?["driverId"] as String?) == fastestLapDriverId) {
        return (driver?["shortName"] as String?)?.toUpperCase();
      }
    }

    return null;
  }

  int? _asInt(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }

  Duration? _parseLapDuration(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final minutesSeconds = trimmed.split(":");
    if (minutesSeconds.length != 2) {
      return null;
    }

    final minutes = int.tryParse(minutesSeconds[0]);
    final secondParts = minutesSeconds[1].split(".");
    if (minutes == null || secondParts.length != 2) {
      return null;
    }

    final seconds = int.tryParse(secondParts[0]);
    final millis = int.tryParse(secondParts[1].padRight(3, "0").substring(0, 3));
    if (seconds == null || millis == null) {
      return null;
    }

    return Duration(minutes: minutes, seconds: seconds, milliseconds: millis);
  }
}
