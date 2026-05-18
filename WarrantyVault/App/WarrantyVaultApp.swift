import SwiftData
import SwiftUI

@main
struct WarrantyVaultApp: App {
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var appearanceManager = AppearanceManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(languageManager)
                .environmentObject(appearanceManager)
                .environmentObject(subscriptionManager)
                .environment(\.locale, languageManager.locale)
                .preferredColorScheme(appearanceManager.preferredColorScheme)
                .task {
                    await subscriptionManager.refreshEntitlements()
                    await subscriptionManager.loadProducts()
                }
        }
        .modelContainer(for: WarrantyItem.self)
    }
}
