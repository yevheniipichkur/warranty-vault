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
    @Published private(set) var loadDiagnostic: String = ""
    @Published private(set) var diagnosticLines: [String] = []

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
        loadDiagnostic = "Requesting \(Self.productIDs.count) product(s)..."
        do {
            for attempt in 1...3 {
                let loaded = try await Product.products(for: Self.productIDs)
                products = loaded
                lastErrorMessage = nil
                diagnosticLines = await makeDiagnosticLines()

                if !loaded.isEmpty {
                    loadDiagnostic = "Loaded \(loaded.count)/\(Self.productIDs.count): \(loaded.map(\.id).joined(separator: ", "))"
                    return
                }

                if attempt < 3 {
                    loadDiagnostic = "StoreKit returned 0 products on attempt \(attempt)/3. Retrying..."
                    try? await Task.sleep(nanoseconds: UInt64(attempt) * 1_500_000_000)
                }
            }

            loadDiagnostic = "StoreKit returned 0 products for IDs: \(Self.productIDs.joined(separator: ", "))"
        } catch {
            products = []
            lastErrorMessage = error.localizedDescription
            diagnosticLines = await makeDiagnosticLines()
            loadDiagnostic = "Error: \(error.localizedDescription)"
        }
    }

    func syncAppStoreAccount() async {
        loadDiagnostic = "Syncing App Store account..."
        do {
            try await AppStore.sync()
            lastErrorMessage = nil
            await refreshEntitlements()
            await loadProducts()
        } catch {
            lastErrorMessage = error.localizedDescription
            diagnosticLines = await makeDiagnosticLines()
            loadDiagnostic = "App Store sync failed: \(error.localizedDescription)"
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

    private func makeDiagnosticLines() async -> [String] {
        let bundleID = Bundle.main.bundleIdentifier ?? "unknown"
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown"
        let receiptName = Bundle.main.appStoreReceiptURL?.lastPathComponent ?? "none"
        let canMakePayments = SKPaymentQueue.canMakePayments() ? "yes" : "no"
        let environment = await appTransactionEnvironment()

        return [
            "Bundle ID: \(bundleID)",
            "Version: \(version) (\(build))",
            "Receipt: \(receiptName)",
            "StoreKit environment: \(environment)",
            "Can make payments: \(canMakePayments)",
            "Requested IDs: \(Self.productIDs.joined(separator: ", "))"
        ]
    }

    private func appTransactionEnvironment() async -> String {
        do {
            let result = try await AppTransaction.shared
            switch result {
            case .verified(let transaction):
                return String(describing: transaction.environment)
            case .unverified(let transaction, let error):
                return "\(String(describing: transaction.environment)) (unverified: \(error.localizedDescription))"
            }
        } catch {
            return "unavailable: \(error.localizedDescription)"
        }
    }
}
