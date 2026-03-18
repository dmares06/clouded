import SwiftUI

struct NotchPanelView: View {
    @ObservedObject var dataStore: DataStore
    @ObservedObject var calendarManager: CalendarManager
    @ObservedObject var pomodoroTimer: PomodoroTimer
    @ObservedObject var panelManager: PanelManager
    var onClose: () -> Void

    @State private var brainDumpOpen = false
    @State private var activeTab: PanelTab = .home
    @State private var datePickerTaskID: UUID?
    @State private var showWidgetPicker = false

    enum PanelTab {
        case home, stats
    }

    // Only tasks vs projects proportion — right column is fixed
    @AppStorage("col_split") private var tasksSplit: Double = 0.50

    // Resizable right-column row heights (proportions)
    @AppStorage("row_pomo") private var pomoHeight: Double = 0.28
    @AppStorage("row_notes") private var notesHeight: Double = 0.40

    // Track drag start values for proper delta handling
    @State private var dragStartTasksSplit: Double?
    @State private var dragStartPomoHeight: Double?
    @State private var dragStartNotesHeight: Double?

    private let brainDumpWidth: CGFloat = 230
    private let brainDumpTabWidth: CGFloat = 26
    private let rightColumnWidth: CGFloat = 180

    private var totalWidth: CGFloat {
        brainDumpOpen
            ? CloudTheme.panelWidth + brainDumpWidth + 1
            : CloudTheme.panelWidth + brainDumpTabWidth + 6
    }

    private var mainContentWidth: CGFloat {
        CloudTheme.panelWidth
    }

    var body: some View {
        HStack(spacing: 0) {
            // Main content
            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 12)
                    .padding(.top, 10)
                    .padding(.bottom, 6)

                Divider().overlay(CloudTheme.borderBlue.opacity(0.4))

                if activeTab == .stats {
                    StatsView(dataStore: dataStore, pomodoroTimer: pomodoroTimer)
                        .padding(12)
                        .transition(.opacity)
                } else {

                // Two-zone layout: left (tasks+projects resizable) | right (fixed timer/notes/calendar)
                GeometryReader { geo in
                    let pad: CGFloat = 8
                    let availableWidth = geo.size.width - pad * 2
                    let availableHeight = geo.size.height - pad * 2
                    let handleWidth: CGFloat = 6

                    // Left zone = everything minus right column and handle
                    let leftZoneWidth = availableWidth - rightColumnWidth - handleWidth
                    let tw = leftZoneWidth * tasksSplit
                    let pw = leftZoneWidth * (1 - tasksSplit)

                    HStack(spacing: 0) {
                        // --- Left zone: Tasks + Projects ---
                        HStack(spacing: 0) {
                            sectionCard { TodoListView(dataStore: dataStore, datePickerTaskID: $datePickerTaskID) }
                                .frame(width: tw, height: availableHeight)

                            // Drag handle between tasks and projects
                            dragHandle(horizontal: true,
                                onDrag: { delta in
                                    if dragStartTasksSplit == nil { dragStartTasksSplit = tasksSplit }
                                    let pct = delta / leftZoneWidth
                                    tasksSplit = max(0.25, min(0.75, (dragStartTasksSplit ?? tasksSplit) + pct))
                                },
                                onEnd: { dragStartTasksSplit = nil }
                            )

                            sectionCard { ProjectsView(dataStore: dataStore) }
                                .frame(width: pw, height: availableHeight)
                        }
                        .frame(width: leftZoneWidth, height: availableHeight)
                        .clipped()
                        .overlay(alignment: .topLeading) {
                            if datePickerTaskID != nil {
                                MiniCalendarView(
                                    onSelectDate: { date in
                                        if let taskID = datePickerTaskID,
                                           let task = dataStore.todos.first(where: { $0.id == taskID }) {
                                            dataStore.setTaskDueDate(task, date: date, calendarManager: calendarManager)
                                        }
                                        withAnimation(CloudTheme.springAnimation) {
                                            datePickerTaskID = nil
                                        }
                                    },
                                    onDismiss: {
                                        withAnimation(CloudTheme.springAnimation) {
                                            datePickerTaskID = nil
                                        }
                                    }
                                )
                                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                                .transition(.opacity)
                                .zIndex(10)
                            }
                        }

                        Spacer().frame(width: handleWidth)

                        // --- Right zone: Timer / Notes / Up Next ---
                        VStack(spacing: 4) {
                            let ph = availableHeight * pomoHeight
                            let nh = availableHeight * notesHeight
                            let uh = max(40, availableHeight - ph - nh - 16)

                            sectionCard { CompactPomodoroView(timer: pomodoroTimer) }
                                .frame(height: ph)

                            dragHandle(horizontal: false,
                                onDrag: { delta in
                                    if dragStartPomoHeight == nil { dragStartPomoHeight = pomoHeight }
                                    let pct = delta / availableHeight
                                    let newPomo = max(0.15, min(0.50, (dragStartPomoHeight ?? pomoHeight) + pct))
                                    if newPomo + notesHeight < 0.85 {
                                        pomoHeight = newPomo
                                    }
                                },
                                onEnd: { dragStartPomoHeight = nil }
                            )

                            sectionCard { NotesView(dataStore: dataStore) }
                                .frame(height: nh)

                            dragHandle(horizontal: false,
                                onDrag: { delta in
                                    if dragStartNotesHeight == nil { dragStartNotesHeight = notesHeight }
                                    let pct = delta / availableHeight
                                    let newNotes = max(0.15, min(0.60, (dragStartNotesHeight ?? notesHeight) + pct))
                                    if pomoHeight + newNotes < 0.85 {
                                        notesHeight = newNotes
                                    }
                                },
                                onEnd: { dragStartNotesHeight = nil }
                            )

                            sectionCard { CompactUpNextView(calendarManager: calendarManager) }
                                .frame(height: uh)
                        }
                        .frame(width: rightColumnWidth, height: availableHeight)
                    }
                    .padding(pad)
                }

                } // end home tab
            }
            .frame(width: mainContentWidth)
            .clipped()

