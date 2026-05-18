import Foundation

enum SubscriptionRules {
    static let freeItemLimit = 10

    static func canAddItem(currentCount: Int, isPro: Bool) -> Bool {
        isPro || currentCount < freeItemLimit
    }
}
