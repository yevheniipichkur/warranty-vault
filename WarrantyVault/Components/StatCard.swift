import SwiftUI

struct StatCard: View {
    let titleKey: String
    let value: String
    let symbolName: String
    let tint: Color

    var body: some View {
        PremiumCard(cornerRadius: DesignSystem.Radius.medium, padding: DesignSystem.Spacing.medium, tint: tint) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: symbolName)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(tint)
                    .frame(width: 36, height: 36)
                    .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.title2.weight(.heavy))
                        .monospacedDigit()
                    Text(LocalizedStringKey(titleKey))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
