import SwiftData
import SwiftUI
import UIKit

struct ItemFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Query private var allItems: [WarrantyItem]

    private let item: WarrantyItem?

    @State private var name: String
    @State private var brand: String
    @State private var modelName: String
    @State private var serialNumber: String
    @State private var store: String
    @State private var purchaseDate: Date
    @State private var warrantyDuration: WarrantyDurationOption
    @State private var warrantyExpirationDate: Date
    @State private var price: Double
    @State private var currency: String
    @State private var category: WarrantyCategory
    @State private var notes: String
    @State private var productImagePath: String?
    @State private var receiptImagePath: String?
    @State private var warrantyDocumentImagePath: String?
    @State private var showingValidationAlert = false
    @State private var showingPaywall = false
    @State private var showingDeleteConfirmation = false
    @State private var showingSaveSuccess = false

    init(item: WarrantyItem? = nil) {
        self.item = item
        _name = State(initialValue: item?.name ?? "")
        _brand = State(initialValue: item?.brand ?? "")
        _modelName = State(initialValue: item?.modelName ?? "")
        _serialNumber = State(initialValue: item?.serialNumber ?? "")
        _store = State(initialValue: item?.store ?? "")
        _purchaseDate = State(initialValue: item?.purchaseDate ?? .now)
        _warrantyDuration = State(initialValue: item == nil ? .twelveMonths : (item?.hasWarranty == false ? .noWarranty : .customDate))
        _warrantyExpirationDate = State(initialValue: item?.warrantyExpirationDate ?? Calendar.current.date(byAdding: .month, value: 12, to: .now) ?? .now)
        _price = State(initialValue: item?.price ?? 0)
        _currency = State(initialValue: item?.currency ?? UserDefaults.standard.string(forKey: "defaultCurrency") ?? "USD")
        _category = State(initialValue: WarrantyCategory(rawValue: item?.category ?? WarrantyCategory.other.rawValue) ?? .other)
        _notes = State(initialValue: item?.notes ?? "")
        _productImagePath = State(initialValue: item?.productImagePath)
        _receiptImagePath = State(initialValue: item?.receiptImagePath)
        _warrantyDocumentImagePath = State(initialValue: item?.warrantyDocumentImagePath)
    }

    var body: some View {
        ZStack {
            Form {
                Section {
                    TextField("item.name", text: $name)
                    TextField("item.brand", text: $brand)
                    TextField("item.model", text: $modelName)
                    TextField("item.serialNumber", text: $serialNumber)
                    TextField("item.store", text: $store)
                } header: {
                    Text("form.section.basic")
                }

                Section {
                    DatePicker("item.purchaseDate", selection: $purchaseDate, displayedComponents: .date)

                    Picker("item.warrantyDuration", selection: $warrantyDuration) {
                        ForEach(WarrantyDurationOption.allCases) { duration in
                            Text(LocalizedStringKey(duration.titleKey)).tag(duration)
                        }
                    }

                    if warrantyDuration != .noWarranty {
                        DatePicker("item.warrantyExpiration", selection: $warrantyExpirationDate, displayedComponents: .date)
                    }
                } header: {
                    Text("form.section.warranty")
                }

                Section {
                    TextField("item.price", value: $price, format: .number)
                        .keyboardType(.decimalPad)
                    TextField("item.currency", text: $currency)
                        .textInputAutocapitalization(.characters)
                    Picker("item.category", selection: $category) {
                        ForEach(WarrantyCategory.allCases) { category in
                            Label(LocalizedStringKey(category.titleKey), systemImage: category.symbolName)
                                .tag(category)
                        }
                    }
                } header: {
                    Text("form.section.purchase")
                }

                Section {
                    TextEditor(text: $notes)
                        .frame(minHeight: 90)
                } header: {
                    Text("item.notes")
                }

                Section {
                    ImagePickerView(titleKey: "image.product", symbolName: "shippingbox", imagePath: $productImagePath)
                    ImagePickerView(titleKey: "image.receipt", symbolName: "doc.text.image", imagePath: $receiptImagePath)
                    ImagePickerView(titleKey: "image.warrantyDocument", symbolName: "doc.badge.gearshape", imagePath: $warrantyDocumentImagePath)
                } header: {
                    Text("form.section.images")
                }

                if item != nil {
                    Section {
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            Label("common.delete", systemImage: "trash")
                        }
                    }
                }
            }

            if showingSaveSuccess {
                Color.black.opacity(0.18)
                    .ignoresSafeArea()
                    .transition(.opacity)

                VStack(spacing: 12) {
                    SuccessCheckmarkAnimation()
                    Text("item.saved")
                        .font(.headline)
                }
                .padding(24)
                .glassBackground(cornerRadius: 26)
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }
        }
        .navigationTitle(item == nil ? "item.add.title" : "item.edit.title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("common.cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("common.save") {
                    save()
                }
                .fontWeight(.semibold)
            }
        }
        .onChange(of: purchaseDate) { _, _ in updateCalculatedExpirationIfNeeded() }
        .onChange(of: warrantyDuration) { _, _ in updateCalculatedExpirationIfNeeded() }
        .alert("validation.title", isPresented: $showingValidationAlert) {
            Button("common.ok", role: .cancel) {}
        } message: {
            Text("validation.nameRequired")
        }
        .confirmationDialog("delete.item.title", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("common.delete", role: .destructive) {
                deleteItem()
            }
            Button("common.cancel", role: .cancel) {}
        } message: {
            Text("delete.item.message")
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
    }

    private func updateCalculatedExpirationIfNeeded() {
        guard warrantyDuration != .customDate else { return }
        warrantyExpirationDate = WarrantyCalculator.expirationDate(
            purchaseDate: purchaseDate,
            duration: warrantyDuration
        ) ?? warrantyExpirationDate
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            showingValidationAlert = true
            return
        }

        guard item != nil || subscriptionManager.canAddItem(currentCount: allItems.count) else {
            showingPaywall = true
            return
        }

        let normalizedCurrency = currency.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let hasWarranty = warrantyDuration != .noWarranty
        let expirationDate = hasWarranty ? warrantyExpirationDate : nil
        let savedItem: WarrantyItem

        if let item {
            item.name = trimmedName
            item.brand = brand
            item.modelName = modelName
            item.serialNumber = serialNumber
            item.store = store
            item.purchaseDate = purchaseDate
            item.hasWarranty = hasWarranty
            item.warrantyExpirationDate = expirationDate
            item.price = price
            item.currency = normalizedCurrency.isEmpty ? "USD" : normalizedCurrency
            item.category = category.rawValue
            item.notes = notes
            item.productImagePath = productImagePath
            item.receiptImagePath = receiptImagePath
            item.warrantyDocumentImagePath = warrantyDocumentImagePath
            item.updatedAt = .now
            savedItem = item
        } else {
            let newItem = WarrantyItem(
                name: trimmedName,
                brand: brand,
                modelName: modelName,
                serialNumber: serialNumber,
                store: store,
                purchaseDate: purchaseDate,
                warrantyExpirationDate: expirationDate,
                hasWarranty: hasWarranty,
                price: price,
                currency: normalizedCurrency.isEmpty ? "USD" : normalizedCurrency,
                category: category.rawValue,
                notes: notes,
                productImagePath: productImagePath,
                receiptImagePath: receiptImagePath,
                warrantyDocumentImagePath: warrantyDocumentImagePath
            )
            modelContext.insert(newItem)
            savedItem = newItem
        }

        try? modelContext.save()

        Task { @MainActor in
            await NotificationManager.shared.rescheduleReminders(for: savedItem)
        }

        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        showingSaveSuccess = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 650_000_000)
            dismiss()
        }
    }

    private func deleteItem() {
        guard let item else { return }
        ImageStorageService.deleteImage(at: item.productImagePath)
        ImageStorageService.deleteImage(at: item.receiptImagePath)
        ImageStorageService.deleteImage(at: item.warrantyDocumentImagePath)
        NotificationManager.shared.removeReminders(for: item.id)
        modelContext.delete(item)
        try? modelContext.save()
        dismiss()
    }
}
