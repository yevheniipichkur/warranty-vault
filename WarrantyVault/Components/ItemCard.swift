import SwiftUI

struct ItemCard: View {
    let item: WarrantyItem

    @Environment(\.locale) private var locale

    var body: some View {
        PremiumCard(cornerRadius: DesignSystem.Radius.large, padding: DesignSystem.Spacing.medium, tint: item.warrantyStatus.tint) {
            HStack(spacing: 14) {
                StoredImageView(imagePath: item.productImagePath, placeholderSystemImage: item.categoryType.symbolName)
                    .frame(width: 76, height: 76)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: item.categoryType.symbolName)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 26, height: 26)
                            .background(item.warrantyStatus.tint.gradient, in: Circle())
                            .offset(x: 5, y: 5)
                    }

                VStack(alignment: .leading, spacing: 7) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(item.name)
                            .font(.headline.weight(.semibold))
                            .lineLimit(1)
                        Spacer(minLength: 6)
                        WarrantyStatusBadge(status: item.warrantyStatus)
                    }

                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    } else {
                        Label(LocalizedStringKey(item.categoryType.titleKey), systemImage: item.categoryType.symbolName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

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

    private var subtitle: String {
        [item.brand, item.store].filter { !$0.isEmpty }.joined(separator: " • ")
    }
}
