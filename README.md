# Index-Number-Weather-Dashboard

This project is a Flutter app. The instructions below explain how to build the Android mobile APKs locally.

Prerequisites

- Install Flutter and add it to your PATH: [Flutter install guide](https://docs.flutter.dev/get-started/install)
- Install Android SDK and configure ANDROID_HOME / local.properties

Quick build steps (Android)

1. Open a terminal and clone the repository (if you have not already):

```bash
git clone https://github.com/RandithaK/Index-Number-Weather-Dashboard.git
cd Index-Number-Weather-Dashboard/weather_dashboard
```

1. Install Flutter packages:

```bash
flutter pub get
```

1. Build Android APKs split by ABI (recommended for smaller APKs per architecture):

```bash
flutter build apk --split-per-abi
```

Notes

- The `--split-per-abi` command produces multiple APK files (one per CPU architecture), which reduces binary size for distribution.
- For release builds you can pass `--release` explicitly; by default `flutter build apk` produces a release build unless otherwise specified.
- If you intend to distribute via Google Play, consider building an Android App Bundle instead: `flutter build appbundle`.

Troubleshooting

- Make sure you have the correct Android SDK, NDK (if needed), and matching Gradle/AGP versions. If CI fails due to Android Gradle Plugin or Gradle version mismatches, update the gradle wrapper or AGP version in the android/ directory.
