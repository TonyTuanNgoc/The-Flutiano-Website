import SwiftUI

struct NewProjectView: View {
    let store: WorkspaceStore

    @State private var draft = NewProjectDraft()
    @State private var createdProject: Project?
    @FocusState private var isTitleFocused: Bool

    private let stageColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
    private let keyColumns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 6)

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    heroSection
                    formColumns
                    submitSection
                }
                .padding(.top, 36)
                .padding(.horizontal, 60)
                .padding(.bottom, 60)
            }
        }
        .overlay {
            if let project = createdProject {
                successOverlay(for: project)
                    .transition(.opacity)
            }
        }
        .task(id: createdProject?.id) {
            guard createdProject != nil else { return }
            try? await Task.sleep(for: .seconds(2.6))
            createdProject = nil
            store.navigate(to: .dashboard)
        }
    }

    private var topBar: some View {
        HStack(spacing: 14) {
            Button {
                store.navigate(to: .dashboard)
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 11, weight: .semibold))

                    Text("Dashboard")
                        .font(.system(size: 12.5))
                }
                .foregroundStyle(FlutianoTheme.textTertiary)
                .padding(.vertical, 7)
                .padding(.horizontal, 12)
                .background {
                    RoundedRectangle(cornerRadius: FlutianoTheme.smallRadius, style: .continuous)
                        .stroke(FlutianoTheme.borderSoft, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)

            Text("New Project")
                .font(.system(size: 14.5, weight: .semibold))
                .foregroundStyle(FlutianoTheme.textPrimary)

            Text("— fill in the details below")
                .font(.system(size: 11.5))
                .foregroundStyle(FlutianoTheme.textMuted)

            Spacer(minLength: 0)

            Button(action: submit) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))

                    Text("Create Project")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(FlutianoTheme.goldHighlight)
                .padding(.vertical, 8)
                .padding(.horizontal, 18)
                .background {
                    RoundedRectangle(cornerRadius: FlutianoTheme.smallRadius, style: .continuous)
                        .fill(FlutianoTheme.goldTint)
                        .overlay(
                            RoundedRectangle(cornerRadius: FlutianoTheme.smallRadius, style: .continuous)
                                .stroke(FlutianoTheme.gold.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 30)
        .frame(height: FlutianoTheme.topbarHeight)
        .background {
            Rectangle()
                .fill(Color(hex: 0x0E0E1A, opacity: 0.88))
                .background(.ultraThinMaterial)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(FlutianoTheme.borderSoft)
                        .frame(height: 1)
                }
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Text("PROJECT TITLE")
                    .font(.system(size: 9.5, weight: .medium))
                    .tracking(1.5)
                    .foregroundStyle(FlutianoTheme.textMuted)

                Rectangle()
                    .fill(FlutianoTheme.borderSoft)
                    .frame(height: 1)
            }
            .padding(.bottom, 14)

            TextField(
                "",
                text: $draft.title,
                prompt: Text("Give your project a name…").foregroundStyle(FlutianoTheme.textMuted)
            )
            .textFieldStyle(.plain)
            .font(.system(size: 40, weight: .heavy))
            .tracking(-1.5)
            .foregroundStyle(FlutianoTheme.textPrimary)
            .focused($isTitleFocused)

            TextField(
                "",
                text: $draft.subtitle,
                prompt: Text("Short description or subtitle (optional)").foregroundStyle(FlutianoTheme.textMuted)
            )
            .textFieldStyle(.plain)
            .font(.system(size: 16))
            .foregroundStyle(FlutianoTheme.textSecondary)
            .padding(.top, 8)
        }
        .padding(.bottom, 48)
    }

    private var formColumns: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 32) {
                leftColumn
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                rightColumn
                    .frame(width: 360, alignment: .topLeading)
            }

            VStack(alignment: .leading, spacing: 28) {
                leftColumn
                rightColumn
            }
        }
    }

    private var leftColumn: some View {
        VStack(alignment: .leading, spacing: 28) {
            formGroup("Starting Stage") {
                LazyVGrid(columns: stageColumns, spacing: 8) {
                    ForEach(NewProjectDraft.stageOptions) { stage in
                        StageOptionView(stage: stage, isSelected: draft.stage == stage) {
                            draft.stage = stage
                        }
                    }
                }
            }

            formGroup("Genre") {
                FlowLayout(itemSpacing: 8, rowSpacing: 8) {
                    ForEach(NewProjectDraft.genreOptions, id: \.self) { genre in
                        SelectableChip(
                            title: genre,
                            isSelected: draft.genres.contains(genre),
                            accent: .gold
                        ) {
                            toggle(genre, in: &draft.genres)
                        }
                    }
                }
            }

            formGroup("Mood") {
                FlowLayout(itemSpacing: 8, rowSpacing: 8) {
                    ForEach(NewProjectDraft.moodOptions, id: \.self) { mood in
                        SelectableChip(
                            title: mood,
                            isSelected: draft.moods.contains(mood),
                            accent: .jade
                        ) {
                            toggle(mood, in: &draft.moods)
                        }
                    }
                }
            }

            formGroup("Key") {
                LazyVGrid(columns: keyColumns, spacing: 6) {
                    ForEach(NewProjectDraft.keyOptions, id: \.self) { key in
                        KeyOptionView(title: key, isSelected: draft.keySignature == key) {
                            draft.keySignature = key
                        }
                    }
                }
            }

            formGroup("Tempo & Time Signature") {
                HStack(spacing: 12) {
                    FormTextField(title: "BPM (e.g. 72)", text: $draft.bpm)
                    FormTextField(title: "Time sig (e.g. 4/4)", text: $draft.timeSignature)
                }
            }

            formGroup("Target Deadline") {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: FlutianoTheme.smallRadius, style: .continuous)
                            .fill(FlutianoTheme.surfaceStrong)
                            .overlay(
                                RoundedRectangle(cornerRadius: FlutianoTheme.smallRadius, style: .continuous)
                                    .stroke(FlutianoTheme.borderSoft, lineWidth: 1)
                            )

                        Image(systemName: "calendar")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(FlutianoTheme.textMuted)
                    }
                    .frame(width: 36, height: 36)

                    DatePicker(
                        "",
                        selection: $draft.deadline,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(formBackground)
                }
            }

            formGroup("Notes") {
                TextEditor(text: $draft.notes)
                    .font(.system(size: 13))
                    .foregroundStyle(FlutianoTheme.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 90)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(formBackground)
                    .overlay(alignment: .topLeading) {
                        if draft.notes.isEmpty {
                            Text("Initial creative direction, references, ideas…")
                                .font(.system(size: 13))
                                .foregroundStyle(FlutianoTheme.textMuted)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                                .allowsHitTesting(false)
                        }
                    }
            }
        }
    }

    private var rightColumn: some View {
        VStack(alignment: .leading, spacing: 28) {
            formGroup("Cover Art") {
                Button {
                    store.showToast(
                        symbol: "photo",
                        title: "Image upload",
                        subtitle: "Cover art upload is queued for the next pass.",
                        accent: .sky
                    )
                } label: {
                    VStack(spacing: 10) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 28, weight: .regular))
                            .foregroundStyle(FlutianoTheme.textMuted)

                        Text("Drop image here")
                            .font(.system(size: 12))
                            .foregroundStyle(FlutianoTheme.textMuted)

                        Text("3000 × 3000 px · JPG or PNG")
                            .font(.system(size: 10))
                            .foregroundStyle(FlutianoTheme.textMuted.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .background {
                        RoundedRectangle(cornerRadius: FlutianoTheme.radius, style: .continuous)
                            .fill(FlutianoTheme.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: FlutianoTheme.radius, style: .continuous)
                                    .stroke(FlutianoTheme.border, style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                            )
                    }
                }
                .buttonStyle(.plain)
            }

            formGroup("Collaborators") {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(
                        [
                            Collaborator(initials: "F", name: "Flutiano", role: "Lead artist", accent: .gold)
                        ]
                    ) { collaborator in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: collaborator.accent == .gold
                                            ? [FlutianoTheme.gold, Color(hex: 0x7A5820)]
                                            : [collaborator.accent.color, collaborator.accent.highlight],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 26, height: 26)
                                .overlay {
                                    Text(collaborator.initials)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(collaborator.accent == .gold ? Color(hex: 0x0E0E1A) : .white)
                                }

                            Text(collaborator.name)
                                .font(.system(size: 12.5))
                                .foregroundStyle(FlutianoTheme.textSecondary)

                            Spacer(minLength: 0)

                            Text(collaborator.role)
                                .font(.system(size: 10))
                                .foregroundStyle(FlutianoTheme.textMuted)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(formBackground)
                    }

                    Button {
                        store.showToast(
                            symbol: "person.crop.circle.badge.plus",
                            title: "Invite collaborator",
                            subtitle: "Collaborator management is ready for the next step.",
                            accent: .gold
                        )
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .semibold))

                            Text("Add collaborator")
                                .font(.system(size: 12))
                        }
                        .foregroundStyle(FlutianoTheme.textMuted)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            RoundedRectangle(cornerRadius: FlutianoTheme.smallRadius, style: .continuous)
                                .stroke(FlutianoTheme.borderSoft, style: StrokeStyle(lineWidth: 1, dash: [5]))
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                }
            }

            formGroup("Reference Tracks") {
                VStack(spacing: 8) {
                    FormTextField(title: "e.g. Yiruma — River Flows in You", text: referenceBinding(at: 0))
                    FormTextField(title: "e.g. Ennio Morricone — Gabriel's Oboe", text: referenceBinding(at: 1))
                    FormTextField(title: "Add another reference…", text: referenceBinding(at: 2))
                }
            }

            formGroup("Target Platforms") {
                FlowLayout(itemSpacing: 8, rowSpacing: 8) {
                    ForEach(NewProjectDraft.platformOptions, id: \.self) { platform in
                        SelectableChip(
                            title: platform,
                            isSelected: draft.platforms.contains(platform),
                            accent: .gold
                        ) {
                            toggle(platform, in: &draft.platforms)
                        }
                    }
                }
            }
        }
    }

    private var submitSection: some View {
        HStack(spacing: 14) {
            Button(action: submit) {
                HStack(spacing: 9) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))

                    Text("Create Project")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(Color(hex: 0x0E0E1A))
                .padding(.vertical, 13)
                .padding(.horizontal, 28)
                .background {
                    RoundedRectangle(cornerRadius: FlutianoTheme.smallRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [FlutianoTheme.gold, Color(hex: 0xB8882A)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: FlutianoTheme.gold.opacity(0.3), radius: 14, y: 6)
                }
            }
            .buttonStyle(.plain)

            Button {
                store.navigate(to: .dashboard)
            } label: {
                Text("Cancel")
                    .font(.system(size: 13))
                    .foregroundStyle(FlutianoTheme.textSecondary)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 22)
                    .background {
                        RoundedRectangle(cornerRadius: FlutianoTheme.smallRadius, style: .continuous)
                            .stroke(FlutianoTheme.border, lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Text("Project will be added to your dashboard")
                .font(.system(size: 11))
                .foregroundStyle(FlutianoTheme.textMuted)
        }
        .padding(.top, 40)
        .padding(.bottom, 4)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(FlutianoTheme.borderSoft)
                .frame(height: 1)
        }
        .padding(.top, 32)
    }

    private var formBackground: some View {
        RoundedRectangle(cornerRadius: FlutianoTheme.smallRadius, style: .continuous)
            .fill(Color(hex: 0x1C1C2C))
            .overlay(
                RoundedRectangle(cornerRadius: FlutianoTheme.smallRadius, style: .continuous)
                    .stroke(FlutianoTheme.borderSoft, lineWidth: 1)
            )
    }

    private func formGroup<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 9.5, weight: .semibold))
                .tracking(1.3)
                .foregroundStyle(FlutianoTheme.textMuted)

            content()
        }
    }

    private func referenceBinding(at index: Int) -> Binding<String> {
        Binding(
            get: { draft.referenceTracks[index] },
            set: { draft.referenceTracks[index] = $0 }
        )
    }

    private func toggle(_ value: String, in set: inout Set<String>) {
        if set.contains(value) {
            set.remove(value)
        } else {
            set.insert(value)
        }
    }

    private func submit() {
        let cleanTitle = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else {
            isTitleFocused = true
            store.showToast(
                symbol: "exclamationmark.circle",
                title: "Project title required",
                subtitle: "Please enter a project title first.",
                accent: .rose
            )
            return
        }

        draft.title = cleanTitle
        let project = store.addProject(from: draft)
        withAnimation(.easeInOut(duration: 0.25)) {
            createdProject = project
        }
    }

    @ViewBuilder
    private func successOverlay(for project: Project) -> some View {
        ZStack {
            Color(hex: 0x0E0E1A, opacity: 0.96)

            VStack(spacing: 20) {
                Circle()
                    .fill(FlutianoTheme.jadeTint)
                    .frame(width: 72, height: 72)
                    .overlay(
                        Circle()
                            .stroke(FlutianoTheme.jade.opacity(0.35), lineWidth: 1.5)
                    )
                    .overlay {
                        Image(systemName: "checkmark")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(FlutianoTheme.jade)
                    }

                Text("“\(project.title)” Created")
                    .font(.system(size: 22, weight: .bold))
                    .tracking(-0.5)
                    .foregroundStyle(FlutianoTheme.textPrimary)

                Text("Starting at \(project.stage.displayName) stage")
                    .font(.system(size: 14))
                    .foregroundStyle(FlutianoTheme.textTertiary)

                Button {
                    createdProject = nil
                    store.navigate(to: .dashboard)
                } label: {
                    Text("Back to Dashboard")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(FlutianoTheme.goldHighlight)
                        .padding(.vertical, 11)
                        .padding(.horizontal, 28)
                        .background {
                            RoundedRectangle(cornerRadius: FlutianoTheme.smallRadius, style: .continuous)
                                .fill(FlutianoTheme.goldTint)
                                .overlay(
                                    RoundedRectangle(cornerRadius: FlutianoTheme.smallRadius, style: .continuous)
                                        .stroke(FlutianoTheme.gold.opacity(0.3), lineWidth: 1)
                                )
                        }
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
        }
        .ignoresSafeArea()
    }
}

private struct FormTextField: View {
    var title: String
    @Binding var text: String

    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(title).foregroundStyle(FlutianoTheme.textMuted)
        )
        .textFieldStyle(.plain)
        .font(.system(size: 13))
        .foregroundStyle(FlutianoTheme.textPrimary)
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background {
            RoundedRectangle(cornerRadius: FlutianoTheme.smallRadius, style: .continuous)
                .fill(Color(hex: 0x1C1C2C))
                .overlay(
                    RoundedRectangle(cornerRadius: FlutianoTheme.smallRadius, style: .continuous)
                        .stroke(FlutianoTheme.borderSoft, lineWidth: 1)
                )
        }
    }
}

