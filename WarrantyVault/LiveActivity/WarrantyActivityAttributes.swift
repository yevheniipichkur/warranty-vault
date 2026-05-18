import ActivityKit
import Foundation

struct WarrantyActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var itemName: String
        var expirationDate: Date
        var daysLeft: Int
    }

    var itemID: String
}
