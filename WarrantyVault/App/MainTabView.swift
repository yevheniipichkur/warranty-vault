import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack { HomeDashboardView() }
                .tabItem {
                    Label(LocalizedStringKey("tab.home"), systemImage: "house.fill")
                }

            NavigationStack { ItemsListView() }
                .tabItem {
                    Label(LocalizedStringKey("tab.items"), systemImage: "shippingbox.fill")
                }

            NavigationStack { RemindersView() }
                .tabItem {
                    Label(LocalizedStringKey("tab.reminders"), systemImage: "bell.badge.fill")
                }

            NavigationStack { SettingsView() }
                .tabItem {
                    Label(LocalizedStringKey("tab.settings"), systemImage: "gearshape.fill")
                }
        }
        .tint(DesignSystem.Colors.premiumBlue)
    }
}
