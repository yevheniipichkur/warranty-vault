import Foundation

enum WarrantyCategory: String, CaseIterable, Identifiable {
    case electronics
    case home
    case kitchen
    case car
    case tools
    case furniture
    case documents
    case other

    var id: String { rawValue }

    var titleKey: String {
        "category.\(rawValue)"
    }

    var symbolName: String {
        switch self {
        case .electronics: "iphone"
        case .home: "house"
        case .kitchen: "fork.knife"
        case .car: "car"
        case .tools: "wrench.and.screwdriver"
        case .furniture: "sofa"
        case .documents: "doc.text"
        case .other: "shippingbox"
        }
    }
}
