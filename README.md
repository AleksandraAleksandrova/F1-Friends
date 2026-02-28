# F1 Friends (Flutter + Firebase)

New project root: `pmu/F1-Friends`

This project is intentionally separate from `pmu/F1-Fan`.

## Stack
- Frontend: Flutter (Android target)
- State management: Riverpod
- Backend: Firebase only
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Storage
  - Firebase Cloud Messaging

## Why this stack fits this project
- Mobile development: Flutter gives fast Android iteration and clean UI architecture.
- OS feature integration: camera/gallery and push notifications are first-class via Flutter plugins.
- Simpler deployment: Firebase removes server hosting and database operations overhead.
- University constraints: faster delivery, clear architecture, lower infrastructure complexity.

## Architecture
- `features/*/domain`: pure models
- `features/*/data`: service contracts/implementations
- `features/*/providers`: state management and controllers
- `features/*/presentation`: UI screens/widgets
- `services/`: cross-feature platform services (storage, notifications)
- `docs/firebase/`: Firestore schema and scheduled scoring design

## Implemented now
- Main app entry with Firebase initialization
- Working Auth screen (email/password sign in + register + sign out)
- Auth service abstraction and Firebase implementation
- Core data model files for users, leagues, predictions, races, scoring
- Firebase config placeholders
- Firestore schema and scheduling design docs

## Android setup
1. Install Flutter SDK and Android Studio.
2. In project root, run:
   - `flutter pub get`
3. Configure Firebase Android app and download `google-services.json`.
4. Place `google-services.json` in `android/app/`.
5. Replace `lib/firebase/firebase_config.dart` values using FlutterFire CLI output.
6. Run emulator and start app:
   - `flutter run`

## Firestore rules deployment (required)
Leagues screen requires Firestore security rules in this repo.

1. Install Firebase CLI and login:
   - `npm i -g firebase-tools`
   - `firebase login`
2. In project root:
   - `firebase use <your-firebase-project-id>`
   - `firebase deploy --only firestore:rules`

If rules are not deployed, league reads/writes fail with:
- `[cloud/firestore/permission-denied]`

## Next steps
- Implement league creation/join flows with Firestore transactions.
- Implement prediction submission and deadline lock logic.
- Add Cloud Functions for scheduled result polling and scoring.
- Add profile image upload UI using camera/gallery.
- Add FCM token registration + deadline reminder dispatch.