            // Spacer between main content and brain dump
            Spacer().frame(width: 6)

            // Brain Dump
            if brainDumpOpen {
                brainDumpPanel
            } else {
                brainDumpTab
            }
        }
        .frame(width: totalWidth, height: CloudTheme.panelHeight)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: CloudTheme.cornerRadius))
        .shadow(color: CloudTheme.panelShadow, radius: 20, x: 0, y: 10)
        .animation(CloudTheme.springAnimation, value: brainDumpOpen)
        .onAppear { calendarManager.requestAccess() }
        .overlay(
            Group {
                if showWidgetPicker {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(CloudTheme.quickAnimation) {
                                showWidgetPicker = false
                            }
                        }
                }
            }
        )
    }

    // MARK: - Brain Dump Panel

    private var brainDumpPanel: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(CloudTheme.gradient)
                Text("Brain Dump")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(CloudTheme.accentBlue)
                Spacer()
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(CloudTheme.textSecondary)
                    .onTapGesture {
                        withAnimation(CloudTheme.springAnimation) {
                            brainDumpOpen = false
                        }
                    }
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
            .padding(.bottom, 4)

            BrainDumpView(dataStore: dataStore)
                .padding(.horizontal, 10)
                .padding(.bottom, 8)
        }
        .frame(width: brainDumpWidth)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(CloudTheme.borderBlue, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.vertical, 6)
        .padding(.trailing, 4)
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }

    // MARK: - Drag Handle

    private func dragHandle(
        horizontal: Bool,
        onDrag: @escaping (CGFloat) -> Void,
        onEnd: @escaping () -> Void = {}
    ) -> some View {
        let size: CGFloat = 10
        return ZStack {
            Rectangle()
                .fill(Color.clear)
            RoundedRectangle(cornerRadius: 1)
                .fill(CloudTheme.borderBlue.opacity(0.5))
                .frame(width: horizontal ? 2 : 20, height: horizontal ? 20 : 2)
        }
        .frame(width: horizontal ? size : nil, height: horizontal ? nil : size)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 1)
                .onChanged { value in
                    let delta = horizontal ? value.translation.width : value.translation.height
                    onDrag(delta)
                }
                .onEnded { _ in onEnd() }
        )
        .onHover { hovering in
            if hovering {
                if horizontal {
                    NSCursor.resizeLeftRight.push()
                } else {
                    NSCursor.resizeUpDown.push()
                }
            } else {
                NSCursor.pop()
            }
        }
    }

    // MARK: - Brain Dump Tab

    private var brainDumpTab: some View {
        VStack(spacing: 4) {
            Spacer()
            Image(systemName: "brain.head.profile")
                .font(.system(size: 12))
                .foregroundStyle(CloudTheme.gradient)
            Text("B").font(.system(size: 8, weight: .bold)).foregroundStyle(CloudTheme.accentBlue)
            Text("R").font(.system(size: 8, weight: .bold)).foregroundStyle(CloudTheme.accentBlue)
            Text("A").font(.system(size: 8, weight: .bold)).foregroundStyle(CloudTheme.accentBlue)
            Text("I").font(.system(size: 8, weight: .bold)).foregroundStyle(CloudTheme.accentBlue)
            Text("N").font(.system(size: 8, weight: .bold)).foregroundStyle(CloudTheme.accentBlue)
            Image(systemName: "mic.fill")
                .font(.system(size: 9))
                .foregroundStyle(CloudTheme.accentBlue)
            Spacer()
        }
        .frame(width: brainDumpTabWidth)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(CloudTheme.borderBlue, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .padding(.vertical, 6)
        .padding(.trailing, 3)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(CloudTheme.springAnimation) { brainDumpOpen = true }
        }
        .onHover { hovering in
            if hovering && !brainDumpOpen {
                withAnimation(CloudTheme.springAnimation) { brainDumpOpen = true }
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "cloud.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(CloudTheme.gradient)
            Text("Cloud")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(CloudTheme.textPrimary)

            // Tab pills
            HStack(spacing: 2) {
                tabPill("Home", icon: "house.fill", tab: .home)
                tabPill("Stats", icon: "chart.bar.fill", tab: .stats)
            }
            .padding(2)
            .background(CloudTheme.borderBlue.opacity(0.3))
            .clipShape(Capsule())

            Spacer()

            let activeCount = dataStore.todos.filter { !$0.isCompleted }.count
            let projectTaskCount = dataStore.projects.reduce(0) { $0 + $1.activeCount }
            if activeCount + projectTaskCount > 0 {
                Text("\(activeCount + projectTaskCount) tasks")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(CloudTheme.textSecondary)
            }

            // Desktop widgets picker
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 3) {
                    Image(systemName: "sidebar.squares.left")
                        .font(.system(size: 10, weight: .medium))
                    Text("Widgets")
                        .font(.system(size: 9, weight: .semibold))
                    Image(systemName: showWidgetPicker ? "chevron.up" : "chevron.down")
                        .font(.system(size: 7, weight: .bold))
                }
                .foregroundStyle(panelManager.widgetsVisible ? CloudTheme.accentBlue : CloudTheme.textSecondary)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(panelManager.widgetsVisible ? CloudTheme.accentBlue.opacity(0.12) : CloudTheme.borderBlue.opacity(0.3))
                .clipShape(Capsule())
                .onTapGesture {
                    withAnimation(CloudTheme.quickAnimation) {
                        showWidgetPicker.toggle()
                    }
                }

                if showWidgetPicker {
                    widgetPickerDropdown
                        .offset(y: 26)
                        .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .topTrailing)))
                }
            }
            .zIndex(10)

            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 13))
                .foregroundStyle(CloudTheme.textSecondary)
                .onTapGesture { onClose() }
        }
    }

    private func tabPill(_ label: String, icon: String, tab: PanelTab) -> some View {
        let isActive = activeTab == tab
        return HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
            Text(label)
                .font(.system(size: 9, weight: .bold))
        }
        .foregroundStyle(isActive ? CloudTheme.textOnAccent : CloudTheme.textSecondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isActive ? CloudTheme.accentBlue : Color.clear)
        .clipShape(Capsule())
        .contentShape(Capsule())
        .onTapGesture {
            withAnimation(CloudTheme.quickAnimation) {
                activeTab = tab
            }
        }
    }

    // MARK: - Widget Picker Dropdown

    private static let widgetLabels: [(key: String, label: String, icon: String)] = [
        ("tasks", "Tasks", "checklist"),
        ("calendar", "Calendar", "calendar"),
        ("notes", "Notes", "note.text"),
        ("brainDump", "Brain Dump", "brain.head.profile"),
        ("projects", "Projects", "folder.fill")
    ]

    private var widgetPickerDropdown: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(Self.widgetLabels, id: \.key) { item in
                let enabled = panelManager.isWidgetEnabled(item.key)
                HStack(spacing: 6) {
                    Image(systemName: enabled ? "checkmark.square.fill" : "square")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(enabled ? CloudTheme.accentBlue : CloudTheme.textSecondary)
                    Image(systemName: item.icon)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(enabled ? CloudTheme.accentBlue : CloudTheme.textSecondary)
                        .frame(width: 14)
                    Text(item.label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(enabled ? CloudTheme.textPrimary : CloudTheme.textSecondary)
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(enabled ? CloudTheme.accentBlue.opacity(0.06) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .contentShape(Rectangle())
                .onTapGesture {
                    panelManager.toggleWidget(item.key)
                }
            }
        }
        .padding(6)
        .frame(width: 150)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(CloudTheme.borderBlue, lineWidth: 1)
        )
    }

    // MARK: - Section Card (light blue tinted)

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: CloudTheme.smallCorner)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CloudTheme.smallCorner)
                    .stroke(CloudTheme.borderBlue, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: CloudTheme.smallCorner))
    }
}

