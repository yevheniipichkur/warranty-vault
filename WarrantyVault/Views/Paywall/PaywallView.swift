import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 54, weight: .bold))
                        .foregroundStyle(DesignSystem.Colors.premiumAmber)
                        .frame(width: 96, height: 96)
                        .background(DesignSystem.Colors.premiumAmber.opacity(0.13), in: RoundedRectangle(cornerRadius: 28, style: .continuous))

                    VStack(spacing: 8) {
                        Text("paywall.title")
                            .font(.largeTitle.weight(.bold))
                        Text("paywall.subtitle")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    HStack(alignment: .top, spacing: 12) {
                        PlanCard(titleKey: "paywall.free", featureKeys: ["paywall.free.items", "paywall.free.reminders"])
                        PlanCard(titleKey: "paywall.pro", featureKeys: ["paywall.pro.unlimited", "paywall.pro.pdf", "paywall.pro.receipts", "paywall.pro.filters", "paywall.pro.scanner", "paywall.pro.calendar", "paywall.pro.icloud"])
                    }

                    VStack(spacing: 10) {
                        if subscriptionManager.products.isEmpty {
                            GlassCard {
                                VStack(spacing: 8) {
                                    Text("paywall.productsUnavailable")
                                        .font(.headline)
                                    Text("paywall.productIDs")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        } else {
                            ForEach(subscriptionManager.products, id: \.id) { product in
                                Button {
                                    Task {
                                        await subscriptionManager.purchase(product)
                                    }
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(product.displayName)
                                                .font(.headline)
                                            Text(product.description)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text(product.displayPrice)
                                            .font(.headline)
                                    }
                                    .padding()
                                    .glassBackground(cornerRadius: 18)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    if let error = subscriptionManager.lastErrorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
                .padding(20)
            }
            .navigationTitle("paywall.navigationTitle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.close") {
                        dismiss()
                    }
                }
            }
            .task {
                await subscriptionManager.loadProducts()
                await subscriptionManager.refreshEntitlements()
            }
        }
    }
}

private struct PlanCard: View {
    let titleKey: String
    let featureKeys: [String]

    var body: some View {
        GlassCard(cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text(LocalizedStringKey(titleKey))
                    .font(.headline)

                ForEach(featureKeys, id: \.self) { key in
                    Label(LocalizedStringKey(key), systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
