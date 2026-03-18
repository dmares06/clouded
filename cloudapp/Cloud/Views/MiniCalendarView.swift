import SwiftUI

struct MiniCalendarView: View {
    let onSelectDate: (Date) -> Void
    let onDismiss: () -> Void

    @State private var displayedMonth: Date = Date()

    private let calendar = Calendar.current
    private let daySymbols = ["S", "M", "T", "W", "T", "F", "S"]

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    private var daysInMonth: [DateComponents] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth) else { return [] }
        return range.map { DateComponents(year: calendar.component(.year, from: displayedMonth),
                                           month: calendar.component(.month, from: displayedMonth),
                                           day: $0) }
    }

    private var firstWeekday: Int {
        let comps = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstDay = calendar.date(from: comps) else { return 0 }
        return (calendar.component(.weekday, from: firstDay) - calendar.firstWeekday + 7) % 7
    }

    var body: some View {
        VStack(spacing: 6) {
            // Header: month navigation
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(CloudTheme.accentBlue)
                    .contentShape(Rectangle())
                    .onTapGesture { shiftMonth(-1) }

                Spacer()

                Text(monthTitle)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(CloudTheme.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(CloudTheme.accentBlue)
                    .contentShape(Rectangle())
                    .onTapGesture { shiftMonth(1) }
            }

            // Weekday headers
            HStack(spacing: 0) {
                ForEach(daySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(CloudTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Day grid
            let days = daysInMonth
            let totalCells = firstWeekday + days.count
            let rows = (totalCells + 6) / 7

            VStack(spacing: 2) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<7, id: \.self) { col in
                            let index = row * 7 + col - firstWeekday
                            if index >= 0, index < days.count, let date = calendar.date(from: days[index]) {
                                dayCell(date: date, day: days[index].day ?? 0)
                            } else {
                                Color.clear
                                    .frame(maxWidth: .infinity, minHeight: 22)
                            }
                        }
                    }
                }
            }

            // Dismiss button
            Text("Cancel")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(CloudTheme.textSecondary)
                .contentShape(Rectangle())
                .onTapGesture { onDismiss() }
                .padding(.top, 2)
        }
        .padding(10)
        .frame(width: 190)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(CloudTheme.borderBlue, lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private func dayCell(date: Date, day: Int) -> some View {
        let isToday = calendar.isDateInToday(date)

        return Text("\(day)")
            .font(.system(size: 11, weight: isToday ? .bold : .medium))
            .foregroundStyle(isToday ? CloudTheme.textOnAccent : CloudTheme.textPrimary)
            .frame(maxWidth: .infinity, minHeight: 22)
            .background(
                isToday
                    ? AnyShape(Circle()).fill(CloudTheme.accentBlue).eraseToAnyView()
                    : AnyShape(Circle()).fill(Color.clear).eraseToAnyView()
            )
            .contentShape(Rectangle())
            .onTapGesture { onSelectDate(date) }
            .onHover { hovering in
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
    }

    private func shiftMonth(_ delta: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: delta, to: displayedMonth) {
            withAnimation(CloudTheme.quickAnimation) {
                displayedMonth = newMonth
            }
        }
    }
}

// MARK: - AnyShape helper

private struct AnyShape: Shape {
    private let builder: (CGRect) -> Path

    init<S: Shape>(_ shape: S) {
        builder = { rect in shape.path(in: rect) }
    }

    func path(in rect: CGRect) -> Path { builder(rect) }
}

private extension View {
    func eraseToAnyView() -> AnyView { AnyView(self) }
}
