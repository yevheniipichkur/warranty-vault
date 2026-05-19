import Foundation

enum ProFeature: CaseIterable {
    case unlimitedItems
    case pdfExport
    case receiptGallery
    case advancedFilters
    case iCloudSync
    case barcodeScanner
    case calendarExport
}

enum SubscriptionRules {
    static let freeItemLimit = 10

    static func canAddItem(currentCount: Int, isPro: Bool) -> Bool {
        isPro || currentCount < freeItemLimit
    }

    static func isFeatureAvailable(_ feature: ProFeature, isPro: Bool) -> Bool {
        switch feature {
        case .unlimitedItems, .pdfExport, .receiptGallery, .advancedFilters, .iCloudSync, .barcodeScanner, .calendarExport:
            isPro
        }
    }
}
