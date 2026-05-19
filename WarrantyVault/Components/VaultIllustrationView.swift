import SwiftUI

enum VaultIllustrationKind {
    case proVault
    case returnWindow
    case repairKit
    case warrantyPack
}

struct VaultIllustrationView: View {
    let kind: VaultIllustrationKind

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isFloating = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.thinMaterial)
                .overlay {
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.premiumBlue.opacity(0.18),
                            DesignSystem.Colors.premiumTeal.opacity(0.10),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .strokeBorder(.primary.opacity(0.07), lineWidth: 0.8)
                }

            Circle()
                .fill(tint.opacity(0.14))
                .frame(width: 72, height: 72)
                .offset(x: 22, y: -18)

            Image(systemName: symbolName)
                .font(.system(size: 48, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(tint)
                .offset(y: reduceMotion ? 0 : (isFloating ? -3 : 3))
        }
        .frame(width: 118, height: 118)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                isFloating.toggle()
            }
        }
    }

    private var symbolName: String {
        switch kind {
        case .proVault: "checkmark.shield.fill"
        case .returnWindow: "arrow.uturn.backward.circle.fill"
        case .repairKit: "stethoscope"
        case .warrantyPack: "doc.richtext.fill"
        }
    }

    private var tint: Color {
        switch kind {
        case .proVault: DesignSystem.Colors.premiumBlue
        case .returnWindow: DesignSystem.Colors.premiumAmber
        case .repairKit: DesignSystem.Colors.premiumTeal
        case .warrantyPack: DesignSystem.Colors.premiumMint
        }
    }
}
