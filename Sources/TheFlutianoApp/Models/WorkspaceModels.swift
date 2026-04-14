import Foundation
import SwiftUI

enum WorkspaceScreen: String, Codable, CaseIterable, Identifiable {
    case dashboard
    case projects
    case workflow
    case practice
    case shoots
    case releases
    case library
    case archive
    case newProject

    var id: String { rawValue }
}

enum AccentTone: String, Codable, CaseIterable, Hashable {
    case gold
    case jade
    case rose
    case sky
    case violet

    var color: Color {
        switch self {
        case .gold: FlutianoTheme.gold
        case .jade: FlutianoTheme.jade
        case .rose: FlutianoTheme.rose
        case .sky: FlutianoTheme.sky
        case .violet: FlutianoTheme.violet
        }
    }

    var tint: Color {
        switch self {
        case .gold: FlutianoTheme.goldTint
        case .jade: FlutianoTheme.jadeTint
        case .rose: FlutianoTheme.roseTint
        case .sky: FlutianoTheme.skyTint
        case .violet: FlutianoTheme.violetTint
        }
    }

    var highlight: Color {
        switch self {
        case .gold: FlutianoTheme.goldHighlight
        case .jade: Color(hex: 0x7FE0B2)
        case .rose: Color(hex: 0xF6A0A0)
        case .sky: Color(hex: 0x9DD0F0)
        case .violet: Color(hex: 0xC4B0FF)
        }
    }
}

enum ProjectStage: String, Codable, CaseIterable, Identifiable {
    case concept
    case moodboard
    case composition
    case arrangement
    case shotlist
    case recording
    case production
    case edit
    case mixing
    case mastering
    case release
    case released
    case archive

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .concept: "Concept"
        case .moodboard: "Moodboard"
        case .composition: "Composition"
        case .arrangement: "Arrangement"
        case .shotlist: "Shotlist"
        case .recording: "Recording"
        case .production: "Production"
        case .edit: "Edit"
        case .mixing: "Mixing"
        case .mastering: "Mastering"
        case .release: "Release"
        case .released: "Released"
        case .archive: "Archive"
        }
    }

    var icon: String {
        switch self {
        case .concept: "lightbulb"
        case .moodboard: "swatchpalette"
        case .composition: "music.note"
        case .arrangement: "music.quarternote.3"
        case .shotlist: "list.bullet.clipboard"
        case .recording: "waveform"
        case .production: "film.stack"
        case .edit: "scissors"
        case .mixing: "slider.horizontal.3"
        case .mastering: "speaker.wave.3"
        case .release: "paperplane"
        case .released: "sparkles"
        case .archive: "archivebox"
        }
    }

    var defaultAccent: AccentTone {
        switch self {
        case .concept, .moodboard:
            .sky
        case .composition, .arrangement, .shotlist, .edit:
            .jade
        case .recording, .production, .mixing, .mastering, .release:
            .gold
        case .released, .archive:
            .violet
        }
    }

    var defaultProgress: Int {
        switch self {
        case .concept: 15
        case .moodboard: 22
        case .composition: 30
        case .arrangement: 45
        case .shotlist: 35
        case .recording: 55
        case .production: 60
        case .edit: 74
        case .mixing: 82
        case .mastering: 92
        case .release: 95
        case .released, .archive: 100
        }
    }

    var workflowFillCount: Int {
        switch self {
        case .concept: 1
        case .moodboard: 2
        case .composition: 2
        case .arrangement: 3
        case .shotlist: 4
        case .recording: 4
        case .production: 5
        case .edit: 5
        case .mixing: 6
        case .mastering: 6
        case .release: 7
        case .released, .archive: 7
        }
    }
}

enum ProjectStatus: String, Codable, Hashable {
    case active
    case inProgress
    case draft
    case released

    var label: String {
        switch self {
        case .active: "Active"
        case .inProgress: "In Progress"
        case .draft: "Draft"
        case .released: "Released"
        }
    }
}

