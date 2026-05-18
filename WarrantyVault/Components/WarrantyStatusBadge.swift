import SwiftUI

struct WarrantyStatusBadge: View {
    let status: WarrantyStatus

    var body: some View {
        Label {
            Text(LocalizedStringKey(status.titleKey))
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        } icon: {
            Image(systemName: status.symbolName)
                .font(.caption.weight(.bold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .foregroundStyle(tint)
        .background(tint.opacity(0.13), in: Capsule(style: .continuous))
    }

    private var tint: Color {
        switch status {
        case .active: .green
        case .expiringSoon: .orange
        case .expired: .red
        case .noWarranty: .secondary
        }
    }
}
