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
    
    func testUUIDv1Parsing() {
        // Test valid UUIDv1 with hyphens
        // This is a sample UUIDv1 generated for approximately 2024-01-01 00:00:00 UTC
        let uuid1 = "9b1deb4d-3b7d-11ef-b4a3-0242ac120002"
        let timestamp = TimestampParser.parse(uuid1)
        XCTAssertNotNil(timestamp)
        
        // Test valid UUIDv1 without hyphens
        let uuid1NoHyphens = "9b1deb4d3b7d11efb4a30242ac120002"
        let timestamp2 = TimestampParser.parse(uuid1NoHyphens)
        XCTAssertNotNil(timestamp2)
        XCTAssertEqual(timestamp, timestamp2)
        
        // Test format detection
        XCTAssertEqual(TimestampParser.guessFormat(uuid1), .uuidv1)
        XCTAssertEqual(TimestampParser.guessFormat(uuid1NoHyphens), .uuidv1)
        
        // Test non-v1 UUID (should return nil)
        let uuid4 = "550e8400-e29b-41d4-a716-446655440000" // Version 4 UUID
        XCTAssertNil(TimestampParser.parse(uuid4))
        XCTAssertNil(TimestampParser.guessFormat(uuid4))
        
        // Test invalid UUID format
        XCTAssertNil(TimestampParser.parse("not-a-uuid"))
        XCTAssertNil(TimestampParser.parse("123456789012345678901234567890ab")) // 32 chars but not hex
    }
    
    func testULIDParsing() {
        // Test valid ULID - represents timestamp around 2024
        let ulid = "01HK3D4R0G0000000000000000"
        let timestamp = TimestampParser.parse(ulid)
        XCTAssertNotNil(timestamp)
        
        // Test format detection
        XCTAssertEqual(TimestampParser.guessFormat(ulid), .ulid)
        
        // Test ULID with lowercase (should still work, as we uppercase it)
        let ulidLowercase = "01hk3d4r0g0000000000000000"
        let timestamp2 = TimestampParser.parse(ulidLowercase)
        XCTAssertNotNil(timestamp2)
        XCTAssertEqual(timestamp, timestamp2)
        
        // Test invalid ULID - wrong length
        XCTAssertNil(TimestampParser.parse("01HK3D4R0G00000"))
        
        // Test invalid ULID - contains invalid characters (I, L, O, U)
        XCTAssertNil(TimestampParser.parse("01HK3D4R0G0000000000000ILO"))
        XCTAssertNil(TimestampParser.guessFormat("01HK3D4R0G0000000000000ILO"))
        
        // Test another valid ULID
        let ulid2 = "01AN4Z07BY79KA1307SR9X4MV3"
        let timestamp3 = TimestampParser.parse(ulid2)
        XCTAssertNotNil(timestamp3)
        XCTAssertEqual(TimestampParser.guessFormat(ulid2), .ulid)
    }
    
    func testMixedFormatDetection() {
        // Ensure different formats are correctly identified
        XCTAssertEqual(TimestampParser.guessFormat("1704067200"), .seconds)
        XCTAssertEqual(TimestampParser.guessFormat("1704067200000"), .milliseconds)
        XCTAssertEqual(TimestampParser.guessFormat("1704067200000000"), .microseconds)
        XCTAssertEqual(TimestampParser.guessFormat("9b1deb4d-3b7d-11ef-b4a3-0242ac120002"), .uuidv1)
        XCTAssertEqual(TimestampParser.guessFormat("01HK3D4R0G0000000000000000"), .ulid)
        
        // Test with various formatting
        XCTAssertEqual(TimestampParser.guessFormat("\"01HK3D4R0G0000000000000000\""), .ulid)
        XCTAssertEqual(TimestampParser.guessFormat("'9b1deb4d-3b7d-11ef-b4a3-0242ac120002'"), .uuidv1)
    }
}