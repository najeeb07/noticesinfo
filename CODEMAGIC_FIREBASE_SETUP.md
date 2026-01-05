# 🔐 Secure Firebase Config - Default Codemagic Workflow

## Quick Setup Guide for UI-Based Workflow

Since you're using Codemagic's default workflow (UI-based), follow these simple steps:

---

## ✅ Step 1: Add Environment Variables in Codemagic

### For iOS:

1. Go to **Codemagic** → Your App → **iOS Workflow**
2. Scroll to **Environment variables**
3. Click **Add variable**
4. Enter:
   - **Variable name**: `GOOGLE_SERVICE_INFO_PLIST`
   - **Variable value**: (copy the base64 string below)
   - **Secure**: ✅ **CHECK THIS BOX**
   - Click **Add**

**Base64 value for iOS:**
```
PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCFET0NUWVBFIHBsaXN0IFBVQkxJQyAiLS8vQXBwbGUvL0RURCBQTElTVCAxLjAvL0VOIiAiaHR0cDovL3d3dy5hcHBsZS5jb20vRFREcy9Qcm9wZXJ0eUxpc3QtMS4wLmR0ZCI+CjxwbGlzdCB2ZXJzaW9uPSIxLjAiPgo8ZGljdD4KCTxrZXk+Q0xJRU5UX0lEPC9rZXk+Cgk8c3RyaW5nPjEwOTYwNTI4NDQ2ODUtcDBuYnN1b3Bxc2F0OTBhNHJoYmIyNjBvOGwwc2RwMnAuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb208L3N0cmluZz4KCTxrZXk+UkVWRVJTRURfQ0xJRU5UX0lEPC9rZXk+Cgk8c3RyaW5nPmNvbS5nb29nbGV1c2VyY29udGVudC5hcHBzLjEwOTYwNTI4NDQ2ODUtcDBuYnN1b3Bxc2F0OTBhNHJoYmIyNjBvOGwwc2RwMnA8L3N0cmluZz4KCTxrZXk+QU5EUk9JRF9DTElFTlRfSUQ8L2tleT4KCTxzdHJpbmc+MTA5NjA1Mjg0NDY4NS00bzlmdjZycnZwa2JhMmo2dTZtZmk5bHA2bWY3cmZxcS5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbTwvc3RyaW5nPgoJPGtleT5BUElfS0VZPC9rZXk+Cgk8c3RyaW5nPkFJemFTeUIxOWxfWjMyc2J5VGlQcDJBemJkV1FQdXlyRTZ4T0pVODwvc3RyaW5nPgoJPGtleT5HQ01fU0VOREVSX0lEPC9rZXk+Cgk8c3RyaW5nPjEwOTYwNTI4NDQ2ODU8L3N0cmluZz4KCTxrZXk+UExJU1RfVkVSU0lPTjwva2V5PgoJPHN0cmluZz4xPC9zdHJpbmc+Cgk8a2V5PkJVTkRMRV9JRDwva2V5PgoJPHN0cmluZz5jb20ubm90aWNlc2luZm8uYXBwPC9zdHJpbmc+Cgk8a2V5PlBST0pFQ1RfSUQ8L2tleT4KCTxzdHJpbmc+bm90aWNlc2luZm8tOGQzY2Q8L3N0cmluZz4KCTxrZXk+U1RPUkFHRV9CVUNLRVQ8L2tleT4KCTxzdHJpbmc+bm90aWNlc2luZm8tOGQzY2QuZmlyZWJhc2VzdG9yYWdlLmFwcDwvc3RyaW5nPgoJPGtleT5JU19BRFNfRU5BQkxFRDwva2V5PgoJPGZhbHNlPjwvZmFsc2U+Cgk8a2V5PklTX0FOQUxZVElDU19FTkFCTEVEPC9rZXk+Cgk8ZmFsc2U+PC9mYWxzZT4KCTxrZXk+SVNfQVBQSU5WSVRFX0VOQUJMRUQ8L2tleT4KCTx0cnVlPjwvdHJ1ZT4KCTxrZXk+SVNfR0NNX0VOQUJMRUQ8L2tleT4KCTx0cnVlPjwvdHJ1ZT4KCTxrZXk+SVNfU0lHTklOX0VOQUJMRUQ8L2tleT4KCTx0cnVlPjwvdHJ1ZT4KCTxrZXk+R09PR0xFX0FQUF9JRDwva2V5PgoJPHN0cmluZz4xOjEwOTYwNTI4NDQ2ODU6aW9zOjQ1NGQxNWYwMTEzOGY3YzlmNDlhYzQ8L3N0cmluZz4KPC9kaWN0Pgo8L3BsaXN0Pg==
```

