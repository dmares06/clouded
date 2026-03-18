import SwiftUI
import AppKit

// MARK: - Focus Helper

private struct FocusedOnAppear: ViewModifier {
    func body(content: Content) -> some View {
        content.background(WindowKeyHelper())
    }
}

private struct WindowKeyHelper: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.makeKeyAndOrderFront(nil)
                window.makeFirstResponder(nil)
            }
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

extension View {
    func focusedOnAppear() -> some View {
        modifier(FocusedOnAppear())
    }
}

// MARK: - Desktop Tasks Widget

struct DesktopTasksWidget: View {
    @ObservedObject var dataStore: DataStore
    @State private var newTaskText = ""
    @State private var isAdding = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "cloud.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(hex: "#4FC3F7"))

                Text("Tasks")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Spacer()

                let activeCount = dataStore.todos.filter { !$0.isCompleted }.count
                if activeCount > 0 {
                    Text("\(activeCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: "#0288D1"))
                        .clipShape(Capsule())
                }

                Button(action: { withAnimation(.easeOut(duration: 0.2)) { isAdding.toggle() } }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "#4FC3F7"))
                }
                .buttonStyle(.plain)
            }

            if isAdding {
                TextField("New task…", text: $newTaskText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .focusedOnAppear()
                    .onSubmit {
                        let trimmed = newTaskText.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        dataStore.addTodo(title: trimmed)
                        newTaskText = ""
                        withAnimation(.easeOut(duration: 0.2)) { isAdding = false }
                    }
            }

            Divider().overlay(Color.white.opacity(0.1))

            // Task list
            let active = dataStore.todos.filter { !$0.isCompleted }.prefix(6)
            if active.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Image(systemName: "cloud.sun")
                            .font(.system(size: 18))
                            .foregroundStyle(Color(hex: "#4FC3F7"))
                        Text("Clear skies!")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            } else {
                ForEach(Array(active)) { todo in
                    HStack(spacing: 8) {
                        Image(systemName: "circle")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.35))
                            .onTapGesture {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    dataStore.toggleTodo(todo)
                                }
                            }

                        Text(todo.title)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                            .lineLimit(1)

                        Spacer()

                        if let cat = dataStore.category(for: todo.categoryID) {
                            Text(cat.name)
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(cat.color)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(cat.color.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.08, green: 0.12, blue: 0.22).opacity(0.85))
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#0288D1").opacity(0.15), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "#4FC3F7").opacity(0.3), Color(hex: "#0288D1").opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(hex: "#0288D1").opacity(0.2), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Desktop Notes Widget

struct DesktopNotesWidget: View {
    @ObservedObject var dataStore: DataStore
    @State private var newNoteText = ""
    @State private var isAdding = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "note.text")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(hex: "#FFA726"))
                Text("Notes")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#FFA726"))
                Spacer()

                Button(action: { withAnimation(.easeOut(duration: 0.2)) { isAdding.toggle() } }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "#FFA726"))
                }
                .buttonStyle(.plain)
            }

            if isAdding {
                TextField("New note…", text: $newNoteText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .focusedOnAppear()
                    .onSubmit {
                        let trimmed = newNoteText.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        let note = dataStore.addNote()
                        dataStore.updateNote(note, content: trimmed)
                        newNoteText = ""
                        withAnimation(.easeOut(duration: 0.2)) { isAdding = false }
                    }
            }

            Divider().overlay(Color.white.opacity(0.1))

            // Notes list
            let recentNotes = dataStore.notes.filter { !$0.content.isEmpty }.prefix(4)
            if recentNotes.isEmpty {
                Text("No notes yet")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))
            } else {
                ForEach(Array(recentNotes)) { note in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(note.content)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.85))
                            .lineLimit(2)

                        Text(note.updatedAt, style: .relative)
                            .font(.system(size: 8))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    .padding(.vertical, 2)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.08, green: 0.12, blue: 0.22).opacity(0.85))
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#FFA726").opacity(0.08), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#FFA726").opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Desktop Brain Dump Widget

struct DesktopBrainDumpWidget: View {
    @ObservedObject var dataStore: DataStore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(hex: "#AB47BC"))
                Text("Brain Dump")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#AB47BC"))
                Spacer()

                let count = dataStore.brainDumps.count
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: "#AB47BC"))
                        .clipShape(Capsule())
                }
            }

            Divider().overlay(Color.white.opacity(0.1))

            let recent = dataStore.brainDumps.prefix(4)
            if recent.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Image(systemName: "brain")
                            .font(.system(size: 18))
                            .foregroundStyle(Color(hex: "#AB47BC"))
                        Text("No dumps yet")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            } else {
                ForEach(Array(recent)) { dump in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dump.title)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                            .lineLimit(1)
                        Text(dump.rawText)
                            .font(.system(size: 9))
                            .foregroundStyle(.white.opacity(0.5))
                            .lineLimit(2)
                    }
                    .padding(.vertical, 2)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.08, green: 0.12, blue: 0.22).opacity(0.85))
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#AB47BC").opacity(0.1), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#AB47BC").opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Desktop Projects Widget

struct DesktopProjectsWidget: View {
    @ObservedObject var dataStore: DataStore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "folder.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(hex: "#66BB6A"))
                Text("Projects")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#66BB6A"))
                Spacer()

                let count = dataStore.projects.count
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: "#66BB6A"))
                        .clipShape(Capsule())
                }
            }

            Divider().overlay(Color.white.opacity(0.1))

            let projects = dataStore.projects.prefix(5)
            if projects.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Image(systemName: "folder")
                            .font(.system(size: 18))
                            .foregroundStyle(Color(hex: "#66BB6A"))
                        Text("No projects yet")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
            } else {
                ForEach(Array(projects)) { project in
                    HStack(spacing: 8) {
                        Text(project.name)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                            .lineLimit(1)

                        Spacer()

                        Text("\(project.activeCount)/\(project.totalCount)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color(hex: "#66BB6A"))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(Color(hex: "#66BB6A").opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.08, green: 0.12, blue: 0.22).opacity(0.85))
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#66BB6A").opacity(0.1), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#66BB6A").opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Desktop Calendar Widget

struct DesktopCalendarWidget: View {
    @ObservedObject var calendarManager: CalendarManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with day
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(dayOfWeek.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color(hex: "#4FC3F7"))
                    Text("\(dayNumber)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                Spacer()

                Image(systemName: "calendar")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "#4FC3F7").opacity(0.6))
            }

            Divider().overlay(Color.white.opacity(0.1))

            // Events
            if calendarManager.authorizationStatus == .fullAccess {
                let events = calendarManager.upcomingEvents.prefix(3)
                if events.isEmpty {
                    Text("No events today")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.4))
                } else {
                    ForEach(Array(events)) { event in
                        HStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(Color(nsColor: event.calendarColor))
                                .frame(width: 3, height: 24)

                            VStack(alignment: .leading, spacing: 1) {
                                Text(event.title)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.9))
                                    .lineLimit(1)
                                Text(event.timeString)
                                    .font(.system(size: 9))
                                    .foregroundStyle(.white.opacity(0.4))
                            }

                            Spacer()

                            Text(event.relativeTimeString)
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundStyle(Color(hex: "#4FC3F7"))
                        }
                    }
                }
            } else {
                Text("Calendar access needed")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.4))
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.08, green: 0.12, blue: 0.22).opacity(0.85))
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#4FC3F7").opacity(0.08), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#4FC3F7").opacity(0.15), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
    }

    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }

    private var dayNumber: Int {
        Calendar.current.component(.day, from: Date())
    }
}
