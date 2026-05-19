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
        static let premiumBlue = Color(red: 0.32, green: 0.43, blue: 0.58)
        static let premiumTeal = Color(red: 0.28, green: 0.54, blue: 0.52)
        static let premiumMint = Color(red: 0.38, green: 0.61, blue: 0.46)
        static let premiumAmber = Color(red: 0.78, green: 0.54, blue: 0.28)
        static let premiumRed = Color(red: 0.70, green: 0.30, blue: 0.32)
        static let neutralGlassTint = Color(red: 0.58, green: 0.62, blue: 0.66)

        static var heroGradient: [Color] {
            [
                premiumBlue.opacity(0.88),
                premiumTeal.opacity(0.82),
                premiumMint.opacity(0.72)
            ]
        }
    }

    enum Shadow {
        static let card = Color.black.opacity(0.055)
        static let elevated = Color.black.opacity(0.10)
    }
}

extension WarrantyStatus {
    var tint: Color {
        switch self {
        case .active: DesignSystem.Colors.premiumMint
        case .expiringSoon: DesignSystem.Colors.premiumAmber
        case .expired: DesignSystem.Colors.premiumRed
        case .noWarranty: DesignSystem.Colors.neutralGlassTint
        }
    }
}
