# TripSense Frontend

Flutter UI for TripSense — AI-powered travel places and suggestions.

## Getting Started

This project provides Login and Register screens wired into the app routes.

## Auth Screens

- Login: email, password
- Register: firstName, lastName, email, password

## Run Locally

```bash
flutter pub get
flutter run
```

## Backend Integration

Login is integrated to Spring at `http://localhost:8080/api/v1/auth/login`.
Register is integrated at `http://localhost:8080/api/v1/users/register`.
You can adjust the base URL/endpoints in `lib/services/auth_service.dart`.

On successful login, the app navigates to the Preferences page
(`PreferencesScreen` at route `/preferences`). If the backend returns a token
under `token`, `accessToken`, or `jwt`, it is stored in `SharedPreferences`
as `auth_token`.

### Preferences

- Categories available: Adventure, Beach, Cultural, Leisure, Nature, Romantic, Wildlife, Historical
- You can select multiple. Saving requires selecting at least one.
- "Skip for now" clears any saved categories and keeps you on the page.

### Submit to Backend

After completing Categories → Location → Dates → Distance & Budget, the app
POSTs your preferences to `http://localhost:8080/api/v1/preferences` with
payload:

```json
{
  "categories": ["Adventure", "Nature"],
  "locations": ["Colombo"],
  "startDate": "2026-01-10",
  "endDate": "2026-03-31",
  "maxDistanceKm": 25,
  "maxBudget": 50000.0
}
```

If logged in and a token is present, the request includes
`Authorization: Bearer <token>`.

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
