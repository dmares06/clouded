import Foundation

struct MonthlyStats: Codable {
    let monthKey: String // "2026-03"
    var tasksCompleted: Int
    var tasksCreated: Int
    var notesCreated: Int
    var projectsCreated: Int
    var brainDumpsRecorded: Int
    var focusSessionsCompleted: Int
    var focusMinutes: Int

    init(monthKey: String) {
        self.monthKey = monthKey
        self.tasksCompleted = 0
        self.tasksCreated = 0
        self.notesCreated = 0
        self.projectsCreated = 0
        self.brainDumpsRecorded = 0
        self.focusSessionsCompleted = 0
        self.focusMinutes = 0
    }

    static var currentMonthKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }

    var displayMonth: String {
        let parts = monthKey.split(separator: "-")
        guard parts.count == 2,
              let monthNum = Int(parts[1]) else { return monthKey }
        let months = ["", "January", "February", "March", "April", "May", "June",
                      "July", "August", "September", "October", "November", "December"]
        let year = String(parts[0])
        return monthNum >= 1 && monthNum <= 12 ? "\(months[monthNum]) \(year)" : monthKey
    }

    var totalActions: Int {
        tasksCompleted + notesCreated + projectsCreated + brainDumpsRecorded + focusSessionsCompleted
    }
}
