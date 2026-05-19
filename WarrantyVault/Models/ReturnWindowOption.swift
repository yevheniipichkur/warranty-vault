import Foundation

enum ReturnWindowOption: String, CaseIterable, Identifiable {
    case none
    case fourteenDays
    case thirtyDays
    case sixtyDays
    case customDate

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .none: "returnWindow.none"
        case .fourteenDays: "returnWindow.14"
        case .thirtyDays: "returnWindow.30"
        case .sixtyDays: "returnWindow.60"
        case .customDate: "returnWindow.custom"
        }
    }

    var dayCount: Int? {
        switch self {
        case .none, .customDate: nil
        case .fourteenDays: 14
        case .thirtyDays: 30
        case .sixtyDays: 60
        }
    }
}

enum ReturnWindowStatus: Equatable {
    case available(daysLeft: Int)
    case expiresToday
    case expired
    case none

    var titleKey: String {
        switch self {
        case .available: "returnStatus.available"
        case .expiresToday: "returnStatus.today"
        case .expired: "returnStatus.expired"
        case .none: "returnStatus.none"
        }
    }
}

enum ReturnWindowCalculator {
    static func deadlineDate(
        purchaseDate: Date,
        option: ReturnWindowOption,
        calendar: Calendar = .current
    ) -> Date? {
        guard let dayCount = option.dayCount else { return nil }
        return calendar.date(byAdding: .day, value: dayCount, to: purchaseDate)
    }

    static func status(deadlineDate: Date?, today: Date = .now, calendar: Calendar = .current) -> ReturnWindowStatus {
        guard let deadlineDate else { return .none }

        let startOfToday = calendar.startOfDay(for: today)
        let deadlineDay = calendar.startOfDay(for: deadlineDate)

        if deadlineDay < startOfToday {
            return .expired
        }

        let days = calendar.dateComponents([.day], from: startOfToday, to: deadlineDay).day ?? 0
        return days == 0 ? .expiresToday : .available(daysLeft: days)
    }
}
