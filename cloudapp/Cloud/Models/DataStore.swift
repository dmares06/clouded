import Foundation
import Combine
import os.log

private let logger = Logger(subsystem: "com.clouded.app", category: "DataStore")

final class DataStore: ObservableObject {
    @Published private(set) var todos: [TodoItem] = []
    @Published private(set) var notes: [NoteItem] = []
    @Published private(set) var projects: [Project] = []
    @Published private(set) var brainDumps: [BrainDump] = []
    @Published private(set) var categories: [TaskCategory] = []
    @Published private(set) var allStats: [MonthlyStats] = []

    private let fileManager = FileManager.default
    private let todosURL: URL
    private let notesURL: URL
    private let projectsURL: URL
    private let brainDumpsURL: URL
    private let categoriesURL: URL
    private let statsURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let cloudDir = appSupport.appendingPathComponent("Cloud", isDirectory: true)

        if !fileManager.fileExists(atPath: cloudDir.path) {
            try? fileManager.createDirectory(at: cloudDir, withIntermediateDirectories: true)
        }

        todosURL = cloudDir.appendingPathComponent("todos.json")
        notesURL = cloudDir.appendingPathComponent("notes.json")
        projectsURL = cloudDir.appendingPathComponent("projects.json")
        brainDumpsURL = cloudDir.appendingPathComponent("braindumps.json")
        categoriesURL = cloudDir.appendingPathComponent("categories.json")
        statsURL = cloudDir.appendingPathComponent("stats.json")

        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601

