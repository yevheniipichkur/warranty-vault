import Foundation

enum WarrantyStatus: String, CaseIterable, Identifiable {
    case active
    case expiringSoon
    case expired
    case noWarranty

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .active: "status.active"
        case .expiringSoon: "status.expiringSoon"
        case .expired: "status.expired"
        case .noWarranty: "status.noWarranty"
        }
    }

    var symbolName: String {
        switch self {
        case .active: "checkmark.seal.fill"
        case .expiringSoon: "exclamationmark.triangle.fill"
        case .expired: "xmark.seal.fill"
        case .noWarranty: "minus.circle.fill"
        }
    }
}
