# iOS Build Instructions - NoticesInfo App

## Prerequisites
- macOS with Xcode 14.0 or later installed
- iOS deployment target: **iOS 15.0+**
- Flutter SDK installed
- CocoaPods installed

## Step-by-Step Build Instructions

### 1. Navigate to Project
```bash
cd /path/to/noticesinfo
```

### 2. Clean Previous Build Artifacts
```bash
# Clean iOS build artifacts
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf ios/.symlinks
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/Flutter.podspec

# Clean Flutter
flutter clean
```

### 3. Get Flutter Dependencies
```bash
flutter pub get
```

### 4. Update CocoaPods Repository
```bash
# This may take a few minutes
pod repo update
```

### 5. Install iOS Pods
```bash
cd ios
pod install --repo-update
cd ..
```

**Note:** You will see "detached HEAD" warnings during pod install - **this is normal and safe to ignore**.

### 6. Build for iOS

#### Option A: Build IPA for Distribution
```bash
flutter build ios --release
```

Then open in Xcode to archive:
```bash
open ios/Runner.xcworkspace
```

In Xcode:
1. Select **Product** → **Archive**
2. Once archived, click **Distribute App**
3. Follow the wizard to create your IPA

#### Option B: Build for Testing on Device
```bash
flutter build ios --debug
open ios/Runner.xcworkspace
```

Then run from Xcode on your connected device.

## Common Issues & Solutions

### Issue: "CocoaPods could not find compatible versions"
**Solution:** Make sure you've run `flutter clean` and `pod repo update` before `pod install`

### Issue: "Firebase requires higher deployment target"
**Solution:** Already fixed in Podfile - iOS 15.0 is set

### Issue: Build fails in Xcode
**Solution:** 
1. Make sure to open `Runner.xcworkspace` (NOT `Runner.xcodeproj`)
2. Clean build folder in Xcode: **Product** → **Clean Build Folder**
3. Try building again

## Package Versions
- **firebase_core**: 4.3.0
- **firebase_auth**: 6.1.3 (requires iOS 15.0+)
- **google_sign_in**: 6.2.2
- **iOS Deployment Target**: 15.0

## Firebase Configuration
Make sure you have:
- `ios/Runner/GoogleService-Info.plist` properly configured
- Firebase project set up in Firebase Console

## Questions?
If you encounter any issues, check the error message carefully and ensure:
1. All dependencies are up to date
2. Xcode is version 14.0+
3. You're opening the `.xcworkspace` file, not `.xcodeproj`
