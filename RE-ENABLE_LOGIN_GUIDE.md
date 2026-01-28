# How to Re-Enable Firebase Login

## Overview

Login functionality was temporarily disabled on January 22, 2026 to fix an iOS 26 beta crash. This guide explains how to restore full login functionality once Firebase/Google Sign-In SDKs are compatible with iOS 26.

---

## When to Re-Enable

Re-enable login when ONE of the following conditions is met:

1. **iOS 26 exits beta** - Apple releases stable iOS 26
2. **Firebase SDK update** - Firebase releases an update confirming iOS 26 support
3. **Google Sign-In SDK update** - Google releases an update for iOS 26
4. **flutter_secure_storage update** - Confirm v10.0.0+ works with iOS 26

---

## Step 1: Update pubspec.yaml

Open `pubspec.yaml` and **uncomment** these lines (around lines 33-37):

### Before (current - disabled):
```yaml
  # TEMPORARILY DISABLED FOR iOS 26 COMPATIBILITY - LOGIN WILL NOT WORK
  # firebase_core: ^3.15.2
  # firebase_auth: ^5.7.0
  # google_sign_in: ^6.3.0  # Stay on v6.x to avoid breaking API changes
  # sign_in_button: ^4.0.1
```

### After (re-enabled):
```yaml
  firebase_core: ^3.15.2
  firebase_auth: ^5.7.0
  google_sign_in: ^6.3.0
  sign_in_button: ^4.0.1
```

> **Note**: Check pub.dev for the latest versions before re-enabling. The versions above may be outdated.

---

## Step 2: Update main.dart

Open `lib/main.dart` and **uncomment** Firebase initialization:

### Before (current - disabled):
```dart
// TEMPORARILY DISABLED FOR iOS 26 - LOGIN WILL NOT WORK
// import 'package:firebase_core/firebase_core.dart';

// ...

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TEMPORARILY DISABLED FOR iOS 26 - LOGIN WILL NOT WORK
  // await Firebase.initializeApp();
```

### After (re-enabled):
```dart
import 'package:firebase_core/firebase_core.dart';

// ...

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
```

---

## Step 3: Restore login_screen.dart

The original `login_screen.dart` file was replaced with a placeholder. You need to restore it from git history.

Run this command in the project root:

```bash
git checkout fbc21a5 -- lib/screens/login_screen.dart
```

This restores the full login screen from the last working commit before it was disabled.

---

## Step 4: Update AppDelegate.swift

Open `ios/Runner/AppDelegate.swift` and **add Firebase initialization**:

### Before (current - disabled):
```swift
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### After (re-enabled):
```swift
import Flutter
import UIKit
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

## Step 5: Run Flutter Commands

```bash
# Get dependencies
flutter pub get

# Clean build cache
flutter clean

# For iOS, update pods
cd ios
pod deintegrate
pod install --repo-update
cd ..
```

---

## Step 6: Test on iOS 26

1. Build and deploy to TestFlight
2. Test on an iOS 26 device
3. Verify app launches without crashing
4. Test Google Sign-In
5. Test Phone Number verification

---

## Step 7: Update Version and Push

```bash
# Bump version in pubspec.yaml
# Example: version: 1.0.17+18

# Commit and push
git add -A
git commit -m "Re-enable Firebase login - iOS 26 now supported"
git push
```

---

## Troubleshooting

### If the app still crashes after re-enabling:

1. **Check Flutter version**: Run `flutter upgrade` to get latest Flutter
2. **Check package versions**: Update all packages to their latest versions
3. **Check Firebase Console**: Ensure iOS app is properly configured
4. **Check GoogleService-Info.plist**: Ensure it's properly added to Xcode project
5. **Check Podfile**: Ensure minimum iOS version is set to 15.0 or higher

### If Google Sign-In doesn't work:

1. Verify `REVERSED_CLIENT_ID` is in Info.plist
2. Check Firebase Console → Authentication → Sign-in method → Google is enabled
3. Verify OAuth consent screen is configured in Google Cloud Console

---

## Files Modified (For Reference)

| File | Change Type |
|------|-------------|
| `pubspec.yaml` | Uncomment Firebase packages |
| `lib/main.dart` | Uncomment Firebase import and init |
| `lib/screens/login_screen.dart` | Restore from git history |
| `ios/Runner/AppDelegate.swift` | Add FirebaseCore import and configure |

---

## Git Commits Reference

- **Last working login commit**: `fbc21a5` (Fix iOS 26 crash: upgrade flutter_secure_storage)
- **Login disabled commit**: `13996d5` (iOS 26 compatibility: disable Firebase/Google Sign-In)

To see the full login_screen.dart code:
```bash
git show fbc21a5:lib/screens/login_screen.dart
```

---

## Contact

If you need assistance re-enabling login, refer to this guide or contact your development team.

**Document Created**: January 22, 2026
**Last Updated**: January 22, 2026
