@preconcurrency import EventKit
import Foundation

enum CalendarExportError: Error {
    case noWarrantyDate
    case permissionDenied
    case saveFailed
}

@MainActor
final class CalendarExportService {
    private let eventStore = EKEventStore()

    func addWarrantyEvent(for item: WarrantyItem, language: AppLanguage) async throws {
        guard let expirationDate = item.warrantyExpirationDate else {
            throw CalendarExportError.noWarrantyDate
        }

        let hasAccess = try await requestCalendarAccess()
        guard hasAccess else {
            throw CalendarExportError.permissionDenied
        }

        guard let calendar = eventStore.defaultCalendarForNewEvents else {
            throw CalendarExportError.saveFailed
        }

        let event = EKEvent(eventStore: eventStore)
        event.calendar = calendar
        event.title = String(format: L10n.string("calendar.event.title", language: language), item.name)
        event.notes = notes(for: item, language: language)

        let start = Calendar.current.startOfDay(for: expirationDate)
        event.startDate = start
        event.endDate = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? expirationDate
        event.isAllDay = true
        event.alarms = [
            EKAlarm(relativeOffset: -30 * 24 * 60 * 60),
            EKAlarm(relativeOffset: -7 * 24 * 60 * 60)
        ]

        do {
            try eventStore.save(event, span: .thisEvent)
        } catch {
            throw CalendarExportError.saveFailed
        }
    }

    private func requestCalendarAccess() async throws -> Bool {
        if #available(iOS 17.0, *) {
            return try await eventStore.requestWriteOnlyAccessToEvents()
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: granted)
                    }
                }
            }
        }
    }

    private func notes(for item: WarrantyItem, language: AppLanguage) -> String {
        var lines = [L10n.string("calendar.event.notesHeader", language: language)]

        if !item.brand.isEmpty {
            lines.append("\(L10n.string("item.brand", language: language)): \(item.brand)")
        }

        if !item.modelName.isEmpty {
            lines.append("\(L10n.string("item.model", language: language)): \(item.modelName)")
        }

        if !item.serialNumber.isEmpty {
            lines.append("\(L10n.string("item.serialNumber", language: language)): \(item.serialNumber)")
        }

        if !item.store.isEmpty {
            lines.append("\(L10n.string("item.store", language: language)): \(item.store)")
        }

        if !item.notes.isEmpty {
            lines.append("\(L10n.string("item.notes", language: language)): \(item.notes)")
        }

        return lines.joined(separator: "\n")
    }
}
