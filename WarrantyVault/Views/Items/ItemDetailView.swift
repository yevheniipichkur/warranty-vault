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
                StoredImageView(imagePath: item.productImagePath, placeholderSystemImage: item.categoryType.symbolName)
                    .frame(maxWidth: .infinity)
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(alignment: .bottomLeading) {
                        WarrantyStatusBadge(status: item.warrantyStatus)
                            .padding(14)
                    }

                if item.warrantyStatus == .expiringSoon {
                    GlassCard(cornerRadius: 18) {
                        Label {
                            Text("detail.expiringWarning")
                                .font(.body.weight(.medium))
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                }

                GlassCard {
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
                    GlassCard {
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
