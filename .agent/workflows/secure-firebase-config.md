---
description: Securely handle GoogleService-Info.plist in Codemagic CI/CD
---

# Secure Firebase Configuration in Codemagic

This guide explains how to securely handle the `GoogleService-Info.plist` file in Codemagic CI/CD without committing sensitive data to your repository.

## ✅ What We've Done

1. **Updated `.gitignore`**: The `GoogleService-Info.plist` is already excluded from version control (line 37)
2. **Updated `codemagic.yaml`**: Added a pre-build script to decode and place the file during build

## 🔐 Setup Instructions for Codemagic

### Step 1: Copy the Base64 Encoded String

Your `GoogleService-Info.plist` has been encoded to base64. Copy this entire string:

```
PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCFET0NUWVBFIHBsaXN0IFBVQkxJQyAiLS8vQXBwbGUvL0RURCBQTElTVCAxLjAvL0VOIiAiaHR0cDovL3d3dy5hcHBsZS5jb20vRFREcy9Qcm9wZXJ0eUxpc3QtMS4wLmR0ZCI+CjxwbGlzdCB2ZXJzaW9uPSIxLjAiPgo8ZGljdD4KCTxrZXk+Q0xJRU5UX0lEPC9rZXk+Cgk8c3RyaW5nPjEwOTYwNTI4NDQ2ODUtcDBuYnN1b3Bxc2F0OTBhNHJoYmIyNjBvOGwwc2RwMnAuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb208L3N0cmluZz4KCTxrZXk+UkVWRVJTRURfQ0xJRU5UX0lEPC9rZXk+Cgk8c3RyaW5nPmNvbS5nb29nbGV1c2VyY29udGVudC5hcHBzLjEwOTYwNTI4NDQ2ODUtcDBuYnN1b3Bxc2F0OTBhNHJoYmIyNjBvOGwwc2RwMnA8L3N0cmluZz4KCTxrZXk+QU5EUk9JRF9DTElFTlRfSUQ8L2tleT4KCTxzdHJpbmc+MTA5NjA1Mjg0NDY4NS00bzlmdjZycnZwa2JhMmo2dTZtZmk5bHA2bWY3cmZxcS5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbTwvc3RyaW5nPgoJPGtleT5BUElfS0VZPC9rZXk+Cgk8c3RyaW5nPkFJemFTeUIxOWxfWjMyc2J5VGlQcDJBemJkV1FQdXlyRTZ4T0pVODwvc3RyaW5nPgoJPGtleT5HQ01fU0VOREVSX0lEPC9rZXk+Cgk8c3RyaW5nPjEwOTYwNTI4NDQ2ODU8L3N0cmluZz4KCTxrZXk+UExJU1RfVkVSU0lPTjwva2V5PgoJPHN0cmluZz4xPC9zdHJpbmc+Cgk8a2V5PkJVTkRMRV9JRDwva2V5PgoJPHN0cmluZz5jb20ubm90aWNlc2luZm8uYXBwPC9zdHJpbmc+Cgk8a2V5PlBST0pFQ1RfSUQ8L2tleT4KCTxzdHJpbmc+bm90aWNlc2luZm8tOGQzY2Q8L3N0cmluZz4KCTxrZXk+U1RPUkFHRV9CVUNLRVQ8L2tleT4KCTxzdHJpbmc+bm90aWNlc2luZm8tOGQzY2QuZmlyZWJhc2VzdG9yYWdlLmFwcDwvc3RyaW5nPgoJPGtleT5JU19BRFNfRU5BQkxFRDwva2V5PgoJPGZhbHNlPjwvZmFsc2U+Cgk8a2V5PklTX0FOQUxZVElDU19FTkFCTEVEPC9rZXk+Cgk8ZmFsc2U+PC9mYWxzZT4KCTxrZXk+SVNfQVBQSU5WSVRFX0VOQUJMRUQ8L2tleT4KCTx0cnVlPjwvdHJ1ZT4KCTxrZXk+SVNfR0NNX0VOQUJMRUQ8L2tleT4KCTx0cnVlPjwvdHJ1ZT4KCTxrZXk+SVNfU0lHTklOX0VOQUJMRUQ8L2tleT4KCTx0cnVlPjwvdHJ1ZT4KCTxrZXk+R09PR0xFX0FQUF9JRDwva2V5PgoJPHN0cmluZz4xOjEwOTYwNTI4NDQ2ODU6aW9zOjQ1NGQxNWYwMTEzOGY3YzlmNDlhYzQ8L3N0cmluZz4KPC9kaWN0Pgo8L3BsaXN0Pg==
```

