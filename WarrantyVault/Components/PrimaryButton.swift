import SwiftUI
import UIKit

struct PrimaryButton: View {
    let titleKey: String
    var systemImage: String?
    var role: ButtonRole?
    let action: () -> Void

    var body: some View {
        Button(role: role) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            Label {
                Text(LocalizedStringKey(titleKey))
                    .font(.headline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            } icon: {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.headline.weight(.semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
        }
        .buttonStyle(PremiumButtonStyle(isDestructive: role == .destructive))
    }
}

private struct PremiumButtonStyle: ButtonStyle {
    let isDestructive: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background {
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .fill(background)
                    .overlay {
                        RoundedRectangle(cornerRadius: 17, style: .continuous)
                            .strokeBorder(.white.opacity(0.24), lineWidth: 0.7)
                    }
            }
            .shadow(color: tint.opacity(configuration.isPressed ? 0.12 : 0.28), radius: configuration.isPressed ? 8 : 16, y: configuration.isPressed ? 3 : 8)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.82), value: configuration.isPressed)
    }

    private var tint: Color {
        isDestructive ? DesignSystem.Colors.premiumRed : DesignSystem.Colors.premiumBlue
    }

    private var background: LinearGradient {
        if isDestructive {
            LinearGradient(colors: [DesignSystem.Colors.premiumRed, DesignSystem.Colors.premiumAmber.opacity(0.78)], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            LinearGradient(colors: [DesignSystem.Colors.premiumBlue.opacity(0.96), DesignSystem.Colors.premiumTeal.opacity(0.92)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}
