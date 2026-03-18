import EventKit
import Foundation
import Combine
import AppKit

final class CalendarManager: ObservableObject {
    @Published private(set) var upcomingEvents: [CalendarEvent] = []
    @Published private(set) var authorizationStatus: EKAuthorizationStatus = .notDetermined

    private let eventStore = EKEventStore()
    private var refreshTimer: Timer?

    struct CalendarEvent: Identifiable {
        let id: String
        let title: String
        let startDate: Date
        let endDate: Date
        let calendarColor: NSColor
        let isAllDay: Bool

        var timeString: String {
            if isAllDay { return "All day" }
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: startDate)
        }

        var relativeTimeString: String {
            let now = Date()
            let interval = startDate.timeIntervalSince(now)

            if interval < 0 {
                return "Now"
            } else if interval < 3600 {
                let minutes = Int(interval / 60)
                return "in \(minutes)m"
            } else if interval < 86400 {
                let hours = Int(interval / 3600)
                return "in \(hours)h"
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                return formatter.string(from: startDate)
            }
        }
    }

    func requestAccess() {
        if #available(macOS 14.0, *) {
            eventStore.requestFullAccessToEvents { [weak self] granted, _ in
                DispatchQueue.main.async {
                    self?.authorizationStatus = granted ? .fullAccess : .denied
                    if granted {
                        self?.fetchUpcomingEvents()
                        self?.startAutoRefresh()
                    }
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { [weak self] granted, _ in
                DispatchQueue.main.async {
                    self?.authorizationStatus = granted ? .authorized : .denied
                    if granted {
                        self?.fetchUpcomingEvents()
                        self?.startAutoRefresh()
                    }
                }
            }
        }
    }

    func fetchUpcomingEvents() {
        let now = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now

        let predicate = eventStore.predicateForEvents(withStart: now, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate)

        upcomingEvents = events
            .sorted { $0.startDate < $1.startDate }
            .prefix(6)
            .map { event in
                CalendarEvent(
                    id: event.eventIdentifier,
                    title: event.title ?? "Untitled",
                    startDate: event.startDate,
                    endDate: event.endDate,
                    calendarColor: event.calendar.color,
                    isAllDay: event.isAllDay
                )
            }
    }

    /// Creates an all-day event on the given date. Returns the event identifier on success.
    func createAllDayEvent(title: String, date: Date) -> String? {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.isAllDay = true
        event.startDate = Calendar.current.startOfDay(for: date)
        event.endDate = Calendar.current.startOfDay(for: date)
        event.calendar = eventStore.defaultCalendarForNewEvents

        do {
            try eventStore.save(event, span: .thisEvent)
            fetchUpcomingEvents()
            return event.eventIdentifier
        } catch {
            print("CalendarManager: failed to create event – \(error)")
            return nil
        }
    }

    /// Removes a previously-created event by its identifier.
    func deleteEvent(identifier: String) {
        guard let event = eventStore.event(withIdentifier: identifier) else { return }
        do {
            try eventStore.remove(event, span: .thisEvent)
            fetchUpcomingEvents()
        } catch {
            print("CalendarManager: failed to delete event – \(error)")
        }
    }

    private func startAutoRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.fetchUpcomingEvents()
        }
    }
}
