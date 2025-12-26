# Codemagic CI/CD Setup for NoticesInfo App

## 🚀 Quick Setup Guide

### Step 1: Push Your Code to GitHub
Make sure all the latest changes are committed and pushed:
```bash
git add .
git commit -m "Updated to iOS 15.0 and fixed dependencies"
git push origin main
```

### Step 2: Configure Codemagic

1. **Go to [Codemagic](https://codemagic.io/)** and sign in
2. **Connect your GitHub repository**
3. **Select your repository**: `noticesinfo`

### Step 3: Configure Build Settings

#### Option A: Using codemagic.yaml (Recommended)
The `codemagic.yaml` file has been created in your project root. You need to:

1. **Edit the file and update these values:**
   ```yaml
   bundle_identifier: com.yourcompany.noticesinfo  # Line 10
   PACKAGE_NAME: "com.yourcompany.noticesinfo"     # Line 47
   recipients: your-email@example.com              # Lines 34, 73
   ```

2. **In Codemagic Dashboard:**
   - Click on your app
   - Go to **Settings** → **Build configuration**
   - Select **"codemagic.yaml"** as the configuration source

#### Option B: Using Codemagic UI
If you prefer the UI instead of YAML:

1. **iOS Settings:**
   - Xcode version: **15.0 or later**
   - CocoaPods: **Default**
   - Flutter channel: **Stable**
   - iOS deployment target: **15.0**

2. **Build Script:**
   ```bash
   flutter pub get
   cd ios && pod install && cd ..
   flutter build ipa --release
   ```

### Step 4: Code Signing (iOS)

You need to configure code signing in Codemagic:

1. **Go to your app settings in Codemagic**
2. **Navigate to Code signing**
3. **Add iOS code signing certificate and provisioning profile**

**Two Options:**

#### A. Automatic Code Signing (Easier)
1. Connect to App Store Connect API
2. Codemagic will handle certificates automatically
3. **You need:**
   - App Store Connect API Key
   - Key ID
   - Issuer ID

#### B. Manual Code Signing
1. Export your certificates from Xcode
2. Upload to Codemagic
3. Upload provisioning profiles

### Step 5: Environment Variables

Add these in Codemagic → **Environment variables**:

For iOS (if using App Store Connect):
- `APP_STORE_CONNECT_PRIVATE_KEY`
- `APP_STORE_CONNECT_KEY_IDENTIFIER`
- `APP_STORE_CONNECT_ISSUER_ID`

### Step 6: Build Configuration

#### Firebase Setup
Make sure you have:
- ✅ `ios/Runner/GoogleService-Info.plist`
- ✅ Properly configured in Firebase Console

#### Verify Files
Before building, ensure these files exist:
- ✅ `ios/Podfile` (iOS 15.0 set)
- ✅ `ios/exportOptions.plist` (Team ID configured)
- ✅ `pubspec.yaml` (correct versions)
- ✅ `codemagic.yaml` (properly configured)

### Step 7: Trigger Build

1. **Push your changes to GitHub**
2. **In Codemagic, click "Start new build"**
3. **Select the workflow:**
   - For iOS: `ios-workflow`
   - For Android: `android-workflow`
4. **Click "Start build"**

### Step 8: Download IPA

Once the build succeeds:
1. Go to **Builds** in Codemagic
2. Click on your successful build
3. Download the **`.ipa` file** from **Artifacts**

---

## 🔧 Troubleshooting Common Issues

### Issue: "Detached HEAD" warnings
**Status:** ✅ Normal - ignore these warnings

### Issue: "CocoaPods could not find compatible versions"
**Solution:**
1. Make sure `ios/Podfile` shows `platform :ios, '15.0'`
2. Verify you've pushed the latest changes to GitHub
3. In Codemagic, try cleaning the build cache

### Issue: "Firebase requires higher deployment target"
**Solution:** Already fixed - iOS 15.0 is set in Podfile

### Issue: "Code signing failed"
**Solution:**
1. Verify your code signing configuration in Codemagic
2. Make sure your certificates are valid
3. Check bundle identifier matches your provisioning profile

### Issue: Build timeout
**Solution:**
1. Check `max_build_duration` in codemagic.yaml (currently 120 minutes)
2. Ensure your Codemagic plan supports the duration

---

## 📋 Important Notes

### Package Versions (Already Configured)
- `firebase_core`: 4.3.0
- `firebase_auth`: 6.1.3 (requires iOS 15.0+)
- `google_sign_in`: 6.2.2
- `Kotlin`: 2.1.0

### iOS Deployment Target
- **Minimum iOS**: 15.0
- **Supported Devices**: iPhone 6s and newer

### Before Each Build
1. ✅ Test locally if possible
2. ✅ Commit and push all changes
3. ✅ Verify Firebase configuration
4. ✅ Check code signing is valid

---

## 🎯 Expected Build Time
- **iOS Build**: 10-15 minutes
- **Android Build**: 5-10 minutes

## 📱 After Successful Build
You'll get:
- **iOS**: `.ipa` file ready for App Store or TestFlight
- **Android**: `.apk` and `.aab` files

---

## 🆘 Need Help?

If you encounter issues:
1. Check the **build logs** in Codemagic for detailed errors
2. Look for lines with `error:` or `failed:`
3. Share the specific error message

**Common Log Locations:**
- Pod install errors: Look for "pod install" section
- Build errors: Look for "flutter build" section
- Code signing errors: Look for "xcodebuild" section
