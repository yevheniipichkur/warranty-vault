import SwiftUI

struct PremiumFormSection<Content: View>: View {
    let titleKey: String
    let systemImage: String
    @ViewBuilder var content: Content

    var body: some View {
        LightweightFormCard(padding: 0) {
            VStack(alignment: .leading, spacing: 0) {
                SectionHeader(titleKey: titleKey, systemImage: systemImage)
                    .padding(.horizontal, DesignSystem.Spacing.large)
                    .padding(.top, DesignSystem.Spacing.large)
                    .padding(.bottom, DesignSystem.Spacing.medium)

                VStack(spacing: 0) {
                    content
                }
            }
        }
    }
}

struct LightweightFormCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    var cornerRadius: CGFloat = DesignSystem.Radius.medium
    var padding: CGFloat = DesignSystem.Spacing.large
    @ViewBuilder var content: Content

    var body: some View {
        // Form controls redraw on every keystroke. Keep these surfaces static
        // and avoid per-row material blur so typing stays responsive.
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(surfaceColor)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.primary.opacity(colorScheme == .dark ? 0.10 : 0.07), lineWidth: 0.7)
            }
            .shadow(color: shadowColor, radius: 10, y: 5)
    }

    private var surfaceColor: Color {
        Color(uiColor: colorScheme == .dark ? .tertiarySystemBackground : .secondarySystemGroupedBackground)
    }

    private var shadowColor: Color {
        colorScheme == .dark ? .clear : Color.black.opacity(0.035)
    }
}

struct PremiumInputRow<Content: View>: View {
    let titleKey: String
    let systemImage: String
    @ViewBuilder var content: Content

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DesignSystem.Colors.premiumBlue)
                .frame(width: 28, height: 28)
                .background(DesignSystem.Colors.premiumBlue.opacity(0.09), in: RoundedRectangle(cornerRadius: 9, style: .continuous))

            Text(LocalizedStringKey(titleKey))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 108, alignment: .leading)
                .lineLimit(2)
                .minimumScaleFactor(0.78)

            content
                .font(.body.weight(.medium))
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, DesignSystem.Spacing.large)
        .padding(.vertical, DesignSystem.Spacing.medium)
        .contentShape(Rectangle())
    }
}

struct PremiumDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 76)
    }
}
