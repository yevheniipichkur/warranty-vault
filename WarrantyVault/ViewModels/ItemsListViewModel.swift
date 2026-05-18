import Foundation

enum ItemsListViewModel {
    static func filteredItems(
        from items: [WarrantyItem],
        searchText: String,
        filter: ItemFilter,
        sort: ItemSortOption
    ) -> [WarrantyItem] {
        let filtered = items
            .filter { $0.matchesSearch(searchText) }
            .filter { filter.includes($0) }

        return sort.sort(filtered)
    }
}
