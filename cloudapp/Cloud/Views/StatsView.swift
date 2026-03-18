import SwiftUI

struct StatsView: View {
    @ObservedObject var dataStore: DataStore
    @ObservedObject var pomodoroTimer: PomodoroTimer

    var body: some View {
        let stats = dataStore.currentMonthStats

        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 12) {
                // Month header
                HStack {
                    Text(stats.displayMonth)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(CloudTheme.textPrimary)
                    Spacer()
                    Text("Monthly Overview")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(CloudTheme.accentBlue)
                }

                // Productivity score ring
                HStack(spacing: 16) {
                    productivityRing(totalActions: stats.totalActions)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Productivity")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(CloudTheme.textPrimary)
                        Text("\(stats.totalActions) total actions")
                            .font(.system(size: 10))
                            .foregroundStyle(CloudTheme.textSecondary)
                        Text("\(stats.focusMinutes) min focused")
                            .font(.system(size: 10))
                            .foregroundStyle(CloudTheme.accentBlue)
                    }

                    Spacer()
                }
                .padding(10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(CloudTheme.borderBlue, lineWidth: 1)
                )

                // Stat cards grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8)
                ], spacing: 8) {
                    statCard(
                        icon: "checkmark.circle.fill",
                        label: "Tasks Completed",
                        value: "\(stats.tasksCompleted)",
                        color: CloudTheme.checkGreen
                    )
                    statCard(
                        icon: "plus.circle.fill",
                        label: "Tasks Created",
                        value: "\(stats.tasksCreated)",
                        color: CloudTheme.accentBlue
                    )
                    statCard(
                        icon: "note.text",
                        label: "Notes Created",
                        value: "\(stats.notesCreated)",
                        color: Color(hex: "#FFA726")
                    )
                    statCard(
                        icon: "folder.fill",
                        label: "Projects Added",
                        value: "\(stats.projectsCreated)",
                        color: CloudTheme.primaryBlue
                    )
                    statCard(
                        icon: "brain.head.profile",
                        label: "Brain Dumps",
                        value: "\(stats.brainDumpsRecorded)",
                        color: Color(hex: "#AB47BC")
                    )
                    statCard(
                        icon: "timer",
                        label: "Focus Sessions",
                        value: "\(stats.focusSessionsCompleted)",
                        color: CloudTheme.dangerRed
                    )
                }

                // Current state summary
                VStack(spacing: 6) {
                    HStack {
                        Text("Right Now")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(CloudTheme.accentBlue)
                        Spacer()
                    }

                    HStack(spacing: 8) {
                        liveStatPill(
                            label: "Active Tasks",
                            value: "\(dataStore.todos.filter { !$0.isCompleted }.count)",
                            color: CloudTheme.accentBlue
                        )
                        liveStatPill(
                            label: "Projects",
                            value: "\(dataStore.projects.count)",
                            color: CloudTheme.primaryBlue
                        )
                        liveStatPill(
                            label: "Notes",
                            value: "\(dataStore.notes.count)",
                            color: Color(hex: "#FFA726")
                        )
                        liveStatPill(
                            label: "Sessions",
                            value: "\(pomodoroTimer.completedSessions)",
                            color: CloudTheme.checkGreen
                        )
                    }
                }

                // Category breakdown
                if !dataStore.categories.isEmpty {
                    VStack(spacing: 6) {
                        HStack {
                            Text("Tasks by Category")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(CloudTheme.accentBlue)
                            Spacer()
                        }

                        ForEach(categoryBreakdown, id: \.0.id) { cat, count in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(cat.color)
                                    .frame(width: 8, height: 8)
                                Text(cat.name)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(CloudTheme.textPrimary)
                                Spacer()
                                Text("\(count)")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(cat.color)

                                // Mini bar
                                let maxCount = categoryBreakdown.map(\.1).max() ?? 1
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(cat.color.opacity(0.3))
                                    .frame(width: 50, height: 6)
                                    .overlay(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(cat.color)
                                            .frame(width: 50 * CGFloat(count) / CGFloat(max(1, maxCount)), height: 6)
                                    }
                            }
                        }
                    }
                    .padding(8)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(CloudTheme.borderBlue, lineWidth: 1)
                    )
                }

                // Streak info
                let completionRate = stats.tasksCreated > 0
                    ? Int(Double(stats.tasksCompleted) / Double(stats.tasksCreated) * 100)
                    : 0
                if stats.tasksCreated > 0 {
                    HStack {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(hex: "#FFA726"))
                        Text("Completion Rate: \(completionRate)%")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(CloudTheme.textPrimary)
                        Spacer()
                    }
                    .padding(8)
                    .background(Color(hex: "#FFA726").opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(2)
        }
    }

    // MARK: - Components

    private func productivityRing(totalActions: Int) -> some View {
        let cap = 100.0
        let progress = min(1.0, Double(totalActions) / cap)
        return ZStack {
            Circle()
                .stroke(CloudTheme.surfaceBlue, lineWidth: 5)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(CloudTheme.gradient, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(totalActions)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(CloudTheme.textPrimary)
        }
        .frame(width: 50, height: 50)
    }

    private func statCard(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundStyle(color)
                Spacer()
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(CloudTheme.textPrimary)
            }
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(CloudTheme.textSecondary)
                .lineLimit(1)
        }
        .padding(8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }

    private func liveStatPill(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 7, weight: .semibold))
                .foregroundStyle(CloudTheme.textPrimary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.4), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Category Breakdown

    private var categoryBreakdown: [(TaskCategory, Int)] {
        let activeTodos = dataStore.todos.filter { !$0.isCompleted }
        return dataStore.categories.compactMap { cat in
            let count = activeTodos.filter { $0.categoryID == cat.id }.count
            return count > 0 ? (cat, count) : nil
        }
        .sorted { $0.1 > $1.1 }
    }
}