        loadAll()
    }

    // MARK: - Category Helpers

    func category(for id: UUID?) -> TaskCategory? {
        guard let id = id else { return nil }
        return categories.first { $0.id == id }
    }

    // MARK: - Stats

    var currentMonthStats: MonthlyStats {
        let key = MonthlyStats.currentMonthKey
        return allStats.first { $0.monthKey == key } ?? MonthlyStats(monthKey: key)
    }

    func incrementStat(_ update: (inout MonthlyStats) -> Void) {
        let key = MonthlyStats.currentMonthKey
        if let idx = allStats.firstIndex(where: { $0.monthKey == key }) {
            var stats = allStats[idx]
            update(&stats)
            allStats = allStats.enumerated().map { $0.offset == idx ? stats : $0.element }
        } else {
            var stats = MonthlyStats(monthKey: key)
            update(&stats)
            allStats = allStats + [stats]
        }
        saveStats()
    }

    func recordFocusSession(minutes: Int) {
        incrementStat { stats in
            stats.focusSessionsCompleted += 1
            stats.focusMinutes += minutes
        }
    }

    // MARK: - Categories

    func addCategory(name: String, colorHex: String) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let cat = TaskCategory(name: name.trimmingCharacters(in: .whitespaces), colorHex: colorHex)
        categories = categories + [cat]
        saveCategories()
    }

    func deleteCategory(_ cat: TaskCategory) {
        categories = categories.filter { $0.id != cat.id }
        // Remove category from tasks that had it
        todos = todos.map { $0.categoryID == cat.id ? $0.withCategory(nil) : $0 }
        saveCategories()
        saveTodos()
    }

    // MARK: - Todos

    func addTodo(title: String, categoryID: UUID? = nil) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let newTodo = TodoItem(title: title.trimmingCharacters(in: .whitespaces), categoryID: categoryID)
        todos = [newTodo] + todos
        saveTodos()
        incrementStat { $0.tasksCreated += 1 }
    }

    func toggleTodo(_ item: TodoItem) {
        if !item.isCompleted {
            incrementStat { $0.tasksCompleted += 1 }
        }
        todos = todos.map { $0.id == item.id ? $0.toggled() : $0 }
        saveTodos()
    }

    func deleteTodo(_ item: TodoItem) {
        todos = todos.filter { $0.id != item.id }
        saveTodos()
    }

    func updateTodo(_ item: TodoItem, title: String) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        todos = todos.map { $0.id == item.id ? $0.withTitle(title.trimmingCharacters(in: .whitespaces)) : $0 }
        saveTodos()
    }

    func setTaskDueDate(_ item: TodoItem, date: Date?, calendarManager: CalendarManager) {
        // Remove old calendar event if one exists
        if let oldEventID = item.calendarEventID {
            calendarManager.deleteEvent(identifier: oldEventID)
        }

        // Create new calendar event if a date was provided
        var newEventID: String?
        if let date = date {
            newEventID = calendarManager.createAllDayEvent(title: item.title, date: date)
        }

        let updated = item.withDueDate(date, calendarEventID: newEventID)
        todos = todos.map { $0.id == item.id ? updated : $0 }
        saveTodos()
    }

    func clearCompleted() {
        todos = todos.filter { !$0.isCompleted }
        saveTodos()
    }

    // MARK: - Notes

    func addNote() -> NoteItem {
        let note = NoteItem()
        notes = [note] + notes
        saveNotes()
        incrementStat { $0.notesCreated += 1 }
        return note
    }

    func updateNote(_ item: NoteItem, content: String) {
        notes = notes.map { $0.id == item.id ? $0.withContent(content) : $0 }
        saveNotes()
    }

    func deleteNote(_ item: NoteItem) {
        notes = notes.filter { $0.id != item.id }
        saveNotes()
    }

    // MARK: - Projects

    func addProject(name: String) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let project = Project(name: name.trimmingCharacters(in: .whitespaces))
        projects = projects + [project]
        saveProjects()
        incrementStat { $0.projectsCreated += 1 }
    }

    func deleteProject(_ project: Project) {
        projects = projects.filter { $0.id != project.id }
        saveProjects()
    }

    func renameProject(_ project: Project, to name: String) {
        projects = projects.map { $0.id == project.id ? $0.withName(name) : $0 }
        saveProjects()
    }

    func addTaskToProject(_ projectID: UUID, title: String) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let task = TodoItem(title: title.trimmingCharacters(in: .whitespaces))
        projects = projects.map { $0.id == projectID ? $0.addingTask(task) : $0 }
        saveProjects()
    }

    func toggleProjectTask(_ projectID: UUID, taskID: UUID) {
        projects = projects.map { $0.id == projectID ? $0.togglingTask(taskID) : $0 }
        saveProjects()
    }

    func updateProjectTask(_ projectID: UUID, taskID: UUID, title: String) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        projects = projects.map { $0.id == projectID ? $0.updatingTask(taskID, title: title.trimmingCharacters(in: .whitespaces)) : $0 }
        saveProjects()
    }

    func deleteProjectTask(_ projectID: UUID, taskID: UUID) {
        projects = projects.map { $0.id == projectID ? $0.deletingTask(taskID) : $0 }
        saveProjects()
    }

    // MARK: - Brain Dumps

    func addBrainDump(rawText: String) {
        guard !rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let structured = BrainDump.structure(rawText)
        let dump = BrainDump(rawText: rawText, structuredItems: structured)
        brainDumps = [dump] + brainDumps
        saveBrainDumps()
        incrementStat { $0.brainDumpsRecorded += 1 }
    }

    func deleteBrainDump(_ dump: BrainDump) {
        brainDumps = brainDumps.filter { $0.id != dump.id }
        saveBrainDumps()
    }

    func convertDumpItemToTask(_ item: String) {
        addTodo(title: item)
    }

    // MARK: - Persistence

    private func loadAll() {
        if let data = try? Data(contentsOf: todosURL),
           let loaded = try? decoder.decode([TodoItem].self, from: data) {
            todos = loaded
        }

        if let data = try? Data(contentsOf: notesURL),
           let loaded = try? decoder.decode([NoteItem].self, from: data) {
            notes = loaded
        }

        if let data = try? Data(contentsOf: projectsURL),
           let loaded = try? decoder.decode([Project].self, from: data) {
            projects = loaded
        }

        if let data = try? Data(contentsOf: brainDumpsURL),
           let loaded = try? decoder.decode([BrainDump].self, from: data) {
            brainDumps = loaded
        }

        if let data = try? Data(contentsOf: categoriesURL),
           let loaded = try? decoder.decode([TaskCategory].self, from: data) {
            categories = loaded
        } else {
            // Seed with defaults on first launch
            categories = TaskCategory.defaults
            saveCategories()
        }

        if let data = try? Data(contentsOf: statsURL),
           let loaded = try? decoder.decode([MonthlyStats].self, from: data) {
            allStats = loaded
        }
    }

    private func save<T: Encodable>(_ items: T, to url: URL, label: String) {
        do {
            let data = try encoder.encode(items)
            try data.write(to: url, options: .atomic)
        } catch {
            logger.error("Failed to save \(label) to \(url.path): \(error.localizedDescription)")
        }
    }

    private func saveBrainDumps() { save(brainDumps, to: brainDumpsURL, label: "brain dumps") }
    private func saveTodos() { save(todos, to: todosURL, label: "todos") }
    private func saveNotes() { save(notes, to: notesURL, label: "notes") }
    private func saveProjects() { save(projects, to: projectsURL, label: "projects") }
    private func saveCategories() { save(categories, to: categoriesURL, label: "categories") }
    private func saveStats() { save(allStats, to: statsURL, label: "stats") }
}
