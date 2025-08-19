# PopZeit - Unix Timestamp Converter for macOS

A lightweight macOS menu bar app that instantly converts Unix timestamps to human-readable dates when copied to the clipboard.

## Features

- **Clipboard Monitoring**: Copy any Unix timestamp to clipboard to see instant conversion
- **Multiple Formats**: Shows UTC, local time, and relative time ("2 days ago")
- **Multiple Timestamp Formats**: Supports seconds (10 digits), milliseconds (13 digits), and microseconds (16 digits)
- **Timezone Support**: Pin your favorite timezones for quick reference
- **Copy to Clipboard**: One-click copy for any time format
- **Customizable**: Configure date formats, popover timeout, and more
- **Accessible**: VoiceOver support and high contrast mode
- **Privacy-First**: All processing happens locally, no data leaves your device
- **Universal Compatibility**: Works with all applications including text editors like Sublime Text, Zed, and Firefoo

## Installation

### Requirements
- macOS 13.0 (Ventura) or later
- No special permissions required

### Download
1. Download the latest release from the [Releases](https://github.com/yourusername/popzeit/releases) page
2. Open the `.dmg` file
3. Drag PopZeit to your Applications folder
4. Launch PopZeit from Applications

### First Launch
1. PopZeit will appear in your menu bar (look for the clock icon)
2. Start copying timestamps to see conversions!

## Usage

### Basic Usage
1. Find a Unix timestamp in any app (e.g., `1724054400` or `1724054400000`)
2. Copy the timestamp (Cmd+C)
3. A popover appears automatically showing the converted time
4. Click the copy button to copy any format to clipboard

### Menu Bar Options
- **Enable/Disable Clipboard Monitoring**: Toggle clipboard monitoring on/off
- **Convert Current Clipboard**: Manually convert timestamp currently in clipboard
- **Preferences**: Customize settings
- **Quit**: Exit PopZeit

### Keyboard Shortcuts
- `Cmd,` - Open Preferences
- `Cmd+Shift+V` - Convert Current Clipboard
- `Cmd+Q` - Quit PopZeit
- `Esc` - Dismiss popover

## Preferences

### General
- Launch at login
- Show/hide dock icon
- Popover timeout duration
- Clipboard monitoring settings

### Formatting
- Customize date format strings
- Enable locale-aware formatting
- Configure formats for UTC, local, and timezone displays

### Timezones
- Search and pin additional timezones
- Remove pinned timezones
- Timezones appear in conversion popover

### Accessibility
- Configure text size
- Enable high contrast mode

## How It Works

PopZeit monitors your clipboard for changes. When you copy text that looks like a Unix timestamp, it automatically shows a conversion popover. This approach:

- Works universally across all applications
- Doesn't require accessibility permissions
- Has no compatibility issues with text editors
- Provides consistent behavior everywhere

**Privacy Note**: PopZeit only monitors clipboard changes for timestamp detection. All processing happens locally on your Mac. No data is sent to external servers.

## Building from Source

### Prerequisites
- Xcode 15.0 or later
- Swift 5.9 or later

### Build Steps
```bash
# Clone the repository
git clone https://github.com/yourusername/popzeit.git
cd popzeit

# Build with Swift Package Manager
swift build -c release

# Or open in Xcode
open PopZeit.xcodeproj
```

### Creating a Release Build
```bash
# Build and archive
xcodebuild -scheme PopZeit -configuration Release archive -archivePath ./build/PopZeit.xcarchive

# Export for distribution
xcodebuild -exportArchive -archivePath ./build/PopZeit.xcarchive -exportPath ./build -exportOptionsPlist ExportOptions.plist

# Sign and notarize (requires Apple Developer account)
./scripts/notarize.sh
```

## Troubleshooting

### Clipboard Not Monitored
1. Check that clipboard monitoring is enabled in the menu bar
2. Restart PopZeit if needed
3. Ensure the copied text is a valid timestamp format

### Timestamp Not Detected
- PopZeit supports timestamps with 10, 13, or 16 digits
- Ensure there are no extra characters around the timestamp
- Try copying just the timestamp number without surrounding text

### Popover Position Issues
- PopZeit automatically adjusts for multiple monitors
- If positioning seems off, try restarting the app

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

PopZeit is released under the MIT License. See [LICENSE](LICENSE) file for details.

## Privacy Policy

PopZeit is designed with privacy in mind:
- All timestamp conversion happens locally on your device
- No data is collected or transmitted to external servers
- No analytics or tracking (unless explicitly opted in)
- Clipboard monitoring only checks for timestamp patterns

## Support

For issues, questions, or suggestions, please [open an issue](https://github.com/yourusername/popzeit/issues) on GitHub.

## Acknowledgments

- Built with Swift and SwiftUI
- Uses macOS NSPasteboard for clipboard monitoring
- Inspired by the need for quick timestamp conversion during development