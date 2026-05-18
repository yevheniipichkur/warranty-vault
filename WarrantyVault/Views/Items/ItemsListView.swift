import SwiftData
import SwiftUI

struct ItemsListView: View {
    @Query(sort: \WarrantyItem.createdAt, order: .reverse) private var items: [WarrantyItem]

    @State private var searchText = ""
    @State private var selectedFilter: ItemFilter = .all
    @State private var selectedSort: ItemSortOption = .newest
    @State private var isShowingItemForm = false

    private var visibleItems: [WarrantyItem] {
        ItemsListViewModel.filteredItems(
            from: items,
            searchText: searchText,
            filter: selectedFilter,
            sort: selectedSort
        )
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

                if visibleItems.isEmpty {
                    EmptyStateView(
                        symbolName: items.isEmpty ? "shippingbox" : "magnifyingglass",
                        titleKey: items.isEmpty ? "items.empty.title" : "items.noResults.title",
                        messageKey: items.isEmpty ? "items.empty.message" : "items.noResults.message",
                        illustrationKind: items.isEmpty ? .emptyBox : .search,
                        actionTitleKey: items.isEmpty ? "item.add" : nil,
                        action: items.isEmpty ? { isShowingItemForm = true } : nil
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