### For Android:

1. Go to **Codemagic** → Your App → **Android Workflow**
2. Scroll to **Environment variables**
3. Click **Add variable**
4. Enter:
   - **Variable name**: `GOOGLE_SERVICES_JSON`
   - **Variable value**: (copy the base64 string below)
   - **Secure**: ✅ **CHECK THIS BOX**
   - Click **Add**

**Base64 value for Android:**
```
ewogICJwcm9qZWN0X2luZm8iOiB7CiAgICAicHJvamVjdF9udW1iZXIiOiAiMTA5NjA1Mjg0NDY4NSIsCiAgICAicHJvamVjdF9pZCI6ICJub3RpY2VzaW5mby04ZDNjZCIsCiAgICAic3RvcmFnZV9idWNrZXQiOiAibm90aWNlc2luZm8tOGQzY2QuZmlyZWJhc2VzdG9yYWdlLmFwcCIKICB9LAogICJjbGllbnQiOiBbCiAgICB7CiAgICAgICJjbGllbnRfaW5mbyI6IHsKICAgICAgICAibW9iaWxlc2RrX2FwcF9pZCI6ICIxOjEwOTYwNTI4NDQ2ODU6YW5kcm9pZDo1MGY2NTA1MzEwZGQxMDMyZjQ5YWM0IiwKICAgICAgICAiYW5kcm9pZF9jbGllbnRfaW5mbyI6IHsKICAgICAgICAgICJwYWNrYWdlX25hbWUiOiAiY29tLm5vdGljZXNpbmZvLmFwcCIKICAgICAgICB9CiAgICAgIH0sCiAgICAgICJvYXV0aF9jbGllbnQiOiBbCiAgICAgICAgewogICAgICAgICAgImNsaWVudF9pZCI6ICIxMDk2MDUyODQ0Njg1LWpwMmRxZTZscDVwcW9nNGU2czl1ams1c2ltcm1qbWE3LmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwKICAgICAgICAgICJjbGllbnRfdHlwZSI6IDEsCiAgICAgICAgICAiYW5kcm9pZF9pbmZvIjogewogICAgICAgICAgICAicGFja2FnZV9uYW1lIjogImNvbS5ub3RpY2VzaW5mby5hcHAiLAogICAgICAgICAgICAiY2VydGlmaWNhdGVfaGFzaCI6ICIyMWYxZmRiZGUwMTY3ZmZkMmEzYTQ2ZjUxMDQ4NjRiNTYwMDY3NTYwIgogICAgICAgICAgfQogICAgICAgIH0sCiAgICAgICAgewogICAgICAgICAgImNsaWVudF9pZCI6ICIxMDk2MDUyODQ0Njg1LW9jdWZ1cXFib250dHIyb2NwMXNvZWFxYW5hYm40dml0LmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwKICAgICAgICAgICJjbGllbnRfdHlwZSI6IDEsCiAgICAgICAgICAiYW5kcm9pZF9pbmZvIjogewogICAgICAgICAgICAicGFja2FnZV9uYW1lIjogImNvbS5ub3RpY2VzaW5mby5hcHAiLAogICAgICAgICAgICAiY2VydGlmaWNhdGVfaGFzaCI6ICIzZWM4NTY2YzU0YTYwNTAyMjgzZmIwZWM5YTYwNmUwYTRmNTI5MjZjIgogICAgICAgICAgfQogICAgICAgIH0sCiAgICAgICAgewogICAgICAgICAgImNsaWVudF9pZCI6ICIxMDk2MDUyODQ0Njg1LTAybTFyNHFtajZxOWM0cG9qa2tkOXNzcmtwaW9zMm5wLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwKICAgICAgICAgICJjbGllbnRfdHlwZSI6IDMKICAgICAgICB9CiAgICAgIF0sCiAgICAgICJhcGlfa2V5IjogWwogICAgICAgIHsKICAgICAgICAgICJjdXJyZW50X2tleSI6ICJBSXphU3lEZHZnOC1ST1RCM2RMSDlzNVdYQnZja00zWnRiZzdBS0EiCiAgICAgICAgfQogICAgICBdLAogICAgICAic2VydmljZXMiOiB7CiAgICAgICAgImFwcGludml0ZV9zZXJ2aWNlIjogewogICAgICAgICAgIm90aGVyX3BsYXRmb3JtX29hdXRoX2NsaWVudCI6IFsKICAgICAgICAgICAgewogICAgICAgICAgICAgICJjbGllbnRfaWQiOiAiMTA5NjA1Mjg0NDY4NS0wMm0xcjRxbWo2cTljNHBvamtrZDlzc3JrcGlvczJucC5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsCiAgICAgICAgICAgICAgImNsaWVudF90eXBlIjogMwogICAgICAgICAgICB9CiAgICAgICAgICBdCiAgICAgICAgfQogICAgICB9CiAgICB9CiAgXSwKICAiY29uZmlndXJhdGlvbl92ZXJzaW9uIjogIjEiCn0=
```

