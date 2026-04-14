import SwiftUI

struct SidebarView: View {
    let store: WorkspaceStore

    var body: some View {
        VStack(spacing: 0) {
            Button(action: { store.navigate(to: .dashboard) }) {
                BrandMarkView()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 34)
            }
            .buttonStyle(.plain)
            .background(alignment: .bottom) {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    SidebarSectionLabel("Main")

                    SidebarItemButton(
                        title: "Dashboard",
                        symbol: "square.grid.2x2.fill",
                        isActive: store.selectedScreen == .dashboard
                    ) {
                        store.navigate(to: .dashboard)
                    }

                    SidebarItemButton(
                        title: "Projects",
                        symbol: "text.justify.left",
                        isActive: store.selectedScreen == .projects || store.selectedScreen == .newProject,
                        badge: "\(store.totalProjects)"
                    ) {
                        store.navigate(to: .projects)
                    }

                    SidebarItemButton(
                        title: "Workflow",
                        symbol: "point.3.connected.trianglepath.dotted",
                        isActive: false
                    ) {
                        store.navigate(to: .workflow)
                    }

                    SidebarSectionLabel("Create", topPadding: 10)

                    SidebarItemButton(
                        title: "Practice",
                        symbol: "music.note",
                        isActive: false
                    ) {
                        store.navigate(to: .practice)
                    }

                    SidebarItemButton(
                        title: "Shoots",
                        symbol: "camera",
                        isActive: false
                    ) {
                        store.navigate(to: .shoots)
                    }

                    SidebarItemButton(
                        title: "Releases",
                        symbol: "sparkles.tv",
                        isActive: false,
                        badge: "\(store.releasedProjects)"
                    ) {
                        store.navigate(to: .releases)
                    }

                    SidebarSectionLabel("Manage", topPadding: 10)

                    SidebarItemButton(
                        title: "Library",
                        symbol: "books.vertical",
                        isActive: false
                    ) {
                        store.navigate(to: .library)
                    }

                    SidebarItemButton(
                        title: "Archive",
                        symbol: "archivebox",
                        isActive: false
                    ) {
                        store.navigate(to: .archive)
                    }
                }
                .padding(.vertical, 14)
            }

            Button(action: {
                store.showToast(
                    symbol: "ellipsis",
                    title: "Flutiano",
                    subtitle: "Artist and Producer profile options are ready for the next pass.",
                    accent: .gold
                )
            }) {
                HStack(spacing: 10) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [FlutianoTheme.gold, Color(hex: 0x7A5820)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 38, height: 38)
                        .overlay {
                            Text("F")
                                .font(FlutianoTypography.body(13, weight: .extraBold))
                                .foregroundStyle(Color(hex: 0x0E0E1A))
                        }

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Flutiano")
                            .font(FlutianoTypography.body(13, weight: .bold))
                            .foregroundStyle(FlutianoTheme.textPrimary)

                        Text("Artist & Producer")
                            .font(FlutianoTypography.body(10.5, weight: .medium))
                            .foregroundStyle(FlutianoTheme.textMuted)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "ellipsis")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(FlutianoTheme.textMuted)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 18)
            }
            .buttonStyle(.plain)
            .background(alignment: .top) {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
            }
        }
        .frame(width: FlutianoTheme.sidebarWidth)
        .background {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: 0x0A0D12, opacity: 0.74),
                            Color(hex: 0x080B10, opacity: 0.64)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .background(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.24), radius: 28, x: 18)
                .overlay(alignment: .trailing) {
                    Rectangle()
                        .fill(Color.white.opacity(0.13))
                        .frame(width: 1)
                }
        }
    }
}

struct WorkspaceTopBar<Trailing: View>: View {
    var title: String
    var subtitle: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(spacing: 14) {
            Text(title)
                .font(FlutianoTypography.display(18, weight: .semibold))
                .foregroundStyle(FlutianoTheme.textPrimary)

            Text("— \(subtitle)")
                .font(FlutianoTypography.body(12.5, weight: .semibold))
                .foregroundStyle(FlutianoTheme.textMuted)

            Spacer(minLength: 0)
            trailing
        }
        .padding(.horizontal, 36)
        .frame(height: FlutianoTheme.topbarHeight)
        .background {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: 0x0A0E14, opacity: 0.62),
                            Color(hex: 0x0A0E14, opacity: 0.48)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .background(.ultraThinMaterial)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 1)
                }
        }
    }
}

struct DatePillView: View {
    var title: String

