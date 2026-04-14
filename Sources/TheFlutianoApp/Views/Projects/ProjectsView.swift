import SwiftUI

struct ProjectsView: View {
    let store: WorkspaceStore

    private let statColumns = [
        GridItem(.adaptive(minimum: 170, maximum: 240), spacing: 12)
    ]

    private let projectColumns = [
        GridItem(.adaptive(minimum: 290, maximum: 360), spacing: 16)
    ]

    var body: some View {
        VStack(spacing: 0) {
            WorkspaceTopBar(title: "Projects", subtitle: "All your work in one place") {
                AccentButton(title: "New Project", symbol: "plus") {
                    store.navigate(to: .newProject)
                }
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    statsRow
                    filterRow
                    projectGrid
                }
                .padding(.top, 28)
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }

    private var statsRow: some View {
        LazyVGrid(columns: statColumns, spacing: 12) {
            ForEach(store.statCards) { stat in
                GlassPanel(padding: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(stat.value)")
                            .font(.system(size: 28, weight: .heavy))
                            .tracking(-0.9)
                            .foregroundStyle(stat.accent?.color ?? FlutianoTheme.textPrimary)

                        Text(stat.title.uppercased())
                            .font(.system(size: 10))
                            .tracking(1)
                            .foregroundStyle(FlutianoTheme.textMuted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ProjectFilter.allCases) { filter in
                    FilterChip(title: filter.title, isActive: store.projectFilter == filter) {
                        store.select(filter: filter)
                    }
                }
            }
        }
    }

    private var projectGrid: some View {
        LazyVGrid(columns: projectColumns, spacing: 16) {
            ForEach(store.filteredProjects) { project in
                ProjectCardView(project: project, style: .expanded) {
                    store.openProject(project)
                }
            }

            if store.projectFilter == .all {
                NewProjectTileView {
                    store.navigate(to: .newProject)
                }
            }
        }
    }
}
