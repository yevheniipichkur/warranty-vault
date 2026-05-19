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
    @State private var isShowingCalendarMessage = false
    @State private var calendarMessageKey = "calendar.added"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                DetailHeroCard(item: item)
                    .animatedCard(delay: 0.02)

                if item.warrantyStatus == .expiringSoon {
                    PremiumCard(cornerRadius: 18, tint: DesignSystem.Colors.premiumAmber) {
                        Label {
                            Text("detail.expiringWarning")
                                .font(.body.weight(.medium))
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(DesignSystem.Colors.premiumAmber)
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

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
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

                DetailActionGrid(
                    reminderScheduled: reminderScheduled,
                    showsLiveActivity: canShowLiveActivityButton,
                    showsCalendar: canShowCalendarButton,
                    liveActivityIsRunning: liveActivityManager.activeActivityID != nil,
                    exportAction: exportPDF,
                    reminderAction: {
                        Task {
                            await NotificationManager.shared.rescheduleReminders(for: item)
                            reminderScheduled = true
                        }
                    },
                    liveActivityAction: {
                        Task {
                            if liveActivityManager.activeActivityID == nil {
                                _ = await liveActivityManager.startWarrantyActivity(for: item)
                            } else {
                                await liveActivityManager.endWarrantyActivity()
                            }
                            isShowingLiveActivityMessage = true
                        }
                    },
                    calendarAction: {
                        Task {
                            await addToCalendar()
                        }
                    }
                )

                Button(role: .destructive) {
                    isShowingDeleteConfirmation = true
                } label: {
                    Label("common.delete", systemImage: "trash")
                        .font(.headline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .foregroundStyle(DesignSystem.Colors.premiumRed)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(DesignSystem.Colors.premiumRed.opacity(0.22), lineWidth: 0.8)
                        }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
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
        .alert("calendar.title", isPresented: $isShowingCalendarMessage) {
            Button("common.ok", role: .cancel) {}
        } message: {
            Text(LocalizedStringKey(calendarMessageKey))
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

    private var canShowCalendarButton: Bool {
        item.hasWarranty && item.warrantyExpirationDate != nil
    }

    private func addToCalendar() async {
        guard subscriptionManager.hasPro else {
            isShowingPaywall = true
            return
        }

        do {
            try await CalendarExportService().addWarrantyEvent(for: item, language: languageManager.selectedLanguage)
            calendarMessageKey = "calendar.added"
        } catch CalendarExportError.permissionDenied {
            calendarMessageKey = "calendar.permissionDenied"
        } catch CalendarExportError.noWarrantyDate {
            calendarMessageKey = "calendar.noWarranty"
        } catch {
            calendarMessageKey = "calendar.failed"
        }

        isShowingCalendarMessage = true
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

private struct DetailActionGrid: View {
    let reminderScheduled: Bool
    let showsLiveActivity: Bool
    let showsCalendar: Bool
    let liveActivityIsRunning: Bool
    let exportAction: () -> Void
    let reminderAction: () -> Void
    let liveActivityAction: () -> Void
    let calendarAction: () -> Void

    private var columns: [GridItem] {
        [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            DetailActionButton(
                titleKey: "detail.exportPDF",
                systemImage: "square.and.arrow.up",
                tint: DesignSystem.Colors.premiumBlue,
                action: exportAction
            )

            DetailActionButton(
                titleKey: "detail.addReminder",
                systemImage: reminderScheduled ? "checkmark.circle.fill" : "bell.badge",
                tint: DesignSystem.Colors.premiumAmber,
                action: reminderAction
            )

            if showsCalendar {
                DetailActionButton(
                    titleKey: "calendar.add",
                    systemImage: "calendar.badge.plus",
                    tint: DesignSystem.Colors.premiumMint,
                    action: calendarAction
                )
            }

            if showsLiveActivity {
                DetailActionButton(
                    titleKey: liveActivityIsRunning ? "liveActivity.stop" : "liveActivity.start",
                    systemImage: liveActivityIsRunning ? "stop.circle" : "waveform.path.ecg.rectangle",
                    tint: DesignSystem.Colors.premiumTeal,
                    action: liveActivityAction
                )
            }
        }
    }
}

private struct DetailActionButton: View {
    let titleKey: String
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.title3.weight(.semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(tint)
                    .frame(width: 38, height: 38)
                    .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                Text(LocalizedStringKey(titleKey))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.82)
            }
            .frame(maxWidth: .infinity, minHeight: 112)
            .padding(.horizontal, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(tint.opacity(0.18), lineWidth: 0.8)
            }
            .shadow(color: tint.opacity(0.08), radius: 10, y: 6)
        }
        .buttonStyle(.plain)
    }
}

private struct DetailHeroCard: View {
    let item: WarrantyItem

    @State private var isViewerPresented = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            StoredImageView(imagePath: item.productImagePath, placeholderSystemImage: item.categoryType.symbolName)
                .frame(maxWidth: .infinity)
                .frame(height: 270)
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
                .overlay(alignment: .topTrailing) {
                    if ImageStorageService.url(for: item.productImagePath) != nil {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.subheadline.weight(.semibold))
                            .padding(8)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .padding(12)
                    }
                }
                .onTapGesture {
                    guard ImageStorageService.url(for: item.productImagePath) != nil else { return }
                    isViewerPresented = true
                }

            VStack(alignment: .leading, spacing: 10) {
                WarrantyStatusBadge(status: item.warrantyStatus)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)
                        .fixedSize(horizontal: false, vertical: true)

                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.82))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .shadow(color: DesignSystem.Shadow.elevated, radius: 22, y: 14)
        .fullScreenCover(isPresented: $isViewerPresented) {
            if let url = ImageStorageService.url(for: item.productImagePath) {
                MediaViewerSheet(urls: [url])
            }
        }
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
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .center, spacing: 10) {
                        timelineTitle
                        Spacer(minLength: 8)
                        WarrantyStatusBadge(status: status)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        timelineTitle
                        WarrantyStatusBadge(status: status)
                    }
                }

                ProgressView(value: progress)
                    .tint(status.tint)
                    .scaleEffect(x: 1, y: 1.35, anchor: .center)

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    TimelineMetric(
                        titleKey: "item.purchaseDate",
                        value: DateFormatterProvider.string(from: purchaseDate, locale: locale),
                        alignment: .leading
                    )

                    TimelineMetric(
                        titleKey: "liveActivity.daysLeft",
                        value: status == .expired ? "0" : "\(daysLeft)",
                        alignment: .center,
                        isEmphasized: true
                    )

                    TimelineMetric(
                        titleKey: "item.warrantyExpiration",
                        value: DateFormatterProvider.string(from: expirationDate, locale: locale),
                        alignment: .leading
                    )
                }
            }
        }
    }

    private var timelineTitle: some View {
        Label(LocalizedStringKey("item.warrantyExpiration"), systemImage: "shield.lefthalf.filled")
            .font(.headline.weight(.semibold))
            .foregroundStyle(.primary)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
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
            VStack(alignment: .leading, spacing: 5) {
                Text(LocalizedStringKey(titleKey))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if let valueKey {
                    Text(LocalizedStringKey(valueKey))
                        .font(.subheadline.weight(.medium))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text(value ?? "")
                        .font(.subheadline.weight(.medium))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 3)
        }
    }
}

