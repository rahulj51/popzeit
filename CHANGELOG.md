# Changelog

All notable changes to PopZeit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-08-19

### Added
- Initial release of PopZeit
- Clipboard monitoring for Unix timestamps (replaces double-click detection)
- Support for seconds (10 digits), milliseconds (13 digits), and microseconds (16 digits)
- UTC, local time, and relative time display
- Pinnable timezone support
- One-click copy for all time formats
- Customizable date formats and popover timeout
- Accessibility support with VoiceOver and high contrast mode
- Privacy-first design with local-only processing
- Menu bar integration with system-wide availability
- Comprehensive preferences window
- Optional sound feedback
- Launch at login support
- Multi-monitor support with smart positioning
- Universal compatibility with all applications including text editors
- Smooth animations and visual feedback
- Comprehensive unit test suite
- Complete documentation and usage guide
- Professional distribution with DMG installer

### Technical Features
- Built with Swift 5.9 and SwiftUI
- macOS 13.0 (Ventura) minimum requirement
- Uses NSPasteboard for clipboard monitoring (no accessibility permissions required)
- Smart timestamp detection with format recognition
- Efficient clipboard monitoring with minimal system impact
- Proper memory management and performance optimization
- Error handling with user-friendly feedback
- Universal application compatibility (works in Sublime Text, Zed, Firefoo, etc.)

### Architecture Changes
- Replaced double-click detection with clipboard monitoring
- Removed dependency on Accessibility API
- Eliminated EventMonitor and SelectedTextProvider components
- Simplified to PasteboardMonitor for universal compatibility
- No special permissions required for operation

### Accessibility
- Full VoiceOver support
- Keyboard navigation
- High contrast mode
- Adjustable text size
- No accessibility permissions required

### Privacy & Security
- No data collection or transmission
- Local-only timestamp processing
- No accessibility API access required
- Minimal system integration
- Open source for transparency

### Distribution
- Professional DMG installer (156KB)
- Unsigned binary with clear installation instructions
- Build scripts for easy compilation
- Comprehensive distribution documentation

## [Future Releases]

### Planned Features
- ISO 8601 timestamp support
- Multiple timestamp detection in text
- Global hotkey for manual conversion
- Advanced theming options
- Natural language date parsing
- Enhanced timezone management

### Development Notes
- Core clipboard monitoring architecture provides universal compatibility
- Eliminated accessibility permission requirements for broader adoption
- Streamlined codebase with fewer dependencies
- Ready for production use and community distribution