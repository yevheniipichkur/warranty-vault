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

    var attentionCount: Int {
        expiringSoonCount + expiredCount + missingReceiptCount + openReturnWindowCount
    }

    var totalValue: Double {
        items.reduce(0) { $0 + $1.price }
    }

    var missingReceiptCount: Int {
        items.filter { ($0.receiptImagePath ?? "").isEmpty }.count
    }

    var openReturnWindowCount: Int {
        items.filter {
            switch $0.returnWindowStatus {
            case .available, .expiresToday: true
            case .expired, .none: false
            }
        }.count
    }

    var repairRecordCount: Int {
        items.reduce(0) { $0 + $1.repairRecords.count }
    }

    var needsAttention: [WarrantyItem] {
        items
            .filter { $0.warrantyStatus == .expiringSoon || $0.warrantyStatus == .expired }
            .sorted {
                ($0.warrantyExpirationDate ?? .distantPast) < ($1.warrantyExpirationDate ?? .distantPast)
            }
            .prefix(3)
            .map { $0 }
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

    var recentItems: [WarrantyItem] {
        Array(items.prefix(3))
    }
}