private struct TimelineMetric: View {
    let titleKey: String
    let value: String
    var alignment: TimelineMetricAlignment = .leading
    var isEmphasized = false

    var body: some View {
        VStack(alignment: horizontalAlignment, spacing: 4) {
            Text(LocalizedStringKey(titleKey))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(textAlignment)
                .minimumScaleFactor(0.78)

            Text(value)
                .font(isEmphasized ? .title3.weight(.bold) : .subheadline.weight(.semibold))
                .monospacedDigit()
                .lineLimit(2)
                .multilineTextAlignment(textAlignment)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity, alignment: frameAlignment)
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var horizontalAlignment: HorizontalAlignment {
        alignment == .center ? .center : .leading
    }

    private var textAlignment: TextAlignment {
        alignment == .center ? .center : .leading
    }

    private var frameAlignment: Alignment {
        alignment == .center ? .center : .leading
    }
}

private enum TimelineMetricAlignment: Equatable {
    case leading
    case center
}

private struct DocumentPreview: View {
    let titleKey: String
    let imagePath: String?

    @State private var isViewerPresented = false

    var body: some View {
        Button {
            guard ImageStorageService.url(for: imagePath) != nil else { return }
            isViewerPresented = true
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                StoredImageView(imagePath: imagePath, placeholderSystemImage: "doc.text.image")
                    .frame(height: 130)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(alignment: .bottomTrailing) {
                        if ImageStorageService.url(for: imagePath) != nil {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.caption.weight(.semibold))
                                .padding(6)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                                .padding(6)
                        }
                    }

                Text(LocalizedStringKey(titleKey))
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $isViewerPresented) {
            if let url = ImageStorageService.url(for: imagePath) {
                MediaViewerSheet(urls: [url])
            }
        }
    }
}
