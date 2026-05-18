import Combine
import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    static let productIDs = [
        "warrantyvault.pro.monthly",
        "warrantyvault.pro.yearly"
    ]

    @Published private(set) var products: [Product] = []
    @Published private(set) var proEntitlementActive = false
    @Published private var debugUnlockPro: Bool
    @Published var lastErrorMessage: String?

    private static let debugUnlockStorageKey = "debugUnlockPro"

    private init() {
        debugUnlockPro = UserDefaults.standard.bool(forKey: Self.debugUnlockStorageKey)
    }

    var hasPro: Bool {
        proEntitlementActive || debugUnlockPro
    }

    var isDebugProUnlocked: Bool {
        debugUnlockPro
    }

    func setDebugProUnlocked(_ isUnlocked: Bool) {
        debugUnlockPro = isUnlocked
        UserDefaults.standard.set(isUnlocked, forKey: Self.debugUnlockStorageKey)
    }

    func canAddItem(currentCount: Int) -> Bool {
        SubscriptionRules.canAddItem(currentCount: currentCount, isPro: hasPro)
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: Self.productIDs)
            lastErrorMessage = nil
        } catch {
            products = []
            lastErrorMessage = error.localizedDescription
        }
    }

    func refreshEntitlements() async {
        var isActive = false

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }

            if Self.productIDs.contains(transaction.productID), transaction.revocationDate == nil {
                isActive = true
            }
        }

        proEntitlementActive = isActive
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verificationResult):
                if case .verified(let transaction) = verificationResult {
                    await transaction.finish()
                    await refreshEntitlements()
                }
            case .pending, .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }
}
