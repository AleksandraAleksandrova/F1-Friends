class RaceWeekend {
  final String id;
  final int seasonYear;
  final int round;
  final String raceName;
  final DateTime startTimeUtc;
  final int numberOfLaps;
  final DateTime? qualifyingStartUtc;

  const RaceWeekend({
    required this.id,
    required this.seasonYear,
    required this.round,
    required this.raceName,
    required this.startTimeUtc,
    required this.numberOfLaps,
    required this.qualifyingStartUtc,
  });

  DateTime get expectedEndTimeUtc =>
      startTimeUtc.add(Duration(seconds: numberOfLaps * 90));
}
