import SwiftData
import SwiftUI

struct AppRootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showSplash = true
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

            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .animation(MotionManager.softAnimation(reduceMotion: reduceMotion), value: hasCompletedOnboarding)
        .onAppear {
            bootstrapPreviewIfNeeded()
            let delay: UInt64 = reduceMotion ? 400_000_000 : 1_300_000_000
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: delay)
                withAnimation(.easeOut(duration: 0.35)) {
                    showSplash = false
                }
            }
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

struct SplashView: View {
    @State private var scale: CGFloat = 0.72
    @State private var opacity: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground).ignoresSafeArea()

            VStack(spacing: 18) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 76, weight: .bold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(DesignSystem.Colors.premiumBlue)

                Text("app.name")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.primary)
            }
            .scaleEffect(reduceMotion ? 1.0 : scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.52, dampingFraction: 0.72)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
        }
    }
}

struct AppBackground: View {
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)

            LinearGradient(
                colors: [
                    DesignSystem.Colors.premiumBlue.opacity(0.055),
                    Color(uiColor: .systemBackground),
                    DesignSystem.Colors.premiumTeal.opacity(0.045)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }
}
