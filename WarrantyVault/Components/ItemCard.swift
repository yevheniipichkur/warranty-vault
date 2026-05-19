import SwiftUI

struct WarrantyItemCard: View {
    let item: WarrantyItem

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.locale) private var locale

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            thumbnail

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.name)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        subtitleView
                    }

                    Spacer(minLength: 6)

                    StatusBadge(status: item.warrantyStatus)
                }

                dateRow

                if item.hasWarranty, item.warrantyExpirationDate != nil {
                    WarrantyProgressLine(progress: warrantyProgress, tint: item.warrantyStatus.tint)
                }
            }
        }
        // Performance: this list cell intentionally avoids per-row Material, gradients,
        // and large shadows so scrolling stays smooth with many warranty items.
        .padding(12)
        .background(cardBackground, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 0.8)
        }
        .shadow(color: shadowColor, radius: colorScheme == .dark ? 0 : 8, x: 0, y: 4)
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var thumbnail: some View {
        StoredImageView(imagePath: item.productImagePath, placeholderSystemImage: item.categoryType.symbolName)
            .frame(width: 58, height: 58)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.7)
            }
    }

    @ViewBuilder
    private var subtitleView: some View {
        if !subtitle.isEmpty {
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.86)
        } else {
            Label(LocalizedStringKey(item.categoryType.titleKey), systemImage: item.categoryType.symbolName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    private var dateRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            DateInfoLine(symbolName: "calendar", text: DateFormatterProvider.string(from: item.purchaseDate, locale: locale))

            if let expiration = item.warrantyExpirationDate {
                DateInfoLine(symbolName: "shield", text: DateFormatterProvider.string(from: expiration, locale: locale))
            }

            if let returnDeadline = item.returnDeadlineDate,
               item.returnWindowStatus != .expired {
                DateInfoLine(symbolName: "arrow.uturn.backward.circle", text: DateFormatterProvider.string(from: returnDeadline, locale: locale))
            }
        }
        .padding(.top, 1)
    }

    private var cardBackground: Color {
        Color(uiColor: colorScheme == .dark ? .secondarySystemBackground : .systemBackground)
    }

    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.07) : Color.black.opacity(0.055)
    }

    private var shadowColor: Color {
        colorScheme == .dark ? .clear : Color.black.opacity(0.045)
    }

    private var subtitle: String {
        var parts = [item.brand, item.store].filter { !$0.isEmpty }
        if item.roomType != .unassigned {
            parts.append(L10n.string(item.roomType.titleKey, locale: locale))
        }
        return parts.joined(separator: " • ")
    }

    private var warrantyProgress: Double {
        guard let expirationDate = item.warrantyExpirationDate else { return 0 }
        let total = expirationDate.timeIntervalSince(item.purchaseDate)
        guard total > 0 else { return item.warrantyStatus == .expired ? 1 : 0 }
        return min(max(Date().timeIntervalSince(item.purchaseDate) / total, 0), 1)
    }
}

typealias ItemCard = WarrantyItemCard

private struct DateInfoLine: View {
    let symbolName: String
    let text: String

    var body: some View {
        Label {
            Text(text)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        } icon: {
            Image(systemName: symbolName)
                .font(.caption.weight(.semibold))
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}

private struct WarrantyProgressLine: View {
    let progress: Double
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(Color.secondary.opacity(0.12))

                Capsule(style: .continuous)
                    .fill(tint.opacity(0.78))
                    .frame(width: max(6, proxy.size.width * CGFloat(progress)))
            }
        }
        .frame(height: 4)
        .accessibilityHidden(true)
    }
}

struct WarrantyCardButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.985 : 1))
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(MotionManager.fastAnimation(reduceMotion: reduceMotion), value: configuration.isPressed)
    }
}
