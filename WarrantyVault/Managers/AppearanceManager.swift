import Combine
import SwiftUI

@MainActor
final class AppearanceManager: ObservableObject {
    static let shared = AppearanceManager()

    @Published var selectedAppearance: AppAppearance {
        didSet {
            UserDefaults.standard.set(selectedAppearance.rawValue, forKey: Self.storageKey)
        }
    }

    private static let storageKey = "selectedAppearance"

    private init() {
        let savedValue = UserDefaults.standard.string(forKey: Self.storageKey) ?? AppAppearance.system.rawValue
        selectedAppearance = AppAppearance(rawValue: savedValue) ?? .system
    }

    var preferredColorScheme: ColorScheme? {
        selectedAppearance.colorScheme
    }
}
