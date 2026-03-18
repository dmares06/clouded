import Foundation

struct TodoItem: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let isCompleted: Bool
    let createdAt: Date
    let categoryID: UUID?
    let dueDate: Date?
    let calendarEventID: String?

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, createdAt: Date = Date(), categoryID: UUID? = nil, dueDate: Date? = nil, calendarEventID: String? = nil) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.categoryID = categoryID
        self.dueDate = dueDate
        self.calendarEventID = calendarEventID
    }

    func toggled() -> TodoItem {
        TodoItem(id: id, title: title, isCompleted: !isCompleted, createdAt: createdAt, categoryID: categoryID, dueDate: dueDate, calendarEventID: calendarEventID)
    }

    func withTitle(_ newTitle: String) -> TodoItem {
        TodoItem(id: id, title: newTitle, isCompleted: isCompleted, createdAt: createdAt, categoryID: categoryID, dueDate: dueDate, calendarEventID: calendarEventID)
    }

    func withCategory(_ categoryID: UUID?) -> TodoItem {
        TodoItem(id: id, title: title, isCompleted: isCompleted, createdAt: createdAt, categoryID: categoryID, dueDate: dueDate, calendarEventID: calendarEventID)
    }

    func withDueDate(_ date: Date?, calendarEventID: String? = nil) -> TodoItem {
        TodoItem(id: id, title: title, isCompleted: isCompleted, createdAt: createdAt, categoryID: categoryID, dueDate: date, calendarEventID: calendarEventID)
    }
}
