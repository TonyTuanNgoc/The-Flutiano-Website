import SwiftUI

struct DashboardView: View {
    let store: WorkspaceStore

    private let quickActionColumns = [
        GridItem(.adaptive(minimum: 124, maximum: 170), spacing: 12)
    ]

    private let projectColumns = [
        GridItem(.adaptive(minimum: 250, maximum: 330), spacing: 18)
    ]

    private let bottomColumns = [
        GridItem(.adaptive(minimum: 230, maximum: 320), spacing: 18)
    ]

    var body: some View {
        VStack(spacing: 0) {
            WorkspaceTopBar(title: "Dashboard", subtitle: store.greeting) {
                HStack(spacing: 12) {
                    DatePillView(title: store.todayLabel)
                    AccentButton(title: "New Project", symbol: "plus") {
                        store.navigate(to: .newProject)
                    }
                }
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    quickActionsSection
                    focusAndProjectsSection
                    bottomPanelsSection
                }
                .padding(.top, 34)
                .padding(.horizontal, 38)
                .padding(.bottom, 48)
            }
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Quick Actions") {
                EmptyView()
            }

            LazyVGrid(columns: quickActionColumns, spacing: 12) {
                ForEach(store.quickActions) { action in
                    QuickActionTileView(action: action) {
                        store.performQuickAction(action)
                    }
                }
            }
        }
    }

    private var focusAndProjectsSection: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 18) {
                recentProjectsSection
                    .frame(maxWidth: .infinity, alignment: .top)

                if let focusProject = store.focusProject {
                    ActiveFocusCard(project: focusProject)
                        .frame(width: 390)
                }
            }

            VStack(alignment: .leading, spacing: 16) {
                recentProjectsSection

                if let focusProject = store.focusProject {
                    ActiveFocusCard(project: focusProject)
                }
            }
        }
    }

    private var recentProjectsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Recent Projects") {
                SectionLinkView(title: "See all projects →") {
                    store.navigate(to: .projects)
                }
            }

            LazyVGrid(columns: projectColumns, spacing: 18) {
                ForEach(store.recentProjects) { project in
                    ProjectCardView(project: project, style: .compact) {
                        store.openProject(project)
                    }
                }
            }
        }
    }

    private var bottomPanelsSection: some View {
        LazyVGrid(columns: bottomColumns, alignment: .leading, spacing: 18) {
            ThisWeekPanel(tasks: store.weeklyTasks) { task in
                store.toggleTask(task)
            }

            MissingAssetsPanel(assets: store.missingAssets)

            ContinueWorkingPanel(projects: store.continueProjects) { project in
                store.openProject(project)
            }

            CreativeLibraryPanel(collections: store.libraryCollections) { collection in
                store.showToast(
                    symbol: collection.symbol,
                    title: collection.toastTitle,
                    subtitle: collection.toastSubtitle,
                    accent: .jade
                )
            }
        }
    }
}

private struct QuickActionTileView: View {
    let action: QuickAction
    let tapAction: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: tapAction) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(action.accent.tint)

                    Image(systemName: action.symbol)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(action.accent.color)
                }
                .frame(width: 42, height: 42)

                Text(action.title)
                    .font(FlutianoTypography.body(12, weight: .bold))
                    .foregroundStyle(FlutianoTheme.textSecondary)
            }
            .frame(maxWidth: .infinity, minHeight: 98)
            .padding(.horizontal, 12)
            .background {
                RoundedRectangle(cornerRadius: FlutianoTheme.radius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isHovered
                                ? [Color(hex: 0x141A22, opacity: 0.48), Color(hex: 0x0C1118, opacity: 0.32)]
                                : [Color(hex: 0x141A22, opacity: 0.34), Color(hex: 0x0C1118, opacity: 0.24)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: FlutianoTheme.radius, style: .continuous)
                            .stroke(isHovered ? FlutianoTheme.border : Color.white.opacity(0.09), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(isHovered ? 0.18 : 0), radius: 16, y: 10)
            }
            .offset(y: isHovered ? -2 : 0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.13)) {
                isHovered = hovering
            }
        }
    }
}

