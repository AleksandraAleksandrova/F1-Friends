# Architecture Overview

## Goal
F1 Friends is structured as a mobile-first Flutter application with Firebase as the only backend platform. The architecture favors:
- clear feature boundaries
- minimal UI business logic
- simple deployment
- easy documentation for academic presentation

## Feature Slices
Each feature follows the same layout:
- `domain`
  - entities and plain models
- `data`
  - repository/service contracts and Firebase/API implementations
- `providers`
  - Riverpod providers and controllers
- `presentation`
  - screens, dialogs, and feature widgets

## Shared Layers
- `lib/core/constants`
  - shared Firestore paths
- `lib/core/widgets`
  - reusable UI controls
- `lib/core/notifications`
  - local notification integration
- `lib/core/utils`
  - shared helpers such as error-to-text mapping
- `lib/l10n`
  - app translations

## Main Data Relationships
- `users/{uid}`
  - user profile, username, language, image URL
- `usernames/{usernameLower}`
  - username lookup index for login
- `leagues/{leagueId}`
  - league metadata and scoring rules
- `leagues/{leagueId}/members/{uid}`
  - member role, points, score breakdown
- `predictions/{raceId}_{uid}`
  - one prediction per user per race

## State Management
Riverpod is used for:
- auth state
- current user profile
- league streams
- race API data
- prediction CRUD
- mock scoring actions

## Localization
The app uses Flutter `gen-l10n`.
Currently supported:
- English
- French

Language preference is stored in Firestore per user and applied at app level.

## Current Tradeoffs
- Mock scoring remains client-triggered for presentation/demo use.
- Some score-related writes are still more permissive than a strict production system would allow.
- A future production-hardening step should move scoring and scheduled evaluation into Cloud Functions.
