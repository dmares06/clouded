import SwiftUI

struct UpNextView: View {
    @ObservedObject var calendarManager: CalendarManager

    var body: some View {
        VStack(spacing: CloudTheme.spacing) {
            if !isAuthorized {
                accessPrompt
            } else if calendarManager.upcomingEvents.isEmpty {
                emptyState
            } else {
                eventList
            }
        }
    }

    private var isAuthorized: Bool {
        calendarManager.authorizationStatus == .fullAccess
    }

    // MARK: - Access Prompt

    private var accessPrompt: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 40))
                .foregroundStyle(CloudTheme.gradient)

            Text("Calendar Access")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(CloudTheme.textPrimary)

            Text("Allow Cloud to show your upcoming events")
                .font(.system(size: 12))
                .foregroundStyle(CloudTheme.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                calendarManager.requestAccess()
            } label: {
                Text("Grant Access")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(CloudTheme.textOnAccent)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(CloudTheme.gradient)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }

    // MARK: - Event List

    private var eventList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 8) {
                // Header
                HStack {
                    Text("Today & Tomorrow")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(CloudTheme.textSecondary)
                    Spacer()
                    Button {
                        calendarManager.fetchUpcomingEvents()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 11))
                            .foregroundStyle(CloudTheme.accentBlue)
                    }
                    .buttonStyle(.plain)
                }

                ForEach(calendarManager.upcomingEvents) { event in
                    eventRow(event)
                }
            }
        }
        .frame(maxHeight: .infinity)
    }

    private func eventRow(_ event: CalendarManager.CalendarEvent) -> some View {
        HStack(spacing: 10) {
            // Calendar color indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(nsColor: event.calendarColor))
                .frame(width: 4, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(CloudTheme.textPrimary)
                    .lineLimit(1)

                Text(event.timeString)
                    .font(.system(size: 11))
                    .foregroundStyle(CloudTheme.textSecondary)
            }

            Spacer()

            Text(event.relativeTimeString)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(event.relativeTimeString == "Now" ? CloudTheme.accentBlue : CloudTheme.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    event.relativeTimeString == "Now"
                        ? CloudTheme.primaryBlue.opacity(0.15)
                        : CloudTheme.surfaceBlue
                )
                .clipShape(Capsule())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(CloudTheme.cloudWhite)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "sun.max")
                .font(.system(size: 40))
                .foregroundStyle(CloudTheme.gradient)
            Text("All clear!")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(CloudTheme.textPrimary)
            Text("No upcoming events")
                .font(.system(size: 12))
                .foregroundStyle(CloudTheme.textSecondary)
            Spacer()
        }
    }
}