private struct ActiveFocusCard: View {
    let project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Active Focus") {
                EmptyView()
            }

            GlassPanel(padding: 22) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("NOW WORKING ON")
                        .font(FlutianoTypography.body(9, weight: .bold))
                        .tracking(1.8)
                        .foregroundStyle(Color.white.opacity(0.45))

                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(project.title)
                                .font(FlutianoTypography.display(24, weight: .semibold))
                                .tracking(-0.8)
                                .foregroundStyle(FlutianoTheme.textPrimary)

                            Text(project.stageSummary)
                                .font(FlutianoTypography.body(12.5, weight: .semibold))
                                .foregroundStyle(FlutianoTheme.textTertiary)
                        }

                        Spacer(minLength: 0)

                        VStack(alignment: .trailing, spacing: 1) {
                            Text("\(project.progress)")
                                .font(FlutianoTypography.body(42, weight: .extraBold))
                                .tracking(-2)
                                .foregroundStyle(FlutianoTheme.goldHighlight)

                            Text("% complete")
                                .font(FlutianoTypography.body(10, weight: .bold))
                                .tracking(1)
                                .foregroundStyle(Color.white.opacity(0.45))
                        }
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 16)

                    GeometryReader { proxy in
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.white.opacity(0.07))
                            .overlay(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                FlutianoTheme.gold.opacity(0.5),
                                                FlutianoTheme.gold,
                                                FlutianoTheme.goldHighlight
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: proxy.size.width * CGFloat(project.progress) / 100)
                                    .shadow(color: FlutianoTheme.gold.opacity(0.3), radius: 10)
                            }
                    }
                    .frame(height: 7)
                    .padding(.bottom, 18)

                    Text("WORKFLOW STAGES")
                        .font(FlutianoTypography.body(9, weight: .bold))
                        .tracking(1.8)
                        .foregroundStyle(Color.white.opacity(0.45))
                        .padding(.bottom, 10)

                    VStack(spacing: 10) {
                        ForEach(project.workflowSteps) { step in
                            HStack(spacing: 12) {
                                Text(step.title)
                                    .font(FlutianoTypography.body(11.5, weight: .semibold))
                                    .foregroundStyle(FlutianoTheme.textSecondary)
                                    .frame(width: 114, alignment: .leading)

                                GeometryReader { proxy in
                                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                                        .fill(Color.white.opacity(0.07))
                                        .overlay(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 999, style: .continuous)
                                                .fill(step.isComplete ? FlutianoTheme.jade : step.accent.color)
                                                .frame(width: proxy.size.width * CGFloat(step.progress) / 100)
                                        }
                                }
                                .frame(height: 5)

                                Text(stepLabel(for: step))
                                    .font(FlutianoTypography.body(10, weight: .bold))
                                    .foregroundStyle(stepLabelAccent(for: step))
                                    .frame(width: 30, alignment: .trailing)
                            }
                        }
                    }
                }
            }
        }
    }

    private func stepLabel(for step: WorkflowStep) -> String {
        if step.isComplete { return "✓" }
        if step.progress == 0 { return "—" }
        return "\(step.progress)%"
    }

    private func stepLabelAccent(for step: WorkflowStep) -> Color {
        if step.isComplete { return FlutianoTheme.jade }
        if step.progress == 0 { return FlutianoTheme.textMuted }
        return step.accent.color
    }
}

private struct ThisWeekPanel: View {
    let tasks: [WeeklyTask]
    let toggle: (WeeklyTask) -> Void

    var body: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("THIS WEEK")
                        .font(FlutianoTypography.body(10, weight: .extraBold))
                        .tracking(1.8)
                        .foregroundStyle(Color.white.opacity(0.62))

                    Spacer(minLength: 0)

