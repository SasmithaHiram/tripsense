# TripSense Frontend

Flutter UI for TripSense — AI-powered travel places and suggestions.

## Getting Started

This project provides Login and Register screens wired into the app routes.

## Auth Screens

- Login: email, password
- Register: role, firstName, lastName, email, password

## Run Locally

```bash
flutter pub get
flutter run
```

## Backend Integration

Login is integrated to Spring at `http://localhost:8080/api/v1/auth/login`.
You can adjust the base URL/endpoints in `lib/services/auth_service.dart`.

On successful login, the app navigates to the Preferences page
(`PreferencesScreen` at route `/preferences`). If the backend returns a token
under `token`, `accessToken`, or `jwt`, it is stored in `SharedPreferences`
as `auth_token`.

### Windows note (plugins)

If you see an error about symlink support when adding or using plugins
(`shared_preferences`), enable Developer Mode:

```powershell
start ms-settings:developers
```

Then restart VS Code or your terminal and run `flutter pub get` again.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
