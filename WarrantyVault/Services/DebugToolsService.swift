#if DEBUG
import Foundation
import SwiftData
import UserNotifications

struct DebugDiagnostics {
    let documentsPath: String
    let imageCount: Int
    let itemCount: Int
}

@MainActor
enum DebugToolsService {
    static let demoPrefix = "Demo "

    static func seedDemoData(context: ModelContext, existingItems: [WarrantyItem]) {
        removeDemoItems(context: context, existingItems: existingItems)

        for item in DemoDataProvider.makeItems(includeDebugExtras: true, namePrefix: demoPrefix) {
            context.insert(item)
        }

        try? context.save()
    }

    static func clearAllData(context: ModelContext, items: [WarrantyItem]) {
        for item in items {
            deleteAssets(for: item)
            context.delete(item)
        }
        try? context.save()
    }

    static func createExpiringWarrantyItem(context: ModelContext) -> WarrantyItem {
        let item = WarrantyItem(
            name: "\(demoPrefix)Expiring headphones",
            brand: "North Audio",
            modelName: "HA-3",
            serialNumber: "DBG-EXP-003",
            store: "Demo Store",
            purchaseDate: Calendar.current.date(byAdding: .month, value: -11, to: .now) ?? .now,
            warrantyExpirationDate: Calendar.current.date(byAdding: .day, value: 3, to: .now),
            hasWarranty: true,
            price: 129,
            currency: "USD",
            category: WarrantyCategory.electronics.rawValue,
            notes: "Created from Developer / QA menu."
        )
        context.insert(item)
        try? context.save()
        return item
    }

    static func createExpiredWarrantyItem(context: ModelContext) -> WarrantyItem {
        let item = WarrantyItem(
            name: "\(demoPrefix)Expired router",
            brand: "HomeLink",
            modelName: "R-900",
            serialNumber: "DBG-EXP-OLD",
            store: "Demo Store",
            purchaseDate: Calendar.current.date(byAdding: .month, value: -14, to: .now) ?? .now,
            warrantyExpirationDate: Calendar.current.date(byAdding: .day, value: -10, to: .now),
            hasWarranty: true,
            price: 89,
            currency: "USD",
            category: WarrantyCategory.home.rawValue,
            notes: "Created from Developer / QA menu."
        )
        context.insert(item)
        try? context.save()
        return item
    }

    static func createNoWarrantyItem(context: ModelContext) -> WarrantyItem {
        let item = WarrantyItem(
            name: "\(demoPrefix)Vintage lamp",
            brand: "Luma",
            store: "Flea Market",
            purchaseDate: .now,
            warrantyExpirationDate: nil,
            hasWarranty: false,
            price: 34,
            currency: "USD",
            category: WarrantyCategory.furniture.rawValue,
            notes: "No warranty debug item."
        )
        context.insert(item)
        try? context.save()
        return item
    }

    static func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
    }

    static func toggleDebugPro() {
        let manager = SubscriptionManager.shared
        manager.setDebugProUnlocked(!manager.isDebugProUnlocked)
    }

    static func resetDebugPro() {
        SubscriptionManager.shared.setDebugProUnlocked(false)
    }

    static func scheduleTestNotification() async -> String {
        let granted = await NotificationManager.shared.requestAuthorizationIfNeeded()
        guard granted else {
            return "debug.notifications.denied"
        }

        let content = UNMutableNotificationContent()
        content.title = "Warranty Vault QA"
        content.body = "Test notification from Developer / QA menu."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "debug-test-notification", content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
            return "debug.notifications.scheduled"
        } catch {
            return "debug.notifications.failed"
        }
    }

    static func startTestLiveActivity(context: ModelContext) async -> String {
        guard LiveActivityManager.shared.isSupported else {
            return "liveActivity.unavailable"
        }

        let item = WarrantyItem(
            name: "\(demoPrefix)Live Activity Test",
            brand: "QA",
            store: "Debug Lab",
            purchaseDate: .now,
            warrantyExpirationDate: Calendar.current.date(byAdding: .day, value: 7, to: .now),
            hasWarranty: true,
            price: 199,
            currency: "USD",
            category: WarrantyCategory.electronics.rawValue,
            notes: "Live Activity test item."
        )
        context.insert(item)
        try? context.save()

        let started = await LiveActivityManager.shared.startWarrantyActivity(for: item)
        return started ? "liveActivity.started" : (LiveActivityManager.shared.lastMessageKey ?? "liveActivity.failed")
    }

    static func exportTestPDF(context: ModelContext) throws -> URL {
        let item = WarrantyItem(
            name: "\(demoPrefix)PDF Export Test",
            brand: "QA",
            modelName: "PDF-1",
            serialNumber: "DBG-PDF-001",
            store: "Debug Lab",
            purchaseDate: .now,
            warrantyExpirationDate: Calendar.current.date(byAdding: .month, value: 12, to: .now),
            hasWarranty: true,
            price: 49,
            currency: "USD",
            category: WarrantyCategory.documents.rawValue,
            notes: "Generated for PDF export testing."
        )
        context.insert(item)
        try? context.save()
        return try PDFExportService().export(item: item, language: LanguageManager.shared.selectedLanguage)
    }

    static func diagnostics(items: [WarrantyItem]) -> DebugDiagnostics {
        let directory = ImageStorageService.imagesDirectory
        let files = (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        return DebugDiagnostics(
            documentsPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path,
            imageCount: files.count,
            itemCount: items.count
        )
    }

    static func resetAllAppSettings() {
        let defaults = UserDefaults.standard
        [
            "hasCompletedOnboarding",
            "selectedLanguage",
            "selectedAppearance",
            "defaultCurrency",
            "reminderDefault30",
            "reminderDefault7",
            "reminderDefault1",
            "debugMenuUnlocked",
            "debugUnlockPro"
        ].forEach { defaults.removeObject(forKey: $0) }

        LanguageManager.shared.selectedLanguage = .system
        AppearanceManager.shared.selectedAppearance = .system
        SubscriptionManager.shared.setDebugProUnlocked(false)
    }

    private static func removeDemoItems(context: ModelContext, existingItems: [WarrantyItem]) {
        for item in existingItems where item.name.hasPrefix(demoPrefix) {
            deleteAssets(for: item)
            context.delete(item)
        }
    }

    private static func deleteAssets(for item: WarrantyItem) {
        ImageStorageService.deleteImage(at: item.productImagePath)
        ImageStorageService.deleteImage(at: item.receiptImagePath)
        ImageStorageService.deleteImage(at: item.warrantyDocumentImagePath)
        NotificationManager.shared.removeReminders(for: item.id)
    }
}
#endif
