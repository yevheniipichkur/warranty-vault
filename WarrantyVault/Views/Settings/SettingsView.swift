import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var appearanceManager: AppearanceManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Query(sort: \WarrantyItem.createdAt, order: .reverse) private var items: [WarrantyItem]

    @AppStorage("defaultCurrency") private var defaultCurrency = "USD"
    @AppStorage("reminderDefault30") private var reminderDefault30 = true
    @AppStorage("reminderDefault7") private var reminderDefault7 = true
    @AppStorage("reminderDefault1") private var reminderDefault1 = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true

    @State private var isShowingDeleteAllConfirmation = false
    @State private var isShowingPaywall = false
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
                TextField("settings.defaultCurrency", text: $defaultCurrency)
                    .textInputAutocapitalization(.characters)
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
        #if DEBUG
        .alert("debug.unlocked.title", isPresented: $isShowingDebugUnlockedAlert) {
            Button("common.ok", role: .cancel) {}
        } message: {
            Text("debug.unlocked.message")
        }
        #endif
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
