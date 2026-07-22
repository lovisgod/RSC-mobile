# iOS Flavor Setup Required

Android flavors are fully configured in Gradle, but iOS schemes must be
created manually in Xcode.

Open Xcode → `ios/Runner.xcworkspace`

Create 3 schemes (each paired with matching build configurations):

1. **development**
   - Bundle ID: `com.rsc.rsc_mobile.dev`
   - Display Name: RSC Dev

2. **staging**
   - Bundle ID: `com.rsc.rsc_mobile.staging`
   - Display Name: RSC Staging

3. **production**
   - Bundle ID: `com.rsc.rsc_mobile`
   - Display Name: RSC

Each scheme is selected by `flutter run/build --flavor <name>`, and the
environment is passed with
`--dart-define=ENVIRONMENT=development|staging|production`.

For now iOS uses the `defaultValue: 'development'` from `AppConfig`
until schemes are configured in Xcode — running without `--flavor` and
without `--dart-define` targets the development API.
