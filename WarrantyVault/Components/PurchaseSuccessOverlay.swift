import Foundation
import SwiftUI
import UIKit

struct PurchaseSuccessOverlay: View {
    let continueAction: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false
    @State private var burst = false

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(0.34))
                .ignoresSafeArea()
                .transition(.opacity)

            VStack(spacing: 18) {
                celebrationMark

                VStack(spacing: 8) {
                    Text("paywall.success.title")
                        .font(.title.weight(.bold))
                        .multilineTextAlignment(.center)

                    Text("paywall.success.message")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                PrimaryButton(titleKey: "paywall.success.continue", systemImage: "checkmark") {
                    continueAction()
                }
                .padding(.top, 4)
            }
            .padding(24)
            .frame(maxWidth: 340)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .strokeBorder(.white.opacity(0.22), lineWidth: 0.9)
            }
            .shadow(color: .black.opacity(0.18), radius: 26, y: 18)
            .scaleEffect(reduceMotion ? 1 : (appeared ? 1 : 0.92))
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            guard !reduceMotion else {
                appeared = true
                burst = true
                return
            }
            withAnimation(.spring(response: 0.48, dampingFraction: 0.76)) {
                appeared = true
            }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.74).delay(0.08)) {
                burst = true
            }
        }
    }

    private var celebrationMark: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { index in
                Capsule()
                    .fill(confettiColor(index))
                    .frame(width: 5, height: 14)
                    .rotationEffect(.degrees(Double(index) * 31))
                    .offset(confettiOffset(index))
                    .opacity(burst ? 1 : 0)
                    .scaleEffect(burst ? 1 : 0.35)
            }

            Circle()
                .stroke(DesignSystem.Colors.premiumMint.opacity(0.24), lineWidth: 10)
                .frame(width: burst ? 118 : 74, height: burst ? 118 : 74)
                .opacity(burst ? 0 : 1)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.premiumMint.opacity(0.96),
                            DesignSystem.Colors.premiumTeal.opacity(0.92)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 88, height: 88)
                .overlay {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 42, weight: .bold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.white)
                        .scaleEffect(burst ? 1 : 0.62)
                }
                .shadow(color: DesignSystem.Colors.premiumMint.opacity(0.28), radius: 22, y: 10)
        }
        .frame(width: 154, height: 130)
        .accessibilityHidden(true)
    }

    private func confettiColor(_ index: Int) -> Color {
        switch index % 4 {
        case 0: DesignSystem.Colors.premiumBlue
        case 1: DesignSystem.Colors.premiumMint
        case 2: DesignSystem.Colors.premiumAmber
        default: DesignSystem.Colors.premiumTeal
        }
    }

    private func confettiOffset(_ index: Int) -> CGSize {
        guard burst && !reduceMotion else { return .zero }
        let angle = Double(index) / 12.0 * Double.pi * 2.0
        let radius: CGFloat = index.isMultiple(of: 2) ? 62 : 52
        return CGSize(width: CGFloat(cos(angle)) * radius, height: CGFloat(sin(angle)) * radius)
    }
}
