import SwiftUI

struct ItemCard: View {
    let item: WarrantyItem

    @Environment(\.locale) private var locale

    var body: some View {
        GlassCard(cornerRadius: 20) {
            HStack(spacing: 14) {
                StoredImageView(imagePath: item.productImagePath, placeholderSystemImage: item.categoryType.symbolName)
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 7) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(item.name)
                            .font(.headline)
                            .lineLimit(1)
                        Spacer(minLength: 6)
                        WarrantyStatusBadge(status: item.warrantyStatus)
                    }

                    Text([item.brand, item.store].filter { !$0.isEmpty }.joined(separator: " • "))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Label(DateFormatterProvider.string(from: item.purchaseDate, locale: locale), systemImage: "calendar")

                        if let expiration = item.warrantyExpirationDate {
                            Label(DateFormatterProvider.string(from: expiration, locale: locale), systemImage: "shield")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                }
            }
        }
    }
}
