import SwiftUI

struct PrimaryButton: View {
    let titleKey: String
    var systemImage: String?
    var role: ButtonRole?
    let action: () -> Void

    var body: some View {
        Button(role: role, action: action) {
            Label {
                Text(LocalizedStringKey(titleKey))
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            } icon: {
                if let systemImage {
                    Image(systemName: systemImage)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 15))
        .controlSize(.large)
    }
}
