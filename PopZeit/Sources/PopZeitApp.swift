import AppKit
import SwiftUI

@main
struct PopZeitApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            PreferencesView()
                .environmentObject(TimestampDetector.shared)
                .environmentObject(PreferencesStore.shared)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var pasteboardMonitor: PasteboardMonitor?
    var popoverController: PopoverController?
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)

        // Create status bar item
        setupStatusBar()

        // Initialize components
        setupPasteboardMonitor()
        setupPopoverController()

        // Startup complete
    }

    private func setupStatusBar() {
        // Setup status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: 60)

        guard let statusItem = statusItem else {
            // Failed to create status item
            return
        }

        if let button = statusItem.button {
            // Use the PopZeit icon
            if let iconImage = NSImage(named: "PopZeit") {
                iconImage.size = NSSize(width: 30, height: 30)
                iconImage.isTemplate = true  // Makes it adapt to menu bar appearance
                button.image = iconImage
                button.imageScaling = .scaleProportionallyUpOrDown
            } else {
                // Fallback to text if image not found
                button.title = "PZ"
                button.font = NSFont.systemFont(ofSize: 12, weight: .bold)
            }

            statusItem.length = 30  // Make it slightly wider for the larger icon
            // Status bar button created
            button.toolTip = "PopZeit - Copy timestamps to clipboard to convert them"

            // Create menu
            let menu = NSMenu()

            // Enable/Disable Monitoring toggle
            let toggleItem = NSMenuItem(
                title: "Enable Clipboard Monitoring", action: #selector(toggleDetection),
                keyEquivalent: "")
            toggleItem.target = self
            menu.addItem(toggleItem)

            menu.addItem(NSMenuItem.separator())

            // Convert from Clipboard (manual)
            let clipboardItem = NSMenuItem(
                title: "Convert Current Clipboard", action: #selector(convertFromClipboard),
                keyEquivalent: "")
            clipboardItem.target = self
            menu.addItem(clipboardItem)
            // Preferences
            let prefsItem = NSMenuItem(
                title: "Preferences...", action: #selector(openPreferences), keyEquivalent: ",")
            prefsItem.target = self
            menu.addItem(prefsItem)

            menu.addItem(NSMenuItem.separator())

            // Quit
            let quitItem = NSMenuItem(
                title: "Quit PopZeit", action: #selector(NSApplication.terminate(_:)),
                keyEquivalent: "q")
            menu.addItem(quitItem)

            statusItem.menu = menu
            // Menu created and attached

            // Update toggle state based on current setting
            updateToggleMenuItem()
        } else {
            // Failed to create status bar button
        }
    }

    @objc private func toggleDetection() {
        TimestampDetector.shared.isEnabled.toggle()
        updateToggleMenuItem()

        // Start or stop the pasteboard monitor based on the new state
        if TimestampDetector.shared.isEnabled {
            pasteboardMonitor?.start()
        } else {
            pasteboardMonitor?.stop()
        }
    }

    @objc private func convertFromClipboard() {
        // Convert from clipboard

        guard let clipboardString = NSPasteboard.general.string(forType: .string) else {
            // No clipboard content
            return
        }

        // Process clipboard content

        if let timestamp = TimestampParser.parse(clipboardString) {
            // Timestamp parsed successfully
            let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
            let format = TimestampParser.guessFormat(clipboardString)
            let model = DisplayModel(
                date: date,
                timezones: PreferencesStore.shared.pinnedTimezones,
                timestamp: timestamp,
                format: format
            )

            // Show popover at current mouse location
            let mouseLocation = NSEvent.mouseLocation
            // Show conversion popover
            PopoverController.shared.show(at: mouseLocation, model: model)
        } else {
            // Invalid timestamp - ignoring
            // Don't show any feedback popup for invalid clipboard content
        }
    }

    @objc private func openPreferences() {
        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
    }

    private func updateToggleMenuItem() {
        if let menu = statusItem?.menu,
            let toggleItem = menu.item(at: 0)
        {
            toggleItem.title =
                TimestampDetector.shared.isEnabled
                ? "Disable Clipboard Monitoring" : "Enable Clipboard Monitoring"
        }
    }

    private func setupPasteboardMonitor() {
        pasteboardMonitor = PasteboardMonitor()
        pasteboardMonitor?.start()
    }

    private func setupPopoverController() {
        popoverController = PopoverController.shared
    }

}