private struct StageOptionView: View {
    let stage: ProjectStage
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: stage.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(isSelected ? FlutianoTheme.gold : FlutianoTheme.textSecondary)

                Text(stage.displayName)
                    .font(.system(size: 10, weight: .medium))
                    .tracking(0.4)
                    .foregroundStyle(isSelected ? FlutianoTheme.goldHighlight : FlutianoTheme.textSecondary)
            }
            .frame(maxWidth: .infinity, minHeight: 74)
            .background {
                RoundedRectangle(cornerRadius: FlutianoTheme.smallRadius, style: .continuous)
                    .fill(isSelected ? FlutianoTheme.goldTint : Color(hex: 0x1C1C2C))
                    .overlay(
                        RoundedRectangle(cornerRadius: FlutianoTheme.smallRadius, style: .continuous)
                            .stroke(
                                isSelected ? FlutianoTheme.gold.opacity(0.35) : FlutianoTheme.borderSoft,
                                lineWidth: 1
                            )
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

private struct SelectableChip: View {
    let title: String
    let isSelected: Bool
    let accent: AccentTone
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(isSelected ? accent.highlight : FlutianoTheme.textSecondary)
                .padding(.vertical, 6)
                .padding(.horizontal, 14)
                .background {
                    Capsule()
                        .fill(isSelected ? accent.tint : Color(hex: 0x1C1C2C))
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? accent.color.opacity(0.35) : FlutianoTheme.borderSoft, lineWidth: 1)
                        )
                }
        }
        .buttonStyle(.plain)
    }
}

private struct KeyOptionView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? FlutianoTheme.goldHighlight : FlutianoTheme.textSecondary)
                .frame(maxWidth: .infinity, minHeight: 34)
                .background {
                    RoundedRectangle(cornerRadius: FlutianoTheme.smallRadius, style: .continuous)
                        .fill(isSelected ? FlutianoTheme.goldTint : Color(hex: 0x1C1C2C))
                        .overlay(
                            RoundedRectangle(cornerRadius: FlutianoTheme.smallRadius, style: .continuous)
                                .stroke(
                                    isSelected ? FlutianoTheme.gold.opacity(0.35) : FlutianoTheme.borderSoft,
                                    lineWidth: 1
                                )
                        )
                }
        }
        .buttonStyle(.plain)
    }
}
