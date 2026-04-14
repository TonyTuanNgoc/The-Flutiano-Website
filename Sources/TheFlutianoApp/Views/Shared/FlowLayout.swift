import SwiftUI

struct FlowLayout: Layout {
    var itemSpacing: CGFloat = 8
    var rowSpacing: CGFloat = 8

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? 0
        if maxWidth == 0 {
            let widths = subviews.map { $0.sizeThatFits(.unspecified).width }
            let heights = subviews.map { $0.sizeThatFits(.unspecified).height }
            return CGSize(width: widths.max() ?? 0, height: heights.reduce(0, +))
        }

        var cursorX: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if cursorX + size.width > maxWidth, cursorX > 0 {
                totalHeight += rowHeight + rowSpacing
                cursorX = 0
                rowHeight = 0
            }

            cursorX += size.width + itemSpacing
            rowHeight = max(rowHeight, size.height)
        }

        totalHeight += rowHeight

        return CGSize(width: maxWidth, height: totalHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var cursorX = bounds.minX
        var cursorY = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if cursorX + size.width > bounds.maxX, cursorX > bounds.minX {
                cursorX = bounds.minX
                cursorY += rowHeight + rowSpacing
                rowHeight = 0
            }

            subview.place(
                at: CGPoint(x: cursorX, y: cursorY),
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )

            cursorX += size.width + itemSpacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
