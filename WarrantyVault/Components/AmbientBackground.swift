import SwiftUI

enum AmbientBackgroundKind {
    case app
    case onboarding
    case paywall
    case receipts
    case reminders
}

struct AmbientBackground: View {
    let kind: AmbientBackgroundKind

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Color(uiColor: colorScheme == .dark ? .systemBackground : .systemGroupedBackground)

            LinearGradient(
                colors: baseGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            GeometryReader { proxy in
                ZStack {
                    AmbientRibbon(colors: upperRibbonColors)
                        .frame(width: proxy.size.width * 1.28, height: 132)
                        .rotationEffect(.degrees(-10))
                        .offset(x: -proxy.size.width * 0.10, y: -18)

                    AmbientRibbon(colors: lowerRibbonColors)
                        .frame(width: proxy.size.width * 1.16, height: 108)
                        .rotationEffect(.degrees(9))
                        .offset(x: proxy.size.width * 0.14, y: proxy.size.height * 0.70)

                    AmbientHairline(tint: accent)
                        .frame(width: proxy.size.width * 0.86, height: 1)
                        .rotationEffect(.degrees(-10))
                        .offset(x: proxy.size.width * 0.10, y: proxy.size.height * 0.22)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var baseGradient: [Color] {
        let surface = Color(uiColor: colorScheme == .dark ? .systemBackground : .systemGroupedBackground)
        switch kind {
        case .app:
            return [
                DesignSystem.Colors.premiumBlue.opacity(colorScheme == .dark ? 0.18 : 0.11),
                surface,
                DesignSystem.Colors.premiumTeal.opacity(colorScheme == .dark ? 0.14 : 0.08)
            ]
        case .onboarding:
            return [
                DesignSystem.Colors.premiumMint.opacity(colorScheme == .dark ? 0.20 : 0.13),
                surface,
                DesignSystem.Colors.premiumAmber.opacity(colorScheme == .dark ? 0.10 : 0.07)
            ]
        case .paywall:
            return [
                DesignSystem.Colors.premiumBlue.opacity(colorScheme == .dark ? 0.22 : 0.13),
                surface,
                DesignSystem.Colors.premiumAmber.opacity(colorScheme == .dark ? 0.12 : 0.08)
            ]
        case .receipts:
            return [
                DesignSystem.Colors.premiumTeal.opacity(colorScheme == .dark ? 0.18 : 0.10),
                surface,
                DesignSystem.Colors.premiumBlue.opacity(colorScheme == .dark ? 0.12 : 0.07)
            ]
        case .reminders:
            return [
                DesignSystem.Colors.premiumAmber.opacity(colorScheme == .dark ? 0.16 : 0.10),
                surface,
                DesignSystem.Colors.premiumMint.opacity(colorScheme == .dark ? 0.13 : 0.08)
            ]
        }
    }

    private var accent: Color {
        switch kind {
        case .app, .paywall: DesignSystem.Colors.premiumBlue
        case .onboarding: DesignSystem.Colors.premiumMint
        case .receipts: DesignSystem.Colors.premiumTeal
        case .reminders: DesignSystem.Colors.premiumAmber
        }
    }

    private var upperRibbonColors: [Color] {
        [
            accent.opacity(colorScheme == .dark ? 0.16 : 0.13),
            DesignSystem.Colors.premiumMint.opacity(colorScheme == .dark ? 0.10 : 0.08),
            .clear
        ]
    }

    private var lowerRibbonColors: [Color] {
        [
            .clear,
            DesignSystem.Colors.premiumAmber.opacity(colorScheme == .dark ? 0.10 : 0.06),
            accent.opacity(colorScheme == .dark ? 0.10 : 0.06)
        ]
    }
}

private struct AmbientRibbon: View {
    let colors: [Color]

    var body: some View {
        RoundedRectangle(cornerRadius: 44, style: .continuous)
            .fill(
                LinearGradient(
                    colors: colors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}

private struct AmbientHairline: View {
    let tint: Color

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, tint.opacity(0.22), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}
