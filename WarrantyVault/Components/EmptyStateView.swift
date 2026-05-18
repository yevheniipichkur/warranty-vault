import SwiftUI

struct EmptyStateView: View {
    let symbolName: String
    let titleKey: String
    let messageKey: String
    var illustrationKind: EmptyStateIllustrationKind = .emptyBox
    var actionTitleKey: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            EmptyStateIllustrationView(kind: illustrationKind)

            VStack(spacing: 6) {
                Text(LocalizedStringKey(titleKey))
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                Text(LocalizedStringKey(messageKey))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitleKey, let action {
                PrimaryButton(titleKey: actionTitleKey, systemImage: "plus", action: action)
                    .frame(maxWidth: 220)
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .softAppear()
    }
}
