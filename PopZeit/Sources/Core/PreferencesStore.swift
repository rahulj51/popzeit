import Foundation
import SwiftUI

class PreferencesStore: ObservableObject {
    static let shared = PreferencesStore()
    
    @AppStorage("popoverTimeout") var popoverTimeout: TimeInterval = 4.0
    @AppStorage("showDismissProgress") var showDismissProgress: Bool = true
    @AppStorage("showRelativeTime") var showRelativeTime: Bool = true
    // Note: useClipboardFallback removed - clipboard monitoring is now the primary method
    @AppStorage("useLocaleAwareFormatting") var useLocaleAwareFormatting: Bool = true
    
    @AppStorage("utcDateFormat") var utcDateFormat: String = "yyyy-MM-dd HH:mm:ss"
    @AppStorage("localDateFormat") var localDateFormat: String = "yyyy-MM-dd HH:mm:ss z"
    @AppStorage("timezoneDateFormat") var timezoneDateFormat: String = "HH:mm:ss z"
    
    @AppStorage("pinnedTimezones") private var pinnedTimezonesData: Data = Data()
    
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false
    @AppStorage("showDockIcon") var showDockIcon: Bool = false
    
    // Note: sound and animation settings removed - FeedbackProvider was removed
    
    @AppStorage("textSize") var textSize: Double = 13.0
    @AppStorage("useHighContrast") var useHighContrast: Bool = false
    
    var pinnedTimezones: [String] {
        get {
            guard !pinnedTimezonesData.isEmpty,
                  let timezones = try? JSONDecoder().decode([String].self, from: pinnedTimezonesData) else {
                return []
            }
            return timezones
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                pinnedTimezonesData = data
            }
        }
    }
    
    private init() {}
    
    func addTimezone(_ identifier: String) {
        var timezones = pinnedTimezones
        if !timezones.contains(identifier) {
            timezones.append(identifier)
            pinnedTimezones = timezones
        }
    }
    
    func removeTimezone(_ identifier: String) {
        pinnedTimezones = pinnedTimezones.filter { $0 != identifier }
    }
    
    func resetToDefaults() {
        popoverTimeout = 4.0
        showDismissProgress = true
        showRelativeTime = true
        useLocaleAwareFormatting = true
        
        utcDateFormat = "yyyy-MM-dd HH:mm:ss"
        localDateFormat = "yyyy-MM-dd HH:mm:ss z"
        timezoneDateFormat = "HH:mm:ss z"
        
        pinnedTimezones = []
        
        launchAtLogin = false
        showDockIcon = false
        
        textSize = 13.0
        useHighContrast = false
    }
}