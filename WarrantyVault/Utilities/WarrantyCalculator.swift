import Foundation

enum WarrantyCalculator {
    static func expirationDate(
        purchaseDate: Date,
        duration: WarrantyDurationOption,
        customDate: Date? = nil,
        calendar: Calendar = .current
    ) -> Date? {
        if duration == .noWarranty {
            return nil
        }

        if duration == .customDate {
            return customDate
        }

        guard let months = duration.monthCount else {
            return nil
        }

        return calendar.date(byAdding: .month, value: months, to: purchaseDate)
    }
}
