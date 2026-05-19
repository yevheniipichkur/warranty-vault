import SwiftUI

struct StoredImageView: View {
    let imagePath: String?
    var placeholderSystemImage: String = "photo"

    var body: some View {
        Group {
            if let uiImage = ImageStorageService.uiImage(for: imagePath) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ImagePlaceholderArtwork(symbolName: placeholderSystemImage)
            }
        }
        .clipped()
    }
}

private struct ImagePlaceholderArtwork: View {
    let symbolName: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
                .overlay {
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.premiumBlue.opacity(0.12),
                            DesignSystem.Colors.premiumTeal.opacity(0.08),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }

            VStack(alignment: .leading, spacing: 5) {
                Capsule(style: .continuous)
                    .fill(DesignSystem.Colors.premiumBlue.opacity(0.20))
                    .frame(width: 34, height: 5)
                Capsule(style: .continuous)
                    .fill(Color.secondary.opacity(0.18))
                    .frame(width: 24, height: 4)
            }
            .offset(x: -10, y: -12)

            Image(systemName: symbolName)
                .font(.title2.weight(.semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(DesignSystem.Colors.neutralGlassTint)
                .frame(width: 42, height: 42)
                .background(Color(uiColor: .systemBackground).opacity(0.72), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                .offset(x: 9, y: 9)
        }
    }
}
