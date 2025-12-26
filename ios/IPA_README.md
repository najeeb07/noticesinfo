✅ iOS IPA Preparation Checklist

This project has the necessary basics for building an IPA, but you (or the person with the Mac) must complete a few items on the Mac to successfully generate a valid IPA.

Essential steps (do these on a Mac with Xcode and valid Apple account):

1. Set the App Bundle Identifier
   - Open `ios/Runner.xcworkspace` in Xcode, select the **Runner** project → **Runner** target → **General** → **Bundle Identifier**.
   - Replace `com.example.noticesinfo` with your app's bundle id (e.g., `com.yourcompany.yourapp`).

2. Add your Apple Team & Signing
   - In Xcode (Signing & Capabilities) select your **Team** and ensure **Automatically manage signing** is ON.
   - If using manual provisioning, install the correct provisioning profiles and certificate.

3. Add Firebase config (if applicable)
   - If your app uses Firebase, download `GoogleService-Info.plist` from Firebase console and place it in `ios/Runner/`.
   - In Xcode, right-click the Runner target → **Add Files to Runner...** and add `GoogleService-Info.plist` to the app target.

4. Install CocoaPods & dependencies
   - On the Mac run:
     - `flutter pub get`
     - `cd ios`
     - `pod install --repo-update`

5. Build the IPA
   - Option A (recommended): In Xcode select **Generic iOS Device** and Product → **Archive**. Use the Organizer to export and upload.
   - Option B (CLI): `flutter build ipa --export-options-plist=ios/exportOptions.plist` (make sure `teamID` and `method` are set correctly in that plist).

Notes & tips
- Deployment target is set to iOS 14.0 in the project (required by `google_maps_flutter_ios`).
- Bitcode is disabled (ENABLE_BITCODE = NO), which is fine for most Flutter apps.

Note: If a plugin requires a higher minimum deployment target (like `google_maps_flutter_ios`), increase the iOS deployment target to at least 14.0 and then run `pod install` on the Mac.
- If plugins require permission keys (camera, microphone, location), ensure the corresponding `NS...` keys are present in `ios/Runner/Info.plist`.
- If you keep `GoogleService-Info.plist` out of source control, add it to `.gitignore` (already suggested below).

If you want, I can:
- Add a placeholder `exportOptions.plist` (done) and a `Podfile` (done).
- Add a step-by-step script — tell me which distribution method you plan to use (App Store or Ad-Hoc).

Good luck — take this folder to the Mac and follow the checklist above. If you run into errors while building on the Mac, share the error log and I’ll help fix it. 🔧