// MARK: - Compact Pomodoro (shared timer)

struct CompactPomodoroView: View {
    @ObservedObject var timer: PomodoroTimer

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                ZStack {
                    Circle().stroke(CloudTheme.borderBlue, lineWidth: 3)
                    Circle()
                        .trim(from: 0, to: timer.progress)
                        .stroke(CloudTheme.gradient, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: timer.progress)
                }
                .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 0) {
                    Text(timer.timeString)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(CloudTheme.textPrimary)
                        .monospacedDigit()
                    Text(timer.isBreak ? "Break" : "Focus")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(timer.isBreak ? CloudTheme.checkGreen : CloudTheme.accentBlue)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(CloudTheme.accentBlue)
                        .frame(width: 22, height: 22)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(CloudTheme.borderBlue, lineWidth: 1))
                        .onTapGesture { timer.reset() }

                    Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(CloudTheme.textOnAccent)
                        .frame(width: 26, height: 26)
                        .background(CloudTheme.gradient)
                        .clipShape(Circle())
                        .onTapGesture { timer.toggleRunning() }

                    Image(systemName: "forward.fill")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(CloudTheme.accentBlue)
                        .frame(width: 22, height: 22)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(CloudTheme.borderBlue, lineWidth: 1))
                        .onTapGesture { timer.skip() }
                }
            }
        }
    }
}

