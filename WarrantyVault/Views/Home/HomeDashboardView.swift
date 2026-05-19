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
            VStack(alignment: .leading, spacing: 22) {
                DashboardHeroView(
                    viewModel: viewModel,
                    totalValue: CurrencyFormatterProvider.string(from: viewModel.totalValue, currencyCode: defaultCurrency, locale: locale)
                )
                .animatedCard(delay: 0.01)

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

private struct DashboardHeroView: View {
    let viewModel: HomeDashboardViewModel
    let totalValue: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("app.name")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Text("settings.dataStaysOnDevice")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.82))
                }

                Spacer(minLength: 8)

                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white)
                    .frame(width: 58, height: 58)
                    .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 19, style: .continuous))
            }

            HStack(spacing: 10) {
                HeroMetric(value: "\(viewModel.activeCount)", titleKey: "status.active", symbolName: "checkmark.seal.fill")
                HeroMetric(value: "\(viewModel.expiringSoonCount)", titleKey: "status.expiringSoon", symbolName: "clock.badge.exclamationmark.fill")
                HeroMetric(value: "\(viewModel.expiredCount)", titleKey: "status.expired", symbolName: "xmark.seal.fill")
            }

            HStack(spacing: 10) {
                PremiumMetricPill(value: "\(viewModel.totalItems)", titleKey: "home.stat.items", symbolName: "shippingbox.fill", tint: .white)
                    .foregroundStyle(.white)
                PremiumMetricPill(value: totalValue, titleKey: "home.stat.value", symbolName: "creditcard.fill", tint: .white)
                    .foregroundStyle(.white)
            }
        }
        .padding(22)
        .background {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(LinearGradient(colors: DesignSystem.Colors.heroGradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .strokeBorder(.white.opacity(0.24), lineWidth: 0.8)
                }
        }
        .shadow(color: DesignSystem.Colors.premiumBlue.opacity(0.24), radius: 24, y: 14)
    }
}

private struct HeroMetric: View {
    let value: String
    let titleKey: String
    let symbolName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: symbolName)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white.opacity(0.92))
            Text(value)
                .font(.title2.weight(.heavy))
                .monospacedDigit()
                .foregroundStyle(.white)
            Text(LocalizedStringKey(titleKey))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.78))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
