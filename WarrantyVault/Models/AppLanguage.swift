import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english = "en"
    case polish = "pl"
    case ukrainian = "uk"
    case russian = "ru"

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .system: "language.system"
        case .english: "language.english"
        case .polish: "language.polish"
        case .ukrainian: "language.ukrainian"
        case .russian: "language.russian"
        }
    }

    var locale: Locale {
        switch self {
        case .system:
            .autoupdatingCurrent
        case .english:
            Locale(identifier: "en")
        case .polish:
            Locale(identifier: "pl")
        case .ukrainian:
            Locale(identifier: "uk")
        case .russian:
            Locale(identifier: "ru")
        }
    }

    var lprojCode: String? {
        switch self {
        case .system: nil
        case .english: "en"
        case .polish: "pl"
        case .ukrainian: "uk"
        case .russian: "ru"
        }
    }
}