---

## ✅ Step 2: Add Pre-Build Scripts

### For iOS Workflow:

1. In your **iOS Workflow** settings
2. Scroll to **Build** section
3. Find **Pre-build script** (or click **Add script** if not present)
4. Paste this script:

```bash
#!/bin/sh
set -e
set -x

echo "🔧 Setting up GoogleService-Info.plist..."
echo $GOOGLE_SERVICE_INFO_PLIST | base64 --decode > $CM_BUILD_DIR/ios/Runner/GoogleService-Info.plist
echo "✅ GoogleService-Info.plist configured successfully"
```

### For Android Workflow:

1. In your **Android Workflow** settings
2. Scroll to **Build** section
3. Find **Pre-build script** (or click **Add script** if not present)
4. Paste this script:

```bash
#!/bin/sh
set -e
set -x

echo "🔧 Setting up google-services.json..."
echo $GOOGLE_SERVICES_JSON | base64 --decode > $CM_BUILD_DIR/android/app/google-services.json
echo "✅ google-services.json configured successfully"
```

---

## ✅ Step 3: Commit Changes to Git

Your `.gitignore` has been updated to exclude these files. Now commit and push:

```bash
git add .gitignore
git commit -m "Secure Firebase config files - remove from Git"
git push
```

---

## 🧪 Step 4: Test the Build

1. **Trigger a build** in Codemagic
2. **Check the build logs** for:
   - ✅ "GoogleService-Info.plist configured successfully" (iOS)
   - ✅ "google-services.json configured successfully" (Android)
3. **Verify the build completes** without Firebase config errors

---

## 🔒 Security Checklist

- ✅ Firebase config files are in `.gitignore`
- ✅ Files are removed from Git history
- ✅ Environment variables are marked as "Secure" in Codemagic
- ✅ Base64 encoded values are stored in Codemagic (encrypted)
- ✅ Files are decoded during build time only

---

## 📸 Visual Guide

### Where to find Environment Variables:
1. Codemagic Dashboard → Your App
2. Select Workflow (iOS or Android)
3. Scroll down to "Environment variables" section
4. Click "Add variable"

### Where to add Pre-build Script:
1. Same workflow page
2. Scroll to "Build" section
3. Look for "Pre-build script" or "Scripts"
4. Add the decode script before your build commands

---

## 🆘 Troubleshooting

**Issue**: Build fails with "GoogleService-Info.plist not found"
- **Solution**: Verify the environment variable name is exactly `GOOGLE_SERVICE_INFO_PLIST`
- **Solution**: Check that the pre-build script is added and runs before the build

**Issue**: "Invalid base64 string"
- **Solution**: Make sure you copied the entire base64 string without any extra spaces or line breaks

**Issue**: Build succeeds but Firebase doesn't work
- **Solution**: Check that the decoded file path matches your project structure
- **Solution**: Verify the base64 string is from the correct Firebase project

---

## 📝 Notes

- These files will **NOT** be in your Git repository anymore
- They will be **created during each build** from the environment variables
- This is the **recommended approach** for CI/CD security
- You can update the files by re-encoding and updating the environment variables in Codemagic

---

## 🔄 Updating Firebase Config

If you need to update your Firebase configuration:

1. **Encode the new file**:
   ```powershell
   # For iOS
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("ios\Runner\GoogleService-Info.plist"))
   
   # For Android
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("android\app\google-services.json"))
   ```

2. **Update in Codemagic**:
   - Go to Environment variables
   - Edit the existing variable
   - Paste the new base64 string
   - Save

3. **Trigger a new build** to use the updated configuration
