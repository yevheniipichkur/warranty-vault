import SwiftData
import SwiftUI

struct ItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @StateObject private var liveActivityManager = LiveActivityManager.shared

    let item: WarrantyItem

    @State private var isShowingEdit = false
    @State private var isShowingDeleteConfirmation = false
    @State private var isShowingPaywall = false
    @State private var sharedURL: URL?
    @State private var reminderScheduled = false
    @State private var isShowingLiveActivityMessage = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                DetailHeroCard(item: item)
                    .animatedCard(delay: 0.02)

                if item.warrantyStatus == .expiringSoon {
                    PremiumCard(cornerRadius: 18, tint: .orange) {
                        Label {
                            Text("detail.expiringWarning")
                                .font(.body.weight(.medium))
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                }

                if item.hasWarranty, let expirationDate = item.warrantyExpirationDate {
                    WarrantyTimelineCard(
                        purchaseDate: item.purchaseDate,
                        expirationDate: expirationDate,
                        status: item.warrantyStatus
                    )
                    .animatedCard(delay: 0.04)
                }

                PremiumCard {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(titleKey: "detail.section.details", systemImage: "info.circle")
                        DetailRow(titleKey: "item.brand", value: item.brand)
                        DetailRow(titleKey: "item.model", value: item.modelName)
                        DetailRow(titleKey: "item.serialNumber", value: item.serialNumber)
                        DetailRow(titleKey: "item.store", value: item.store)
                        DetailRow(titleKey: "item.purchaseDate", value: DateFormatterProvider.string(from: item.purchaseDate, locale: locale))
                        DetailRow(titleKey: "item.warrantyExpiration", value: item.warrantyExpirationDate.map { DateFormatterProvider.string(from: $0, locale: locale) } ?? L10n.string("common.none", language: languageManager.selectedLanguage))
                        DetailRow(titleKey: "item.price", value: CurrencyFormatterProvider.string(from: item.price, currencyCode: item.currency, locale: locale))
                        DetailRow(titleKey: "item.category", valueKey: item.categoryType.titleKey)
                        if !item.notes.isEmpty {
                            DetailRow(titleKey: "item.notes", value: item.notes)
                        }
                    }
                }

                if item.receiptImagePath != nil || item.warrantyDocumentImagePath != nil {
                    PremiumCard {
                        VStack(alignment: .leading, spacing: 14) {
                            SectionHeader(titleKey: "detail.section.documents", systemImage: "doc.text.image")

                            HStack(spacing: 12) {
                                if item.receiptImagePath != nil {
                                    DocumentPreview(titleKey: "image.receipt", imagePath: item.receiptImagePath)
                                }

                                if item.warrantyDocumentImagePath != nil {
                                    DocumentPreview(titleKey: "image.warrantyDocument", imagePath: item.warrantyDocumentImagePath)
                                }
                            }
                        }
                    }
                }

                VStack(spacing: 10) {
                    PrimaryButton(titleKey: "detail.exportPDF", systemImage: "square.and.arrow.up") {
                        exportPDF()
                    }

                    PrimaryButton(titleKey: "detail.addReminder", systemImage: reminderScheduled ? "checkmark" : "bell.badge") {
                        Task {
                            await NotificationManager.shared.rescheduleReminders(for: item)
                            reminderScheduled = true
                        }
                    }

                    if canShowLiveActivityButton {
                        PrimaryButton(
                            titleKey: liveActivityManager.activeActivityID == nil ? "liveActivity.start" : "liveActivity.stop",
                            systemImage: liveActivityManager.activeActivityID == nil ? "waveform.path.ecg.rectangle" : "stop.circle"
                        ) {
                            Task {
                                if liveActivityManager.activeActivityID == nil {
                                    _ = await liveActivityManager.startWarrantyActivity(for: item)
                                } else {
                                    await liveActivityManager.endWarrantyActivity()
                                }
                                isShowingLiveActivityMessage = true
                            }
                        }
                    }

                    PrimaryButton(titleKey: "common.delete", systemImage: "trash", role: .destructive) {
                        isShowingDeleteConfirmation = true
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("common.edit") {
                    isShowingEdit = true
                }
            }
        }
        .sheet(isPresented: $isShowingEdit) {
            NavigationStack {
                ItemFormView(item: item)
            }
        }
        .sheet(isPresented: Binding(
            get: { sharedURL != nil },
            set: { isPresented in
                if !isPresented {
                    sharedURL = nil
                }
            }
        )) {
            if let sharedURL {
                ShareSheet(items: [sharedURL])
            }
        }
        .sheet(isPresented: $isShowingPaywall) {
            PaywallView()
        }
        .alert("liveActivity.title", isPresented: $isShowingLiveActivityMessage) {
            Button("common.ok", role: .cancel) {}
        } message: {
            Text(LocalizedStringKey(liveActivityManager.lastMessageKey ?? "liveActivity.started"))
        }
        .confirmationDialog("delete.item.title", isPresented: $isShowingDeleteConfirmation, titleVisibility: .visible) {
            Button("common.delete", role: .destructive) {
                deleteItem()
            }
            Button("common.cancel", role: .cancel) {}
        } message: {
            Text("delete.item.message")
        }
    }

    private func exportPDF() {
        guard subscriptionManager.hasPro else {
            isShowingPaywall = true
            return
        }

        if let url = try? PDFExportService().export(item: item, language: languageManager.selectedLanguage) {
            sharedURL = url
        }
    }

    private var canShowLiveActivityButton: Bool {
        item.hasWarranty && item.warrantyExpirationDate != nil && item.warrantyStatus != .expired
    }

    private func deleteItem() {
        ImageStorageService.deleteImage(at: item.productImagePath)
        ImageStorageService.deleteImage(at: item.receiptImagePath)
        ImageStorageService.deleteImage(at: item.warrantyDocumentImagePath)
        NotificationManager.shared.removeReminders(for: item.id)
        modelContext.delete(item)
        try? modelContext.save()
        dismiss()
    }
}

