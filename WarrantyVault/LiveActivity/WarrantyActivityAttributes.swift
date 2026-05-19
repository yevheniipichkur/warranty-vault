import ActivityKit
import Foundation

struct WarrantyActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var itemName: String
        var expirationDate: Date
        var daysLeft: Int
        var statusText: String
        var daysLeftText: String
        var checkReceiptText: String
        var dayShortText: String
    }

    var itemID: String
}
