import Combine
import Foundation

@MainActor
final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published var selectedLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: Self.storageKey)
        }
    }

    private static let storageKey = "selectedLanguage"

    private init() {
        let savedValue = UserDefaults.standard.string(forKey: Self.storageKey) ?? AppLanguage.system.rawValue
        selectedLanguage = AppLanguage(rawValue: savedValue) ?? .system
    }

    var locale: Locale {
        selectedLanguage.locale
    }
}
