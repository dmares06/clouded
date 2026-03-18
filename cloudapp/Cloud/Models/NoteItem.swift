import Foundation

struct NoteItem: Identifiable, Codable, Equatable {
    let id: UUID
    let content: String
    let updatedAt: Date

    init(id: UUID = UUID(), content: String = "", updatedAt: Date = Date()) {
        self.id = id
        self.content = content
        self.updatedAt = updatedAt
    }

    func withContent(_ newContent: String) -> NoteItem {
        NoteItem(id: id, content: newContent, updatedAt: Date())
    }
}
