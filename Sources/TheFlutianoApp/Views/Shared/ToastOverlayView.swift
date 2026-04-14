import SwiftUI

struct ToastOverlayView: View {
    let toast: ToastMessage

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: toast.symbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(toast.accent.highlight)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(toast.title)
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundStyle(FlutianoTheme.textPrimary)

                Text(toast.subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.white.opacity(0.5))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 18)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(hex: 0x141223, opacity: 0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.45), radius: 14, y: 10)
        }
        .frame(minWidth: 220)
    }
}
