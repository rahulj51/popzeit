#!/bin/bash

# PopZeit Build Script

set -e

echo "Building PopZeit..."

# Clean previous builds
rm -rf .build build
mkdir -p build

# Build the executable
echo "Building with Swift Package Manager..."
echo "Building for current architecture..."
swift build -c release
EXECUTABLE_PATH=".build/release/PopZeit"

# Check if build was successful
if [ ! -f "$EXECUTABLE_PATH" ]; then
    echo "Build failed - executable not found at $EXECUTABLE_PATH"
    exit 1
fi

# Create app bundle structure
echo "Creating app bundle..."
APP_BUNDLE="build/PopZeit.app"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Copy executable to bundle
cp "$EXECUTABLE_PATH" "$APP_BUNDLE/Contents/MacOS/"
chmod +x "$APP_BUNDLE/Contents/MacOS/PopZeit"

# Copy Info.plist
cp PopZeit/Info.plist "$APP_BUNDLE/Contents/"

# Copy entitlements (for reference)
cp PopZeit/PopZeit.entitlements "$APP_BUNDLE/Contents/"

# Copy app icon and resources
echo "Copying app icon and resources..."
cp PopZeit/Resources/PopZeit.icns "$APP_BUNDLE/Contents/Resources/"
cp PopZeit/Resources/PopZeit.png "$APP_BUNDLE/Contents/Resources/"

# Make the app executable
chmod -R 755 "$APP_BUNDLE"

# Extract version from Info.plist
VERSION=$(plutil -extract CFBundleShortVersionString raw "$APP_BUNDLE/Contents/Info.plist")

# Create ZIP archive for distribution
echo "Creating ZIP archive for distribution..."
cd build
ZIP_NAME="PopZeit-${VERSION}.zip"
zip -r "$ZIP_NAME" PopZeit.app
cd ..

# Calculate SHA256 for Homebrew Cask
SHA256=$(shasum -a 256 "build/$ZIP_NAME" | cut -d' ' -f1)

echo "Build complete!"
echo "App bundle created at: $APP_BUNDLE"
echo "ZIP archive created at: build/$ZIP_NAME"
echo "SHA256: $SHA256"
echo ""
echo "To test the app:"
echo "   ./build/PopZeit.app/Contents/MacOS/PopZeit"
echo ""
echo "To run as a proper macOS app:"
echo "   open $APP_BUNDLE"
echo ""
echo "For Homebrew Cask distribution:"
echo "   Version: $VERSION"
echo "   Archive: build/$ZIP_NAME"
echo "   SHA256: $SHA256"