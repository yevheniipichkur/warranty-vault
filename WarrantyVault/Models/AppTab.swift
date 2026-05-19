import Foundation

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case items
    case reminders
    case settings

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .home: "tab.home"
        case .items: "tab.items"
        case .reminders: "tab.reminders"
        case .settings: "tab.settings"
        }
    }

    var symbolName: String {
        switch self {
        case .home: "house.fill"
        case .items: "shippingbox.fill"
        case .reminders: "bell.badge.fill"
        case .settings: "gearshape.fill"
        }
    }
}
