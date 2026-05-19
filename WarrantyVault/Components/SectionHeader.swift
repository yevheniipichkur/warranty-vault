import SwiftUI

struct SectionHeader: View {
    let titleKey: String
    var systemImage: String?

    var body: some View {
        HStack(spacing: 8) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 28, height: 28)
                    .background(Color.accentColor.opacity(0.11), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            }
            Text(LocalizedStringKey(titleKey))
                .font(.headline.weight(.semibold))
            Spacer()
        }
        .accessibilityAddTraits(.isHeader)
    }
}
