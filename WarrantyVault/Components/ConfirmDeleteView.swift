import SwiftUI

struct ConfirmDeleteView: View {
    let titleKey: String
    let messageKey: String
    let deleteAction: () -> Void
    let cancelAction: () -> Void

    var body: some View {
        GlassCard {
            VStack(spacing: 18) {
                Image(systemName: "trash.fill")
                    .font(.title.weight(.bold))
                    .foregroundStyle(DesignSystem.Colors.premiumRed)
                    .frame(width: 58, height: 58)
                    .background(DesignSystem.Colors.premiumRed.opacity(0.12), in: Circle())

                VStack(spacing: 6) {
                    Text(LocalizedStringKey(titleKey))
                        .font(.title3.weight(.semibold))
                    Text(LocalizedStringKey(messageKey))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 12) {
                    Button("common.cancel", action: cancelAction)
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)

                    Button(role: .destructive, action: deleteAction) {
                        Text("common.delete")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
    }
}
