import Foundation

enum L10n {
    static func string(_ key: String, language: AppLanguage = .system) -> String {
        guard let code = language.lprojCode,
              let path = Bundle.main.path(forResource: code, ofType: "lproj"),
              let bundle = Bundle(path: path)
        else {
            return Bundle.main.localizedString(forKey: key, value: key, table: nil)
        }

        return bundle.localizedString(forKey: key, value: key, table: nil)
    }

    static func string(_ key: String, locale: Locale) -> String {
        let languageCode = locale.identifier.split(separator: "_").first.map(String.init)
        guard let languageCode,
              let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
              let bundle = Bundle(path: path)
        else {
            return Bundle.main.localizedString(forKey: key, value: key, table: nil)
        }

        return bundle.localizedString(forKey: key, value: key, table: nil)
    }
}
