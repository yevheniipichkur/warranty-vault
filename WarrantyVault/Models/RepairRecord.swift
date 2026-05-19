import Foundation

struct RepairRecord: Codable, Identifiable, Equatable {
    var id: UUID
    var date: Date
    var serviceCenter: String
    var cost: Double
    var currency: String
    var notes: String

    init(
        id: UUID = UUID(),
        date: Date = .now,
        serviceCenter: String = "",
        cost: Double = 0,
        currency: String = "USD",
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.serviceCenter = serviceCenter
        self.cost = cost
        self.currency = currency
        self.notes = notes
    }
}
