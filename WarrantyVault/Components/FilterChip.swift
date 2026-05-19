import SwiftUI

struct FilterChip: View {
    let titleKey: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(LocalizedStringKey(titleKey))
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .background {
                    Capsule(style: .continuous)
                        .fill(backgroundStyle)
                        .overlay {
                            Capsule(style: .continuous)
                                .strokeBorder(isSelected ? Color.white.opacity(0.25) : Color.primary.opacity(0.08), lineWidth: 0.7)
                        }
                }
        }
        .buttonStyle(.plain)
        .shadow(color: isSelected ? Color.accentColor.opacity(0.18) : .clear, radius: 10, y: 5)
    }

    private var backgroundStyle: LinearGradient {
        if isSelected {
            LinearGradient(colors: [DesignSystem.Colors.premiumBlue, DesignSystem.Colors.premiumTeal], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            LinearGradient(colors: [Color.secondary.opacity(0.11), Color.secondary.opacity(0.07)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}
