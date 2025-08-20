#!/bin/bash
# PopZeit Install Script

set -e

echo "Installing PopZeit..."

# Download latest release
LATEST_RELEASE=$(curl -s https://api.github.com/repos/rahulj51/popzeit/releases/latest | grep "tag_name" | cut -d '"' -f 4)
VERSION=${LATEST_RELEASE#v}
DOWNLOAD_URL="https://github.com/rahulj51/popzeit/releases/download/${LATEST_RELEASE}/PopZeit-${VERSION}.zip"

echo "Downloading PopZeit v${VERSION}..."

# Download to temporary location
cd /tmp
curl -L -o PopZeit.zip "$DOWNLOAD_URL"

# Extract
echo "Extracting..."
unzip -q PopZeit.zip

# Remove quarantine attributes (this prevents "damaged app" warnings)
echo "Removing quarantine attributes..."
xattr -dr com.apple.quarantine PopZeit.app 2>/dev/null || true

# Install to Applications
echo "Installing to /Applications..."
if [ -d "/Applications/PopZeit.app" ]; then
    echo "Removing existing installation..."
    rm -rf "/Applications/PopZeit.app"
fi

mv PopZeit.app /Applications/

# Cleanup
rm PopZeit.zip

echo ""
echo "✅ PopZeit installed successfully!"
echo ""
echo "🚀 PopZeit is now available in your Applications folder."
echo "   Launch it to see the timestamp converter in your menu bar."
echo ""
echo "💡 Tip: PopZeit runs as a menu bar app - look for it in your menu bar after launching."