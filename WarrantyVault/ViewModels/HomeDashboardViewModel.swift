import Foundation

struct HomeDashboardViewModel {
    let items: [WarrantyItem]

    var totalItems: Int {
        items.count
    }

    var activeCount: Int {
        items.filter { $0.warrantyStatus == .active }.count
    }

    var expiringSoonCount: Int {
        items.filter { $0.warrantyStatus == .expiringSoon }.count
    }

    var expiredCount: Int {
        items.filter { $0.warrantyStatus == .expired }.count
    }

    var totalValue: Double {
        items.reduce(0) { $0 + $1.price }
    }

    var upcomingExpirations: [WarrantyItem] {
        items
            .filter { $0.hasWarranty && $0.warrantyExpirationDate != nil && $0.warrantyStatus != .expired }
            .sorted {
                ($0.warrantyExpirationDate ?? .distantFuture) < ($1.warrantyExpirationDate ?? .distantFuture)
            }
            .prefix(5)
            .map { $0 }
    }
}
