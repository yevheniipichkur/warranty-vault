import Foundation
import PDFKit
import UIKit

struct PDFExportService {
    func export(item: WarrantyItem, language: AppLanguage = .system) throws -> URL {
        let pageBounds = CGRect(x: 0, y: 0, width: 612, height: 792)
        let filename = "\(item.name.replacingOccurrences(of: " ", with: "-"))-\(item.id.uuidString.prefix(8)).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)

        try renderer.writePDF(to: url) { context in
            context.beginPage()

            let titleFont = UIFont.preferredFont(forTextStyle: .largeTitle).withTraits(.traitBold)
            let headlineFont = UIFont.preferredFont(forTextStyle: .headline)
            let bodyFont = UIFont.preferredFont(forTextStyle: .body)
            let captionFont = UIFont.preferredFont(forTextStyle: .caption1)

            var y: CGFloat = 44
            let margin: CGFloat = 42
            let contentWidth = pageBounds.width - margin * 2

            draw(
                text: L10n.string("pdf.title", language: language),
                in: CGRect(x: margin, y: y, width: contentWidth, height: 42),
                font: titleFont,
                color: .label
            )
            y += 52

            draw(text: item.name, in: CGRect(x: margin, y: y, width: contentWidth, height: 28), font: headlineFont, color: .label)
            y += 36

            if let image = ImageStorageService.uiImage(for: item.productImagePath) {
                y = drawImage(image, y: y, margin: margin, contentWidth: contentWidth)
                y += 18
            }

            let rows: [(String, String)] = [
                ("item.brand", item.brand),
                ("item.model", item.modelName),
                ("item.serialNumber", item.serialNumber),
                ("item.store", item.store),
                ("item.purchaseDate", DateFormatterProvider.string(from: item.purchaseDate)),
                ("item.warrantyExpiration", item.warrantyExpirationDate.map { DateFormatterProvider.string(from: $0) } ?? L10n.string("common.none", language: language)),
                ("item.price", CurrencyFormatterProvider.string(from: item.price, currencyCode: item.currency)),
                ("item.notes", item.notes)
            ]

            for row in rows where !row.1.isEmpty {
                let label = L10n.string(row.0, language: language)
                draw(text: label, in: CGRect(x: margin, y: y, width: 180, height: 24), font: captionFont, color: .secondaryLabel)
                draw(text: row.1, in: CGRect(x: margin + 190, y: y, width: contentWidth - 190, height: 44), font: bodyFont, color: .label)
                y += row.0 == "item.notes" ? 58 : 30
            }

            if let receipt = ImageStorageService.uiImage(for: item.receiptImagePath) {
                y += 8
                draw(text: L10n.string("pdf.receipt", language: language), in: CGRect(x: margin, y: y, width: contentWidth, height: 28), font: headlineFont, color: .label)
                y += 32
                _ = drawImage(receipt, y: y, margin: margin, contentWidth: contentWidth)
            }
        }

        _ = PDFDocument(url: url)
        return url
    }

    private func draw(text: String, in rect: CGRect, font: UIFont, color: UIColor) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
        ]
        text.draw(in: rect, withAttributes: attributes)
    }

    private func drawImage(_ image: UIImage, y: CGFloat, margin: CGFloat, contentWidth: CGFloat) -> CGFloat {
        let maxHeight: CGFloat = 210
        let ratio = min(contentWidth / image.size.width, maxHeight / image.size.height)
        let size = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        let rect = CGRect(x: margin, y: y, width: size.width, height: size.height)
        image.draw(in: rect)
        return y + size.height
    }
}

private extension UIFont {
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else {
            return self
        }

        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
