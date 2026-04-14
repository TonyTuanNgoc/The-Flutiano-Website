import AppKit
import SwiftUI

enum FlutianoTypography {
    static func body(_ size: CGFloat, weight: BodyWeight = .medium) -> Font {
        font(named: weight.fontName, fallback: .system(size: size, weight: weight.systemWeight), size: size)
    }

    static func display(_ size: CGFloat, weight: DisplayWeight = .medium) -> Font {
        font(named: weight.fontName, fallback: .system(size: size, weight: weight.systemWeight), size: size)
    }

    static func font(named postScriptName: String, fallback: Font, size: CGFloat) -> Font {
        if NSFont(name: postScriptName, size: size) != nil {
            return .custom(postScriptName, size: size)
        }
        return fallback
    }

    enum BodyWeight {
        case medium
        case semibold
        case bold
        case extraBold

        var fontName: String {
            switch self {
            case .medium: "Manrope-Medium"
            case .semibold: "Manrope-SemiBold"
            case .bold: "Manrope-Bold"
            case .extraBold: "Manrope-ExtraBold"
            }
        }

        var systemWeight: Font.Weight {
            switch self {
            case .medium: .medium
            case .semibold: .semibold
            case .bold: .bold
            case .extraBold: .heavy
            }
        }
    }

    enum DisplayWeight {
        case medium
        case semibold
        case bold

        var fontName: String {
            switch self {
            case .medium: "Sora-Medium"
            case .semibold: "Sora-SemiBold"
            case .bold: "Sora-Bold"
            }
        }

        var systemWeight: Font.Weight {
            switch self {
            case .medium: .medium
            case .semibold: .semibold
            case .bold: .bold
            }
        }
    }
}
