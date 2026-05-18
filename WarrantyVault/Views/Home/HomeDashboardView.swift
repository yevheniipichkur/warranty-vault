import SwiftData
import SwiftUI

struct HomeDashboardView: View {
    @Environment(\.locale) private var locale
    @AppStorage("defaultCurrency") private var defaultCurrency = "USD"
    @Query(sort: \WarrantyItem.createdAt, order: .reverse) private var items: [WarrantyItem]

    @State private var isShowingItemForm = false

    private var viewModel: HomeDashboardViewModel {
        HomeDashboardViewModel(items: items)
    }

    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if items.isEmpty {
                    EmptyStateView(
                        symbolName: "shippingbox",
                        titleKey: "home.empty.title",
                        messageKey: "home.empty.message",
                        illustrationKind: .emptyBox,
                        actionTitleKey: "item.add",
                        action: { isShowingItemForm = true }
                    )
                    .padding(.top, 48)
                } else {
                    LazyVGrid(columns: gridColumns, spacing: 12) {
                        StatCard(titleKey: "home.stat.items", value: "\(viewModel.totalItems)", symbolName: "shippingbox.fill", tint: .blue)
                            .animatedCard(delay: 0.02)
                        StatCard(titleKey: "home.stat.expiring", value: "\(viewModel.expiringSoonCount)", symbolName: "clock.badge.exclamationmark.fill", tint: .orange)
                            .animatedCard(delay: 0.06)
                        StatCard(titleKey: "home.stat.expired", value: "\(viewModel.expiredCount)", symbolName: "xmark.seal.fill", tint: .red)
                            .animatedCard(delay: 0.10)
                        StatCard(
                            titleKey: "home.stat.value",
                            value: CurrencyFormatterProvider.string(from: viewModel.totalValue, currencyCode: defaultCurrency, locale: locale),
                            symbolName: "creditcard.fill",
                            tint: .green
                        )
                        .animatedCard(delay: 0.14)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(titleKey: "home.upcoming", systemImage: "calendar.badge.clock")

                        if viewModel.upcomingExpirations.isEmpty {
                            GlassCard {
                                Text("home.noUpcoming")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        } else {
                            ForEach(viewModel.upcomingExpirations) { item in
                                NavigationLink {
                                    ItemDetailView(item: item)
                                } label: {
                                    ItemCard(item: item)
                                        .animatedCard(delay: 0.04)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("home.title")
        .toolbar {
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
