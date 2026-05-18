import SwiftUI

enum MotionManager {
    static func softAnimation(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .spring(response: 0.42, dampingFraction: 0.86)
    }

    static func fastAnimation(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.9)
    }
}

struct AnimatedCardModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let delay: Double

    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .scaleEffect(reduceMotion ? 1 : (appeared ? 1 : 0.97))
            .offset(y: reduceMotion ? 0 : (appeared ? 0 : 12))
            .onAppear {
                guard !appeared else { return }

                let work = {
                    withAnimation(MotionManager.softAnimation(reduceMotion: reduceMotion)) {
                        appeared = true
                    }
                }

                if reduceMotion || delay == 0 {
                    work()
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
                }
            }
    }
}

struct SoftAppearModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .scaleEffect(reduceMotion ? 1 : (appeared ? 1 : 0.985))
            .onAppear {
                withAnimation(MotionManager.softAnimation(reduceMotion: reduceMotion)) {
                    appeared = true
                }
            }
    }
}

extension View {
    func animatedCard(delay: Double = 0) -> some View {
        modifier(AnimatedCardModifier(delay: delay))
    }

    func softAppear() -> some View {
        modifier(SoftAppearModifier())
    }
}
