import SwiftUI

struct TaskCategory: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let name: String
    let colorHex: String

    init(id: UUID = UUID(), name: String, colorHex: String) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }

    var color: Color {
        Color(hex: colorHex)
    }

    func withName(_ name: String) -> TaskCategory {
        TaskCategory(id: id, name: name, colorHex: colorHex)
    }

    func withColor(_ hex: String) -> TaskCategory {
        TaskCategory(id: id, name: name, colorHex: hex)
    }

    // MARK: - Default Categories

    static let defaults: [TaskCategory] = [
        TaskCategory(name: "Personal", colorHex: "#4FC3F7"),
        TaskCategory(name: "Business", colorHex: "#AB47BC"),
        TaskCategory(name: "Kids School", colorHex: "#FFA726"),
        TaskCategory(name: "Errands", colorHex: "#66BB6A"),
        TaskCategory(name: "Health", colorHex: "#EC407A"),
        TaskCategory(name: "Urgent", colorHex: "#EF5350"),
        TaskCategory(name: "Social", colorHex: "#26C6DA"),
        TaskCategory(name: "Work", colorHex: "#5C6BC0"),
    ]
}

// MARK: - Color from Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
