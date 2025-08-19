import XCTest
@testable import PopZeit

final class TimestampParserTests: XCTestCase {
    
    func testParseValidTimestamps() {
        // Test 10-digit seconds
        XCTAssertEqual(TimestampParser.parse("1724054400"), 1724054400)
        
        // Test 13-digit milliseconds
        XCTAssertEqual(TimestampParser.parse("1724054400000"), 1724054400)
        
        // Test 16-digit microseconds
        XCTAssertEqual(TimestampParser.parse("1724054400000000"), 1724054400)
        
        // Test with underscores
        XCTAssertEqual(TimestampParser.parse("1_724_054_400"), 1724054400)
        
        // Test with commas
        XCTAssertEqual(TimestampParser.parse("1,724,054,400"), 1724054400)
        
        // Test with quotes
        XCTAssertEqual(TimestampParser.parse("\"1724054400\""), 1724054400)
        XCTAssertEqual(TimestampParser.parse("'1724054400'"), 1724054400)
        
        // Test with whitespace
        XCTAssertEqual(TimestampParser.parse(" 1724054400 "), 1724054400)
    }
    
    func testParseInvalidTimestamps() {
        // Test non-numeric strings
        XCTAssertNil(TimestampParser.parse("not_a_number"))
        XCTAssertNil(TimestampParser.parse("abc123"))
        XCTAssertNil(TimestampParser.parse(""))
        
        // Test invalid lengths
        XCTAssertNil(TimestampParser.parse("123"))          // Too short
        XCTAssertNil(TimestampParser.parse("12345678901"))  // 11 digits
        XCTAssertNil(TimestampParser.parse("123456789012")) // 12 digits
        XCTAssertNil(TimestampParser.parse("12345678901234")) // 14 digits
        XCTAssertNil(TimestampParser.parse("123456789012345")) // 15 digits
        
        // Test floating point
        XCTAssertNil(TimestampParser.parse("1724054400.5"))
    }
    
    func testFormatGuessing() {
        XCTAssertEqual(TimestampParser.guessFormat("1724054400"), .seconds)
        XCTAssertEqual(TimestampParser.guessFormat("1724054400000"), .milliseconds)
        XCTAssertEqual(TimestampParser.guessFormat("1724054400000000"), .microseconds)
        XCTAssertNil(TimestampParser.guessFormat("invalid"))
        XCTAssertNil(TimestampParser.guessFormat("123"))
    }
    
    func testAmbiguousTimestamps() {
        // Test very old timestamp (before 2001)
        let oldTimestamp: Int64 = 946684800 // Year 2000
        XCTAssertTrue(TimestampParser.isAmbiguous(oldTimestamp))
        
        // Test future timestamp (after 2286)
        let futureTimestamp: Int64 = 10000000000 // Year 2286+
        XCTAssertTrue(TimestampParser.isAmbiguous(futureTimestamp))
        
        // Test normal timestamp (2024)
        let normalTimestamp: Int64 = 1724054400
        XCTAssertFalse(TimestampParser.isAmbiguous(normalTimestamp))
    }
    
    func testEdgeCases() {
        // Test maximum values for each format
        let maxSeconds = "9999999999"           // 10 digits
        let maxMilliseconds = "9999999999999"   // 13 digits
        let maxMicroseconds = "9999999999999999" // 16 digits
        
        XCTAssertNotNil(TimestampParser.parse(maxSeconds))
        XCTAssertNotNil(TimestampParser.parse(maxMilliseconds))
        XCTAssertNotNil(TimestampParser.parse(maxMicroseconds))
        
        // Test minimum values
        let minSeconds = "0000000001"           // 10 digits with leading zeros
        let minMilliseconds = "0000000001000"   // 13 digits with leading zeros
        let minMicroseconds = "0000000001000000" // 16 digits with leading zeros
        
        XCTAssertEqual(TimestampParser.parse(minSeconds), 1)
        XCTAssertEqual(TimestampParser.parse(minMilliseconds), 1)
        XCTAssertEqual(TimestampParser.parse(minMicroseconds), 1)
    }
    
    func testRealWorldExamples() {
        // Common Unix epoch timestamps
        XCTAssertEqual(TimestampParser.parse("0"), 0)                    // Unix epoch
        XCTAssertEqual(TimestampParser.parse("1000000000"), 1000000000)  // Sept 9, 2001
        XCTAssertEqual(TimestampParser.parse("1577836800"), 1577836800)  // Jan 1, 2020
        XCTAssertEqual(TimestampParser.parse("1704067200"), 1704067200)  // Jan 1, 2024
        
        // JavaScript timestamps (milliseconds)
        XCTAssertEqual(TimestampParser.parse("1577836800000"), 1577836800) // Jan 1, 2020
        XCTAssertEqual(TimestampParser.parse("1704067200000"), 1704067200) // Jan 1, 2024
    }
}