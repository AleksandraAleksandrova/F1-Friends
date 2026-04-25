# F1 Friends

Mobile-first Formula 1 prediction app for private friend leagues, built with Flutter and Firebase.

## Stack
- Flutter
- Riverpod
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Cloud Messaging

## Current Features
- Email/password authentication
- Login with email or username
- Password reset by email
- Private leagues with join code
- League member leaderboard
- Race weekends and latest result data from `f1api.dev`
- One prediction per user per race
- Prediction lock after estimated qualifying end
- Mock scoring flow for demos/presentations
- Profile username editing
- Profile image upload from gallery/camera
- In-app language selection
- English and French localization

## Project Structure
- `lib/features/*/domain`
  - app models and entities
- `lib/features/*/data`
  - data services and integrations
- `lib/features/*/providers`
  - Riverpod state and controllers
- `lib/features/*/presentation`
  - screens and widgets
- `lib/core`
  - shared constants, UI helpers, notifications, utilities
- `lib/l10n`
  - localization files and generated translations

## Local Setup
1. Open a terminal in:
   - `C:\Users\Admin\Desktop\uni\3-2\pmu\F1-Friends`
2. Install dependencies:
   - `flutter pub get`
3. Ensure Firebase Android config exists:
   - `android/app/google-services.json`
4. Publish Firestore rules from:
   - `firestore.rules`
5. Run the app:
   - `flutter run`

## Useful Commands
- Analyze:
  - `flutter analyze`
- Debug build:
  - `flutter build apk --debug`
- Clean rebuild:
  - `flutter clean`
  - `flutter pub get`
  - `flutter run`

## Firestore Notes
- Username login depends on the `usernames` collection/index.
- League membership uses `leagues/{leagueId}/members/{uid}` as the main source of truth.
- Current rules are shaped for the active mobile app flow and demo scoring support.

## Recommended Next Backend Step
- Move scoring and scheduled result evaluation fully into Cloud Functions so score updates become server-authoritative.
