import SwiftUI

struct PremiumFormSection<Content: View>: View {
    let titleKey: String
    let systemImage: String
    @ViewBuilder var content: Content

    var body: some View {
        PremiumCard(cornerRadius: DesignSystem.Radius.large, padding: 0) {
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

struct PremiumInputRow<Content: View>: View {
    let titleKey: String
    let systemImage: String
    @ViewBuilder var content: Content

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.accentColor)
                .frame(width: 28, height: 28)
                .background(Color.accentColor.opacity(0.10), in: RoundedRectangle(cornerRadius: 9, style: .continuous))

            Text(LocalizedStringKey(titleKey))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 118, alignment: .leading)
                .lineLimit(2)
                .minimumScaleFactor(0.78)

            content
                .font(.body.weight(.medium))
                .multilineTextAlignment(.trailing)
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