enum ProjectFilter: String, CaseIterable, Identifiable {
    case all
    case production
    case arrangement
    case concept
    case released

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: "All"
        case .production: "Production"
        case .arrangement: "Arrangement"
        case .concept: "Concept"
        case .released: "Released"
        }
    }

    func matches(_ project: Project) -> Bool {
        switch self {
        case .all:
            true
        case .production:
            project.stage == .production
        case .arrangement:
            project.stage == .arrangement
        case .concept:
            project.stage == .concept
        case .released:
            project.status == .released || project.stage == .released
        }
    }
}

struct WorkflowStep: Codable, Hashable, Identifiable {
    let id: UUID
    var title: String
    var progress: Int
    var accent: AccentTone

    init(
        id: UUID = UUID(),
        title: String,
        progress: Int,
        accent: AccentTone
    ) {
        self.id = id
        self.title = title
        self.progress = progress
        self.accent = accent
    }

    var isComplete: Bool { progress >= 100 }
}

struct Collaborator: Codable, Hashable, Identifiable {
    let id: UUID
    var initials: String
    var name: String
    var role: String
    var accent: AccentTone

    init(
        id: UUID = UUID(),
        initials: String,
        name: String,
        role: String,
        accent: AccentTone
    ) {
        self.id = id
        self.initials = initials
        self.name = name
        self.role = role
        self.accent = accent
    }
}

struct Project: Codable, Hashable, Identifiable {
    let id: UUID
    var title: String
    var subtitle: String
    var stage: ProjectStage
    var status: ProjectStatus
    var accent: AccentTone
    var progress: Int
    var nextAction: String
    var keySignature: String
    var deadlineLabel: String
    var lastEditedLabel: String
    var workflowFilledSteps: Int
    var workflowTotalSteps: Int
    var dashboardRank: Int?
    var continueRank: Int?
    var lastEditedRank: Int
    var isFocus: Bool
    var genres: [String]
    var moods: [String]
    var platforms: [String]
    var bpm: Int?
    var timeSignature: String
    var notes: String
    var referenceTracks: [String]
    var collaborators: [Collaborator]
    var workflowSteps: [WorkflowStep]

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        stage: ProjectStage,
        status: ProjectStatus,
        accent: AccentTone,
        progress: Int,
        nextAction: String,
        keySignature: String,
        deadlineLabel: String,
        lastEditedLabel: String,
        workflowFilledSteps: Int,
        workflowTotalSteps: Int = 7,
        dashboardRank: Int? = nil,
        continueRank: Int? = nil,
        lastEditedRank: Int,
        isFocus: Bool = false,
        genres: [String],
        moods: [String],
        platforms: [String],
        bpm: Int? = nil,
        timeSignature: String = "",
        notes: String = "",
        referenceTracks: [String] = [],
        collaborators: [Collaborator] = [],
        workflowSteps: [WorkflowStep] = []
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.stage = stage
        self.status = status
        self.accent = accent
        self.progress = progress
        self.nextAction = nextAction
        self.keySignature = keySignature
        self.deadlineLabel = deadlineLabel
        self.lastEditedLabel = lastEditedLabel
        self.workflowFilledSteps = workflowFilledSteps
        self.workflowTotalSteps = workflowTotalSteps
        self.dashboardRank = dashboardRank
        self.continueRank = continueRank
        self.lastEditedRank = lastEditedRank
        self.isFocus = isFocus
        self.genres = genres
        self.moods = moods
        self.platforms = platforms
        self.bpm = bpm
        self.timeSignature = timeSignature
        self.notes = notes
        self.referenceTracks = referenceTracks
        self.collaborators = collaborators
        self.workflowSteps = workflowSteps
    }

    var statusAccent: AccentTone {
        switch status {
        case .active: .gold
        case .inProgress: .jade
        case .draft: .sky
        case .released: .violet
        }
    }

    var stageSummary: String {
        "\(keySignature) · \(stage.displayName) stage"
    }

    var continueIcon: String {
        switch accent {
        case .gold: "music.note"
        case .jade: "music.quarternote.3"
        case .rose: "exclamationmark.triangle"
        case .sky: "sparkles"
        case .violet: "star"
        }
    }
}

