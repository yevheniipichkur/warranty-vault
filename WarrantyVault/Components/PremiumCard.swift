import SwiftUI

struct PremiumCard<Content: View>: View {
    var cornerRadius: CGFloat = DesignSystem.Radius.large
    var padding: CGFloat = DesignSystem.Spacing.large
    var tint: Color = Color.accentColor
    @ViewBuilder var content: Content

    init(
        cornerRadius: CGFloat = DesignSystem.Radius.large,
        padding: CGFloat = DesignSystem.Spacing.large,
        tint: Color = Color.accentColor,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.thinMaterial)
                    .overlay {
                        LinearGradient(
                            colors: [
                                .white.opacity(0.28),
                                tint.opacity(0.08),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.primary.opacity(0.08), lineWidth: 0.8)
            }
            .shadow(color: DesignSystem.Shadow.card, radius: 18, y: 10)
    }
}

struct PremiumMetricPill: View {
    let value: String
    let titleKey: String
    let symbolName: String
    let tint: Color

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: symbolName)
                .font(.footnote.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 26, height: 26)
                .background(tint.opacity(0.15), in: Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.headline.weight(.bold))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Text(LocalizedStringKey(titleKey))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
