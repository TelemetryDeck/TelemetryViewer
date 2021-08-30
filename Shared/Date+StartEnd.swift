import Foundation

extension Date {
    var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    var startOfHour: Date {
        let components = utcCalendar.dateComponents([.year, .month, .day, .hour], from: self)
        return utcCalendar.date(from: components)!
    }

    var endOfHour: Date {
        var components = DateComponents()
        components.hour = 1
        components.second = -1
        return utcCalendar.date(byAdding: components, to: startOfHour)!
    }

    var startOfDay: Date {
        utcCalendar.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return utcCalendar.date(byAdding: components, to: startOfDay)!
    }

    var startOfWeek: Date {
        let components = utcCalendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self)
        return utcCalendar.date(from: components)!
    }

    var endOfWeek: Date {
        var components = DateComponents()
        components.weekOfYear = 1
        components.second = -1
        return utcCalendar.date(byAdding: components, to: startOfWeek)!
    }

    var startOfMonth: Date {
        let components = utcCalendar.dateComponents([.year, .month], from: startOfDay)
        return utcCalendar.date(from: components)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return utcCalendar.date(byAdding: components, to: startOfMonth)!
    }
}
