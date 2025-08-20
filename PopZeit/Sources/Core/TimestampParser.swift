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
        
        // First, try to parse as UUIDv1
        if let uuidTimestamp = parseUUIDv1(cleaned) {
            return uuidTimestamp
        }
        
        // Try to parse as ULID
        if let ulidTimestamp = parseULID(cleaned) {
            return ulidTimestamp
        }
        
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
    
    private static func parseUUIDv1(_ text: String) -> Int64? {
        // UUIDv1 format: XXXXXXXX-XXXX-1XXX-XXXX-XXXXXXXXXXXX
        // The version 1 UUID has the version in the high nibble of the 7th byte
        let uuid = text.replacingOccurrences(of: "-", with: "").lowercased()
        
        // Check if it's a valid UUID format (32 hex chars)
        guard uuid.count == 32,
              uuid.range(of: "^[0-9a-f]{32}$", options: .regularExpression) != nil else {
            return nil
        }
        
        // Check if it's version 1 (time-based UUID)
        // The version is in the most significant 4 bits of the 7th byte (13th hex char)
        let versionIndex = uuid.index(uuid.startIndex, offsetBy: 12)
        let versionChar = uuid[versionIndex]
        guard versionChar == "1" else {
            return nil
        }
        
        // Extract timestamp components
        // UUIDv1 stores time as 100-nanosecond intervals since October 15, 1582
        // Time is stored in three parts:
        // - time_low: bytes 0-3 (chars 0-7)
        // - time_mid: bytes 4-5 (chars 8-11)
        // - time_hi: bytes 6-7 (chars 12-15, but only lower 12 bits)
        
        let timeLowStr = String(uuid.prefix(8))
        let timeMidStr = String(uuid.dropFirst(8).prefix(4))
        let timeHiStr = String(uuid.dropFirst(12).prefix(4))
        
        guard let timeLow = UInt64(timeLowStr, radix: 16),
              let timeMid = UInt64(timeMidStr, radix: 16),
              let timeHi = UInt64(timeHiStr, radix: 16) else {
            return nil
        }
        
        // Reconstruct the 60-bit timestamp
        // Note: time_hi has version in upper 4 bits, so mask with 0x0FFF
        let timestamp = (timeHi & 0x0FFF) << 48 | timeMid << 32 | timeLow
        
        // Convert from 100-nanosecond intervals since 1582-10-15 to Unix timestamp
        // Difference between 1582-10-15 and 1970-01-01 in 100-nanosecond intervals
        let gregorianToUnixOffset: UInt64 = 122192928000000000
        
        guard timestamp > gregorianToUnixOffset else {
            return nil
        }
        
        let unixNanos = (timestamp - gregorianToUnixOffset) * 100
        let unixSeconds = Int64(unixNanos / 1_000_000_000)
        
        return validateTimestamp(unixSeconds)
    }
    
    private static func parseULID(_ text: String) -> Int64? {
        // ULID format: 26 characters in Crockford's Base32
        // First 10 characters encode 48-bit timestamp (milliseconds since Unix epoch)
        let ulid = text.uppercased()
        
        // Check if it's valid ULID format
        guard ulid.count == 26 else {
            return nil
        }
        
        // Crockford's Base32 alphabet (excluding I, L, O, U to avoid confusion)
        let alphabet = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
        
        // Validate all characters are in the alphabet
        guard ulid.allSatisfy({ alphabet.contains($0) }) else {
            return nil
        }
        
        // Extract and decode the timestamp part (first 10 characters)
        let timestampPart = String(ulid.prefix(10))
        var timestamp: UInt64 = 0
        
        for char in timestampPart {
            guard let index = alphabet.firstIndex(of: char) else {
                return nil
            }
            let value = alphabet.distance(from: alphabet.startIndex, to: index)
            timestamp = timestamp * 32 + UInt64(value)
        }
        
        // ULID timestamp is in milliseconds, convert to seconds
        let seconds = Int64(timestamp / 1000)
        
        return validateTimestamp(seconds)
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
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "'", with: "")
        
        // Check for UUIDv1
        let uuidPattern = text.replacingOccurrences(of: "-", with: "").lowercased()
        if uuidPattern.count == 32,
           uuidPattern.range(of: "^[0-9a-f]{32}$", options: .regularExpression) != nil {
            let versionIndex = uuidPattern.index(uuidPattern.startIndex, offsetBy: 12)
            if uuidPattern[versionIndex] == "1" {
                return .uuidv1
            }
        }
        
        // Check for ULID
        let ulidPattern = cleaned.uppercased()
        if ulidPattern.count == 26 {
            let alphabet = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
            if ulidPattern.allSatisfy({ alphabet.contains($0) }) {
                return .ulid
            }
        }
        
        // Check for numeric timestamps
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
    case uuidv1
    case ulid
    
    var description: String {
        switch self {
        case .seconds: return "Unix timestamp (seconds)"
        case .milliseconds: return "Unix timestamp (milliseconds)"
        case .microseconds: return "Unix timestamp (microseconds)"
        case .uuidv1: return "UUIDv1 (time-based UUID)"
        case .ulid: return "ULID (Universally Unique Lexicographically Sortable ID)"
        }
    }
}