import SwiftUI

enum PremiumArtworkKind {
    case vault
    case receipt
    case reminder
    case archive
    case search
    case pro
}

struct PremiumArtworkView: View {
    let kind: PremiumArtworkKind
    var size: CGFloat = 128

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var lifted = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                .fill(.thinMaterial)
                .overlay {
                    LinearGradient(
                        colors: [
                            tint.opacity(0.22),
                            secondaryTint.opacity(0.12),
                            Color.white.opacity(0.10)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: size * 0.24, style: .continuous))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                        .strokeBorder(.primary.opacity(0.08), lineWidth: 0.8)
                }

            documentStack
                .offset(x: -size * 0.08, y: reduceMotion ? 0 : (lifted ? -size * 0.018 : size * 0.018))

            Image(systemName: symbolName)
                .font(.system(size: size * 0.31, weight: .bold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(tint)
                .frame(width: size * 0.43, height: size * 0.43)
                .background(Color(uiColor: .systemBackground).opacity(0.78), in: RoundedRectangle(cornerRadius: size * 0.13, style: .continuous))
                .offset(x: size * 0.18, y: size * 0.12)

            accentPlate
                .offset(x: size * 0.20, y: -size * 0.21)
        }
        .frame(width: size, height: size)
        .shadow(color: tint.opacity(0.16), radius: size * 0.10, y: size * 0.05)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                lifted.toggle()
            }
        }
    }

    private var documentStack: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.09, style: .continuous)
                .fill(.background.opacity(0.56))
                .frame(width: size * 0.48, height: size * 0.58)
                .rotationEffect(.degrees(-8))
                .offset(x: -size * 0.08, y: size * 0.03)

            RoundedRectangle(cornerRadius: size * 0.09, style: .continuous)
                .fill(.background.opacity(0.82))
                .frame(width: size * 0.48, height: size * 0.60)
                .overlay(alignment: .topLeading) {
                    VStack(alignment: .leading, spacing: size * 0.045) {
                        ForEach(0..<3, id: \.self) { index in
                            Capsule(style: .continuous)
                                .fill(index == 0 ? tint.opacity(0.35) : Color.secondary.opacity(0.14))
                                .frame(width: index == 2 ? size * 0.21 : size * 0.29, height: size * 0.028)
                        }
                    }
                    .padding(size * 0.09)
                }
        }
    }

    private var accentPlate: some View {
        Image(systemName: accentSymbolName)
            .font(.system(size: size * 0.14, weight: .heavy))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(secondaryTint)
            .frame(width: size * 0.28, height: size * 0.24)
            .background(Color(uiColor: .systemBackground).opacity(0.82), in: RoundedRectangle(cornerRadius: size * 0.10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: size * 0.10, style: .continuous)
                    .strokeBorder(secondaryTint.opacity(0.20), lineWidth: 0.8)
            }
    }

    private var symbolName: String {
        switch kind {
        case .vault: "checkmark.shield.fill"
        case .receipt: "doc.text.image.fill"
        case .reminder: "bell.badge.fill"
        case .archive: "square.and.arrow.up.fill"
        case .search: "magnifyingglass"
        case .pro: "crown.fill"
        }
    }

    private var accentSymbolName: String {
        switch kind {
        case .vault, .pro: "sparkles"
        case .receipt: "checkmark.seal.fill"
        case .reminder: "clock.fill"
        case .archive: "tray.full.fill"
        case .search: "line.3.horizontal.decrease.circle.fill"
        }
    }

    private var tint: Color {
        switch kind {
        case .vault: DesignSystem.Colors.premiumBlue
        case .receipt: DesignSystem.Colors.premiumTeal
        case .reminder: DesignSystem.Colors.premiumAmber
        case .archive: DesignSystem.Colors.premiumMint
        case .search: DesignSystem.Colors.neutralGlassTint
        case .pro: DesignSystem.Colors.premiumBlue
        }
    }

    private var secondaryTint: Color {
        switch kind {
        case .vault: DesignSystem.Colors.premiumMint
        case .receipt: DesignSystem.Colors.premiumBlue
        case .reminder: DesignSystem.Colors.premiumRed
        case .archive: DesignSystem.Colors.premiumTeal
        case .search: DesignSystem.Colors.premiumAmber
        case .pro: DesignSystem.Colors.premiumAmber
        }
    }
}

struct ScreenHeroCard: View {
    let titleKey: String
    let messageKey: String
    let artworkKind: PremiumArtworkKind
    var tint: Color = DesignSystem.Colors.premiumBlue

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 7) {
                Text(LocalizedStringKey(titleKey))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(LocalizedStringKey(messageKey))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            PremiumArtworkView(kind: artworkKind, size: 76)
                .accessibilityHidden(true)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.thinMaterial)
                .overlay {
                    LinearGradient(
                        colors: [tint.opacity(0.14), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.primary.opacity(0.07), lineWidth: 0.8)
        }
    }
}
