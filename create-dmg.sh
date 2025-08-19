#!/bin/bash

# PopZeit DMG Creation Script
# Creates a distributable DMG file for PopZeit

set -e

# Configuration
APP_NAME="PopZeit"
VERSION="1.0.0"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
VOLUME_NAME="${APP_NAME}"
SOURCE_APP="build/${APP_NAME}.app"
DMG_PATH="build/${DMG_NAME}"
TEMP_DMG="build/temp.dmg"

# Check if app exists
if [ ! -d "$SOURCE_APP" ]; then
    echo "Error: App bundle not found at $SOURCE_APP"
    echo "Please run ./build.sh first"
    exit 1
fi

echo "Creating DMG for ${APP_NAME} v${VERSION}..."

# Clean up any existing DMG
rm -f "$DMG_PATH" "$TEMP_DMG"

# Create a temporary DMG
echo "Creating temporary DMG..."
hdiutil create -size 50m -fs HFS+ -volname "$VOLUME_NAME" "$TEMP_DMG"

# Mount the temporary DMG
echo "Mounting temporary DMG..."
MOUNT_OUTPUT=$(hdiutil attach "$TEMP_DMG")
MOUNT_PATH=$(echo "$MOUNT_OUTPUT" | grep -o '/Volumes/.*' | head -1)

# Copy app to DMG
echo "Copying app to DMG..."
cp -R "$SOURCE_APP" "$MOUNT_PATH/"

# Create a symbolic link to Applications folder
ln -s /Applications "$MOUNT_PATH/Applications"

# Create a simple background and layout (optional)
# This would normally include a background image and icon positioning
# For now, we'll keep it simple

# Unmount the temporary DMG
echo "Unmounting temporary DMG..."
hdiutil detach "$MOUNT_PATH"

# Convert to compressed DMG
echo "Creating final compressed DMG..."
hdiutil convert "$TEMP_DMG" -format UDZO -o "$DMG_PATH"

# Clean up temporary DMG
rm -f "$TEMP_DMG"

# Calculate DMG size
DMG_SIZE=$(du -h "$DMG_PATH" | cut -f1)

echo ""
echo "DMG created successfully!"
echo "Location: $DMG_PATH"
echo "Size: $DMG_SIZE"
echo ""
echo "Distribution notes:"
echo "1. This DMG contains an unsigned app"
echo "2. Users will see a security warning when opening"
echo "3. They'll need to right-click and choose 'Open' to bypass Gatekeeper"
echo ""
echo "For proper distribution without warnings:"
echo "1. Sign the app with a Developer ID certificate"
echo "2. Notarize the app with Apple"
echo "3. Staple the notarization ticket to the DMG"