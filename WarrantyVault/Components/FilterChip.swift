import SwiftUI

struct FilterChip: View {
    let titleKey: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(LocalizedStringKey(titleKey))
                .font(.caption.weight(isSelected ? .semibold : .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .foregroundStyle(isSelected ? DesignSystem.Colors.premiumBlue : Color.secondary)
                .background {
                    Capsule(style: .continuous)
                        .fill(backgroundColor)
                        .overlay {
                            Capsule(style: .continuous)
                                .strokeBorder(isSelected ? DesignSystem.Colors.premiumBlue.opacity(0.24) : Color.primary.opacity(0.07), lineWidth: 0.7)
                        }
                }
        }
        .buttonStyle(.plain)
    }

    private var backgroundColor: Color {
        isSelected ? DesignSystem.Colors.premiumBlue.opacity(0.13) : Color.secondary.opacity(0.08)
    }
}

typealias FilterPill = FilterChip
