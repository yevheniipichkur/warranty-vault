import SwiftUI

struct SectionHeader: View {
    let titleKey: String
    var systemImage: String?

    var body: some View {
        HStack(spacing: 8) {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(Color.accentColor)
            }
            Text(LocalizedStringKey(titleKey))
                .font(.headline)
            Spacer()
        }
        .accessibilityAddTraits(.isHeader)
    }
}
