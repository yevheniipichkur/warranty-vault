import Combine
import Foundation
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let center = UNUserNotificationCenter.current()

    private init() {}

    func refreshAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    @discardableResult
    func requestAuthorizationIfNeeded() async -> Bool {
        await refreshAuthorizationStatus()

        if authorizationStatus == .authorized || authorizationStatus == .provisional {
            return true
        }

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            await refreshAuthorizationStatus()
            return granted
        } catch {
            return false
        }
    }

    func removeReminders(for itemID: UUID) {
        let identifiers = Self.identifiers(for: itemID)
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func rescheduleReminders(for item: WarrantyItem, dayOffsets: [Int] = NotificationManager.defaultReminderOffsets()) async {
        removeReminders(for: item.id)

        guard item.hasWarranty, let expirationDate = item.warrantyExpirationDate else {
            return
        }

        guard await requestAuthorizationIfNeeded() else {
            return
        }

        let language = LanguageManager.shared.selectedLanguage

        for days in dayOffsets {
            guard let triggerDate = Calendar.current.date(byAdding: .day, value: -days, to: expirationDate),
                  triggerDate > Date()
            else {
                continue
            }

            let content = UNMutableNotificationContent()
            content.title = L10n.string("notification.expiring.title", language: language)
            let format = L10n.string("notification.expiring.body", language: language)
            content.body = String(format: format, item.name, days)
            content.sound = .default

            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: Self.identifier(for: item.id, days: days),
                content: content,
                trigger: trigger
            )

            try? await center.add(request)
        }
    }

    func pendingRequests() async -> [UNNotificationRequest] {
        await withCheckedContinuation { continuation in
            center.getPendingNotificationRequests { requests in
                continuation.resume(returning: requests)
            }
        }
    }

    nonisolated static func identifier(for itemID: UUID, days: Int) -> String {
        "warranty-\(itemID.uuidString)-\(days)"
    }

    nonisolated static func identifiers(for itemID: UUID) -> [String] {
        [30, 7, 1].map { identifier(for: itemID, days: $0) }
    }

    nonisolated static func defaultReminderOffsets(userDefaults: UserDefaults = .standard) -> [Int] {
        let defaults: [(key: String, days: Int)] = [
            ("reminderDefault30", 30),
            ("reminderDefault7", 7),
            ("reminderDefault1", 1)
        ]

        return defaults.compactMap { entry in
            if userDefaults.object(forKey: entry.key) == nil {
                return entry.days
            }
            return userDefaults.bool(forKey: entry.key) ? entry.days : nil
        }
    }
}
