import SwiftUI

struct TodoListView: View {
    @ObservedObject var dataStore: DataStore
    @Binding var datePickerTaskID: UUID?
    @State private var newTaskText = ""
    @State private var selectedCategoryID: UUID?
    @State private var showCategoryPicker = false
    @State private var expandedTaskIDs: Set<UUID> = []
    @State private var editingTaskID: UUID?
    @State private var editTaskText = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(CloudTheme.accentBlue)
                Text("Tasks")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(CloudTheme.accentBlue)

                let activeCount = dataStore.todos.filter { !$0.isCompleted }.count
                if activeCount > 0 {
                    Text("\(activeCount)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(CloudTheme.textOnAccent)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(CloudTheme.accentBlue)
                        .clipShape(Capsule())
                }

                Spacer()

                if dataStore.todos.contains(where: { $0.isCompleted }) {
                    Text("Clear done")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(CloudTheme.accentBlue)
                        .onTapGesture {
                            withAnimation(CloudTheme.springAnimation) {
                                dataStore.clearCompleted()
                            }
                        }
                }
            }

            // Add task input
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(CloudTheme.gradient)

                    TextField("Add a task...", text: $newTaskText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(CloudTheme.textPrimary)
                        .focused($isInputFocused)
                        .onSubmit { addTask() }

                    // Category selector button
                    categoryButton
                }
                .padding(9)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isInputFocused ? CloudTheme.accentBlue : CloudTheme.borderBlue, lineWidth: 1)
                )

                // Category picker dropdown
                if showCategoryPicker {
                    categoryPickerView
                }
            }

            // Task list
            if dataStore.todos.isEmpty {
                Spacer()
                VStack(spacing: 6) {
                    Image(systemName: "cloud.sun")
                        .font(.system(size: 24))
                        .foregroundStyle(CloudTheme.gradient)
                    Text("Clear skies!")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(CloudTheme.textPrimary)
                }
                Spacer()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 3) {
                        let active = dataStore.todos.filter { !$0.isCompleted }
                        let completed = dataStore.todos.filter { $0.isCompleted }

                        ForEach(active) { todo in
                            todoRow(todo, dimmed: false)
                        }

                        if !completed.isEmpty {
                            Divider().padding(.vertical, 4)
                            ForEach(completed) { todo in
                                todoRow(todo, dimmed: true)
                            }
                        }
                    }
                }
            }

            if !dataStore.todos.isEmpty {
                let active = dataStore.todos.filter { !$0.isCompleted }.count
                Text("\(active) remaining")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(CloudTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: - Category Button

    private var categoryButton: some View {
        HStack(spacing: 3) {
            if let catID = selectedCategoryID, let cat = dataStore.category(for: catID) {
                Circle()
                    .fill(cat.color)
                    .frame(width: 8, height: 8)
                Text(cat.name)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(cat.color)
            } else {
                Image(systemName: "tag")
                    .font(.system(size: 10))
                    .foregroundStyle(CloudTheme.textSecondary)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.white)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(CloudTheme.borderBlue, lineWidth: 1))
        .onTapGesture {
            withAnimation(CloudTheme.quickAnimation) {
                showCategoryPicker.toggle()
            }
        }
    }

    // MARK: - Category Picker

    private var categoryPickerView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                // "None" option
                Text("None")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(selectedCategoryID == nil ? CloudTheme.textOnAccent : CloudTheme.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(selectedCategoryID == nil ? CloudTheme.accentBlue : Color.white)
                    .clipShape(Capsule())
                    .onTapGesture {
                        withAnimation(CloudTheme.quickAnimation) {
                            selectedCategoryID = nil
                            showCategoryPicker = false
                        }
                    }

                ForEach(dataStore.categories) { cat in
                    HStack(spacing: 3) {
                        Circle()
                            .fill(cat.color)
                            .frame(width: 6, height: 6)
                        Text(cat.name)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(selectedCategoryID == cat.id ? CloudTheme.textOnAccent : cat.color)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(selectedCategoryID == cat.id ? cat.color : cat.color.opacity(0.12))
                    .clipShape(Capsule())
                    .onTapGesture {
                        withAnimation(CloudTheme.quickAnimation) {
                            selectedCategoryID = cat.id
                            showCategoryPicker = false
                        }
                    }
                }
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: - Task Row

    private func todoRow(_ todo: TodoItem, dimmed: Bool) -> some View {
        let isExpanded = expandedTaskIDs.contains(todo.id)
        let isEditing = editingTaskID == todo.id

        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                // Checkbox
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 15))
                    .foregroundStyle(todo.isCompleted ? CloudTheme.checkGreen : CloudTheme.accentBlue.opacity(0.5))
                    .onTapGesture {
                        withAnimation(CloudTheme.springAnimation) {
                            dataStore.toggleTodo(todo)
                        }
                    }

                if isEditing {
                    TextField("Edit task...", text: $editTaskText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(CloudTheme.textPrimary)
                        .lineLimit(1...8)
                        .onSubmit {
                            dataStore.updateTodo(todo, title: editTaskText)
                            editingTaskID = nil
                        }

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(CloudTheme.checkGreen)
                        .onTapGesture {
                            dataStore.updateTodo(todo, title: editTaskText)
                            editingTaskID = nil
                        }
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(todo.title)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(dimmed ? CloudTheme.textSecondary : CloudTheme.textPrimary)
                            .strikethrough(todo.isCompleted, color: CloudTheme.textSecondary)
                            .lineLimit(isExpanded ? nil : 1)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Category pill
                        if let cat = dataStore.category(for: todo.categoryID) {
                            Text(cat.name)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(cat.color)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(cat.color.opacity(0.12))
                                .clipShape(Capsule())
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
                                editingTaskID = todo.id
                                editTaskText = todo.title
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Due date tag
                    if let due = todo.dueDate {
                        Text(Self.shortDateString(due))
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(CloudTheme.accentBlue)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(CloudTheme.accentBlue.opacity(0.1))
                            .clipShape(Capsule())
                    }

                    // Calendar icon to assign date
                    Image(systemName: "calendar")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(todo.dueDate != nil ? CloudTheme.accentBlue : CloudTheme.accentBlue.opacity(0.4))
                        .onTapGesture {
                            withAnimation(CloudTheme.springAnimation) {
                                datePickerTaskID = datePickerTaskID == todo.id ? nil : todo.id
                            }
                        }

                    // Category color dot
                    if let cat = dataStore.category(for: todo.categoryID) {
                        Circle()
                            .fill(cat.color)
                            .frame(width: 6, height: 6)
                    }

                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(CloudTheme.accentBlue.opacity(0.4))
                        .onTapGesture {
                            withAnimation(CloudTheme.springAnimation) {
                                dataStore.deleteTodo(todo)
                            }
                        }
                }
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 5)
        .background(Color.white.opacity(dimmed ? 0.4 : 0.7))
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
                    expandedTaskIDs.remove(todo.id)
                } else {
                    expandedTaskIDs.insert(todo.id)
                }
            }
        }
    }

    private static func shortDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private func addTask() {
        withAnimation(CloudTheme.springAnimation) {
            dataStore.addTodo(title: newTaskText, categoryID: selectedCategoryID)
            newTaskText = ""
        }
    }
}
