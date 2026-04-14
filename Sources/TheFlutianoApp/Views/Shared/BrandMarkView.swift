import SwiftUI

struct BrandMarkView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                FlutianoTheme.gold.opacity(0.22),
                                FlutianoTheme.gold.opacity(0.10)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(FlutianoTheme.gold.opacity(0.28), lineWidth: 1)
                    )
                    .shadow(color: Color.white.opacity(0.03), radius: 0, y: 1)

                BrandGlyph()
                    .frame(width: 18, height: 18)
            }
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 4) {
                Text("The Flutiano")
                    .font(FlutianoTypography.display(27, weight: .semibold))
                    .tracking(-1.1)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                FlutianoTheme.goldHighlight,
                                FlutianoTheme.gold,
                                FlutianoTheme.gold.opacity(0.72)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("CREATIVE SYSTEM")
                    .font(FlutianoTypography.body(9, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(FlutianoTheme.textMuted)
            }
        }
    }
}

private struct BrandGlyph: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: width * 0.17, y: height * 0.83))
                    path.addQuadCurve(
                        to: CGPoint(x: width * 0.45, y: height * 0.40),
                        control: CGPoint(x: width * 0.23, y: height * 0.50)
                    )
                    path.addQuadCurve(
                        to: CGPoint(x: width * 0.68, y: height * 0.44),
                        control: CGPoint(x: width * 0.55, y: height * 0.31)
                    )
                    path.addLine(to: CGPoint(x: width * 0.78, y: height * 0.22))
                    path.addQuadCurve(
                        to: CGPoint(x: width * 0.88, y: height * 0.28),
                        control: CGPoint(x: width * 0.84, y: height * 0.10)
                    )
                    path.addLine(to: CGPoint(x: width * 0.73, y: height * 0.42))
                    path.addQuadCurve(
                        to: CGPoint(x: width * 0.70, y: height * 0.62),
                        control: CGPoint(x: width * 0.78, y: height * 0.52)
                    )
                    path.addQuadCurve(
                        to: CGPoint(x: width * 0.52, y: height * 0.80),
                        control: CGPoint(x: width * 0.66, y: height * 0.76)
                    )
                    path.addQuadCurve(
                        to: CGPoint(x: width * 0.17, y: height * 0.83),
                        control: CGPoint(x: width * 0.35, y: height * 0.90)
                    )
                }
                .stroke(
                    FlutianoTheme.gold,
                    style: StrokeStyle(lineWidth: 1.3, lineCap: .round, lineJoin: .round)
                )

                Circle()
                    .fill(FlutianoTheme.gold.opacity(0.7))
                    .frame(width: width * 0.11, height: width * 0.11)
                    .position(x: width * 0.58, y: height * 0.53)

                Circle()
                    .fill(FlutianoTheme.gold.opacity(0.5))
                    .frame(width: width * 0.08, height: width * 0.08)
                    .position(x: width * 0.47, y: height * 0.67)
            }
        }
    }
}
