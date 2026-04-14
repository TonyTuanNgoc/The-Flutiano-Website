import Foundation
import Observation

@MainActor
@Observable
final class WorkspaceStore {
    var selectedScreen: WorkspaceScreen = .dashboard
    var projectFilter: ProjectFilter = .all
    var projects: [Project]
    var weeklyTasks: [WeeklyTask]
    var missingAssets: [MissingAsset]
    var toast: ToastMessage?

    let quickActions: [QuickAction]
    let libraryCollections: [LibraryCollection]

    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        self.quickActions = Seed.quickActions
        self.libraryCollections = Seed.libraryCollections

        if let snapshot = Self.loadSnapshot() {
            self.projects = snapshot.projects
            self.weeklyTasks = snapshot.weeklyTasks
            self.missingAssets = snapshot.missingAssets
        } else {
            self.projects = Seed.projects
            self.weeklyTasks = Seed.weeklyTasks
            self.missingAssets = Seed.missingAssets
            persist()
        }
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good morning"
        case 12..<18:
            return "Good afternoon"
        default:
            return "Good evening"
        }
    }

    var todayLabel: String {
        Date.now.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day().year())
    }

    var totalProjects: Int { projects.count }
    var activeProjects: Int { projects.filter { $0.status == .active || $0.status == .inProgress }.count }
    var releasedProjects: Int { projects.filter { $0.status == .released }.count }
    var draftProjects: Int { projects.filter { $0.status == .draft }.count }

    var statCards: [StatCardData] {
        [
            StatCardData(value: totalProjects, title: "Total Projects"),
            StatCardData(value: activeProjects, title: "Active", accent: .gold),
            StatCardData(value: releasedProjects, title: "Released", accent: .violet),
            StatCardData(value: draftProjects, title: "Drafts", accent: .sky)
        ]
    }

    var recentProjects: [Project] {
        projects
            .filter { $0.dashboardRank != nil }
            .sorted { ($0.dashboardRank ?? .max) < ($1.dashboardRank ?? .max) }
    }

    var continueProjects: [Project] {
        projects
            .filter { $0.continueRank != nil }
            .sorted { ($0.continueRank ?? .max) < ($1.continueRank ?? .max) }
    }

    var focusProject: Project? {
        projects.first(where: \.isFocus)
    }

    var filteredProjects: [Project] {
        projects.filter(projectFilter.matches)
    }

    func navigate(to screen: WorkspaceScreen) {
        switch screen {
        case .dashboard, .projects, .newProject:
            selectedScreen = screen
        case .workflow:
            showToast(
                symbol: "point.3.connected.trianglepath.dotted",
                title: "Workflow",
                subtitle: "Building the stage pipeline…",
                accent: .gold
            )
        case .practice:
            showToast(
                symbol: "music.note",
                title: "Practice",
                subtitle: "Your scales and exercises await.",
                accent: .gold
            )
        case .shoots:
            showToast(
                symbol: "camera",
                title: "Shoots",
                subtitle: "Your photography sessions will live here.",
                accent: .sky
            )
        case .releases:
            showToast(
                symbol: "sparkles.tv",
                title: "Releases",
                subtitle: "Track your published work in one place.",
                accent: .violet
            )
        case .library:
            showToast(
                symbol: "books.vertical",
                title: "Library",
                subtitle: "All your references and samples stay organized here.",
                accent: .jade
            )
        case .archive:
            showToast(
                symbol: "archivebox",
                title: "Archive",
                subtitle: "Completed work will be grouped here.",
                accent: .sky
            )
        }
    }

    func openProject(_ project: Project) {
        showToast(
            symbol: "play.fill",
            title: project.title,
            subtitle: "Project details can be expanded next from this app shell.",
            accent: project.accent
        )
    }

    func select(filter: ProjectFilter) {
        projectFilter = filter
    }

    func performQuickAction(_ action: QuickAction) {
        if let destination = action.destination {
            selectedScreen = destination
        } else {
            showToast(
                symbol: action.symbol,
                title: action.toastTitle,
                subtitle: action.toastSubtitle,
                accent: action.accent
            )
        }
    }

    func toggleTask(_ task: WeeklyTask) {
        guard let index = weeklyTasks.firstIndex(where: { $0.id == task.id }) else { return }
        weeklyTasks[index].isDone.toggle()
        persist()
    }

    func showToast(symbol: String, title: String, subtitle: String, accent: AccentTone) {
        toast = ToastMessage(
            symbol: symbol,
            title: title,
            subtitle: subtitle,
            accent: accent
        )
    }

    func dismissToast() {
        toast = nil
    }

    @discardableResult
    func addProject(from draft: NewProjectDraft) -> Project {
        let stage = draft.stage
        let accent = stage.defaultAccent
        let status = status(for: stage)
        let progress = stage.defaultProgress
        let deadlineLabel = draft.deadline.formatted(.dateTime.month(.abbreviated).day())
        let cleanedReferences = draft.referenceTracks
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let subtitle = draft.subtitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let nextAction = nextAction(for: stage)
        let notes = draft.notes.trimmingCharacters(in: .whitespacesAndNewlines)

        projects.indices.forEach { index in
            projects[index].dashboardRank = nil
            projects[index].continueRank = nil
            projects[index].isFocus = false
            projects[index].lastEditedRank += 1
        }

        let project = Project(
            title: draft.title.trimmingCharacters(in: .whitespacesAndNewlines),
            subtitle: subtitle.isEmpty ? nextAction : subtitle,
            stage: stage,
            status: status,
            accent: accent,
            progress: progress,
            nextAction: nextAction,
            keySignature: draft.keySignature,
            deadlineLabel: deadlineLabel,
            lastEditedLabel: "just now",
            workflowFilledSteps: stage.workflowFillCount,
            dashboardRank: 1,
            continueRank: 1,
            lastEditedRank: 0,
            isFocus: stage == .production,
            genres: Array(draft.genres).sorted(),
            moods: Array(draft.moods).sorted(),
            platforms: Array(draft.platforms).sorted(),
            bpm: Int(draft.bpm),
            timeSignature: draft.timeSignature.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes,
            referenceTracks: cleanedReferences,
            collaborators: [
                Collaborator(
                    initials: "F",
                    name: "Flutiano",
                    role: "Lead artist",
                    accent: .gold
                )
            ],
            workflowSteps: workflowSteps(for: stage, accent: accent)
        )

        projects.insert(project, at: 0)

        missingAssets.insert(
            MissingAsset(
                title: "Cover artwork",
                projectTitle: project.title,
                accent: .rose
            ),
            at: 0
        )

        if cleanedReferences.isEmpty {
            missingAssets.insert(
                MissingAsset(
                    title: "Reference tracks",
                    projectTitle: project.title,
                    accent: .sky
                ),
                at: min(1, missingAssets.count)
            )
        }

        persist()
        return project
    }

    private func status(for stage: ProjectStage) -> ProjectStatus {
        switch stage {
        case .concept, .moodboard:
            .draft
        case .released, .archive:
            .released
        case .production, .release:
            .active
        default:
            .inProgress
        }
    }

    private func nextAction(for stage: ProjectStage) -> String {
        switch stage {
        case .concept:
            "Build initial moodboard and gather references"
        case .moodboard:
            "Refine the visual direction and lock references"
        case .composition:
            "Develop the harmonic motif and melody"
        case .arrangement:
            "Shape the arrangement and add supporting layers"
        case .shotlist:
            "Plan the visual sequence and production notes"
        case .recording:
            "Capture the hero performance and review takes"
        case .production:
            "Refine the production balance and export passes"
        case .edit:
            "Tighten the edit and finalize transitions"
        case .mixing:
            "Balance the mix and prepare the final master"
        case .mastering:
            "Finalize loudness and delivery formats"
        case .release:
            "Prepare the launch assets and release schedule"
        case .released:
            "Monitor distribution and audience response"
        case .archive:
            "Store the project assets and notes cleanly"
        }
    }

    private func workflowSteps(for stage: ProjectStage, accent: AccentTone) -> [WorkflowStep] {
        let canonicalSteps = [
            "Concept", "Composition", "Arrangement",
            "Recording", "Production", "Mixing", "Mastering"
        ]

        let completedCount = stage.workflowFillCount

        return canonicalSteps.enumerated().map { index, title in
            if index < completedCount - 1 {
                return WorkflowStep(title: title, progress: 100, accent: .jade)
            } else if index == completedCount - 1 {
                return WorkflowStep(title: title, progress: min(stage.defaultProgress, 95), accent: accent)
            } else {
                return WorkflowStep(title: title, progress: 0, accent: .sky)
            }
        }
    }

    private func persist() {
        let snapshot = WorkspaceSnapshot(
            projects: projects,
            weeklyTasks: weeklyTasks,
            missingAssets: missingAssets
        )

        do {
            let directory = Self.snapshotDirectory()
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            let data = try encoder.encode(snapshot)
            try data.write(to: directory.appendingPathComponent("workspace.json"), options: .atomic)
        } catch {
            print("Failed to persist workspace snapshot: \(error.localizedDescription)")
        }
    }

    private static func loadSnapshot() -> WorkspaceSnapshot? {
        let fileURL = snapshotDirectory().appendingPathComponent("workspace.json")
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(WorkspaceSnapshot.self, from: data)
    }

    private static func snapshotDirectory() -> URL {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        return root.appendingPathComponent("TheFlutianoApp", isDirectory: true)
    }
}

