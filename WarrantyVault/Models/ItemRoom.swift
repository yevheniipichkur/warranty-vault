import Foundation

enum ItemRoom: String, CaseIterable, Identifiable {
    case unassigned
    case kitchen
    case livingRoom
    case bedroom
    case office
    case garage
    case car
    case storage

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .unassigned: "room.unassigned"
        case .kitchen: "room.kitchen"
        case .livingRoom: "room.livingRoom"
        case .bedroom: "room.bedroom"
        case .office: "room.office"
        case .garage: "room.garage"
        case .car: "room.car"
        case .storage: "room.storage"
        }
    }

    var symbolName: String {
        switch self {
        case .unassigned: "square.grid.2x2"
        case .kitchen: "fork.knife"
        case .livingRoom: "sofa.fill"
        case .bedroom: "bed.double.fill"
        case .office: "desktopcomputer"
        case .garage: "wrench.and.screwdriver.fill"
        case .car: "car.fill"
        case .storage: "archivebox.fill"
        }
    }
}
