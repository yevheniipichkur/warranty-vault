#if DEBUG
import SwiftUI

struct DebugActionRow: View {
    let titleKey: String
    let subtitleKey: String?
    let systemImage: String
    var role: ButtonRole?
    let action: () -> Void

    init(titleKey: String, subtitleKey: String? = nil, systemImage: String, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
        self.systemImage = systemImage
        self.role = role
        self.action = action
    }

    var body: some View {
        Button(role: role, action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundStyle(role == .destructive ? .red : Color.accentColor)
                    .frame(width: 34, height: 34)
                    .background((role == .destructive ? Color.red : Color.accentColor).opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(LocalizedStringKey(titleKey))
                        .font(.body)
                        .foregroundStyle(role == .destructive ? .red : .primary)

                    if let subtitleKey {
                        Text(LocalizedStringKey(subtitleKey))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
#endif
