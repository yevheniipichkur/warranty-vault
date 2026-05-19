import Foundation

enum CurrencyFormatterProvider {
    static let commonCurrencies: [String] = [
        "USD", "EUR", "GBP", "PLN", "UAH", "CHF", "CAD", "AUD",
        "JPY", "CNY", "SEK", "NOK", "DKK", "CZK", "HUF", "RON",
        "TRY", "KRW", "INR", "BRL", "MXN", "SGD", "HKD", "NZD",
        "AED", "SAR", "ZAR", "ILS", "THB", "MYR", "IDR", "PHP"
    ]

    static func displayName(for code: String) -> String {
        let name = Locale.current.localizedString(forCurrencyCode: code) ?? code
        let symbol = Locale.current.currencySymbol ?? ""
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.currencyCode = code
        fmt.locale = Locale(identifier: "en_US")
        fmt.maximumFractionDigits = 0
        let sym = fmt.currencySymbol ?? code
        if sym == code { return "\(code) — \(name)" }
        return "\(code) \(sym) — \(name)"
    }

    static func string(from value: Double, currencyCode: String, locale: Locale = .autoupdatingCurrent) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(currencyCode) \(value)"
    }
}
