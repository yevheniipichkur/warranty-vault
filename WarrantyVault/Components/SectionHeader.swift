import SwiftUI

struct SectionHeader: View {
    let titleKey: String
    var systemImage: String?

    var body: some View {
        HStack(spacing: 8) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(DesignSystem.Colors.premiumBlue)
                    .frame(width: 22, height: 22)
                    .background(DesignSystem.Colors.premiumBlue.opacity(0.09), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            }
            Text(LocalizedStringKey(titleKey))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            Spacer()
        }
        .accessibilityAddTraits(.isHeader)
    }
}

typealias SectionTitle = SectionHeader