    var body: some View {
        Text(title)
            .font(FlutianoTypography.body(11, weight: .bold))
            .foregroundStyle(FlutianoTheme.textMuted)
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background {
                Capsule()
                    .fill(Color.white.opacity(0.05))
                    .overlay(Capsule().stroke(Color.white.opacity(0.10), lineWidth: 1))
            }
    }
}

struct AccentButton: View {
    var title: String
    var symbol: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.system(size: 11.5, weight: .semibold))

                Text(title)
                    .font(FlutianoTypography.body(12.5, weight: .extraBold))
            }
            .foregroundStyle(FlutianoTheme.goldHighlight)
            .padding(.vertical, 10)
            .padding(.horizontal, 18)
            .background {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                FlutianoTheme.gold.opacity(0.22),
                                FlutianoTheme.gold.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Capsule()
                            .stroke(FlutianoTheme.gold.opacity(0.30), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.20), radius: 12, y: 8)
            }
        }
        .buttonStyle(.plain)
    }
}

struct SectionHeaderView<Trailing: View>: View {
    var title: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(alignment: .center) {
            Text(title.uppercased())
                .font(FlutianoTypography.body(10, weight: .extraBold))
                .tracking(1.8)
                .foregroundStyle(Color.white.opacity(0.62))

            Spacer(minLength: 12)
            trailing
        }
    }
}

struct SectionLinkView: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(FlutianoTypography.body(11, weight: .bold))
                .foregroundStyle(FlutianoTheme.goldHighlight)
                .opacity(0.9)
        }
        .buttonStyle(.plain)
    }
}

struct GlassPanel<Content: View>: View {
    var padding: CGFloat = 20
    var cornerRadius: CGFloat = FlutianoTheme.radius
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
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
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(FlutianoTheme.border, lineWidth: 1)
                    )
                    .shadow(color: Color(hex: 0x04070C, opacity: 0.22), radius: 24, y: 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                            .blur(radius: 0.2)
                    )
            }
    }
}

struct FilterChip: View {
    var title: String
    var isActive: Bool
    var accent: AccentTone = .gold
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(FlutianoTypography.body(12, weight: isActive ? .bold : .medium))
                .foregroundStyle(isActive ? accent.highlight : FlutianoTheme.textTertiary)
                .padding(.vertical, 6)
                .padding(.horizontal, 14)
                .background {
                    Capsule()
                        .fill(isActive ? accent.tint : Color.white.opacity(0.04))
                        .overlay(
                            Capsule()
                                .stroke(
                                    isActive ? accent.color.opacity(0.35) : FlutianoTheme.borderSoft,
                                    lineWidth: 1
                                )
                        )
                }
        }
        .buttonStyle(.plain)
    }
}

private struct SidebarItemButton: View {
    var title: String
    var symbol: String
    var isActive: Bool
    var badge: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.system(size: 15, weight: .medium))
                    .opacity(isActive ? 1 : 0.72)
                    .frame(width: 18)

                Text(title)
                    .font(FlutianoTypography.body(16, weight: .bold))

                Spacer(minLength: 0)

                if let badge {
                    Text(badge)
                        .font(FlutianoTypography.body(10, weight: .bold))
                        .foregroundStyle(isActive ? FlutianoTheme.textPrimary.opacity(0.75) : FlutianoTheme.textTertiary.opacity(0.9))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.08))
                        )
                }
            }
            .foregroundStyle(isActive ? FlutianoTheme.goldHighlight : FlutianoTheme.textTertiary.opacity(1))
            .padding(.horizontal, 18)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        isActive
                            ? LinearGradient(
                                colors: [
                                    FlutianoTheme.gold.opacity(0.20),
                                    FlutianoTheme.gold.opacity(0.10)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            : LinearGradient(colors: [.clear, .clear], startPoint: .leading, endPoint: .trailing)
                    )
                    .overlay {
                        if isActive {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.04), lineWidth: 1)
                        }
                    }
            }
            .padding(.horizontal, 10)
        }
        .buttonStyle(.plain)
    }
}

private struct SidebarSectionLabel: View {
    var title: String
    var topPadding: CGFloat = 0

    init(_ title: String, topPadding: CGFloat = 0) {
        self.title = title
        self.topPadding = topPadding
    }

    var body: some View {
        Text(title.uppercased())
            .font(FlutianoTypography.body(8, weight: .bold))
            .tracking(2.2)
            .foregroundStyle(FlutianoTheme.textMuted)
            .padding(.top, topPadding)
            .padding(.bottom, 4)
            .padding(.horizontal, 28)
    }
}
