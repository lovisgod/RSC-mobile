# Running Different Environments

The environment is selected by two flags that must always match:

- `--flavor` — picks the Android product flavor (app id, app name)
- `--dart-define=ENVIRONMENT=...` — picks the `AppConfig` (base URL,
  payment redirect URL)

Running without either flag defaults to **development** config (but no
Android flavor — always pass `--flavor` on Android).

## Development (default)
```sh
flutter run \
  --flavor development \
  --dart-define=ENVIRONMENT=development
```

## Staging (for QA)
```sh
flutter run \
  --flavor staging \
  --dart-define=ENVIRONMENT=staging
```

## Production
```sh
flutter run \
  --flavor production \
  --dart-define=ENVIRONMENT=production
```

## Build APK for QA (staging)
```sh
flutter build apk \
  --flavor staging \
  --dart-define=ENVIRONMENT=staging \
  --release
```

## Build APK for production
```sh
flutter build apk \
  --flavor production \
  --dart-define=ENVIRONMENT=production \
  --release
```

## Firebase note

`google-services.json` now lives in flavor-specific directories
(`android/app/src/development|staging|production/`), currently the same
file for all three (same Firebase project).

⚠️ The Firebase project only registers the app id `com.rsc.rsc_mobile`.
The development/staging copies of `google-services.json` contain a
duplicated client entry with the suffixed package name
(`com.rsc.rsc_mobile.dev` / `.staging`) so the build succeeds — this is a
workaround. The proper fix: add those two app ids to the Firebase project
(console → Project settings → Add app), download the refreshed
`google-services.json`, and replace the flavor copies with it. Until
then, some Firebase services (e.g. FCM token registration) may not work
on dev/staging builds.

## iOS

iOS schemes (`development`, `staging`, `production`) are configured to match
the flags above — the same `flutter run/build --flavor <name>` commands work
on iOS now. Bundle IDs: `com.rsc.rsc_mobile.dev` / `.staging` / (none) for
production, matching the Android application IDs and the Firebase project
registration.

Running without `--flavor` on iOS falls back to the original `Runner` scheme
(bundle id `com.rsc.rscMobile`) for backwards compatibility.
