import Foundation

struct TimestampParser {
    
    static func parse(_ text: String) -> Int64? {
        // Clean up the string
        let cleaned = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "'", with: "")
        
        // Try to parse as number
        guard let number = Int64(cleaned) else { return nil }
        
        // Convert to seconds based on digit count
        switch cleaned.count {
        case 10:
            // Already in seconds
            return validateTimestamp(number)
            
        case 13:
            // Milliseconds - convert to seconds
            let seconds = number / 1000
            return validateTimestamp(seconds)
            
        case 16:
            // Microseconds - convert to seconds
            let seconds = number / 1_000_000
            return validateTimestamp(seconds)
            
        default:
            // Not a recognized timestamp format
            return nil
        }
    }
    
    private static func validateTimestamp(_ seconds: Int64) -> Int64? {
        // Validate the timestamp is in a reasonable range
        // Between year 2001 and 2286 (32-bit boundary)
        let minTimestamp: Int64 = 978307200  // January 1, 2001
        let maxTimestamp: Int64 = 9999999999 // November 20, 2286
        
        if seconds >= minTimestamp && seconds <= maxTimestamp {
            return seconds
        }
        
        // Still return it but it will be marked as ambiguous
        return seconds
    }
    
    static func isAmbiguous(_ timestamp: Int64) -> Bool {
        let minTimestamp: Int64 = 978307200  // January 1, 2001
        let maxTimestamp: Int64 = 9999999999 // November 20, 2286
        
        return timestamp < minTimestamp || timestamp > maxTimestamp
    }
    
    static func guessFormat(_ text: String) -> TimestampFormat? {
        let cleaned = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: ",", with: "")
        
        guard Int64(cleaned) != nil else { return nil }
        
        switch cleaned.count {
        case 10: return .seconds
        case 13: return .milliseconds
        case 16: return .microseconds
        default: return nil
        }
    }
}

enum TimestampFormat {
    case seconds
    case milliseconds
    case microseconds
    
    var description: String {
        switch self {
        case .seconds: return "Unix timestamp (seconds)"
        case .milliseconds: return "Unix timestamp (milliseconds)"
        case .microseconds: return "Unix timestamp (microseconds)"
        }
    }
}