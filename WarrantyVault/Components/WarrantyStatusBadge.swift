import SwiftUI

struct WarrantyStatusBadge: View {
    let status: WarrantyStatus

    var body: some View {
        Label {
            Text(LocalizedStringKey(status.titleKey))
                .font(.caption.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        } icon: {
            Image(systemName: status.symbolName)
                .font(.caption.weight(.bold))
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 7)
        .foregroundStyle(status.tint)
        .background(.ultraThinMaterial, in: Capsule(style: .continuous))
        .overlay {
            Capsule(style: .continuous)
                .strokeBorder(status.tint.opacity(0.28), lineWidth: 0.8)
        }
        .shadow(color: status.tint.opacity(0.12), radius: 8, y: 4)
    }
}
