import SwiftUI

struct StatusBadge: View {
    let status: WarrantyStatus

    var body: some View {
        Label {
            Text(LocalizedStringKey(status.titleKey))
                .font(.caption2.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        } icon: {
            Image(systemName: status.symbolName)
                .font(.caption2.weight(.bold))
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .foregroundStyle(status.tint)
        .background(status.tint.opacity(0.12), in: Capsule(style: .continuous))
        .overlay {
            Capsule(style: .continuous)
                .strokeBorder(status.tint.opacity(0.22), lineWidth: 0.7)
        }
    }
}

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