// MARK: - Compact Up Next

struct CompactUpNextView: View {
    @ObservedObject var calendarManager: CalendarManager

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(CloudTheme.accentBlue)
                Text("Up Next")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(CloudTheme.accentBlue)
                Spacer()
                if !isAuthorized {
                    Text("Allow")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(CloudTheme.accentBlue)
                        .onTapGesture { calendarManager.requestAccess() }
                }
            }
            if isAuthorized {
                if calendarManager.upcomingEvents.isEmpty {
                    Text("No upcoming events")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(CloudTheme.textSecondary)
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 3) {
                            ForEach(calendarManager.upcomingEvents.prefix(3)) { event in
                                HStack(spacing: 5) {
                                    RoundedRectangle(cornerRadius: 1.5)
                                        .fill(Color(nsColor: event.calendarColor))
                                        .frame(width: 3, height: 18)
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(event.title)
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundStyle(CloudTheme.textPrimary)
                                            .lineLimit(1)
                                        Text(event.timeString)
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundStyle(CloudTheme.textSecondary)
                                    }
                                    Spacer()
                                    Text(event.relativeTimeString)
                                        .font(.system(size: 9, weight: .semibold))
                                        .foregroundStyle(CloudTheme.accentBlue)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var isAuthorized: Bool {
        calendarManager.authorizationStatus == .fullAccess
    }
}

// MARK: - Visual Effect Background

struct VisualEffectBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .hudWindow
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
