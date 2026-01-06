#!/bin/bash
set -e

echo "🔧 Copying GoogleService-Info.plist to app bundle..."

# Ensure the file exists
if [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "❌ ERROR: GoogleService-Info.plist not found!"
    exit 1
fi

# Copy to the build directory
cp -v ios/Runner/GoogleService-Info.plist ios/Runner/

echo "✅ GoogleService-Info.plist copied successfully"
