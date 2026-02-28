# Result Polling and Scoring Schedule (Firebase)

Because the F1 API has no webhook, use scheduled Cloud Functions.

## Job flow
1. A scheduled function runs every 5 minutes.
2. It finds races where `expectedEndTimeUtc <= now` and `raceResults.status == pending`.
3. It calls F1 API results endpoint.
4. If result is non-null and non-empty:
   - Write `raceResults/{raceId}` as `available`.
   - Run scoring transaction for each league containing that race round.
   - Update `leagueScores` and `leagueTotals`.
   - Mark `raceResults.status = processed`.
5. If result is empty, keep `pending` and retry next schedule tick.

## Notification flow
1. Another scheduled function runs hourly.
2. It identifies upcoming race deadlines (e.g., 24h before qualifying).
3. It creates notification jobs in Firestore and sends FCM to active tokens.

## Notes
- Keep scoring idempotent by writing deterministic doc IDs:
  - `leagueScores/{leagueId}_{raceId}_{uid}`
  - `leagueTotals/{leagueId}_{uid}`
- Use Firestore transactions or batched writes for consistency.