private struct DetailHeroCard: View {
    let item: WarrantyItem

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            StoredImageView(imagePath: item.productImagePath, placeholderSystemImage: item.categoryType.symbolName)
                .frame(maxWidth: .infinity)
                .frame(height: 286)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .overlay {
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.10), .black.opacity(0.52)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .strokeBorder(.white.opacity(0.18), lineWidth: 0.8)
                }

            VStack(alignment: .leading, spacing: 10) {
                WarrantyStatusBadge(status: item.warrantyStatus)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.82))
                            .lineLimit(1)
                    }
                }
            }
            .padding(18)
        }
        .shadow(color: DesignSystem.Shadow.elevated, radius: 22, y: 14)
    }

    private var subtitle: String {
        [item.brand, item.store].filter { !$0.isEmpty }.joined(separator: " • ")
    }
}

private struct WarrantyTimelineCard: View {
    @Environment(\.locale) private var locale

    let purchaseDate: Date
    let expirationDate: Date
    let status: WarrantyStatus

    private var progress: Double {
        let total = expirationDate.timeIntervalSince(purchaseDate)
        guard total > 0 else { return status == .expired ? 1 : 0 }
        let elapsed = Date().timeIntervalSince(purchaseDate)
        return min(max(elapsed / total, 0), 1)
    }

    private var daysLeft: Int {
        LiveActivityManager.daysLeft(until: expirationDate)
    }

    var body: some View {
        PremiumCard(tint: status.tint) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label(LocalizedStringKey("item.warrantyExpiration"), systemImage: "shield.lefthalf.filled")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                    WarrantyStatusBadge(status: status)
                }

                ProgressView(value: progress)
                    .tint(status.tint)
                    .scaleEffect(x: 1, y: 1.35, anchor: .center)

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("item.purchaseDate")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(DateFormatterProvider.string(from: purchaseDate, locale: locale))
                            .font(.subheadline.weight(.semibold))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("liveActivity.daysLeft")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(status == .expired ? "0" : "\(daysLeft)")
                            .font(.title3.weight(.bold))
                            .monospacedDigit()
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("item.warrantyExpiration")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(DateFormatterProvider.string(from: expirationDate, locale: locale))
                            .font(.subheadline.weight(.semibold))
                    }
                }
            }
        }
    }
}

private struct DetailRow: View {
    let titleKey: String
    var value: String?
    var valueKey: String?

    var body: some View {
        if let value, value.isEmpty {
            EmptyView()
        } else {
            HStack(alignment: .top, spacing: 12) {
                Text(LocalizedStringKey(titleKey))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(width: 136, alignment: .leading)

                if let valueKey {
                    Text(LocalizedStringKey(valueKey))
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text(value ?? "")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

private struct DocumentPreview: View {
    let titleKey: String
    let imagePath: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            StoredImageView(imagePath: imagePath, placeholderSystemImage: "doc.text.image")
                .frame(height: 130)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Text(LocalizedStringKey(titleKey))
                .font(.caption.weight(.semibold))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}
