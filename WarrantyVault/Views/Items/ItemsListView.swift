import SwiftData
import SwiftUI

struct ItemsListView: View {
    @Query(sort: \WarrantyItem.createdAt, order: .reverse) private var items: [WarrantyItem]

    @State private var searchText = ""
    @State private var selectedFilter: ItemFilter = .all
    @State private var selectedSort: ItemSortOption = .newest
    @State private var isShowingItemForm = false

    private var useGrouped: Bool {
        selectedFilter == .all && searchText.isEmpty
    }

    private var visibleItems: [WarrantyItem] {
        ItemsListViewModel.filteredItems(
            from: items,
            searchText: searchText,
            filter: selectedFilter,
            sort: selectedSort
        )
    }

    private var attentionItems: [WarrantyItem] {
        items.filter { $0.warrantyStatus == .expiringSoon || $0.warrantyStatus == .expired }
            .sorted { ($0.warrantyExpirationDate ?? .distantPast) < ($1.warrantyExpirationDate ?? .distantPast) }
    }

    private var activeItems: [WarrantyItem] {
        items.filter { $0.warrantyStatus == .active }
            .sorted { ($0.warrantyExpirationDate ?? .distantFuture) < ($1.warrantyExpirationDate ?? .distantFuture) }
    }

    private var noWarrantyItems: [WarrantyItem] {
        items.filter { $0.warrantyStatus == .noWarranty }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ItemFilter.allCases) { filter in
                            FilterChip(titleKey: filter.titleKey, isSelected: selectedFilter == filter) {
                                withAnimation(.smooth) {
                                    selectedFilter = filter
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 4)
                }

                if items.isEmpty {
                    EmptyStateView(
                        symbolName: "shippingbox",
                        titleKey: "items.empty.title",
                        messageKey: "items.empty.message",
                        illustrationKind: .emptyBox,
                        actionTitleKey: "item.add",
                        action: { isShowingItemForm = true }
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 42)
                } else if useGrouped {
                    GroupedItemsList(
                        attentionItems: attentionItems,
                        activeItems: activeItems,
                        noWarrantyItems: noWarrantyItems
                    )
                    .padding(.horizontal, 20)
                } else if visibleItems.isEmpty {
                    EmptyStateView(
                        symbolName: "magnifyingglass",
                        titleKey: "items.noResults.title",
                        messageKey: "items.noResults.message",
                        illustrationKind: .search,
                        actionTitleKey: nil,
                        action: nil
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 42)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(visibleItems) { item in
                            NavigationLink {
                                ItemDetailView(item: item)
                            } label: {
                                ItemCard(item: item)
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
        .navigationTitle("items.title")
        .searchable(text: $searchText, prompt: "items.search.placeholder")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Picker("sort.title", selection: $selectedSort) {
                        ForEach(ItemSortOption.allCases) { option in
                            Text(LocalizedStringKey(option.titleKey)).tag(option)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
                .accessibilityLabel(Text("sort.title"))
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingItemForm = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(Text("item.add"))
            }
        }
        .sheet(isPresented: $isShowingItemForm) {
            NavigationStack {
                ItemFormView()
            }
            .presentationCornerRadius(28)
        }
    }
}

private struct GroupedItemsList: View {
    let attentionItems: [WarrantyItem]
    let activeItems: [WarrantyItem]
    let noWarrantyItems: [WarrantyItem]

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 20) {
            if !attentionItems.isEmpty {
                ItemGroup(titleKey: "home.needsAttention", systemImage: "exclamationmark.shield.fill", items: attentionItems)
            }
            if !activeItems.isEmpty {
                ItemGroup(titleKey: "status.active", systemImage: "checkmark.seal.fill", items: activeItems)
            }
            if !noWarrantyItems.isEmpty {
                ItemGroup(titleKey: "status.noWarranty", systemImage: "shield.slash", items: noWarrantyItems)
            }
        }
    }
}

private struct ItemGroup: View {
    let titleKey: String
    let systemImage: String
    let items: [WarrantyItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(titleKey: titleKey, systemImage: systemImage)
            ForEach(items) { item in
                NavigationLink {
                    ItemDetailView(item: item)
                } label: {
                    ItemCard(item: item)
                        .animatedCard(delay: 0.02)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
