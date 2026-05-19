import SwiftData
import SwiftUI

struct ReceiptsGalleryView: View {
    @Query(sort: \WarrantyItem.purchaseDate, order: .reverse) private var items: [WarrantyItem]

    @State private var searchText = ""
    @State private var selectedCategory: WarrantyCategory?

    private var receiptItems: [WarrantyItem] {
        items
            .filter { $0.receiptImagePath != nil }
            .filter { item in
                selectedCategory == nil || item.categoryType == selectedCategory
            }
            .filter { item in
                item.matchesSearch(searchText) || item.store.localizedCaseInsensitiveContains(searchText)
            }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(titleKey: "filter.all", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }

                        ForEach(WarrantyCategory.allCases) { category in
                            FilterChip(titleKey: category.titleKey, isSelected: selectedCategory == category) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 4)
                }

                if receiptItems.isEmpty {
                    EmptyStateView(
                        symbolName: "doc.text.image",
                        titleKey: "receipts.empty.title",
                        messageKey: "receipts.empty.message",
                        illustrationKind: .receiptShield
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 42)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 156), spacing: 12)], spacing: 12) {
                        ForEach(receiptItems) { item in
                            NavigationLink {
                                ItemDetailView(item: item)
                            } label: {
                                ReceiptCard(item: item)
                                    .animatedCard(delay: 0.03)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 8)
        }
        .navigationTitle("receipts.title")
        .searchable(text: $searchText, prompt: "receipts.search.placeholder")
    }
}

private struct ReceiptCard: View {
    let item: WarrantyItem

    var body: some View {
        PremiumCard(cornerRadius: 20, padding: DesignSystem.Spacing.medium, tint: item.warrantyStatus.tint) {
            VStack(alignment: .leading, spacing: 10) {
                StoredImageView(imagePath: item.receiptImagePath, placeholderSystemImage: "doc.text.image")
                    .frame(height: 142)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.name)
                        .font(.headline)
                        .lineLimit(1)
                    Text(item.store.isEmpty ? item.brand : item.store)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }
}
