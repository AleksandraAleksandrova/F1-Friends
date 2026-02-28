# Firestore Data Model (Example)

This project uses Firestore as the primary backend datastore.

## Collections

### users/{uid}
- username: string
- email: string
- displayName: string?
- profileImageUrl: string?
- joinedLeagueIds: string[]
- createdAt: timestamp

### leagues/{leagueId}
- name: string
- joinCode: string (unique via Cloud Function guard)
- adminUserId: string
- seasonYear: number
- startRound: number
- endRound: number
- scoringLocked: bool (always true after creation)
- scoringRules: map
  - pointsP1Exact: number
  - pointsP2Exact: number
  - pointsP3Exact: number
  - pointsFastestLapExact: number
  - pointsDnfExact: number
  - pointsBonusAllPodiumExact: number
- createdAt: timestamp

### leagues/{leagueId}/members/{uid}
- userId: string
- username: string
- profileImageUrl: string?
- joinedAt: timestamp

### races/{raceId}
- seasonYear: number
- round: number
- raceName: string
- startTimeUtc: timestamp
- numberOfLaps: number
- expectedEndTimeUtc: timestamp
- externalRaceId: string

### raceResults/{raceId}
- status: string (pending | available | processed | failed)
- p1DriverCode: string
- p2DriverCode: string
- p3DriverCode: string
- fastestLapDriverCode: string
- dnfCount: number?
- sourcePayload: map
- fetchedAt: timestamp
- processedAt: timestamp?

### predictions/{raceId}_{uid}
Single prediction reused across all leagues.
- raceId: string
- userId: string
- p1DriverCode: string
- p2DriverCode: string
- p3DriverCode: string
- fastestLapDriverCode: string
- dnfCount: number?
- submittedAt: timestamp
- status: string (draft | submitted | locked)

### leagueScores/{leagueId}_{raceId}_{uid}
- leagueId: string
- raceId: string
- userId: string
- pointsTotal: number
- pointsBreakdown: map
- scoredAt: timestamp

### leagueTotals/{leagueId}_{uid}
- leagueId: string
- userId: string
- totalPoints: number
- updatedAt: timestamp

### notifications/{notificationId}
- userId: string
- raceId: string?
- leagueId: string?
- type: string (prediction_deadline_reminder)
- channel: string (push | local)
- scheduledFor: timestamp
- sentAt: timestamp?
- status: string
