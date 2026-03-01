import "../domain/race_result.dart";
import "../domain/race_weekend.dart";

class F1Driver {
  final String driverId;
  final String shortName;
  final String name;
  final String surname;
  final String teamId;

  const F1Driver({
    required this.driverId,
    required this.shortName,
    required this.name,
    required this.surname,
    required this.teamId,
  });

  String get displayLabel => "$shortName - $name $surname";
}

class LatestRaceSummary {
  final int seasonYear;
  final int round;
  final String raceName;
  final DateTime raceStartUtc;
  final List<PodiumEntry> podium;
  final String? fastestLapDriverId;
  final int? dnfCount;

  const LatestRaceSummary({
    required this.seasonYear,
    required this.round,
    required this.raceName,
    required this.raceStartUtc,
    required this.podium,
    required this.fastestLapDriverId,
    required this.dnfCount,
  });
}

class PodiumEntry {
  final int position;
  final String driverId;
  final String shortName;
  final String fullName;

  const PodiumEntry({
    required this.position,
    required this.driverId,
    required this.shortName,
    required this.fullName,
  });
}

class RaceHubData {
  final RaceWeekend? nextRace;
  final RaceWeekend? lastRace;
  final LatestRaceSummary? latestResults;
  final List<RaceWeekend> seasonRaces;

  const RaceHubData({
    required this.nextRace,
    required this.lastRace,
    required this.latestResults,
    required this.seasonRaces,
  });
}

abstract class F1ApiService {
  Future<RaceWeekend?> fetchNextRace();

  Future<RaceWeekend?> fetchLastRaceDetails();

  Future<LatestRaceSummary?> fetchLatestRaceResults();

  Future<List<RaceWeekend>> fetchRacesBySeason(int year);

  Future<RaceResult?> fetchLatestRaceResultForScoring();

  Future<List<F1Driver>> fetchCurrentDrivers();
}
