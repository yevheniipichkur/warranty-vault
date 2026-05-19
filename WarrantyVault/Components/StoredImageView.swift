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
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.thinMaterial)
                        .overlay {
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.premiumBlue.opacity(0.16),
                                    DesignSystem.Colors.premiumTeal.opacity(0.10),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    Image(systemName: placeholderSystemImage)
                        .font(.title2.weight(.semibold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color.accentColor.opacity(0.82))
                }
            }
        }
        .clipped()
    }
}
