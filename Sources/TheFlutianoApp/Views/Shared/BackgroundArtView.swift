import SwiftUI

struct BackgroundArtView: View {
    var body: some View {
        GeometryReader { _ in
            ZStack {
                FlutianoTheme.background

                Image("dashboard-bg", bundle: .module)
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(1.035)
                    .saturation(0.96)
                    .contrast(1.04)
                    .brightness(-0.08)
                    .blur(radius: 0.8)
                    .overlay {
                        LinearGradient(
                            colors: [
                                Color(hex: 0x07080B, opacity: 0.66),
                                Color(hex: 0x0B0D11, opacity: 0.34),
                                Color(hex: 0x160F0A, opacity: 0.26)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                    .overlay {
                        LinearGradient(
                            colors: [
                                Color(hex: 0x05070A, opacity: 0.08),
                                Color(hex: 0x040509, opacity: 0.66)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    .clipped()

                Rectangle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: 0xE6A766, opacity: 0.22),
                                .clear
                            ],
                            center: UnitPoint(x: 0.66, y: 0.2),
                            startRadius: 0,
                            endRadius: 460
                        )
                    )
                    .blendMode(.screen)

                Rectangle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: 0x35515E, opacity: 0.12),
                                .clear
                            ],
                            center: UnitPoint(x: 0.1, y: 0.84),
                            startRadius: 0,
                            endRadius: 380
                        )
                    )
                    .blendMode(.screen)

                LinearGradient(
                    colors: [
                        Color(hex: 0x030508, opacity: 0.05),
                        Color(hex: 0x030508, opacity: 0.44)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .blendMode(.screen)
            }
            .ignoresSafeArea()
        }
    }
}
