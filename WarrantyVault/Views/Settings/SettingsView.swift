import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var appearanceManager: AppearanceManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @StateObject private var cloudSyncManager = CloudSyncManager.shared

    @AppStorage("defaultCurrency") private var defaultCurrency = "USD"
    @AppStorage("reminderDefault30") private var reminderDefault30 = true
    @AppStorage("reminderDefault7") private var reminderDefault7 = true
    @AppStorage("reminderDefault1") private var reminderDefault1 = true

    @State private var isShowingPaywall = false
    @State private var isShowingICloudInfo = false
    @AppStorage("debugMenuUnlocked") private var debugMenuUnlocked = false
    @State private var appVersionTapCount = 0
    @State private var isShowingDebugUnlockedAlert = false

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
                .onTapGesture {
                    appVersionTapCount += 1
                    if appVersionTapCount >= 7 {
                        debugMenuUnlocked = true
                        appVersionTapCount = 0
                        isShowingDebugUnlockedAlert = true
                    }
                }

                if debugMenuUnlocked {
                    NavigationLink {
                        DebugMenuView()
                    } label: {
                        Label("debug.title", systemImage: "ladybug")
                    }
                }
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
        .alert("icloud.title", isPresented: $isShowingICloudInfo) {
            Button("common.ok", role: .cancel) {}
        } message: {
            Text("icloud.setupMessage")
        }
        .alert("debug.unlocked.title", isPresented: $isShowingDebugUnlockedAlert) {
            Button("common.ok", role: .cancel) {}
        } message: {
            Text("debug.unlocked.message")
        }
        .onAppear {
            cloudSyncManager.refreshStatus()
        }
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
