class RaceResult {
  final String raceId;
  final String p1DriverCode;
  final String p2DriverCode;
  final String p3DriverCode;
  final String fastestLapDriverCode;
  final int? dnfCount;

  const RaceResult({
    required this.raceId,
    required this.p1DriverCode,
    required this.p2DriverCode,
    required this.p3DriverCode,
    required this.fastestLapDriverCode,
    required this.dnfCount,
  });
}
