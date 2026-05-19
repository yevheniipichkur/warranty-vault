import SwiftData
import SwiftUI

struct DebugMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var appearanceManager: AppearanceManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Query(sort: \WarrantyItem.createdAt, order: .reverse) private var items: [WarrantyItem]

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("defaultCurrency") private var defaultCurrency = "USD"
    @AppStorage("reminderDefault30") private var reminderDefault30 = true
    @AppStorage("reminderDefault7") private var reminderDefault7 = true
    @AppStorage("reminderDefault1") private var reminderDefault1 = true
    @AppStorage("debugMenuUnlocked") private var debugMenuUnlocked = false

    @State private var confirmation: DebugConfirmation?
    @State private var messageKey: String?
    @State private var diagnostics: DebugDiagnostics?
    @State private var sharedURL: URL?
    @State private var isShowingPaywall = false
    @State private var isShowingPurchaseSuccessPreview = false

    var body: some View {
        Form {
            Section {
                Label(debugBuildLabel, systemImage: "ladybug.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.orange)
            }

            Section("settings.section.storekit") {
                DebugActionRow(titleKey: "settings.storekitRefresh", systemImage: "arrow.clockwise") {
                    Task {
                        await subscriptionManager.loadProducts()
                        await subscriptionManager.refreshEntitlements()
                        messageKey = "debug.storekitRefreshed"
                    }
                }

                DebugActionRow(titleKey: "settings.storekitSync", systemImage: "arrow.triangle.2.circlepath") {
                    Task {
                        await subscriptionManager.syncAppStoreAccount()
                        messageKey = "debug.storekitSynced"
                    }
                }

                if !subscriptionManager.loadDiagnostic.isEmpty {
                    Text(subscriptionManager.loadDiagnostic)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .textSelection(.enabled)
                }

                ForEach(subscriptionManager.diagnosticLines, id: \.self) { line in
                    StoreKitDiagnosticLine(line: line)
                }
            }

            Section("debug.section.data") {
                DebugActionRow(titleKey: "debug.seedDemoData", subtitleKey: "debug.seedDemoData.subtitle", systemImage: "sparkles") {
                    confirmation = .seedDemo
                }
                DebugActionRow(titleKey: "debug.createExpiring", systemImage: "clock.badge.exclamationmark") {
                    _ = DebugToolsService.createExpiringWarrantyItem(context: modelContext)
                    messageKey = "debug.created"
                }
                DebugActionRow(titleKey: "debug.createExpired", systemImage: "xmark.seal") {
                    _ = DebugToolsService.createExpiredWarrantyItem(context: modelContext)
                    messageKey = "debug.created"
                }
                DebugActionRow(titleKey: "debug.createNoWarranty", systemImage: "minus.circle") {
                    _ = DebugToolsService.createNoWarrantyItem(context: modelContext)
                    messageKey = "debug.created"
                }
                DebugActionRow(titleKey: "debug.createReturnWindow", systemImage: "arrow.uturn.backward.circle") {
                    _ = DebugToolsService.createReturnWindowItem(context: modelContext)
                    messageKey = "debug.created"
                }
                DebugActionRow(titleKey: "debug.createRepairHistory", systemImage: "stethoscope") {
                    _ = DebugToolsService.createRepairHistoryItem(context: modelContext)
                    messageKey = "debug.created"
                }
                DebugActionRow(titleKey: "settings.exportJSON", systemImage: "square.and.arrow.up") {
                    do {
                        sharedURL = try JSONExportService.export(items: items)
                    } catch {
                        messageKey = "debug.exportFailed"
                    }
                }
                DebugActionRow(titleKey: "debug.clearAllData", systemImage: "trash", role: .destructive) {
                    confirmation = .clearAllData
                }
            }

            Section("debug.section.paywall") {
                DebugActionRow(titleKey: "debug.togglePro", subtitleKey: subscriptionManager.hasPro ? "settings.proUnlocked" : nil, systemImage: "hammer") {
                    DebugToolsService.toggleDebugPro()
                    messageKey = subscriptionManager.isDebugProUnlocked ? "debug.proEnabled" : "debug.proDisabled"
                }
                DebugActionRow(titleKey: "debug.resetPro", systemImage: "arrow.counterclockwise") {
                    DebugToolsService.resetDebugPro()
                    messageKey = "debug.proReset"
                }
                DebugActionRow(titleKey: "debug.triggerPaywall", systemImage: "crown") {
                    isShowingPaywall = true
                }
                DebugActionRow(titleKey: "debug.previewPurchaseSuccess", systemImage: "sparkles") {
                    isShowingPurchaseSuccessPreview = true
                }
            }

            Section("debug.section.notifications") {
                DebugActionRow(titleKey: "debug.testNotifications", systemImage: "bell") {
                    Task {
                        messageKey = await DebugToolsService.scheduleTestNotification()
                    }
                }
            }

            Section("debug.section.liveActivity") {
                DebugActionRow(titleKey: "debug.testLiveActivity", systemImage: "activity") {
                    Task {
                        messageKey = await DebugToolsService.startTestLiveActivity(context: modelContext)
                    }
                }
                DebugActionRow(titleKey: "liveActivity.stop", systemImage: "stop.circle") {
                    Task {
                        await LiveActivityManager.shared.endWarrantyActivity()
                        messageKey = "liveActivity.stopped"
                    }
                }
            }

            Section("debug.section.pdf") {
                DebugActionRow(titleKey: "debug.exportTestPDF", systemImage: "doc.richtext") {
                    do {
                        sharedURL = try DebugToolsService.exportTestPDF(context: modelContext)
                    } catch {
                        messageKey = "debug.exportFailed"
                    }
                }
            }

            Section("debug.section.localization") {
                Picker("settings.language", selection: $languageManager.selectedLanguage) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(LocalizedStringKey(language.titleKey)).tag(language)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("debug.section.appearance") {
                Picker("settings.appearance", selection: $appearanceManager.selectedAppearance) {
                    ForEach(AppAppearance.allCases) { appearance in
                        Text(LocalizedStringKey(appearance.titleKey)).tag(appearance)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("debug.section.diagnostics") {
                DebugActionRow(titleKey: "debug.showAppPaths", systemImage: "folder") {
                    diagnostics = DebugToolsService.diagnostics(items: items)
                }

                if let diagnostics {
                    Text("Documents: \(diagnostics.documentsPath)")
                        .font(.caption)
                        .textSelection(.enabled)
                    Text("Items: \(diagnostics.itemCount)")
                        .font(.caption)
                    Text("Images: \(diagnostics.imageCount)")
                        .font(.caption)
                }
            }

            Section("debug.section.reset") {
                DebugActionRow(titleKey: "debug.disableMenu", systemImage: "eye.slash") {
                    debugMenuUnlocked = false
                    dismiss()
                }

                DebugActionRow(titleKey: "debug.resetOnboarding", systemImage: "rectangle.stack") {
                    DebugToolsService.resetOnboarding()
                    hasCompletedOnboarding = false
                    messageKey = "debug.resetDone"
                }
                DebugActionRow(titleKey: "debug.resetAllSettings", systemImage: "arrow.triangle.2.circlepath", role: .destructive) {
                    confirmation = .resetSettings
                }
            }
        }
        .overlay {
            if isShowingPurchaseSuccessPreview {
                PurchaseSuccessOverlay {
                    withAnimation(.easeOut(duration: 0.2)) {
                        isShowingPurchaseSuccessPreview = false
                    }
                }
            }
        }
        .navigationTitle("debug.title")
        .sheet(isPresented: $isShowingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: Binding(
            get: { sharedURL != nil },
            set: { isPresented in
                if !isPresented { sharedURL = nil }
            }
        )) {
            if let sharedURL {
                ShareSheet(items: [sharedURL])
            }
        }
        .alert("debug.message.title", isPresented: Binding(
            get: { messageKey != nil },
            set: { isPresented in
                if !isPresented { messageKey = nil }
            }
        )) {
            Button("common.ok", role: .cancel) {}
        } message: {
            Text(LocalizedStringKey(messageKey ?? "debug.done"))
        }
        .confirmationDialog("debug.confirm.title", isPresented: Binding(
            get: { confirmation != nil },
            set: { isPresented in
                if !isPresented { confirmation = nil }
            }
        ), titleVisibility: .visible) {
            if let confirmation {
                Button(LocalizedStringKey(confirmation.buttonKey), role: confirmation.role) {
                    run(confirmation)
                    self.confirmation = nil
                }
            }
            Button("common.cancel", role: .cancel) {
                confirmation = nil
            }
        } message: {
            Text(LocalizedStringKey(confirmation?.messageKey ?? "debug.confirm.message"))
        }
    }

    private func run(_ confirmation: DebugConfirmation) {
        switch confirmation {
        case .seedDemo:
            DebugToolsService.seedDemoData(context: modelContext, existingItems: items)
            messageKey = "debug.seeded"
        case .clearAllData:
            DebugToolsService.clearAllData(context: modelContext, items: items)
            messageKey = "debug.cleared"
        case .resetSettings:
            DebugToolsService.resetAllAppSettings()
            debugMenuUnlocked = false
            hasCompletedOnboarding = false
            defaultCurrency = "USD"
            reminderDefault30 = true
            reminderDefault7 = true
            reminderDefault1 = true
            messageKey = "debug.resetDone"
        }
    }

    private var debugBuildLabel: String {
        #if DEBUG
        return "DEBUG BUILD"
        #else
        return "QA MODE"
        #endif
    }
}

typealias QASettingsView = DebugMenuView
typealias DebugSettingsView = DebugMenuView

private enum DebugConfirmation {
    case seedDemo
    case clearAllData
    case resetSettings

    var buttonKey: String {
        switch self {
        case .seedDemo: "debug.seedDemoData"
        case .clearAllData: "debug.clearAllData"
        case .resetSettings: "debug.resetAllSettings"
        }
    }

    var messageKey: String {
        switch self {
        case .seedDemo: "debug.seedConfirm.message"
        case .clearAllData: "settings.deleteAll.message"
        case .resetSettings: "debug.resetSettings.message"
        }
    }

    var role: ButtonRole? {
        switch self {
        case .clearAllData, .resetSettings: .destructive
        case .seedDemo: nil
        }
    }
}