### Step 2: Add Environment Variable in Codemagic

1. **Login to Codemagic**: Go to [codemagic.io](https://codemagic.io)
2. **Navigate to your app**: Select your `noticesinfo` application
3. **Go to Environment variables**:
   - Click on **Environment variables** in the left sidebar
4. **Create a new group** (if not exists):
   - Click **Add new group**
   - Group name: `firebase_config`
   - Click **Create**
5. **Add the variable**:
   - Click **Add variable** in the `firebase_config` group
   - **Variable name**: `GOOGLE_SERVICE_INFO_PLIST`
   - **Variable value**: Paste the base64 string from Step 1
   - **Secure**: ✅ **CHECK THIS BOX** (This encrypts the value)
   - Click **Add**

### Step 3: Verify the Configuration

Your `codemagic.yaml` has been updated with:
- Reference to the `firebase_config` group in the environment section
- A pre-build script that decodes and places the file

The script will:
1. Decode the base64 string
2. Create the file at `ios/Runner/GoogleService-Info.plist`
3. Make it available for the build process

### Step 4: Test the Build

1. **Commit and push** your updated `codemagic.yaml`:
   ```bash
   git add codemagic.yaml
   git commit -m "Add secure Firebase config handling"
   git push
   ```

2. **Trigger a build** in Codemagic
3. **Check the logs** for the "Setup GoogleService-Info.plist" step
4. You should see: "GoogleService-Info.plist has been set up successfully"

## 🔒 Security Best Practices

✅ **DO:**
- Keep the `GoogleService-Info.plist` in `.gitignore`
- Use encrypted environment variables in Codemagic
- Regularly rotate Firebase API keys if compromised
- Use different Firebase projects for development and production

❌ **DON'T:**
- Commit `GoogleService-Info.plist` to version control
- Share the base64 encoded string publicly
- Use the same Firebase project for testing and production
- Store the file in public repositories

## 🔄 Updating the File

If you need to update the `GoogleService-Info.plist`:

1. **Encode the new file**:
   ```powershell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("ios\Runner\GoogleService-Info.plist"))
   ```

2. **Update the environment variable** in Codemagic:
   - Go to Environment variables → `firebase_config` group
   - Edit `GOOGLE_SERVICE_INFO_PLIST`
   - Paste the new base64 string
   - Save

3. **Trigger a new build** to use the updated configuration

## 📱 Android Configuration (google-services.json)

For Android, the same approach has been applied:

### Step 1: Copy the Base64 Encoded String for Android

Your `google-services.json` has been encoded to base64. Copy this entire string:

```
ewogICJwcm9qZWN0X2luZm8iOiB7CiAgICAicHJvamVjdF9udW1iZXIiOiAiMTA5NjA1Mjg0NDY4NSIsCiAgICAicHJvamVjdF9pZCI6ICJub3RpY2VzaW5mby04ZDNjZCIsCiAgICAic3RvcmFnZV9idWNrZXQiOiAibm90aWNlc2luZm8tOGQzY2QuZmlyZWJhc2VzdG9yYWdlLmFwcCIKICB9LAogICJjbGllbnQiOiBbCiAgICB7CiAgICAgICJjbGllbnRfaW5mbyI6IHsKICAgICAgICAibW9iaWxlc2RrX2FwcF9pZCI6ICIxOjEwOTYwNTI4NDQ2ODU6YW5kcm9pZDo1MGY2NTA1MzEwZGQxMDMyZjQ5YWM0IiwKICAgICAgICAiYW5kcm9pZF9jbGllbnRfaW5mbyI6IHsKICAgICAgICAgICJwYWNrYWdlX25hbWUiOiAiY29tLm5vdGljZXNpbmZvLmFwcCIKICAgICAgICB9CiAgICAgIH0sCiAgICAgICJvYXV0aF9jbGllbnQiOiBbCiAgICAgICAgewogICAgICAgICAgImNsaWVudF9pZCI6ICIxMDk2MDUyODQ0Njg1LWpwMmRxZTZscDVwcW9nNGU2czl1ams1c2ltcm1qbWE3LmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwKICAgICAgICAgICJjbGllbnRfdHlwZSI6IDEsCiAgICAgICAgICAiYW5kcm9pZF9pbmZvIjogewogICAgICAgICAgICAicGFja2FnZV9uYW1lIjogImNvbS5ub3RpY2VzaW5mby5hcHAiLAogICAgICAgICAgICAiY2VydGlmaWNhdGVfaGFzaCI6ICIyMWYxZmRiZGUwMTY3ZmZkMmEzYTQ2ZjUxMDQ4NjRiNTYwMDY3NTYwIgogICAgICAgICAgfQogICAgICAgIH0sCiAgICAgICAgewogICAgICAgICAgImNsaWVudF9pZCI6ICIxMDk2MDUyODQ0Njg1LW9jdWZ1cXFib250dHIyb2NwMXNvZWFxYW5hYm40dml0LmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwKICAgICAgICAgICJjbGllbnRfdHlwZSI6IDEsCiAgICAgICAgICAiYW5kcm9pZF9pbmZvIjogewogICAgICAgICAgICAicGFja2FnZV9uYW1lIjogImNvbS5ub3RpY2VzaW5mby5hcHAiLAogICAgICAgICAgICAiY2VydGlmaWNhdGVfaGFzaCI6ICIzZWM4NTY2YzU0YTYwNTAyMjgzZmIwZWM5YTYwNmUwYTRmNTI5MjZjIgogICAgICAgICAgfQogICAgICAgIH0sCiAgICAgICAgewogICAgICAgICAgImNsaWVudF9pZCI6ICIxMDk2MDUyODQ0Njg1LTAybTFyNHFtajZxOWM0cG9qa2tkOXNzcmtwaW9zMm5wLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwKICAgICAgICAgICJjbGllbnRfdHlwZSI6IDMKICAgICAgICB9CiAgICAgIF0sCiAgICAgICJhcGlfa2V5IjogWwogICAgICAgIHsKICAgICAgICAgICJjdXJyZW50X2tleSI6ICJBSXphU3lEZHZnOC1ST1RCM2RMSDlzNVdYQnZja00zWnRiZzdBS0EiCiAgICAgICAgfQogICAgICBdLAogICAgICAic2VydmljZXMiOiB7CiAgICAgICAgImFwcGludml0ZV9zZXJ2aWNlIjogewogICAgICAgICAgIm90aGVyX3BsYXRmb3JtX29hdXRoX2NsaWVudCI6IFsKICAgICAgICAgICAgewogICAgICAgICAgICAgICJjbGllbnRfaWQiOiAiMTA5NjA1Mjg0NDY4NS0wMm0xcjRxbWo2cTljNHBvamtrZDlzc3JrcGlvczJucC5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsCiAgICAgICAgICAgICAgImNsaWVudF90eXBlIjogMwogICAgICAgICAgICB9CiAgICAgICAgICBdCiAgICAgICAgfQogICAgICB9CiAgICB9CiAgXSwKICAiY29uZmlndXJhdGlvbl92ZXJzaW9uIjogIjEiCn0=
```

### Step 2: Add to Codemagic Environment Variables

1. Go to the same `firebase_config` group you created earlier
2. **Add another variable**:
   - **Variable name**: `GOOGLE_SERVICES_JSON`
   - **Variable value**: Paste the base64 string from above
   - **Secure**: ✅ **CHECK THIS BOX**
   - Click **Add**

The `codemagic.yaml` Android workflow has already been updated with the decode script.

## 🆘 Troubleshooting

**Issue**: "GOOGLE_SERVICE_INFO_PLIST not found"
- **Solution**: Ensure the `firebase_config` group is added to the workflow's environment groups

**Issue**: "Invalid base64 string"
- **Solution**: Re-encode the file and ensure no extra spaces or line breaks

**Issue**: "File not found during build"
- **Solution**: Check the script logs to ensure the decode step completed successfully

## 📚 Additional Resources

- [Codemagic Environment Variables Documentation](https://docs.codemagic.io/yaml-basic-configuration/configuring-environment-variables/)
- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [Codemagic YAML Configuration](https://docs.codemagic.io/yaml/yaml-getting-started/)
