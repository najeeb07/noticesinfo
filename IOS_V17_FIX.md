# iOS Crash Fix - Version 1.0.17+18

## Problem
The app was crashing immediately on launch on iOS (Thread 0 Crashed: `swift_getObjectType`) with `EXC_BAD_ACCESS`. This persisted even after removing Firebase.

## Root Cause
The crash is caused by the **`flutter_secure_storage`** plugin (version 10.0.0). This plugin uses Swift and was causing a segmentation fault during the native initialization phase on some iOS versions, likely due to Keychain access issues or Swift runtime incompatibility in the current environment.

Since you had already removed Login and Firebase, this plugin was the remaining native component causing the instability.

## Solution Implemented
1. **Removed `flutter_secure_storage`** from `pubspec.yaml`.
2. **Updated `TranslationService`** to use `SharedPreferences` instead of secure storage for the Google Translate API key. Since the API key is hardcoded in `main.dart`, strictly secure storage is not critical for basic functionality, and `SharedPreferences` is much more stable.
3. **Bumped Version** to `1.0.17+18` for TestFlight submission.

## Next Steps
1. **Push Changes** to your repository.
2. **Rebuild in Codemagic**.
3. **Test** the new build on TestFlight.

The app should now launch successfully without the native crash.
