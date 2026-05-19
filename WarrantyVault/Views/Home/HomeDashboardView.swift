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
                    ProtectionCenterView(viewModel: viewModel)

                    if !viewModel.needsAttention.isEmpty {
                        HomeItemSection(titleKey: "home.needsAttention", systemImage: "exclamationmark.shield.fill", items: viewModel.needsAttention)
                            .animatedCard(delay: 0.03)
                    }

                    if !viewModel.upcomingExpirations.isEmpty {
                        HomeItemSection(titleKey: "home.upcoming", systemImage: "calendar.badge.clock", items: viewModel.upcomingExpirations)
                            .animatedCard(delay: 0.06)
                    }

                    if !viewModel.recentItems.isEmpty {
                        HomeItemSection(titleKey: "home.recentItems", systemImage: "clock.arrow.circlepath", items: viewModel.recentItems)
                            .animatedCard(delay: 0.09)
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

private struct ProtectionCenterView: View {
    let viewModel: HomeDashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(titleKey: "home.protectionCenter", systemImage: "shield.checkered")

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ActionInsightCard(
                    value: "\(viewModel.openReturnWindowCount)",
                    titleKey: "home.returnWindows",
                    symbolName: "arrow.uturn.backward.circle.fill",
                    tint: DesignSystem.Colors.premiumAmber
                )

                ActionInsightCard(
                    value: "\(viewModel.missingReceiptCount)",
                    titleKey: "home.missingReceipts",
                    symbolName: "doc.text.magnifyingglass",
                    tint: DesignSystem.Colors.premiumRed
                )

                ActionInsightCard(
                    value: "\(viewModel.repairRecordCount)",
                    titleKey: "home.repairsLogged",
                    symbolName: "stethoscope",
                    tint: DesignSystem.Colors.premiumTeal
                )

                ActionInsightCard(
                    value: "\(viewModel.activeCount)",
                    titleKey: "home.coveredItems",
                    symbolName: "checkmark.shield.fill",
                    tint: DesignSystem.Colors.premiumMint
                )
            }
        }
    }
}

private struct ActionInsightCard: View {
    let value: String
    let titleKey: String
    let symbolName: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: symbolName)
                .font(.subheadline.weight(.bold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(value)
                .font(.title3.weight(.bold))
                .monospacedDigit()

            Text(LocalizedStringKey(titleKey))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.secondary.opacity(0.07), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(tint.opacity(0.14), lineWidth: 0.8)
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
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Text(LocalizedStringKey(viewModel.attentionCount == 0 ? "home.hero.allGood" : "home.hero.attention"))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                PremiumArtworkView(kind: .vault, size: 82)
                    .accessibilityHidden(true)
            }

            HStack(spacing: 10) {
                HeroMetric(value: "\(viewModel.activeCount)", titleKey: "status.active", symbolName: "checkmark.seal.fill", tint: DesignSystem.Colors.premiumMint)
                HeroMetric(value: "\(viewModel.expiringSoonCount)", titleKey: "status.expiringSoon", symbolName: "clock.badge.exclamationmark.fill", tint: DesignSystem.Colors.premiumAmber)
                HeroMetric(value: "\(viewModel.expiredCount)", titleKey: "status.expired", symbolName: "xmark.seal.fill", tint: DesignSystem.Colors.premiumRed)
            }

            HStack(spacing: 10) {
                PremiumMetricPill(value: "\(viewModel.totalItems)", titleKey: "home.stat.items", symbolName: "shippingbox.fill", tint: DesignSystem.Colors.premiumBlue)
                PremiumMetricPill(value: totalValue, titleKey: "home.stat.value", symbolName: "creditcard.fill", tint: DesignSystem.Colors.premiumTeal)
            }
        }
        .padding(22)
        .background {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.thinMaterial)
                .overlay {
                    LinearGradient(colors: DesignSystem.Colors.heroGradient.map { $0.opacity(0.24) }, startPoint: .topLeading, endPoint: .bottomTrailing)
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .strokeBorder(.primary.opacity(0.07), lineWidth: 0.8)
                }
        }
        .shadow(color: DesignSystem.Shadow.card, radius: 22, y: 12)
    }
}

private struct HeroMetric: View {
    let value: String
    let titleKey: String
    let symbolName: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: symbolName)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(tint)
            Text(value)
                .font(.title2.weight(.heavy))
                .monospacedDigit()
                .foregroundStyle(.primary)
            Text(LocalizedStringKey(titleKey))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(.primary.opacity(0.06), lineWidth: 0.7)
        }
    }
}

private struct HomeItemSection: View {
    @Environment(\.modelContext) private var modelContext
    let titleKey: String
    let systemImage: String
    let items: [WarrantyItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(titleKey: titleKey, systemImage: systemImage)

            ForEach(items) { item in
                NavigationLink {
                    ItemDetailView(item: item)
                } label: {
                    ItemCard(item: item)
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        deleteItem(item)
                    } label: {
                        Label("common.delete", systemImage: "trash")
                    }
                }
            }
        }
    }

    private func deleteItem(_ item: WarrantyItem) {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        ImageStorageService.deleteImage(at: item.productImagePath)
        ImageStorageService.deleteImage(at: item.receiptImagePath)
        ImageStorageService.deleteImage(at: item.warrantyDocumentImagePath)
        NotificationManager.shared.removeReminders(for: item.id)
        modelContext.delete(item)
        try? modelContext.save()
    }
}