                    Text("\(tasks.count) tasks")
                        .font(FlutianoTypography.body(11, weight: .medium))
                        .foregroundStyle(FlutianoTheme.textMuted)
                }

                ForEach(tasks) { task in
                    Button(action: { toggle(task) }) {
                        HStack(alignment: .top, spacing: 10) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .stroke(task.isDone ? FlutianoTheme.jade : Color.white.opacity(0.15), lineWidth: 1.5)
                                .background(
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(task.isDone ? FlutianoTheme.jade : .clear)
                                )
                                .overlay {
                                    if task.isDone {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(Color.black)
                                    }
                                }
                                .frame(width: 16, height: 16)
                                .padding(.top, 1)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(task.title)
                                    .font(FlutianoTypography.body(12.5, weight: .semibold))
                                    .foregroundStyle(task.isDone ? FlutianoTheme.textMuted : Color.white.opacity(0.90))
                                    .strikethrough(task.isDone)

                                Text(task.subtitle)
                                    .font(FlutianoTypography.body(9, weight: .bold))
                                    .tracking(1)
                                    .foregroundStyle(FlutianoTheme.textMuted)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .overlay(alignment: .bottom) {
                            if task.id != tasks.last?.id {
                                Rectangle()
                                    .fill(Color.white.opacity(0.05))
                                    .frame(height: 1)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct MissingAssetsPanel: View {
    let assets: [MissingAsset]

    var body: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("MISSING ASSETS")
                        .font(FlutianoTypography.body(10, weight: .extraBold))
                        .tracking(1.8)
                        .foregroundStyle(Color.white.opacity(0.62))

                    Spacer(minLength: 0)

                    Text("\(assets.count)")
                        .font(FlutianoTypography.body(11, weight: .semibold))
                        .foregroundStyle(FlutianoTheme.rose)
                }

                ForEach(assets) { asset in
                    HStack(alignment: .center, spacing: 10) {
                        Circle()
                            .fill(asset.accent.color)
                            .frame(width: 6, height: 6)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(asset.title)
                                .font(FlutianoTypography.body(12, weight: .bold))
                                .foregroundStyle(Color.white.opacity(0.90))

                            Text(asset.projectTitle)
                                .font(FlutianoTypography.body(10, weight: .semibold))
                                .foregroundStyle(FlutianoTheme.textMuted)
                        }
                    }
                    .padding(.vertical, 9)
                    .overlay(alignment: .bottom) {
                        if asset.id != assets.last?.id {
                            Rectangle()
                                .fill(Color.white.opacity(0.05))
                                .frame(height: 1)
                        }
                    }
                }
            }
        }
    }
}

private struct ContinueWorkingPanel: View {
    let projects: [Project]
    let open: (Project) -> Void

    var body: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 12) {
                Text("CONTINUE WORKING")
                    .font(FlutianoTypography.body(10, weight: .extraBold))
                    .tracking(1.8)
                    .foregroundStyle(Color.white.opacity(0.62))

                ForEach(projects) { project in
                    Button(action: { open(project) }) {
                        HStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .fill(project.accent.tint)
                                .frame(width: 28, height: 28)
                                .overlay {
                                    Image(systemName: project.continueIcon)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(project.accent.color)
                            }

                            VStack(alignment: .leading, spacing: 1) {
                                Text(project.title)
                                    .font(FlutianoTypography.body(12, weight: .bold))
                                    .foregroundStyle(Color.white.opacity(0.90))

                                Text("\(project.stage.displayName) · \(project.lastEditedLabel)")
                                    .font(FlutianoTypography.body(10, weight: .semibold))
                                    .foregroundStyle(FlutianoTheme.textMuted)
                            }

                            Spacer(minLength: 0)

                            Text("→")
                                .font(.system(size: 12))
                                .foregroundStyle(FlutianoTheme.textMuted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 9)
                        .padding(.horizontal, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color.white.opacity(0.03))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct CreativeLibraryPanel: View {
    let collections: [LibraryCollection]
    let open: (LibraryCollection) -> Void

    var body: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 12) {
                Text("CREATIVE LIBRARY")
                    .font(FlutianoTypography.body(10, weight: .extraBold))
                    .tracking(1.8)
                    .foregroundStyle(Color.white.opacity(0.62))

                ForEach(collections) { collection in
                    Button(action: { open(collection) }) {
                        HStack(spacing: 8) {
                            Image(systemName: collection.symbol)
                                .font(.system(size: 14))
                                .foregroundStyle(FlutianoTheme.textSecondary)
                                .frame(width: 16)

                            Text(collection.title)
                                .font(FlutianoTypography.body(12, weight: .bold))
                                .foregroundStyle(Color.white.opacity(0.90))

                            Spacer(minLength: 0)

                            Text("\(collection.count)")
                                .font(FlutianoTypography.body(10, weight: .bold))
                                .foregroundStyle(FlutianoTheme.textMuted)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 1)
                                .background(Capsule().fill(Color.white.opacity(0.06)))
                        }
                        .padding(.vertical, 9)
                        .overlay(alignment: .bottom) {
                            if collection.id != collections.last?.id {
                                Rectangle()
                                    .fill(Color.white.opacity(0.05))
                                    .frame(height: 1)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
