import Foundation

struct Project: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let tasks: [TodoItem]
    let createdAt: Date

    init(id: UUID = UUID(), name: String, tasks: [TodoItem] = [], createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.tasks = tasks
        self.createdAt = createdAt
    }

    func withName(_ newName: String) -> Project {
        Project(id: id, name: newName, tasks: tasks, createdAt: createdAt)
    }

    func addingTask(_ task: TodoItem) -> Project {
        Project(id: id, name: name, tasks: [task] + tasks, createdAt: createdAt)
    }

    func togglingTask(_ taskID: UUID) -> Project {
        let updated = tasks.map { $0.id == taskID ? $0.toggled() : $0 }
        return Project(id: id, name: name, tasks: updated, createdAt: createdAt)
    }

    func deletingTask(_ taskID: UUID) -> Project {
        Project(id: id, name: name, tasks: tasks.filter { $0.id != taskID }, createdAt: createdAt)
    }

    func updatingTask(_ taskID: UUID, title: String) -> Project {
        let updated = tasks.map { $0.id == taskID ? $0.withTitle(title) : $0 }
        return Project(id: id, name: name, tasks: updated, createdAt: createdAt)
    }

    var activeCount: Int { tasks.filter { !$0.isCompleted }.count }
    var completedCount: Int { tasks.filter { $0.isCompleted }.count }
    var totalCount: Int { tasks.count }
}
