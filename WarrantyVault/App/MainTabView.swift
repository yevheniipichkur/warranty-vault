import SwiftUI

struct MainTabView: View {
    @State private var selection: AppTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selection {
                case .home:
                    NavigationStack { HomeDashboardView() }
                case .items:
                    NavigationStack { ItemsListView() }
                case .receipts:
                    NavigationStack { ReceiptsGalleryView() }
                case .reminders:
                    NavigationStack { RemindersView() }
                case .settings:
                    NavigationStack { SettingsView() }
                }
            }
            .padding(.bottom, 76)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            GlassTabBar(selection: $selection)
        }
    }
}
