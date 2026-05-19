import SwiftUI

struct SuccessCheckmarkAnimation: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    var body: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Colors.premiumMint.opacity(0.16))
            Image(systemName: "checkmark")
                .font(.system(size: 38, weight: .bold))
                .foregroundStyle(DesignSystem.Colors.premiumMint)
                .scaleEffect(isVisible ? 1 : 0.7)
                .opacity(isVisible ? 1 : 0)
        }
        .frame(width: 92, height: 92)
        .onAppear {
            withAnimation(MotionManager.softAnimation(reduceMotion: reduceMotion)) {
                isVisible = true
            }
        }
    }
}
