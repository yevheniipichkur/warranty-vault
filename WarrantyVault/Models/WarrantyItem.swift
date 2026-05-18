import Foundation
import SwiftData

@Model
final class WarrantyItem: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var brand: String
    var modelName: String
    var serialNumber: String
    var store: String
    var purchaseDate: Date
    var warrantyExpirationDate: Date?
    var hasWarranty: Bool
    var price: Double
    var currency: String
    var category: String
    var notes: String
    var productImagePath: String?
    var receiptImagePath: String?
    var warrantyDocumentImagePath: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        brand: String = "",
        modelName: String = "",
        serialNumber: String = "",
        store: String = "",
        purchaseDate: Date = .now,
        warrantyExpirationDate: Date? = nil,
        hasWarranty: Bool = true,
        price: Double = 0,
        currency: String = "USD",
        category: String = WarrantyCategory.other.rawValue,
        notes: String = "",
        productImagePath: String? = nil,
        receiptImagePath: String? = nil,
        warrantyDocumentImagePath: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.modelName = modelName
        self.serialNumber = serialNumber
        self.store = store
        self.purchaseDate = purchaseDate
        self.warrantyExpirationDate = warrantyExpirationDate
        self.hasWarranty = hasWarranty
        self.price = price
        self.currency = currency
        self.category = category
        self.notes = notes
        self.productImagePath = productImagePath
        self.receiptImagePath = receiptImagePath
        self.warrantyDocumentImagePath = warrantyDocumentImagePath
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension WarrantyItem {
    var warrantyStatus: WarrantyStatus {
        WarrantyStatusProvider.status(
            expirationDate: warrantyExpirationDate,
            hasWarranty: hasWarranty,
            today: .now
        )
    }

    var categoryType: WarrantyCategory {
        WarrantyCategory(rawValue: category) ?? .other
    }

    func matchesSearch(_ query: String) -> Bool {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedQuery.isEmpty else { return true }

        return [
            name,
            brand,
            modelName,
            serialNumber,
            store,
            categoryType.rawValue
        ]
        .map { $0.lowercased() }
        .contains { $0.contains(normalizedQuery) }
    }
}
