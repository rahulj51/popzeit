import Cocoa

class PasteboardMonitor {
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    
    func start() {
        // Starting clipboard monitoring
        
        // Initialize with current pasteboard state
        lastChangeCount = NSPasteboard.general.changeCount
        
        // Check pasteboard every 0.5 seconds on main thread
        DispatchQueue.main.async { [weak self] in
            self?.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                self?.checkPasteboard()
            }
        }
        
        // Clipboard monitoring started
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        // Clipboard monitoring stopped
    }
    
    private func checkPasteboard() {
        guard TimestampDetector.shared.isEnabled else { return }
        
        let currentChangeCount = NSPasteboard.general.changeCount
        
        // Only process if pasteboard has changed
        guard currentChangeCount != lastChangeCount else { return }
        
        lastChangeCount = currentChangeCount
        
        // Get clipboard content
        guard let clipboardString = NSPasteboard.general.string(forType: .string) else {
            return
        }
        
        let trimmed = clipboardString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Don't process if empty
        guard !trimmed.isEmpty else {
            return
        }
        
        // Try to parse as timestamp
        if let timestamp = TimestampParser.parse(trimmed) {
            // Process detected timestamp
            
            let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
            let format = TimestampParser.guessFormat(trimmed)
            let model = DisplayModel(
                date: date,
                timezones: PreferencesStore.shared.pinnedTimezones,
                timestamp: timestamp,
                format: format
            )
            
            // Show popover at current mouse location
            let mouseLocation = NSEvent.mouseLocation
            PopoverController.shared.show(at: mouseLocation, model: model)
        }
    }
    
    deinit {
        stop()
    }
}