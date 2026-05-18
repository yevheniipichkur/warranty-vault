import PhotosUI
import SwiftUI

struct ImagePickerView: View {
    let titleKey: String
    let symbolName: String
    @Binding var imagePath: String?

    @State private var selectedItem: PhotosPickerItem?
    @State private var isSaving = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(titleKey: titleKey, systemImage: symbolName)

            HStack(spacing: 12) {
                Group {
                    if isSaving {
                        SkeletonPlaceholder(cornerRadius: 16)
                    } else {
                        StoredImageView(imagePath: imagePath, placeholderSystemImage: symbolName)
                    }
                }
                .frame(width: 82, height: 82)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label(LocalizedStringKey(imagePath == nil ? "image.choose" : "image.replace"), systemImage: "photo.on.rectangle")
                    }
                    .buttonStyle(.bordered)

                    if imagePath != nil {
                        Button(role: .destructive) {
                            ImageStorageService.deleteImage(at: imagePath)
                            imagePath = nil
                        } label: {
                            Label(LocalizedStringKey("image.remove"), systemImage: "trash")
                        }
                        .buttonStyle(.borderless)
                    }
                }

                Spacer()

                if isSaving {
                    ProgressView()
                }
            }
        }
        .onChange(of: selectedItem) { _, newValue in
            Task {
                isSaving = true
                defer { isSaving = false }

                if let savedPath = try? await ImageStorageService.saveImage(from: newValue) {
                    ImageStorageService.deleteImage(at: imagePath)
                    imagePath = savedPath
                }
            }
        }
    }
}
