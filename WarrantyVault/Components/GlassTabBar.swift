import SwiftUI
import UIKit

struct GlassTabBar: View {
    @Binding var selection: AppTab
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases) { tab in
                GlassTabItem(tab: tab, isSelected: selection == tab) {
                    guard selection != tab else { return }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                        selection = tab
                    }
                }
            }
        }
        .padding(8)
        .glassBackground(cornerRadius: 28)
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
        .animation(MotionManager.fastAnimation(reduceMotion: reduceMotion), value: selection)
    }
}

struct GlassTabItem: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.symbolName)
                    .font(.system(size: isSelected ? 18 : 17, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                Text(LocalizedStringKey(tab.titleKey))
                    .font(.caption2.weight(isSelected ? .semibold : .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .scaleEffect(isSelected ? 1.04 : 1)
            .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
            .background {
                if isSelected {
                    Capsule(style: .continuous)
                        .fill(Color.accentColor.opacity(0.14))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(LocalizedStringKey(tab.titleKey)))
    }
}
