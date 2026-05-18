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
                    VStack(spacing: 28) {
                        EmptyStateIllustrationView(kind: page.illustrationKind)

                        VStack(spacing: 10) {
                            Text(LocalizedStringKey(page.titleKey))
                                .font(.title.weight(.bold))
                                .multilineTextAlignment(.center)
                            Text(LocalizedStringKey(page.messageKey))
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            PrimaryButton(titleKey: currentPage == pages.indices.last ? "onboarding.getStarted" : "common.next", systemImage: "arrow.right") {
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

private struct OnboardingPage {
    let illustrationKind: EmptyStateIllustrationKind
    let titleKey: String
    let messageKey: String
}
