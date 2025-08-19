import XCTest
@testable import PopZeit

final class ConverterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Reset preferences to defaults for consistent testing
        PreferencesStore.shared.resetToDefaults()
    }
    
    func testUTCFormatting() {
        // Test with known timestamp: January 1, 2024 00:00:00 UTC
        let date = Date(timeIntervalSince1970: 1704067200)
        let formatted = Converter.formatUTC(date)
        
        // Should match default UTC format
        XCTAssertEqual(formatted, "2024-01-01 00:00:00")
    }
    
    func testLocalFormatting() {
        let date = Date(timeIntervalSince1970: 1704067200)
        let formatted = Converter.formatLocal(date)
        
        // Should include timezone information
        XCTAssertTrue(formatted.contains("2024-01-01"))
        XCTAssertTrue(formatted.contains(":"))
    }
    
    func testTimezoneFormatting() {
        let date = Date(timeIntervalSince1970: 1704067200)
        let utcTimezone = TimeZone(abbreviation: "UTC")!
        let formatted = Converter.formatTimezone(date, timezone: utcTimezone)
        
        XCTAssertTrue(formatted.contains("00:00:00"))
        XCTAssertTrue(formatted.contains("UTC") || formatted.contains("GMT"))
    }
    
    func testRelativeFormatting() {
        // Test with recent date
        let fiveMinutesAgo = Date(timeIntervalSinceNow: -300)
        let formatted = Converter.formatRelative(fiveMinutesAgo)
        
        XCTAssertTrue(formatted.contains("minute") || formatted.contains("ago"))
    }
    
    func testDetailedTimeInfo() {
        let date = Date(timeIntervalSince1970: 1704067200) // Jan 1, 2024 00:00:00 UTC
        let utcTimezone = TimeZone(abbreviation: "UTC")!
        let info = Converter.formatDetailed(date, timezone: utcTimezone)
        
        XCTAssertEqual(info.date, "2024-01-01")
        XCTAssertEqual(info.time, "00:00:00")
        XCTAssertEqual(info.timestamp, 1704067200)
        XCTAssertEqual(info.timezone, "UTC")
        XCTAssertEqual(info.offset, 0)
    }
    
    func testCustomDateFormats() {
        let date = Date(timeIntervalSince1970: 1704067200)
        
        // Test custom UTC format
        PreferencesStore.shared.utcDateFormat = "MMM d, yyyy HH:mm"
        let customFormatted = Converter.formatUTC(date)
        XCTAssertTrue(customFormatted.contains("Jan"))
        XCTAssertTrue(customFormatted.contains("2024"))
        XCTAssertTrue(customFormatted.contains("00:00"))
    }
    
    func testEdgeCaseDates() {
        // Test Unix epoch
        let epochDate = Date(timeIntervalSince1970: 0)
        let epochFormatted = Converter.formatUTC(epochDate)
        XCTAssertEqual(epochFormatted, "1970-01-01 00:00:00")
        
        // Test Y2K
        let y2kDate = Date(timeIntervalSince1970: 946684800)
        let y2kFormatted = Converter.formatUTC(y2kDate)
        XCTAssertEqual(y2kFormatted, "2000-01-01 00:00:00")
        
        // Test future date
        let futureDate = Date(timeIntervalSince1970: 2000000000) // May 18, 2033
        let futureFormatted = Converter.formatUTC(futureDate)
        XCTAssertTrue(futureFormatted.contains("2033"))
    }
    
    func testTimezoneHandling() {
        let date = Date(timeIntervalSince1970: 1704067200)
        
        // Test different timezones
        if let nyTimezone = TimeZone(identifier: "America/New_York") {
            let nyFormatted = Converter.formatTimezone(date, timezone: nyTimezone)
            XCTAssertTrue(nyFormatted.contains("EST") || nyFormatted.contains("EDT") || nyFormatted.contains("-05") || nyFormatted.contains("-04"))
        }
        
        if let tokyoTimezone = TimeZone(identifier: "Asia/Tokyo") {
            let tokyoFormatted = Converter.formatTimezone(date, timezone: tokyoTimezone)
            XCTAssertTrue(tokyoFormatted.contains("JST") || tokyoFormatted.contains("+09"))
        }
    }
    
    func testRelativeTimeVariations() {
        let now = Date()
        
        // Test various time intervals
        let oneHourAgo = Date(timeInterval: -3600, since: now)
        let oneDayAgo = Date(timeInterval: -86400, since: now)
        let oneWeekAgo = Date(timeInterval: -604800, since: now)
        
        let oneHourRelative = Converter.formatRelative(oneHourAgo)
        let oneDayRelative = Converter.formatRelative(oneDayAgo)
        let oneWeekRelative = Converter.formatRelative(oneWeekAgo)
        
        XCTAssertTrue(oneHourRelative.contains("hour") || oneHourRelative.contains("ago"))
        XCTAssertTrue(oneDayRelative.contains("day") || oneDayRelative.contains("yesterday") || oneDayRelative.contains("ago"))
        XCTAssertTrue(oneWeekRelative.contains("week") || oneWeekRelative.contains("day") || oneWeekRelative.contains("ago"))
    }
}