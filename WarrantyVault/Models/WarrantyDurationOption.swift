import Foundation

enum WarrantyDurationOption: String, CaseIterable, Identifiable {
    case noWarranty
    case sixMonths
    case twelveMonths
    case twentyFourMonths
    case thirtySixMonths
    case customDate

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .noWarranty: "duration.noWarranty"
        case .sixMonths: "duration.6"
        case .twelveMonths: "duration.12"
        case .twentyFourMonths: "duration.24"
        case .thirtySixMonths: "duration.36"
        case .customDate: "duration.custom"
        }
    }

    var monthCount: Int? {
        switch self {
        case .noWarranty, .customDate:
            nil
        case .sixMonths:
            6
        case .twelveMonths:
            12
        case .twentyFourMonths:
            24
        case .thirtySixMonths:
            36
        }
    }
}
