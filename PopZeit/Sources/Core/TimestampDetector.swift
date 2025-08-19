import Foundation
import Combine

class TimestampDetector: ObservableObject {
    static let shared = TimestampDetector()
    
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "DetectionEnabled")
            // Clipboard monitoring state updated
        }
    }
    
    init() {
        // Default to enabled on first launch
        if UserDefaults.standard.object(forKey: "DetectionEnabled") != nil {
            // Has launched before, use stored value
            self.isEnabled = UserDefaults.standard.bool(forKey: "DetectionEnabled")
            // Using stored detection setting
        } else {
            // First launch, default to enabled
            self.isEnabled = true
            UserDefaults.standard.set(true, forKey: "DetectionEnabled")
            // First launch - enabling detection
        }
    }
}