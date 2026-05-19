import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(illustrationKind: .receiptShield, titleKey: "onboarding.receipts.title", messageKey: "onboarding.receipts.message"),
        OnboardingPage(illustrationKind: .reminderBell, titleKey: "onboarding.reminders.title", messageKey: "onboarding.reminders.message"),
        OnboardingPage(illustrationKind: .archiveExport, titleKey: "onboarding.export.title", messageKey: "onboarding.export.message")
    ]

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 28)

            Text("app.name")
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)

            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    OnboardingPageView(page: page, isActive: currentPage == index)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            PrimaryButton(
                titleKey: currentPage == pages.indices.last ? "onboarding.getStarted" : "common.next",
                systemImage: "arrow.right"
            ) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                if currentPage == pages.indices.last {
                    withAnimation(MotionManager.softAnimation(reduceMotion: reduceMotion)) {
                        hasCompletedOnboarding = true
                    }
                } else {
                    withAnimation(MotionManager.softAnimation(reduceMotion: reduceMotion)) {
                        currentPage += 1
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 28) {
            EmptyStateIllustrationView(kind: page.illustrationKind)
                .scaleEffect(appeared || reduceMotion ? 1.0 : 0.72)
                .opacity(appeared ? 1.0 : 0.0)
                .animation(.spring(response: 0.52, dampingFraction: 0.72).delay(0.0), value: appeared)

            VStack(spacing: 10) {
                Text(LocalizedStringKey(page.titleKey))
                    .font(.title.weight(.bold))
                    .multilineTextAlignment(.center)
                    .offset(y: appeared || reduceMotion ? 0 : 22)
                    .opacity(appeared ? 1.0 : 0.0)
                    .animation(.spring(response: 0.48, dampingFraction: 0.78).delay(0.10), value: appeared)

                Text(LocalizedStringKey(page.messageKey))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .offset(y: appeared || reduceMotion ? 0 : 22)
                    .opacity(appeared ? 1.0 : 0.0)
                    .animation(.spring(response: 0.48, dampingFraction: 0.78).delay(0.18), value: appeared)
            }
        }
        .onAppear { triggerAnimation() }
        .onChange(of: isActive) { _, active in
            if active { triggerAnimation() }
            else { appeared = false }
        }
    }

    private func triggerAnimation() {
        appeared = false
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 60_000_000)
            appeared = true
        }
    }
}

private struct OnboardingPage {
    let illustrationKind: EmptyStateIllustrationKind
    let titleKey: String
    let messageKey: String
}
