import Foundation

@MainActor
final class CloudSyncManager: ObservableObject {
    static let shared = CloudSyncManager()

    @Published private(set) var iCloudAccountAvailable = false
    @Published private(set) var statusKey = "icloud.status.setupRequired"

    private init() {}

    func refreshStatus() {
        iCloudAccountAvailable = FileManager.default.ubiquityIdentityToken != nil
        statusKey = iCloudAccountAvailable ? "icloud.status.setupRequired" : "icloud.status.noAccount"
    }
}
