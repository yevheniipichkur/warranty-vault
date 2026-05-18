import SwiftData
import SwiftUI

struct AppRootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    #if DEBUG
    @Environment(\.modelContext) private var modelContext
    @Query private var previewItems: [WarrantyItem]
    #endif

    var body: some View {
        ZStack {
            AppBackground()

            if hasCompletedOnboarding {
                MainTabView()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(MotionManager.softAnimation(reduceMotion: reduceMotion), value: hasCompletedOnboarding)
        .onAppear {
            bootstrapPreviewIfNeeded()
        }
    }

    private func bootstrapPreviewIfNeeded() {
        #if DEBUG
        guard ProcessInfo.processInfo.arguments.contains("-WarrantyVaultPreviewMode") else {
            return
        }

        hasCompletedOnboarding = true

        guard previewItems.isEmpty else {
            return
        }

        for item in DemoDataProvider.makeItems(includeDebugExtras: true, namePrefix: "Demo ") {
            modelContext.insert(item)
        }
        try? modelContext.save()
        #endif
    }
}

struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(uiColor: .systemBackground),
                Color(uiColor: .secondarySystemBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
