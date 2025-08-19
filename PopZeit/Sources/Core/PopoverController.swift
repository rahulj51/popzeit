import Cocoa
import SwiftUI

class PopoverController {
    static let shared = PopoverController()
    
    private var popover: NSPopover?
    private var invisibleWindow: NSWindow?
    private var dismissTimer: Timer?
    private var clickOutsideMonitor: Any?
    
    private init() {}
    
    func show(at screenPoint: NSPoint, model: DisplayModel) {
        // Show popover for timestamp conversion
        
        // Validate that we have meaningful content to show
        guard !model.utcString.isEmpty && !model.localString.isEmpty else {
            // Empty model data, not showing popover
            return
        }
        
        // Close any existing popover
        close()
        
        // Find the screen containing the cursor
        guard let screen = NSScreen.screens.first(where: { screen in
            NSMouseInRect(screenPoint, screen.frame, false)
        }) else {
            // Could not find screen for point
            return
        }
        
        // Create the popover
        let popover = NSPopover()
        popover.behavior = .applicationDefined  // Most stable behavior
        popover.animates = true
        
        // Create the SwiftUI view with environment objects
        let contentView = PopoverView(model: model) { [weak self] in
            self?.close()
        }
        .environmentObject(PreferencesStore.shared)
        
        // Set up the popover content
        let hostingController = NSHostingController(rootView: contentView)
        popover.contentViewController = hostingController
        popover.contentSize = NSSize(width: 360, height: 240)
        
        // Create an invisible window to anchor the popover
        let window = NSWindow(
            contentRect: NSRect(origin: screenPoint, size: NSSize(width: 1, height: 1)),
            styleMask: [],
            backing: .buffered,
            defer: false
        )
        window.level = .floating
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hidesOnDeactivate = false
        window.ignoresMouseEvents = false
        
        // Add a small view to anchor the popover
        let anchorView = NSView(frame: NSRect(x: 0, y: 0, width: 1, height: 1))
        window.contentView = anchorView
        window.makeKeyAndOrderFront(nil)
        // Anchor window created
        
        // Store references first
        self.popover = popover
        self.invisibleWindow = window
        
        // Determine the best edge for the popover
        let preferredEdge = determineEdge(for: screenPoint, in: screen.visibleFrame)
        
        // Show the popover with a slight delay to ensure window is visible
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            // Make sure window and anchorView still exist
            guard let window = self?.invisibleWindow,
                  let anchorView = window.contentView,
                  window.isVisible else {
                // Anchor window not available
                return
            }
            
            // Show popover
            popover.show(
                relativeTo: anchorView.bounds,
                of: anchorView,
                preferredEdge: preferredEdge
            )
            // Popover displayed
            
            // Set up click-outside-to-close monitoring
            if popover.isShown {
                self?.setupClickOutsideMonitoring()
            }
        }
        
        // Start auto-dismiss timer
        startDismissTimer()
    }
    
    func close() {
        // Close popover and cleanup
        
        dismissTimer?.invalidate()
        dismissTimer = nil
        
        if let monitor = clickOutsideMonitor {
            NSEvent.removeMonitor(monitor)
            clickOutsideMonitor = nil
        }
        
        if let popover = popover, popover.isShown {
            popover.performClose(nil)
        }
        popover = nil
        
        if let window = invisibleWindow {
            window.orderOut(nil)
        }
        invisibleWindow = nil
    }
    
    private func determineEdge(for point: NSPoint, in frame: NSRect) -> NSRectEdge {
        // Determine the best edge based on cursor position
        let centerY = frame.midY
        
        // More space below cursor
        if point.y > centerY {
            return .minY
        } else {
            return .maxY
        }
    }
    
    private func setupClickOutsideMonitoring() {
        clickOutsideMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            // Close popover when clicking outside
            self?.close()
        }
    }
    
    private func startDismissTimer() {
        dismissTimer?.invalidate()
        
        let timeout = PreferencesStore.shared.popoverTimeout
        dismissTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
            self?.close()
        }
    }
}