private enum Seed {
    static let leadCollaborators = [
        Collaborator(initials: "F", name: "Flutiano", role: "Lead artist", accent: .gold)
    ]

    static let projects: [Project] = [
        Project(
            title: "Can't Help Falling in Love",
            subtitle: "Mix the string arrangement and export stems for mastering",
            stage: .production,
            status: .active,
            accent: .gold,
            progress: 60,
            nextAction: "Mix the string arrangement and export stems for mastering",
            keySignature: "D major",
            deadlineLabel: "Apr 20",
            lastEditedLabel: "1h ago",
            workflowFilledSteps: 5,
            dashboardRank: 1,
            continueRank: 1,
            lastEditedRank: 1,
            isFocus: true,
            genres: ["Cover", "Cinematic"],
            moods: ["Romantic", "Intimate"],
            platforms: ["Apple Music", "Spotify", "YouTube"],
            bpm: 72,
            timeSignature: "4/4",
            notes: "String arrangement is close. Final export stems are next for mastering prep.",
            referenceTracks: [
                "Elvis Presley — Can't Help Falling in Love",
                "Andrea Bocelli — Con Te Partiro"
            ],
            collaborators: leadCollaborators,
            workflowSteps: [
                WorkflowStep(title: "Concept", progress: 100, accent: .jade),
                WorkflowStep(title: "Composition", progress: 100, accent: .jade),
                WorkflowStep(title: "Arrangement", progress: 100, accent: .jade),
                WorkflowStep(title: "Recording", progress: 100, accent: .jade),
                WorkflowStep(title: "Production", progress: 70, accent: .gold),
                WorkflowStep(title: "Mixing", progress: 0, accent: .sky),
                WorkflowStep(title: "Mastering", progress: 0, accent: .sky)
            ]
        ),
        Project(
            title: "Time to Say Goodbye",
            subtitle: "Orchestrate the bridge section and balance soprano line",
            stage: .arrangement,
            status: .inProgress,
            accent: .jade,
            progress: 45,
            nextAction: "Orchestrate the bridge section and balance soprano line",
            keySignature: "E minor",
            deadlineLabel: "May 10",
            lastEditedLabel: "3d ago",
            workflowFilledSteps: 4,
            lastEditedRank: 4,
            genres: ["Classical", "Cover"],
            moods: ["Dramatic", "Triumphant"],
            platforms: ["Apple Music", "Spotify", "YouTube"],
            bpm: 68,
            timeSignature: "4/4",
            notes: "Bridge needs orchestration depth before moving into production.",
            referenceTracks: [
                "Andrea Bocelli — Time to Say Goodbye"
            ],
            collaborators: leadCollaborators
        ),
        Project(
            title: "Hello Việt Nam",
            subtitle: "Build initial moodboard and gather reference tracks",
            stage: .concept,
            status: .draft,
            accent: .sky,
            progress: 15,
            nextAction: "Build initial moodboard and gather reference tracks",
            keySignature: "G major",
            deadlineLabel: "Jun 15",
            lastEditedLabel: "just now",
            workflowFilledSteps: 1,
            dashboardRank: 2,
            continueRank: 3,
            lastEditedRank: 0,
            genres: ["Cinematic", "Original"],
            moods: ["Romantic", "Nostalgic"],
            platforms: ["YouTube"],
            notes: "Moodboard-led project inspired by the homeland theme and cinematic flute textures.",
            collaborators: leadCollaborators
        ),
        Project(
            title: "La La Land Theme",
            subtitle: "Finish chord voicings and add the counter-melody line",
            stage: .arrangement,
            status: .inProgress,
            accent: .jade,
            progress: 30,
            nextAction: "Finish chord voicings and add the counter-melody line",
            keySignature: "Eb major",
            deadlineLabel: "May 5",
            lastEditedLabel: "2d ago",
            workflowFilledSteps: 3,
            dashboardRank: 3,
            continueRank: 2,
            lastEditedRank: 3,
            genres: ["Film Score", "Cover"],
            moods: ["Romantic", "Ethereal"],
            platforms: ["Spotify", "YouTube"],
            bpm: 62,
            timeSignature: "3/4",
            notes: "Counter-melody and voicing polish are the two active tasks.",
            referenceTracks: [
                "Justin Hurwitz — Mia & Sebastian's Theme"
            ],
            collaborators: leadCollaborators
        ),
        Project(
            title: "My Heart Will Go On",
            subtitle: "Published and distributed across all major platforms",
            stage: .released,
            status: .released,
            accent: .violet,
            progress: 100,
            nextAction: "Published and distributed across all major platforms",
            keySignature: "E major",
            deadlineLabel: "Released",
            lastEditedLabel: "Jan 2026",
            workflowFilledSteps: 7,
            lastEditedRank: 5,
            genres: ["Cover", "Cinematic"],
            moods: ["Dramatic", "Triumphant"],
            platforms: ["Apple Music", "Spotify", "YouTube"],
            bpm: 70,
            timeSignature: "4/4",
            notes: "Completed release with distribution already done.",
            collaborators: leadCollaborators
        )
    ]

