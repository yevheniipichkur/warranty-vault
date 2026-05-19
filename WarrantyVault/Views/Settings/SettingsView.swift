import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var appearanceManager: AppearanceManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @StateObject private var cloudSyncManager = CloudSyncManager.shared
    @Query(sort: \WarrantyItem.createdAt, order: .reverse) private var items: [WarrantyItem]

    @AppStorage("defaultCurrency") private var defaultCurrency = "USD"
    @AppStorage("reminderDefault30") private var reminderDefault30 = true
    @AppStorage("reminderDefault7") private var reminderDefault7 = true
    @AppStorage("reminderDefault1") private var reminderDefault1 = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true

    @State private var isShowingDeleteAllConfirmation = false
    @State private var isShowingPaywall = false
    @State private var isShowingICloudInfo = false
    @State private var sharedURL: URL?
    #if DEBUG
    @AppStorage("debugMenuUnlocked") private var debugMenuUnlocked = false
    @State private var appVersionTapCount = 0
    @State private var isShowingDebugUnlockedAlert = false
    #endif

    var body: some View {
        Form {
            Section("settings.section.language") {
                Picker("settings.language", selection: $languageManager.selectedLanguage) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(LocalizedStringKey(language.titleKey)).tag(language)
                    }
                }
            }

            Section("settings.section.defaults") {
                Picker("settings.defaultCurrency", selection: $defaultCurrency) {
                    ForEach(CurrencyFormatterProvider.commonCurrencies, id: \.self) { code in
                        Text(CurrencyFormatterProvider.displayName(for: code)).tag(code)
                    }
                }
                Toggle("settings.reminder30", isOn: $reminderDefault30)
                Toggle("settings.reminder7", isOn: $reminderDefault7)
                Toggle("settings.reminder1", isOn: $reminderDefault1)
            }

            Section("settings.section.appearance") {
                Picker("settings.appearance", selection: $appearanceManager.selectedAppearance) {
                    ForEach(AppAppearance.allCases) { appearance in
                        Text(LocalizedStringKey(appearance.titleKey)).tag(appearance)
                    }
                }
                Label("settings.appearanceInfo", systemImage: "circle.lefthalf.filled")
            }

            Section("settings.section.data") {
                Button {
                    insertDemoData()
                } label: {
                    Label("settings.seedDemo", systemImage: "sparkles")
                }

                Button {
                    exportJSON()
                } label: {
                    Label("settings.exportJSON", systemImage: "square.and.arrow.up")
                }

                Button {
                    hasCompletedOnboarding = false
                } label: {
                    Label("settings.showOnboarding", systemImage: "rectangle.stack")
                }

                Button(role: .destructive) {
                    isShowingDeleteAllConfirmation = true
                } label: {
                    Label("settings.deleteAll", systemImage: "trash")
                }
            }

            Section("settings.section.pro") {
                Button {
                    isShowingPaywall = true
                } label: {
                    Label {
                        Text(LocalizedStringKey(subscriptionManager.hasPro ? "settings.proUnlocked" : "settings.openPaywall"))
                    } icon: {
                        Image(systemName: "crown")
                    }
                }
            }

            Section("settings.section.storekit") {
                Button {
                    Task {
                        await subscriptionManager.loadProducts()
                        await subscriptionManager.refreshEntitlements()
                    }
                } label: {
                    Label("settings.storekitRefresh", systemImage: "arrow.clockwise")
                }

                Button {
                    Task {
                        await subscriptionManager.syncAppStoreAccount()
                    }
                } label: {
                    Label("settings.storekitSync", systemImage: "arrow.triangle.2.circlepath")
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

            Section("settings.section.proFeatures") {
                SettingsFeatureRow(
                    titleKey: "feature.scanner.title",
                    subtitleKey: "feature.scanner.subtitle",
                    systemImage: "barcode.viewfinder",
                    isUnlocked: subscriptionManager.hasPro
                ) {
                    if !subscriptionManager.hasPro {
                        isShowingPaywall = true
                    }
                }

                SettingsFeatureRow(
                    titleKey: "feature.calendar.title",
                    subtitleKey: "feature.calendar.subtitle",
                    systemImage: "calendar.badge.plus",
                    isUnlocked: subscriptionManager.hasPro
                ) {
                    if !subscriptionManager.hasPro {
                        isShowingPaywall = true
                    }
                }

                SettingsFeatureRow(
                    titleKey: "feature.icloud.title",
                    subtitleKey: cloudSyncManager.statusKey,
                    systemImage: "icloud",
                    isUnlocked: subscriptionManager.hasPro
                ) {
                    if subscriptionManager.hasPro {
                        cloudSyncManager.refreshStatus()
                        isShowingICloudInfo = true
                    } else {
                        isShowingPaywall = true
                    }
                }
            }

            Section("settings.section.about") {
                HStack {
                    Label("settings.appVersion", systemImage: "info.circle")
                    Spacer()
                    Text(appVersion)
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
                #if DEBUG
                .onTapGesture {
                    appVersionTapCount += 1
                    if appVersionTapCount >= 7 {
                        debugMenuUnlocked = true
                        appVersionTapCount = 0
                        isShowingDebugUnlockedAlert = true
                    }
                }
                #endif

                #if DEBUG
                if debugMenuUnlocked {
                    NavigationLink {
                        DebugMenuView()
                    } label: {
                        Label("debug.title", systemImage: "ladybug")
                    }
                }
                #endif
            }

            Section("settings.section.privacy") {
                Text("settings.dataStaysOnDevice")
                    .font(.body)
                Text("settings.privacyNote")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("settings.title")
        .sheet(isPresented: $isShowingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: Binding(
            get: { sharedURL != nil },
            set: { isPresented in
                if !isPresented {
                    sharedURL = nil
                }
            }
        )) {
            if let sharedURL {
                ShareSheet(items: [sharedURL])
            }
        }
        .alert("settings.deleteAll.title", isPresented: $isShowingDeleteAllConfirmation) {
            Button("common.delete", role: .destructive) {
                deleteAllData()
            }
            Button("common.cancel", role: .cancel) {}
        } message: {
            Text("settings.deleteAll.message")
        }
        .alert("icloud.title", isPresented: $isShowingICloudInfo) {
            Button("common.ok", role: .cancel) {}
        } message: {
            Text("icloud.setupMessage")
        }
        #if DEBUG
        .alert("debug.unlocked.title", isPresented: $isShowingDebugUnlockedAlert) {
            Button("common.ok", role: .cancel) {}
        } message: {
            Text("debug.unlocked.message")
        }
        #endif
        .onAppear {
            cloudSyncManager.refreshStatus()
        }
    }

    private func insertDemoData() {
        for item in DemoDataProvider.makeItems() {
            modelContext.insert(item)
        }
        try? modelContext.save()
    }

    private func exportJSON() {
        sharedURL = try? JSONExportService.export(items: items)
    }

    private func deleteAllData() {
        for item in items {
            ImageStorageService.deleteImage(at: item.productImagePath)
            ImageStorageService.deleteImage(at: item.receiptImagePath)
            ImageStorageService.deleteImage(at: item.warrantyDocumentImagePath)
            NotificationManager.shared.removeReminders(for: item.id)
            modelContext.delete(item)
        }

        try? modelContext.save()
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }
}

private struct SettingsFeatureRow: View {
    let titleKey: String
    let subtitleKey: String
    let systemImage: String
    let isUnlocked: Bool
    let lockedAction: () -> Void

    var body: some View {
        Button {
            lockedAction()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(DesignSystem.Colors.premiumBlue)
                    .frame(width: 34, height: 34)
                    .background(DesignSystem.Colors.premiumBlue.opacity(0.10), in: RoundedRectangle(cornerRadius: 11, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(LocalizedStringKey(titleKey))
                        .foregroundStyle(.primary)
                    Text(LocalizedStringKey(subtitleKey))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isUnlocked {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(DesignSystem.Colors.premiumMint)
                } else {
                    Label("paywall.pro", systemImage: "lock.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DesignSystem.Colors.premiumAmber)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
