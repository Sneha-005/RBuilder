# Resume Builder (Flutter + Firebase)

A Flutter app with Firebase-powered authentication and onboarding to collect profile/resume data.

## Features

- Email/Password auth 
- Multi-step onboarding flow
- Firestore-backed profile storage + edits

## Prerequisites

- Flutter SDK installed (`flutter doctor` is clean)
- A Firebase project (Authentication + Firestore enabled)

Optional (recommended): FlutterFire CLI for generating Firebase config

```bash
dart pub global activate flutterfire_cli
```

## Setup

### 1) Install dependencies

```bash
flutter pub get
```

### 2) Generate Firebase configuration (required)

This project expects `lib/firebase_options.dart` to exist locally.

`lib/firebase_options.dart` is **ignored by git** to avoid committing credentials.

Generate it via FlutterFire:

```bash
flutterfire configure
```

If you can’t use FlutterFire right now, use the committed template:

- Copy `lib/firebase_options.example.dart` → `lib/firebase_options.dart`
- Replace placeholders with your Firebase project values

### 3) Run

```bash
flutter run
```

## Useful Docs

- Quick setup walkthrough: `QUICK_START.md`
- Full file map/reference: `QUICK_REFERENCE.md`
- Project summary/notes: `SUMMARY.md`

## Troubleshooting

- Firebase init fails: re-run `flutterfire configure` and confirm `lib/firebase_options.dart` exists
- Google Sign-In fails: verify OAuth settings and (Android) SHA-1 in Firebase Console
- Firestore permission denied: check your Firestore rules
