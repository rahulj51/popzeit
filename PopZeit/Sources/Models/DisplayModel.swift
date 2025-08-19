import Foundation

struct DisplayModel {
    let date: Date
    let timezones: [String]
    let timestamp: Int64
    let timestampFormat: TimestampFormat?
    
    init(date: Date, timezones: [String], timestamp: Int64? = nil, format: TimestampFormat? = nil) {
        self.date = date
        self.timezones = timezones
        self.timestamp = timestamp ?? Int64(date.timeIntervalSince1970)
        self.timestampFormat = format
    }
    
    var utcString: String {
        Converter.formatUTC(date)
    }
    
    var localString: String {
        Converter.formatLocal(date)
    }
    
    var relativeString: String {
        Converter.formatRelative(date)
    }
    
    var isAmbiguous: Bool {
        TimestampParser.isAmbiguous(timestamp)
    }
    
    var additionalTimezones: [TimezoneDisplay] {
        timezones.compactMap { identifier in
            guard let timezone = TimeZone(identifier: identifier) else { return nil }
            return TimezoneDisplay(
                id: identifier,
                label: timezone.abbreviation() ?? identifier,
                value: Converter.formatTimezone(date, timezone: timezone),
                timezone: timezone
            )
        }
    }
}

struct TimezoneDisplay: Identifiable {
    let id: String
    let label: String
    let value: String
    let timezone: TimeZone
}