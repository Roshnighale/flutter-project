# NoteFlow

A clean Flutter personal notes application built with Firebase Authentication, Cloud Firestore, and Provider.

## Features

- Email/password authentication
- Persistent authentication
- Create notes
- Real-time notes
- Edit notes
- Delete notes with confirmation
- User-specific notes
- Provider state management
- Light mode
- Dark mode
- Form validation
- Friendly Firebase error handling
- Loading states and duplicate-submission protection

## Tech Stack

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Provider

## Project Structure

```text
lib/
├── models/
│   └── note.dart
├── services/
│   ├── auth_service.dart
│   └── firestore_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── note_provider.dart
│   └── theme_provider.dart
├── theme/
│   └── app_theme.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── notes/
│   │   └── note_editor_screen.dart
│   └── settings/
│       └── settings_screen.dart
└── main.dart
```

## Firebase Setup

1. Create a Firebase project.
2. In Firebase Console, enable **Authentication → Sign-in method → Email/Password**.
3. Create a **Cloud Firestore** database.
4. Install FlutterFire CLI if needed.
5. From the project root, run:

```bash
flutterfire configure
```

6. This generates `lib/firebase_options.dart`.
7. Do not manually invent Firebase project values; use the generated file.
8. Publish the rules in `firestore.rules` to your Firestore database.
9. Run:

```bash
flutter pub get
flutter run
```

### Firebase CLI alternative

After installing/configuring the Firebase CLI:

```bash
firebase deploy --only firestore:rules
```

## Installation

```bash
flutter pub get
flutter run
```

## Screenshots

Replace the placeholders below with actual screenshots before GitHub 

## Security

Notes are stored at:

```text
users/{uid}/notes/{noteId}
```

The included Firestore rules require an authenticated user and ensure the UID in the path matches `request.auth.uid`. This prevents one user from reading or writing another user's notes.

Never use insecure rules such as:

```text
allow read, write: if true;
```

## Important Firebase Note

`firebase_options.dart` is generated for a specific Firebase project and is intentionally not included in this source package. Run `flutterfire configure` for your own Firebase project before running the app.

## Black-box Test Checklist

### Authentication

- Open app while logged out
- Try login with empty fields
- Try invalid login
- Create an account
- Login
- Close/reopen the app
- Verify the user remains logged in
- Logout
- Verify Home is inaccessible while logged out

### CRUD

- Create a note
- Verify it appears immediately
- Create multiple notes
- Edit a note
- Verify the changes
- Cancel a delete
- Confirm a delete
- Verify the list updates in real time

### Theme

- Switch Light → Dark
- Switch Dark → Light
- Navigate between screens
- Verify the active theme remains active
- Verify notes/authentication state is not lost

## GitHub Readiness

Before publishing:

- Add your screenshots
- Run `flutter analyze`
- Run `flutter test`
- Run the app through the black-box checklist
- Confirm no passwords or secret credentials are committed
- Configure Firebase for the repository/project being used
