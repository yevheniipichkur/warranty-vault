import SwiftData
import SwiftUI
import UserNotifications

struct RemindersView: View {
    @Query(sort: \WarrantyItem.createdAt, order: .reverse) private var items: [WarrantyItem]
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var pendingCount = 0

    private var warrantyItems: [WarrantyItem] {
        items
            .filter { $0.hasWarranty && $0.warrantyExpirationDate != nil && $0.warrantyStatus != .expired }
            .sorted { ($0.warrantyExpirationDate ?? .distantFuture) < ($1.warrantyExpirationDate ?? .distantFuture) }
    }

    var body: some View {
        ZStack {
            AmbientBackground(kind: .reminders)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeroCard(
                        titleKey: "reminders.title",
                        messageKey: "reminders.empty.message",
                        artworkKind: .reminder,
                        tint: DesignSystem.Colors.premiumAmber
                    )

                    PremiumCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(titleKey: "reminders.permission", systemImage: "bell.badge")
                            Text(statusTextKey)
                                .font(.body)
                                .foregroundStyle(.secondary)

                            PrimaryButton(titleKey: "reminders.enable", systemImage: "bell.badge") {
                                Task {
                                    _ = await notificationManager.requestAuthorizationIfNeeded()
                                    await refreshPendingCount()
                                }
                            }
                        }
                    }

                    PremiumCard(cornerRadius: DesignSystem.Radius.medium, tint: DesignSystem.Colors.premiumAmber) {
                        HStack {
                            Label("reminders.pending", systemImage: "clock")
                            Spacer()
                            Text("\(pendingCount)")
                                .font(.title3.weight(.bold))
                                .monospacedDigit()
                        }
                    }

                    if warrantyItems.isEmpty {
                        EmptyStateView(
                            symbolName: "bell.slash",
                            titleKey: "reminders.empty.title",
                            messageKey: "reminders.empty.message",
                            illustrationKind: .reminderBell
                        )
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(titleKey: "reminders.upcoming", systemImage: "calendar.badge.clock")
                            ForEach(warrantyItems) { item in
                                ReminderItemRow(item: item) {
                                    Task {
                                        await notificationManager.rescheduleReminders(for: item)
                                        await refreshPendingCount()
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("reminders.title")
        .task {
            await notificationManager.refreshAuthorizationStatus()
            await refreshPendingCount()
        }
    }

    private var statusTextKey: LocalizedStringKey {
        switch notificationManager.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            "reminders.status.enabled"
        case .denied:
            "reminders.status.denied"
        case .notDetermined:
            "reminders.status.notDetermined"
        @unknown default:
            "reminders.status.notDetermined"
        }
    }

    private func refreshPendingCount() async {
        pendingCount = await notificationManager.pendingRequests().count
    }
}

private struct ReminderItemRow: View {
    let item: WarrantyItem
    let scheduleAction: () -> Void

    @Environment(\.locale) private var locale

    var body: some View {
        PremiumCard(cornerRadius: 18, padding: DesignSystem.Spacing.medium, tint: item.warrantyStatus.tint) {
            HStack(spacing: 12) {
                Image(systemName: item.categoryType.symbolName)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(item.warrantyStatus.tint)
                    .frame(width: 42, height: 42)
                    .background(item.warrantyStatus.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                        .lineLimit(1)
                    if let expiration = item.warrantyExpirationDate {
                        Text(DateFormatterProvider.string(from: expiration, locale: locale))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Button(action: scheduleAction) {
                    Image(systemName: "bell.badge")
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 12))
                .accessibilityLabel(Text("detail.addReminder"))
            }
        }
    }
}
