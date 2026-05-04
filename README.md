# Resume Builder (Flutter + Firebase)

Resume Builder is a Flutter app that collects resume/profile data through an onboarding flow and stores it in Firebase (Auth + Firestore). After onboarding, users can view and edit their profile.

## What’s included

- Email/password authentication (Firebase Auth)
- Multi-step onboarding form for profile details
- Firestore-backed profile storage with real-time updates
- Profile view + edit screens

## Tech stack

- Flutter (Dart)
- Firebase Auth (`firebase_auth`)
- Cloud Firestore (`cloud_firestore`)
- Firebase Core (`firebase_core`)

## Key files

- `lib/main.dart` — app entry + Firebase initialization + routing
- `lib/screens/auth/*` — login/signup UI
- `lib/screens/onboarding/onboarding_screen.dart` — onboarding flow
- `lib/screens/profile/*` — profile view + edit
- `lib/services/*` — Firebase Auth + Firestore helpers
- `lib/models/models.dart` — Firestore data models

## Getting started

### Prerequisites

- Flutter SDK installed (make sure `flutter doctor` is clean)
- A Firebase project with:
	- Authentication: Email/Password enabled
	- Firestore Database enabled

### 1) Install dependencies

```bash
flutter pub get
```

### 2) Create Firebase config (required)

This project expects `lib/firebase_options.dart` to exist locally.

To avoid committing credentials, `lib/firebase_options.dart` is **ignored by git**.

Recommended (generate via FlutterFire CLI):

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

If you can’t use FlutterFire right now, use the committed template:

- Copy `lib/firebase_options.example.dart` → `lib/firebase_options.dart`
- Replace the placeholders with your Firebase project values

### 3) Run the app

```bash
flutter run
```

### 4) Run tests (optional)

```bash
flutter test
```


