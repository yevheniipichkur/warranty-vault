import Foundation

enum WarrantyStatusProvider {
    static let expiringSoonDayThreshold = 30

    static func status(
        expirationDate: Date?,
        hasWarranty: Bool,
        today: Date,
        calendar: Calendar = .current
    ) -> WarrantyStatus {
        guard hasWarranty, let expirationDate else {
            return .noWarranty
        }

        let startOfToday = calendar.startOfDay(for: today)
        let startOfExpiration = calendar.startOfDay(for: expirationDate)

        if startOfExpiration < startOfToday {
            return .expired
        }

        let days = calendar.dateComponents([.day], from: startOfToday, to: startOfExpiration).day ?? 0
        return days <= expiringSoonDayThreshold ? .expiringSoon : .active
    }
}
