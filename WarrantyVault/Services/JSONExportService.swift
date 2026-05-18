import Foundation

enum JSONExportService {
    static func export(items: [WarrantyItem]) throws -> URL {
        let payload = items.map(ExportedWarrantyItem.init)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("warranty-vault-export.json")
        try data.write(to: url, options: [.atomic])
        return url
    }
}

private struct ExportedWarrantyItem: Codable {
    let id: UUID
    let name: String
    let brand: String
    let modelName: String
    let serialNumber: String
    let store: String
    let purchaseDate: Date
    let warrantyExpirationDate: Date?
    let hasWarranty: Bool
    let price: Double
    let currency: String
    let category: String
    let notes: String
    let createdAt: Date
    let updatedAt: Date

    init(item: WarrantyItem) {
        id = item.id
        name = item.name
        brand = item.brand
        modelName = item.modelName
        serialNumber = item.serialNumber
        store = item.store
        purchaseDate = item.purchaseDate
        warrantyExpirationDate = item.warrantyExpirationDate
        hasWarranty = item.hasWarranty
        price = item.price
        currency = item.currency
        category = item.category
        notes = item.notes
        createdAt = item.createdAt
        updatedAt = item.updatedAt
    }
}
