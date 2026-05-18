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

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var float = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.thinMaterial)
                .frame(width: 126, height: 126)
                .overlay {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(.primary.opacity(0.08), lineWidth: 1)
                }

            Circle()
                .fill(Color.accentColor.opacity(0.12))
                .frame(width: 78, height: 78)
                .offset(x: 18, y: -18)

            symbol
                .font(.system(size: 50, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color.accentColor)
                .offset(y: reduceMotion ? 0 : (float ? -4 : 4))
        }
        .frame(width: 136, height: 136)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                float.toggle()
            }
        }
    }

    @ViewBuilder
    private var symbol: some View {
        switch kind {
        case .receiptShield:
            Image(systemName: "doc.text.image.fill")
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.green)
                        .background(.background, in: Circle())
                        .offset(x: 12, y: 8)
                }
        case .emptyBox:
            Image(systemName: "shippingbox.fill")
        case .reminderBell:
            Image(systemName: "bell.badge.fill")
        case .archiveExport:
            Image(systemName: "square.and.arrow.up.fill")
        case .search:
            Image(systemName: "magnifyingglass")
        }
    }
}
