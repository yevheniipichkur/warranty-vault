import Foundation

enum DemoDataProvider {
    static func makeItems(calendar: Calendar = .current, includeDebugExtras: Bool = false, namePrefix: String = "") -> [WarrantyItem] {
        let now = Date()
        let day: TimeInterval = 86_400

        var items = [
            WarrantyItem(
                name: "\(namePrefix)iPhone",
                brand: "Apple",
                modelName: "iPhone 15 Pro",
                serialNumber: "FVFXC0DEMO15",
                store: "Apple Store",
                purchaseDate: now.addingTimeInterval(-120 * day),
                warrantyExpirationDate: calendar.date(byAdding: .month, value: 12, to: now.addingTimeInterval(-120 * day)),
                price: 999,
                currency: "USD",
                category: WarrantyCategory.electronics.rawValue
            ),
            WarrantyItem(
                name: "\(namePrefix)MacBook",
                brand: "Apple",
                modelName: "MacBook Air 13",
                serialNumber: "C02DEMOBOOK",
                store: "Authorized Reseller",
                purchaseDate: now.addingTimeInterval(-260 * day),
                warrantyExpirationDate: calendar.date(byAdding: .month, value: 24, to: now.addingTimeInterval(-260 * day)),
                price: 1299,
                currency: "USD",
                category: WarrantyCategory.electronics.rawValue
            ),
            WarrantyItem(
                name: "\(namePrefix)AirPods",
                brand: "Apple",
                modelName: "AirPods Pro",
                store: "Media Store",
                purchaseDate: now.addingTimeInterval(-340 * day),
                warrantyExpirationDate: now.addingTimeInterval(18 * day),
                price: 249,
                currency: "USD",
                category: WarrantyCategory.electronics.rawValue
            ),
            WarrantyItem(
                name: "\(namePrefix)Washing machine",
                brand: "Bosch",
                modelName: "Series 6",
                store: "Home Market",
                purchaseDate: now.addingTimeInterval(-520 * day),
                warrantyExpirationDate: calendar.date(byAdding: .month, value: 36, to: now.addingTimeInterval(-520 * day)),
                price: 699,
                currency: "USD",
                category: WarrantyCategory.home.rawValue
            ),
            WarrantyItem(
                name: "\(namePrefix)Car battery",
                brand: "Varta",
                store: "Auto Parts",
                purchaseDate: now.addingTimeInterval(-900 * day),
                warrantyExpirationDate: now.addingTimeInterval(-12 * day),
                price: 140,
                currency: "USD",
                category: WarrantyCategory.car.rawValue
            ),
            WarrantyItem(
                name: "\(namePrefix)Coffee machine",
                brand: "De'Longhi",
                modelName: "Magnifica",
                store: "Kitchen Plus",
                purchaseDate: now.addingTimeInterval(-80 * day),
                warrantyExpirationDate: calendar.date(byAdding: .month, value: 24, to: now.addingTimeInterval(-80 * day)),
                price: 429,
                currency: "USD",
                category: WarrantyCategory.kitchen.rawValue
            )
        ]

        if includeDebugExtras {
            items.append(contentsOf: [
                WarrantyItem(
                    name: "\(namePrefix)TV",
                    brand: "Aster",
                    modelName: "Vision 55",
                    store: "Demo Electronics",
                    purchaseDate: now.addingTimeInterval(-400 * day),
                    warrantyExpirationDate: calendar.date(byAdding: .month, value: 24, to: now.addingTimeInterval(-400 * day)),
                    price: 799,
                    currency: "USD",
                    category: WarrantyCategory.electronics.rawValue
                ),
                WarrantyItem(
                    name: "\(namePrefix)Vacuum cleaner",
                    brand: "CleanCo",
                    modelName: "Air Sweep",
                    store: "Home Market",
                    purchaseDate: now.addingTimeInterval(-40 * day),
                    warrantyExpirationDate: nil,
                    hasWarranty: false,
                    price: 179,
                    currency: "USD",
                    category: WarrantyCategory.home.rawValue
                )
            ])
        }

        return items
    }
}
