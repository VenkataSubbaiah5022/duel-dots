# DuelDots

A simple online 2-player strategy board game where players take turns claiming dots on a 5×5 grid. The player with the highest score when the board fills up wins.

## Features (v1)

- Anonymous login
- Create / Join room with shareable room codes
- Real-time multiplayer gameplay via Firestore
- Win/Lose/Draw detection
- Player profile with stats
- Leaderboard ranked by wins

## Tech Stack

- **Flutter** + **Dart**
- **Riverpod** for state management
- **go_router** for navigation
- **Firebase** (Auth, Firestore, Analytics, Crashlytics)

## Getting Started

### Prerequisites

- Flutter SDK 3.38+
- Firebase project
- Android Studio / Xcode for device builds

### 1. Install dependencies

```bash
cd duel_dots
flutter pub get
```

### 2. Configure Firebase

Firebase config files are **not** in this repo (see `.gitignore`). Each developer generates them locally:

```bash
dart pub global activate flutterfire_cli
firebase login
flutterfire configure --project=dueldots-3f969 --platforms=android,ios -y --overwrite-firebase-options
```

> **Note:** Use the **Project ID** (`dueldots-3f969`), not the display name (`dueldots`). Run `firebase projects:list` to find yours.

This generates (gitignored, local only):
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Templates: `lib/firebase_options.dart.example`, `android/app/google-services.json.example`

### 3. Enable Firebase services

In the [Firebase Console](https://console.firebase.google.com):

1. **Authentication** → Sign-in method → Enable **Anonymous**
2. **Firestore** → Create database → Start in test mode, then deploy rules:

```bash
firebase deploy --only firestore:rules
```

3. **Analytics** and **Crashlytics** — enabled automatically

### 4. Firestore indexes

Create a composite index for the leaderboard query:

- Collection: `users`
- Fields: `wins` (Descending)

Firebase will prompt with a link when you first open the leaderboard.

### 5. Run the app

```bash
flutter run
```

## Project Structure

```
lib/
├── core/           # Theme, routing, constants, Firebase init
├── features/
│   ├── auth/       # Anonymous login, user profile
│   ├── home/       # Main dashboard
│   ├── room/       # Create/join/waiting room
│   ├── game/       # Board, moves, results
│   ├── leaderboard/
│   └── profile/
├── shared/         # Reusable widgets
└── main.dart
```

## Game Rules

- 5×5 grid, two players (Blue vs Red)
- Players alternate turns, tapping empty cells
- When the board is full, the player with more cells wins
- Ties are possible

## Build for Release

### Android (Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (App Store)

```bash
flutter build ipa --release
```

## Optional: App Icon & Splash

Add a 1024×1024 PNG at `assets/icon/app_icon.png`, then add to `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.3
  flutter_native_splash: ^2.4.5

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"

flutter_native_splash:
  color: "#1A237E"
  image: assets/icon/app_icon.png
```

Then run:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## License

Private project — all rights reserved.
