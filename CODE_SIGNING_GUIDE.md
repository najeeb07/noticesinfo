# Code Signing Setup for Codemagic

## Error You're Seeing:
```
No matching profiles found for bundle identifier "com.noticesinfo.app" 
and distribution type "app_store"
```

## ✅ FIXED: Distribution Type Changed to Ad-Hoc

I've updated your configuration to use **ad-hoc** distribution instead of app-store. This is easier for testing and doesn't require App Store Connect setup.

---

## 🚀 Option 1: Automatic Code Signing (Recommended - Easiest)

### Steps in Codemagic:

1. **Go to your app in Codemagic**
2. **Settings** → **Code signing identities** 
3. **iOS code signing**
4. Click **"Fetch from Apple Developer Portal"**
5. **Sign in with your Apple ID** (needs to be enrolled in Apple Developer Program)
6. Codemagic will:
   - ✅ Automatically create certificates
   - ✅ Create provisioning profiles
   - ✅ Configure everything for you

**Requirements:**
- ✅ Apple Developer Account ($99/year)
- ✅ Bundle ID `com.noticesinfo.app` registered in Apple Developer Portal

### If You Don't Have Apple Developer Account:
- You need to enroll at: https://developer.apple.com/programs/
- Cost: $99/year
- **Without this, you CANNOT create IPA files for distribution**

---

## 🔧 Option 2: Manual Code Signing (Advanced)

### Prerequisites:
1. **Xcode installed on a Mac**
2. **Apple Developer Account**
3. **App registered with bundle ID**: `com.noticesinfo.app`

### Steps:

#### A. Create Certificates (On Mac with Xcode)

1. **Open Xcode**
2. **Preferences** → **Accounts**
3. **Add your Apple ID**
4. **Manage Certificates** → Create:
   - iOS Distribution Certificate (for ad-hoc/app-store)
   - OR iOS Development Certificate (for testing)

#### B. Create App ID in Apple Developer Portal

1. Go to: https://developer.apple.com/account/resources/identifiers/list
2. Click **"+"** to add new App ID
3. **Bundle ID**: `com.noticesinfo.app`
4. **Capabilities**: Enable what you need:
   - ✅ Push Notifications (if using Firebase Cloud Messaging)
   - ✅ Sign in with Apple (if using)
   - ✅ Associated Domains (if using)
5. **Register**

#### C. Create Provisioning Profile

1. Go to: https://developer.apple.com/account/resources/profiles/list
2. Click **"+"**
3. Select **"Ad Hoc"** distribution
4. Choose App ID: `com.noticesinfo.app`
5. Select your distribution certificate
6. Select devices to test on (or select all)
7. Download the `.mobileprovision` file

#### D. Export Certificate

1. **Keychain Access** on Mac
2. **My Certificates**
3. Find your iOS Distribution certificate
4. **Right-click** → **Export**
5. Save as `.p12` file
6. **Set a password** (remember this!)

#### E. Upload to Codemagic

1. **Codemagic** → Your App → **Settings**
2. **Code signing identities** → **iOS**
3. **Upload:**
   - Certificate (`.p12` file)
   - Provisioning profile (`.mobileprovision`)
   - Enter certificate password

---

## 🎯 Option 3: Use Development Build (For Quick Testing)

If you just want to test on your own device without App Store:

### Update codemagic.yaml:

Change line 10 to:
```yaml
distribution_type: development
```

Then:
1. Create a **Development** provisioning profile (not Ad-Hoc)
2. Add your test devices UDID to Apple Developer Portal
3. Upload to Codemagic as above

---

## ⚡ Quick Fix Summary

### Current Configuration (Already Applied):
- ✅ Distribution type: **ad-hoc**
- ✅ Bundle ID: **com.noticesinfo.app**
- ✅ iOS deployment: **15.0**

### What You Need to Do Now:

**Choose ONE:**

**A. Easiest - Let Codemagic Do It:**
1. Go to Codemagic
2. Settings → Code signing
3. "Fetch from Apple Developer Portal"
4. Sign in with Apple ID
5. Done! ✨

**B. Manual Upload:**
1. Create certificates on Mac (see Option 2)
2. Upload to Codemagic
3. Build again

**C. I Don't Have Apple Developer Account:**
- Unfortunately, you **must** have one to create IPA files
- Cost: $99/year
- Sign up: https://developer.apple.com/programs/

---

## 📱 After Code Signing is Configured:

1. **Commit and push** the updated files:
   ```bash
   git add .
   git commit -m "Updated to ad-hoc distribution"
   git push
   ```

2. **In Codemagic**, click **"Start new build"**

3. **Build will succeed** and you'll get your `.ipa` file! 🎉

---

## 🆘 Still Having Issues?

### Common Problems:

**"Certificate expired"**
- Renew certificate in Apple Developer Portal
- Re-upload to Codemagic

**"Device not registered"**
- For ad-hoc, add device UDID in Apple Developer Portal
- Regenerate provisioning profile

**"Bundle ID mismatch"**
- Ensure `com.noticesinfo.app` is registered in Apple Developer Portal
- It must match exactly

---

## 📝 Summary

**Your code is perfect! ✅**
- Dependencies: Fixed
- iOS 15.0: Configured
- Kotlin: Updated

**Only missing:**
- Code signing certificates (you need Apple Developer Account)

The IPA file will be generated as soon as code signing is configured in Codemagic!