    static let weeklyTasks: [WeeklyTask] = [
        WeeklyTask(
            title: "Mix string arrangement for Can't Help",
            subtitle: "Production · High priority",
            isDone: false
        ),
        WeeklyTask(
            title: "Record flute melody — take 3",
            subtitle: "Recording · Done",
            isDone: true
        ),
        WeeklyTask(
            title: "Gather reference tracks for Hello Việt Nam",
            subtitle: "Concept · Medium priority",
            isDone: false
        ),
        WeeklyTask(
            title: "Finish La La Land counter-melody",
            subtitle: "Arrangement · Medium priority",
            isDone: false
        )
    ]

    static let missingAssets: [MissingAsset] = [
        MissingAsset(
            title: "Cover artwork",
            projectTitle: "Can't Help Falling in Love",
            accent: .rose
        ),
        MissingAsset(
            title: "Lyric sheet",
            projectTitle: "La La Land Theme",
            accent: .gold
        ),
        MissingAsset(
            title: "Reference tracks",
            projectTitle: "Hello Việt Nam",
            accent: .sky
        )
    ]

    static let quickActions: [QuickAction] = [
        QuickAction(
            title: "New Project",
            symbol: "plus",
            accent: .gold,
            destination: .newProject,
            toastTitle: "New Project",
            toastSubtitle: "Open the project creation workspace."
        ),
        QuickAction(
            title: "Quick Note",
            symbol: "note.text",
            accent: .sky,
            toastTitle: "Quick Note",
            toastSubtitle: "Idea captured to your notes."
        ),
        QuickAction(
            title: "Record",
            symbol: "mic",
            accent: .jade,
            toastTitle: "Record",
            toastSubtitle: "Opening the audio workspace."
        ),
        QuickAction(
            title: "Schedule",
            symbol: "calendar",
            accent: .rose,
            toastTitle: "Schedule",
            toastSubtitle: "Practice session blocked."
        ),
        QuickAction(
            title: "Upload",
            symbol: "arrow.up.doc",
            accent: .violet,
            toastTitle: "Upload",
            toastSubtitle: "Drag your files here."
        ),
        QuickAction(
            title: "Share",
            symbol: "point.3.connected.trianglepath.dotted",
            accent: .gold,
            toastTitle: "Share",
            toastSubtitle: "Share links are ready to copy."
        )
    ]

    static let libraryCollections: [LibraryCollection] = [
        LibraryCollection(
            title: "Sheet Music",
            count: 12,
            symbol: "music.quarternote.3",
            toastTitle: "Sheet Music",
            toastSubtitle: "Loading your scores."
        ),
        LibraryCollection(
            title: "Samples & Loops",
            count: 48,
            symbol: "headphones",
            toastTitle: "Samples",
            toastSubtitle: "Loading your sample library."
        ),
        LibraryCollection(
            title: "Visual References",
            count: 24,
            symbol: "camera",
            toastTitle: "References",
            toastSubtitle: "Loading your visual references."
        ),
        LibraryCollection(
            title: "Notes & Ideas",
            count: 7,
            symbol: "note.text",
            toastTitle: "Notes",
            toastSubtitle: "Loading your creative notes."
        )
    ]
}
