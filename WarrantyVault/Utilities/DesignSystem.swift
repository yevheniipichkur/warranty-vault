import SwiftUI

enum DesignSystem {
    enum Spacing {
        static let xsmall: CGFloat = 6
        static let small: CGFloat = 10
        static let medium: CGFloat = 14
        static let large: CGFloat = 20
        static let xlarge: CGFloat = 28
    }

    enum Radius {
        static let small: CGFloat = 12
        static let medium: CGFloat = 18
        static let large: CGFloat = 24
        static let xlarge: CGFloat = 30
    }

    enum Colors {
        static let premiumBlue = Color(red: 0.18, green: 0.42, blue: 0.86)
        static let premiumTeal = Color(red: 0.10, green: 0.62, blue: 0.58)
        static let premiumMint = Color(red: 0.22, green: 0.70, blue: 0.44)
        static let premiumAmber = Color(red: 0.96, green: 0.58, blue: 0.18)

        static var heroGradient: [Color] {
            [
                premiumBlue.opacity(0.95),
                premiumTeal.opacity(0.92),
                premiumMint.opacity(0.86)
            ]
        }
    }

    enum Shadow {
        static let card = Color.black.opacity(0.08)
        static let elevated = Color.black.opacity(0.14)
    }
}

extension WarrantyStatus {
    var tint: Color {
        switch self {
        case .active: DesignSystem.Colors.premiumMint
        case .expiringSoon: DesignSystem.Colors.premiumAmber
        case .expired: .red
        case .noWarranty: .secondary
        }
    }
}