struct WeeklyTask: Codable, Hashable, Identifiable {
    let id: UUID
    var title: String
    var subtitle: String
    var isDone: Bool

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        isDone: Bool
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.isDone = isDone
    }
}

struct MissingAsset: Codable, Hashable, Identifiable {
    let id: UUID
    var title: String
    var projectTitle: String
    var accent: AccentTone

    init(
        id: UUID = UUID(),
        title: String,
        projectTitle: String,
        accent: AccentTone
    ) {
        self.id = id
        self.title = title
        self.projectTitle = projectTitle
        self.accent = accent
    }
}

struct LibraryCollection: Hashable, Identifiable {
    let id: UUID
    var title: String
    var count: Int
    var symbol: String
    var toastTitle: String
    var toastSubtitle: String

    init(
        id: UUID = UUID(),
        title: String,
        count: Int,
        symbol: String,
        toastTitle: String,
        toastSubtitle: String
    ) {
        self.id = id
        self.title = title
        self.count = count
        self.symbol = symbol
        self.toastTitle = toastTitle
        self.toastSubtitle = toastSubtitle
    }
}

struct QuickAction: Hashable, Identifiable {
    let id: UUID
    var title: String
    var symbol: String
    var accent: AccentTone
    var destination: WorkspaceScreen?
    var toastTitle: String
    var toastSubtitle: String

    init(
        id: UUID = UUID(),
        title: String,
        symbol: String,
        accent: AccentTone,
        destination: WorkspaceScreen? = nil,
        toastTitle: String,
        toastSubtitle: String
    ) {
        self.id = id
        self.title = title
        self.symbol = symbol
        self.accent = accent
        self.destination = destination
        self.toastTitle = toastTitle
        self.toastSubtitle = toastSubtitle
    }
}

struct StatCardData: Hashable, Identifiable {
    let id: UUID
    var value: Int
    var title: String
    var accent: AccentTone?

    init(
        id: UUID = UUID(),
        value: Int,
        title: String,
        accent: AccentTone? = nil
    ) {
        self.id = id
        self.value = value
        self.title = title
        self.accent = accent
    }
}

struct ToastMessage: Equatable, Identifiable {
    let id: UUID
    var symbol: String
    var title: String
    var subtitle: String
    var accent: AccentTone

    init(
        id: UUID = UUID(),
        symbol: String,
        title: String,
        subtitle: String,
        accent: AccentTone
    ) {
        self.id = id
        self.symbol = symbol
        self.title = title
        self.subtitle = subtitle
        self.accent = accent
    }
}

struct WorkspaceSnapshot: Codable {
    var projects: [Project]
    var weeklyTasks: [WeeklyTask]
    var missingAssets: [MissingAsset]
}

struct NewProjectDraft {
    var title = ""
    var subtitle = ""
    var stage: ProjectStage = .concept
    var genres: Set<String> = ["Cinematic"]
    var moods: Set<String> = ["Romantic"]
    var keySignature = "D♯"
    var bpm = ""
    var timeSignature = ""
    var deadline = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()
    var notes = ""
    var referenceTracks = ["", "", ""]
    var platforms: Set<String> = ["YouTube"]

    static let stageOptions: [ProjectStage] = [
        .concept, .moodboard, .arrangement, .shotlist,
        .production, .edit, .release, .archive
    ]

    static let genreOptions = [
        "Cinematic", "Classical", "Ambient", "Film Score",
        "Neo-Soul", "Jazz", "Contemporary", "Original", "Cover"
    ]

    static let moodOptions = [
        "Melancholic", "Romantic", "Ethereal", "Intimate",
        "Dramatic", "Peaceful", "Nostalgic", "Triumphant"
    ]

    static let keyOptions = [
        "C", "C♯", "D", "D♯", "E", "F",
        "F♯", "G", "G♯", "A", "A♯", "B"
    ]

    static let platformOptions = [
        "YouTube", "Spotify", "Instagram",
        "Apple Music", "SoundCloud", "TikTok"
    ]
}
