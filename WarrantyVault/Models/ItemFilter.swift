import Foundation

enum ItemFilter: String, CaseIterable, Identifiable {
    case all
    case active
    case expiringSoon
    case expired
    case noWarranty

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .all: "filter.all"
        case .active: "filter.active"
        case .expiringSoon: "filter.expiringSoon"
        case .expired: "filter.expired"
        case .noWarranty: "filter.noWarranty"
        }
    }

    func includes(_ item: WarrantyItem) -> Bool {
        switch self {
        case .all:
            true
        case .active:
            item.warrantyStatus == .active
        case .expiringSoon:
            item.warrantyStatus == .expiringSoon
        case .expired:
            item.warrantyStatus == .expired
        case .noWarranty:
            item.warrantyStatus == .noWarranty
        }
    }
}
