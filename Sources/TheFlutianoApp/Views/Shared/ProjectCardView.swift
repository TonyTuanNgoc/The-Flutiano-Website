import SwiftUI

enum ProjectCardStyle {
    case compact
    case expanded
}

struct ProjectCardView: View {
    let project: Project
    let style: ProjectCardStyle
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                project.accent.color,
                                project.accent.color.opacity(0.35)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: project.status == .draft ? 3 : 4)

                VStack(alignment: .leading, spacing: 11) {
                    HStack(alignment: .top, spacing: 8) {
                        StageBadgeView(project: project)
                        Spacer(minLength: 0)

                        if style == .expanded {
                            StatusChipView(project: project)
                        }
                    }

                    Text(project.title)
                        .font(FlutianoTypography.display(16, weight: .semibold))
                        .tracking(-0.45)
                        .foregroundStyle(FlutianoTheme.textPrimary)
                        .multilineTextAlignment(.leading)

                    Text(project.nextAction)
                        .font(FlutianoTypography.body(12, weight: .medium))
                        .foregroundStyle(FlutianoTheme.textSecondary)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(3)

                    WorkflowMiniBar(project: project)

                    VStack(alignment: .leading, spacing: 5) {
                        HStack(alignment: .lastTextBaseline) {
                            (
                                Text("\(project.progress)")
                                    .font(FlutianoTypography.body(style == .expanded ? 26 : 30, weight: .extraBold))
                                +
                                Text("%")
                                    .font(FlutianoTypography.body(style == .expanded ? 11 : 12, weight: .medium))
                            )
                            .foregroundStyle(project.accent.color)

                            Spacer(minLength: 0)

                            Text(project.stage.displayName)
                                .font(FlutianoTypography.body(10, weight: .bold))
                                .tracking(0.7)
                                .foregroundStyle(Color.white.opacity(0.45))
                        }

                        GeometryReader { proxy in
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(Color.white.opacity(0.08))
                                .overlay(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [project.accent.color, project.accent.highlight],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: proxy.size.width * CGFloat(project.progress) / 100)
                                }
                        }
                        .frame(height: 4)
                    }
                    .padding(.top, 2)
                }
                .padding(.top, 18)
                .padding(.horizontal, 20)
                .padding(.bottom, style == .expanded ? 14 : 20)

                if style == .expanded {
                    ProjectMetaRow(project: project)

                    HStack(spacing: 6) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11, weight: .semibold))

                        Text("Open project →")
                            .font(FlutianoTypography.body(11.5, weight: .bold))
                    }
                    .foregroundStyle(isHovered ? project.accent.highlight : FlutianoTheme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(alignment: .top) {
                        Rectangle()
                            .fill(Color.white.opacity(0.07))
                            .frame(height: 1)
                    }
                }
            }
            .background {
                RoundedRectangle(cornerRadius: FlutianoTheme.radius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: 0x11161D, opacity: 0.48),
                                Color(hex: 0x0B0F15, opacity: 0.32)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: FlutianoTheme.radius, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: FlutianoTheme.radius, style: .continuous)
                            .stroke(FlutianoTheme.border, lineWidth: 1)
                    )
                    .shadow(
                        color: Color.black.opacity(isHovered ? 0.34 : 0.18),
                        radius: isHovered ? 24 : 8,
                        y: isHovered ? 14 : 4
                    )
            }
            .scaleEffect(isHovered ? 1.01 : 1)
            .offset(y: isHovered ? -2 : 0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.18)) {
                isHovered = hovering
            }
        }
    }
}

struct NewProjectTileView: View {
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(FlutianoTheme.goldTint)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(FlutianoTheme.gold.opacity(0.2), lineWidth: 1)
                        )

                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(FlutianoTheme.gold)
                }
                .frame(width: 40, height: 40)

                Text("Start a new project")
                    .font(FlutianoTypography.body(13, weight: .semibold))
                    .foregroundStyle(FlutianoTheme.textSecondary)

                Text("Bring your next idea to life")
                    .font(FlutianoTypography.body(11, weight: .medium))
                    .foregroundStyle(FlutianoTheme.textMuted)
            }
            .frame(maxWidth: .infinity, minHeight: 220)
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: FlutianoTheme.radius, style: .continuous)
                    .fill(Color.white.opacity(0.02))
                    .overlay(
                        RoundedRectangle(cornerRadius: FlutianoTheme.radius, style: .continuous)
                            .stroke(Color.white.opacity(isHovered ? 0.22 : 0.12), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                    )
            }
            .offset(y: isHovered ? -2 : 0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.14)) {
                isHovered = hovering
            }
        }
    }
}

private struct StageBadgeView: View {
    let project: Project

    var body: some View {
        HStack(spacing: 5) {
            PulseDotView(color: project.accent.color, isAnimated: project.status == .active)

            Text(project.stage.displayName)
                .font(FlutianoTypography.body(10, weight: .bold))
        }
        .foregroundStyle(project.accent.highlight)
        .padding(.vertical, 4)
        .padding(.leading, 8)
        .padding(.trailing, 10)
        .background {
            Capsule()
                .fill(project.accent.tint)
                .overlay(
                    Capsule()
                        .stroke(project.accent.color.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

private struct StatusChipView: View {
    let project: Project

    var body: some View {
        Text(project.status.label)
            .font(FlutianoTypography.body(9.5, weight: .bold))
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .background {
                Capsule()
                    .fill(project.statusAccent.tint.opacity(0.8))
                    .overlay(
                        Capsule()
                            .stroke(project.statusAccent.color.opacity(0.2), lineWidth: 1)
                    )
            }
            .foregroundStyle(project.statusAccent.highlight)
    }
}

private struct WorkflowMiniBar: View {
    let project: Project

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<project.workflowTotalSteps, id: \.self) { index in
                Capsule()
                    .fill(index < project.workflowFilledSteps ? project.accent.color : Color.white.opacity(0.10))
                    .frame(maxWidth: .infinity)
                    .frame(height: 3)
            }
        }
    }
}

private struct ProjectMetaRow: View {
    let project: Project

    var body: some View {
        HStack(spacing: 0) {
            ProjectMetaCell(symbol: "music.note", title: "Key", value: project.keySignature)
            ProjectMetaCell(symbol: "calendar", title: "Deadline", value: project.deadlineLabel)
            ProjectMetaCell(symbol: "clock", title: "Edited", value: project.lastEditedLabel)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1)
        }
    }
}

private struct ProjectMetaCell: View {
    let symbol: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: symbol)
                .font(.system(size: 10))
                .foregroundStyle(FlutianoTheme.textMuted.opacity(0.8))
                .frame(width: 12)

            VStack(alignment: .leading, spacing: 1) {
                Text(title.uppercased())
                    .font(FlutianoTypography.body(9, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(FlutianoTheme.textMuted)

                Text(value)
                    .font(FlutianoTypography.body(11, weight: .semibold))
                    .foregroundStyle(FlutianoTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, symbol == "music.note" ? 0 : 12)
        .overlay(alignment: .leading) {
            if symbol != "music.note" {
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 1)
            }
        }
    }
}

private struct PulseDotView: View {
    let color: Color
    let isAnimated: Bool

    @State private var pulsing = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 6, height: 6)
            .scaleEffect(isAnimated && pulsing ? 0.7 : 1)
            .opacity(isAnimated && pulsing ? 0.45 : 1)
            .onAppear {
                pulsing = true
            }
            .animation(
                isAnimated ? .easeInOut(duration: 1.8).repeatForever(autoreverses: true) : .default,
                value: pulsing
            )
    }
}
