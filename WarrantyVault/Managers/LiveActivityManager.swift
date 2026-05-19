import ActivityKit
import Combine
import Foundation

@MainActor
final class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()

    @Published private(set) var activeActivityID: String?
    @Published var lastMessageKey: String?

    private init() {
        if #available(iOS 16.2, *) {
            activeActivityID = Activity<WarrantyActivityAttributes>.activities.first?.id
        }
    }

    var isSupported: Bool {
        if #available(iOS 16.2, *) {
            return ActivityAuthorizationInfo().areActivitiesEnabled
        }
        return false
    }

    func startWarrantyActivity(for item: WarrantyItem) async -> Bool {
        guard #available(iOS 16.2, *) else {
            lastMessageKey = "liveActivity.unavailable"
            return false
        }

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            lastMessageKey = "liveActivity.disabled"
            return false
        }

        guard let expirationDate = item.warrantyExpirationDate,
              item.warrantyStatus != .expired
        else {
            lastMessageKey = "liveActivity.noEligibleItem"
            return false
        }

        await endWarrantyActivity()

        let attributes = WarrantyActivityAttributes(itemID: item.id.uuidString)
        let state = contentState(for: item, expirationDate: expirationDate)
        let content = ActivityContent(state: state, staleDate: Calendar.current.date(byAdding: .hour, value: 8, to: .now))

        do {
            let activity = try Activity<WarrantyActivityAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            activeActivityID = activity.id
            lastMessageKey = "liveActivity.started"
            return true
        } catch {
            lastMessageKey = "liveActivity.failed"
            return false
        }
    }

    func updateWarrantyActivity(for item: WarrantyItem) async {
        guard #available(iOS 16.2, *),
              let expirationDate = item.warrantyExpirationDate,
              let activity = Activity<WarrantyActivityAttributes>.activities.first
        else {
            return
        }

        let state = contentState(for: item, expirationDate: expirationDate)
        await activity.update(ActivityContent(state: state, staleDate: Calendar.current.date(byAdding: .hour, value: 8, to: .now)))
        activeActivityID = activity.id
    }

    func endWarrantyActivity() async {
        guard #available(iOS 16.2, *) else {
            activeActivityID = nil
            return
        }

        for activity in Activity<WarrantyActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        activeActivityID = nil
        lastMessageKey = "liveActivity.stopped"
    }

    nonisolated static func daysLeft(until date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: .now)
        let end = calendar.startOfDay(for: date)
        return max(0, calendar.dateComponents([.day], from: start, to: end).day ?? 0)
    }

    private func contentState(for item: WarrantyItem, expirationDate: Date) -> WarrantyActivityAttributes.ContentState {
        let language = LanguageManager.shared.selectedLanguage

        return WarrantyActivityAttributes.ContentState(
            itemName: item.name,
            expirationDate: expirationDate,
            daysLeft: Self.daysLeft(until: expirationDate),
            statusText: L10n.string("liveActivity.status.expiringSoon", language: language),
            daysLeftText: L10n.string("liveActivity.daysLeft", language: language),
            checkReceiptText: L10n.string("liveActivity.checkReceipt", language: language),
            dayShortText: L10n.string("liveActivity.dayShort", language: language)
        )
    }
}
