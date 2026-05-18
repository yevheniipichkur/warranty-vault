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
                    Image(systemName: placeholderSystemImage)
                        .font(.title2.weight(.semibold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .clipped()
    }
}
