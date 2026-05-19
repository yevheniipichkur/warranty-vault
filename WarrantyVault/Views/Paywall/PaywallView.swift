import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero
                    VStack(spacing: 14) {
                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(DesignSystem.Colors.premiumAmber)
                            .frame(width: 90, height: 90)
                            .background(DesignSystem.Colors.premiumAmber.opacity(0.12), in: RoundedRectangle(cornerRadius: 26, style: .continuous))

                        Text("paywall.title")
                            .font(.title.weight(.bold))
                            .multilineTextAlignment(.center)

                        Text("paywall.hero.message")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    // Benefits
                    VStack(spacing: 12) {
                        BenefitRow(
                            symbol: "infinity",
                            tint: DesignSystem.Colors.premiumBlue,
                            titleKey: "paywall.pro.unlimited",
                            bodyKey: "paywall.benefit.unlimited.body"
                        )
                        BenefitRow(
                            symbol: "doc.richtext",
                            tint: DesignSystem.Colors.premiumTeal,
                            titleKey: "paywall.pro.pdf",
                            bodyKey: "paywall.benefit.pdf.body"
                        )
                        BenefitRow(
                            symbol: "barcode.viewfinder",
                            tint: DesignSystem.Colors.premiumMint,
                            titleKey: "paywall.pro.scanner",
                            bodyKey: "paywall.benefit.scanner.body"
                        )
                        BenefitRow(
                            symbol: "bell.badge",
                            tint: DesignSystem.Colors.premiumAmber,
                            titleKey: "paywall.pro.calendar",
                            bodyKey: "paywall.benefit.calendar.body"
                        )
                    }

                    // Free plan note
                    Text("paywall.freeTierNote")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)

                    // Purchase buttons
                    VStack(spacing: 10) {
                        if subscriptionManager.products.isEmpty {
                            GlassCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("paywall.productsUnavailable")
                                        .font(.headline)
                                        .fixedSize(horizontal: false, vertical: true)
                                    if !subscriptionManager.loadDiagnostic.isEmpty {
                                        Text(subscriptionManager.loadDiagnostic)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.leading)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    if !subscriptionManager.diagnosticLines.isEmpty {
                                        Divider()
                                            .padding(.vertical, 4)
                                        ForEach(subscriptionManager.diagnosticLines, id: \.self) { line in
                                            StoreKitDiagnosticLine(line: line)
                                        }
                                    }

                                    VStack(spacing: 8) {
                                        Button {
                                            Task {
                                                await subscriptionManager.loadProducts()
                                                await subscriptionManager.refreshEntitlements()
                                            }
                                        } label: {
                                            Label("settings.storekitRefresh", systemImage: "arrow.clockwise")
                                                .font(.caption.weight(.semibold))
                                                .lineLimit(2)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .buttonStyle(.bordered)
                                        .controlSize(.small)

                                        Button {
                                            Task {
                                                await subscriptionManager.syncAppStoreAccount()
                                            }
                                        } label: {
                                            Label("settings.storekitSync", systemImage: "arrow.triangle.2.circlepath")
                                                .font(.caption.weight(.semibold))
                                                .lineLimit(2)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .buttonStyle(.bordered)
                                        .controlSize(.small)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        } else {
                            ForEach(subscriptionManager.products, id: \.id) { product in
                                Button {
                                    Task {
                                        await subscriptionManager.purchase(product)
                                    }
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(product.displayName)
                                                .font(.headline)
                                            Text(product.description)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text(product.displayPrice)
                                            .font(.title3.weight(.bold))
                                            .foregroundStyle(DesignSystem.Colors.premiumBlue)
                                    }
                                    .padding()
                                    .background(DesignSystem.Colors.premiumBlue.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .strokeBorder(DesignSystem.Colors.premiumBlue.opacity(0.2), lineWidth: 1)
                                    }
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

struct StoreKitDiagnosticLine: View {
    let line: String

    private var parts: (title: String, value: String) {
        guard let separator = line.firstIndex(of: ":") else {
            return ("", line)
        }

        let title = String(line[..<separator])
        let valueStart = line.index(after: separator)
        let value = String(line[valueStart...]).trimmingCharacters(in: .whitespaces)
        return (title, value)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if !parts.title.isEmpty {
                Text(verbatim: parts.title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text(verbatim: wrappable(parts.value))
                .font(.caption2.monospaced())
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func wrappable(_ value: String) -> String {
        let breakChar = "\u{200B}"
        return value
            .replacingOccurrences(of: ".", with: "." + breakChar)
            .replacingOccurrences(of: "-", with: "-" + breakChar)
            .replacingOccurrences(of: "_", with: "_" + breakChar)
            .replacingOccurrences(of: "/", with: "/" + breakChar)
            .replacingOccurrences(of: ",", with: "," + breakChar)
    }
}

private struct BenefitRow: View {
    let symbol: String
    let tint: Color
    let titleKey: String
    let bodyKey: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 44, height: 44)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 13, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(LocalizedStringKey(titleKey))
                    .font(.subheadline.weight(.semibold))
                Text(LocalizedStringKey(bodyKey))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.primary.opacity(0.06), lineWidth: 0.7)
        }
    }
}
