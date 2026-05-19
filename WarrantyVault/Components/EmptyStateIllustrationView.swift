import SwiftUI

enum EmptyStateIllustrationKind {
    case receiptShield
    case emptyBox
    case reminderBell
    case archiveExport
    case search
}

struct EmptyStateIllustrationView: View {
    let kind: EmptyStateIllustrationKind

    var body: some View {
        PremiumArtworkView(kind: artworkKind, size: 136)
        .frame(width: 136, height: 136)
    }

    private var artworkKind: PremiumArtworkKind {
        switch kind {
        case .receiptShield:
            .receipt
        case .emptyBox:
            .vault
        case .reminderBell:
            .reminder
        case .archiveExport:
            .archive
        case .search:
            .search
        }
    }
}
