import SwiftUI

enum FlutianoTheme {
    static let background = Color(hex: 0x06070B)

    static let surfaceSoft = Color(hex: 0x0C1219, opacity: 0.28)
    static let surface = Color(hex: 0x0F151E, opacity: 0.42)
    static let surfaceStrong = Color(hex: 0x131A24, opacity: 0.56)
    static let surfaceStrongest = Color(hex: 0x1C242E, opacity: 0.72)

    static let borderSoft = Color.white.opacity(0.09)
    static let border = Color.white.opacity(0.15)
    static let borderStrong = Color.white.opacity(0.24)

    static let gold = Color(hex: 0xD4AA6A)
    static let goldHighlight = Color(hex: 0xEACC96)
    static let goldTint = Color(hex: 0xD4AA6A, opacity: 0.17)

    static let jade = Color(hex: 0x5EC9B1)
    static let jadeTint = Color(hex: 0x5EC9B1, opacity: 0.14)

    static let rose = Color(hex: 0xF07575)
    static let roseTint = Color(hex: 0xF07575, opacity: 0.14)

    static let sky = Color(hex: 0x80BFE7)
    static let skyTint = Color(hex: 0x80BFE7, opacity: 0.13)

    static let violet = Color(hex: 0xA78BFA)
    static let violetTint = Color(hex: 0xA78BFA, opacity: 0.13)

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.82)
    static let textTertiary = Color.white.opacity(0.56)
    static let textMuted = Color.white.opacity(0.34)

    static let sidebarWidth: CGFloat = 304
    static let topbarHeight: CGFloat = 76
    static let radius: CGFloat = 20
    static let smallRadius: CGFloat = 14
}

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}
