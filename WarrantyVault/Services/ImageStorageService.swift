import Foundation
import PhotosUI
import UIKit

enum ImageStorageService {
    private static let directoryName = "WarrantyVaultImages"

    static var imagesDirectory: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(directoryName, isDirectory: true)
    }

    static func saveImage(from item: PhotosPickerItem?) async throws -> String? {
        guard let item,
              let data = try await item.loadTransferable(type: Data.self)
        else {
            return nil
        }

        return try saveImageData(data)
    }

    static func saveImageData(_ data: Data) throws -> String {
        try FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true, attributes: nil)

        let filename = "\(UUID().uuidString).jpg"
        let url = imagesDirectory.appendingPathComponent(filename)

        if let image = UIImage(data: data),
           let jpegData = image.jpegData(compressionQuality: 0.88) {
            try jpegData.write(to: url, options: [.atomic])
        } else {
            try data.write(to: url, options: [.atomic])
        }

        return filename
    }

    static func url(for imagePath: String?) -> URL? {
        guard let imagePath, !imagePath.isEmpty else {
            return nil
        }

        if imagePath.hasPrefix("/") {
            return URL(fileURLWithPath: imagePath)
        }

        return imagesDirectory.appendingPathComponent(imagePath)
    }

    static func uiImage(for imagePath: String?) -> UIImage? {
        guard let url = url(for: imagePath) else {
            return nil
        }

        return UIImage(contentsOfFile: url.path)
    }

    static func deleteImage(at imagePath: String?) {
        guard let url = url(for: imagePath) else {
            return
        }

        try? FileManager.default.removeItem(at: url)
    }
}
