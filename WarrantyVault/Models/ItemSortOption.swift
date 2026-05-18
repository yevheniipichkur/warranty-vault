import Foundation

enum ItemSortOption: String, CaseIterable, Identifiable {
    case newest
    case warrantyExpiration
    case price
    case name

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .newest: "sort.newest"
        case .warrantyExpiration: "sort.warrantyExpiration"
        case .price: "sort.price"
        case .name: "sort.name"
        }
    }

    func sort(_ items: [WarrantyItem]) -> [WarrantyItem] {
        switch self {
        case .newest:
            items.sorted { $0.createdAt > $1.createdAt }
        case .warrantyExpiration:
            items.sorted {
                switch ($0.warrantyExpirationDate, $1.warrantyExpirationDate) {
                case let (lhs?, rhs?):
                    return lhs < rhs
                case (_?, nil):
                    return true
                case (nil, _?):
                    return false
                case (nil, nil):
                    return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }
            }
        case .price:
            items.sorted { $0.price > $1.price }
        case .name:
            items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
    }
}
