import SwiftUI

struct ProjectsView: View {
    @ObservedObject var dataStore: DataStore
    @State private var openProjectID: UUID?
    @State private var newProjectName = ""
    @State private var newTaskText = ""
    @State private var expandedTaskIDs: Set<UUID> = []
    @State private var editingTaskID: UUID?
    @State private var editTaskText = ""
    @State private var editingProjectID: UUID?
    @State private var editProjectName = ""
    @FocusState private var projectInputFocused: Bool
    @FocusState private var taskInputFocused: Bool

    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                if let projectID = openProjectID,
                   let project = dataStore.projects.first(where: { $0.id == projectID }) {
                    Button {
                        withAnimation(CloudTheme.springAnimation) {
                            openProjectID = nil
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 9, weight: .bold))
                            Text("Projects")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(CloudTheme.accentBlue)
                    }
                    .buttonStyle(.plain)

                    Text("/")
                        .font(.system(size: 10))
                        .foregroundStyle(CloudTheme.textSecondary)

                    if editingProjectID == project.id {
                        TextField("Project name...", text: $editProjectName)
                            .textFieldStyle(.plain)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(CloudTheme.textPrimary)
                            .onSubmit {
                                dataStore.renameProject(project, to: editProjectName)
                                editingProjectID = nil
                            }

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(CloudTheme.checkGreen)
                            .onTapGesture {
                                dataStore.renameProject(project, to: editProjectName)
                                editingProjectID = nil
                            }
                    } else {
                        Text(project.name)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(CloudTheme.textPrimary)
                            .lineLimit(1)
                            .onTapGesture {
                                editingProjectID = project.id
                                editProjectName = project.name
                            }
                    }
                } else {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(CloudTheme.accentBlue)
                    Text("Projects")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(CloudTheme.accentBlue)
                }
                Spacer()
            }

            if let projectID = openProjectID,
               let project = dataStore.projects.first(where: { $0.id == projectID }) {
                projectDetailView(project)
            } else {
                projectListView
            }
        }
    }

    // MARK: - Project List

    private var projectListView: some View {
        VStack(spacing: 6) {
            // Add project input
            HStack(spacing: 6) {
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 13))
                    .foregroundStyle(CloudTheme.gradient)

                TextField("New project...", text: $newProjectName)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(CloudTheme.textPrimary)
                    .focused($projectInputFocused)
                    .onSubmit { addProject() }
            }
            .padding(8)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(projectInputFocused ? CloudTheme.accentBlue : CloudTheme.borderBlue, lineWidth: 1)
            )

            if dataStore.projects.isEmpty {
                Spacer()
                VStack(spacing: 6) {
                    Image(systemName: "folder")
                        .font(.system(size: 22))
                        .foregroundStyle(CloudTheme.gradient)
                    Text("No projects yet")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(CloudTheme.textPrimary)
                }
                Spacer()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 4) {
                        ForEach(dataStore.projects) { project in
                            projectRow(project)
                        }
                    }
                }
            }
        }
    }

    private func projectRow(_ project: Project) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "folder.fill")
                .font(.system(size: 14))
                .foregroundStyle(CloudTheme.accentBlue)

            VStack(alignment: .leading, spacing: 1) {
                Text(project.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(CloudTheme.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    if project.activeCount > 0 {
                        Text("\(project.activeCount) active")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(CloudTheme.accentBlue)
                    }
                    if project.completedCount > 0 {
                        Text("\(project.completedCount) done")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(CloudTheme.checkGreen)
                    }
                    if project.totalCount == 0 {
                        Text("Empty")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(CloudTheme.textSecondary)
                    }
                }
            }

            Spacer()

            // Progress indicator
            if project.totalCount > 0 {
                let progress = CGFloat(project.completedCount) / CGFloat(project.totalCount)
                ZStack {
                    Circle()
                        .stroke(CloudTheme.surfaceBlue, lineWidth: 2)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(CloudTheme.checkGreen, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 18, height: 18)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(CloudTheme.textSecondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(CloudTheme.borderBlue, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(CloudTheme.springAnimation) {
                openProjectID = project.id
                newTaskText = ""
            }
        }
    }

    // MARK: - Project Detail (tasks inside a project)

    private func projectDetailView(_ project: Project) -> some View {
        VStack(spacing: 6) {
            // Add task input
            HStack(spacing: 6) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(CloudTheme.gradient)

                TextField("Add task to \(project.name)...", text: $newTaskText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(CloudTheme.textPrimary)
                    .focused($taskInputFocused)
                    .onSubmit {
                        withAnimation(CloudTheme.springAnimation) {
                            dataStore.addTaskToProject(project.id, title: newTaskText)
                            newTaskText = ""
                        }
                    }
            }
            .padding(8)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(taskInputFocused ? CloudTheme.accentBlue : CloudTheme.borderBlue, lineWidth: 1)
            )

            if project.tasks.isEmpty {
                Spacer()
                Text("No tasks yet")
                    .font(.system(size: 11))
                    .foregroundStyle(CloudTheme.textSecondary)
                Spacer()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 3) {
                        let active = project.tasks.filter { !$0.isCompleted }
                        let completed = project.tasks.filter { $0.isCompleted }

                        ForEach(active) { task in
                            projectTaskRow(project: project, task: task, dimmed: false)
                        }

                        if !completed.isEmpty {
                            HStack {
                                Text("Completed")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundStyle(CloudTheme.textSecondary)
                                Spacer()
                            }
                            .padding(.top, 4)

                            ForEach(completed) { task in
                                projectTaskRow(project: project, task: task, dimmed: true)
                            }
                        }
                    }
                }

                // Summary
                HStack {
                    Text("\(project.activeCount) remaining")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(CloudTheme.textSecondary)
                    Spacer()
                }
            }
        }
    }

    private func projectTaskRow(project: Project, task: TodoItem, dimmed: Bool) -> some View {
        let isExpanded = expandedTaskIDs.contains(task.id)
        let isEditing = editingTaskID == task.id
        let bullets = parseBullets(from: task.title)

        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                // Checkbox
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 15))
                    .foregroundStyle(task.isCompleted ? CloudTheme.checkGreen : CloudTheme.accentBlue.opacity(0.5))
                    .onTapGesture {
                        withAnimation(CloudTheme.springAnimation) {
                            dataStore.toggleProjectTask(project.id, taskID: task.id)
                        }
                    }

                if isEditing {
                    TextField("Edit task...", text: $editTaskText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(CloudTheme.textPrimary)
                        .lineLimit(1...8)
                        .onSubmit {
                            dataStore.updateProjectTask(project.id, taskID: task.id, title: editTaskText)
                            editingTaskID = nil
                        }

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(CloudTheme.checkGreen)
                        .onTapGesture {
                            dataStore.updateProjectTask(project.id, taskID: task.id, title: editTaskText)
                            editingTaskID = nil
                        }
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        if isExpanded {
                            Text(bullets.isEmpty ? task.title : bullets[0])
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(dimmed ? CloudTheme.textSecondary : CloudTheme.textPrimary)
                                .strikethrough(task.isCompleted, color: CloudTheme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text(task.title)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(dimmed ? CloudTheme.textSecondary : CloudTheme.textPrimary)
                                .strikethrough(task.isCompleted, color: CloudTheme.textSecondary)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        if isExpanded {
                            HStack(spacing: 4) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 9, weight: .medium))
                                Text("Edit")
                                    .font(.system(size: 9, weight: .semibold))
                            }
                            .foregroundStyle(CloudTheme.accentBlue)
                            .padding(.top, 4)
                            .onTapGesture {
                                editingTaskID = task.id
                                editTaskText = task.title
                            }
                        }
                    }

                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(CloudTheme.accentBlue.opacity(0.4))
                        .onTapGesture {
                            withAnimation(CloudTheme.springAnimation) {
                                dataStore.deleteProjectTask(project.id, taskID: task.id)
                            }
                        }
                }
            }

            // Expanded bullet breakdown
            if isExpanded && !isEditing && bullets.count > 1 {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(bullets.dropFirst().enumerated()), id: \.offset) { _, bullet in
                        HStack(alignment: .top, spacing: 6) {
                            Circle()
                                .fill(CloudTheme.accentBlue)
                                .frame(width: 4, height: 4)
                                .padding(.top, 5)

                            Text(bullet)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(dimmed ? CloudTheme.textSecondary : CloudTheme.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.leading, 23)
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Expanded full text (when no bullets parsed)
            if isExpanded && !isEditing && bullets.count <= 1 && task.title.count > 40 {
                Text(task.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(dimmed ? CloudTheme.textSecondary : CloudTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 23)
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 5)
        .background((isExpanded || isEditing) ? Color.white : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            (isExpanded || isEditing) ? RoundedRectangle(cornerRadius: 6)
                .stroke(CloudTheme.accentBlue.opacity(0.3), lineWidth: 1) : nil
        )
        .opacity(dimmed ? 0.6 : 1)
        .contentShape(Rectangle())
        .onTapGesture {
            guard !isEditing else { return }
            withAnimation(CloudTheme.springAnimation) {
                if isExpanded {
                    expandedTaskIDs.remove(task.id)
                } else {
                    expandedTaskIDs.insert(task.id)
                }
            }
        }
    }

    // MARK: - Bullet Parsing

    /// Parses a long task string into bullet points by splitting on:
    /// newlines, numbered lists (1. 2. 3.), dashes/bullets (- *), and semicolons
    private func parseBullets(from text: String) -> [String] {
        // Split on newlines first
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        if lines.count > 1 {
            return lines
        }

        // Try splitting on numbered patterns: "1." "2." etc.
        let numberedPattern = try? NSRegularExpression(pattern: #"(?:^|\s)(\d+[\.\)]\s)"#)
        if let regex = numberedPattern {
            let range = NSRange(text.startIndex..., in: text)
            let matches = regex.matches(in: text, range: range)
            if matches.count >= 2 {
                var parts: [String] = []
                var lastEnd = text.startIndex
                for match in matches {
                    if let r = Range(match.range, in: text) {
                        let before = String(text[lastEnd..<r.lowerBound]).trimmingCharacters(in: .whitespaces)
                        if !before.isEmpty { parts.append(before) }
                        lastEnd = r.lowerBound
                    }
                }
                let remaining = String(text[lastEnd...]).trimmingCharacters(in: .whitespaces)
                if !remaining.isEmpty { parts.append(remaining) }
                if parts.count > 1 { return parts }
            }
        }

        // Try splitting on semicolons
        let semiParts = text.components(separatedBy: ";")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        if semiParts.count >= 2 {
            return semiParts
        }

        // Try splitting on " - " (dash separated items)
        let dashParts = text.components(separatedBy: " - ")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        if dashParts.count >= 2 {
            return dashParts
        }

        return [text]
    }

    // MARK: - Actions

    private func addProject() {
        withAnimation(CloudTheme.springAnimation) {
            dataStore.addProject(name: newProjectName)
            newProjectName = ""
        }
    }
}
