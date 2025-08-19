import Foundation

struct Converter {
    
    static func formatUTC(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = PreferencesStore.shared.utcDateFormat
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
    
    static func formatLocal(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = PreferencesStore.shared.localDateFormat
        formatter.timeZone = TimeZone.current
        
        // Use locale-aware formatting if enabled
        if PreferencesStore.shared.useLocaleAwareFormatting {
            formatter.setLocalizedDateFormatFromTemplate(PreferencesStore.shared.localDateFormat)
        }
        
        return formatter.string(from: date)
    }
    
    static func formatTimezone(_ date: Date, timezone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = PreferencesStore.shared.timezoneDateFormat
        formatter.timeZone = timezone
        
        if PreferencesStore.shared.useLocaleAwareFormatting {
            formatter.setLocalizedDateFormatFromTemplate(PreferencesStore.shared.timezoneDateFormat)
        }
        
        return formatter.string(from: date)
    }
    
    static func formatRelative(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.dateTimeStyle = .numeric
        
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    static func formatDetailed(_ date: Date, timezone: TimeZone? = nil) -> DetailedTimeInfo {
        let tz = timezone ?? TimeZone.current
        
        let formatter = DateFormatter()
        formatter.timeZone = tz
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Get various components
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        formatter.dateFormat = "HH:mm:ss"
        let timeString = formatter.string(from: date)
        
        formatter.dateFormat = "EEEE"
        let dayOfWeek = formatter.string(from: date)
        
        let calendar = Calendar.current
        let components = calendar.dateComponents(in: tz, from: date)
        
        let dayOfYear: Int
        if #available(macOS 15, *) {
            dayOfYear = components.dayOfYear ?? 0
        } else {
            // Fallback calculation for macOS < 15
            let startOfYear = calendar.dateInterval(of: .year, for: date)?.start ?? date
            let daysSinceStartOfYear = calendar.dateComponents([.day], from: startOfYear, to: date).day ?? 0
            dayOfYear = daysSinceStartOfYear + 1
        }
        
        return DetailedTimeInfo(
            date: dateString,
            time: timeString,
            dayOfWeek: dayOfWeek,
            timezone: tz.abbreviation() ?? tz.identifier,
            offset: tz.secondsFromGMT() / 3600,
            timestamp: Int64(date.timeIntervalSince1970),
            week: components.weekOfYear ?? 0,
            dayOfYear: dayOfYear
        )
    }
}

struct DetailedTimeInfo {
    let date: String
    let time: String
    let dayOfWeek: String
    let timezone: String
    let offset: Int
    let timestamp: Int64
    let week: Int
    let dayOfYear: Int
    
    var fullString: String {
        "\(date) \(time) \(timezone)"
    }
    
    var extendedInfo: String {
        "Week \(week), Day \(dayOfYear) • \(dayOfWeek)"
    }
}