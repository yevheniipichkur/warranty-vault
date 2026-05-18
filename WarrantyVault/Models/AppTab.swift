import Foundation

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case items
    case receipts
    case reminders
    case settings

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .home: "tab.home"
        case .items: "tab.items"
        case .receipts: "tab.receipts"
        case .reminders: "tab.reminders"
        case .settings: "tab.settings"
        }
    }

    var symbolName: String {
        switch self {
        case .home: "house.fill"
        case .items: "shippingbox.fill"
        case .receipts: "doc.text.image.fill"
        case .reminders: "bell.badge.fill"
        case .settings: "gearshape.fill"
        }
    }
}
