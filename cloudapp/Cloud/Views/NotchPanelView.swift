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

    private let brainDumpWidth: CGFloat = 230
    private let brainDumpTabWidth: CGFloat = 26

    /// Ordered list of enabled notch widgets (preserves canonical order)
    private var orderedNotchWidgets: [String] {
        PanelManager.allNotchWidgetKeys.filter { panelManager.isNotchWidgetEnabled($0) }
    }

    private var showBrainDumpSidebar: Bool {
        !panelManager.isNotchWidgetEnabled("brainDump")
    }

    private var totalWidth: CGFloat {
        if !showBrainDumpSidebar {
            return CloudTheme.panelWidth
        }
        return brainDumpOpen
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

                // Dynamic widget grid
                GeometryReader { geo in
                    let pad: CGFloat = 8
                    let spacing: CGFloat = 6
                    let availableWidth = geo.size.width - pad * 2
                    let availableHeight = geo.size.height - pad * 2
                    let widgets = orderedNotchWidgets
                    let count = widgets.count

                    if count <= 4 {
                        // Single row, equal widths
                        let colWidth = (availableWidth - spacing * CGFloat(max(count - 1, 0))) / CGFloat(max(count, 1))
                        HStack(spacing: spacing) {
                            ForEach(widgets, id: \.self) { key in
                                sectionCard { notchWidgetView(for: key) }
                                    .frame(width: colWidth, height: availableHeight)
                                    .transition(.opacity.combined(with: .scale))
                            }
                        }
                        .padding(pad)
                    } else {
                        // Two rows
                        let topCount = Int(ceil(Double(count) / 2.0))
                        let topWidgets = Array(widgets.prefix(topCount))
                        let bottomWidgets = Array(widgets.dropFirst(topCount))
                        let rowSpacing: CGFloat = 6
                        let rowHeight = (availableHeight - rowSpacing) / 2

                        VStack(spacing: rowSpacing) {
                            HStack(spacing: spacing) {
                                let tw = (availableWidth - spacing * CGFloat(max(topWidgets.count - 1, 0))) / CGFloat(max(topWidgets.count, 1))
                                ForEach(topWidgets, id: \.self) { key in
                                    sectionCard { notchWidgetView(for: key) }
                                        .frame(width: tw, height: rowHeight)
                                        .transition(.opacity.combined(with: .scale))
                                }
                            }
                            HStack(spacing: spacing) {
                                let bw = (availableWidth - spacing * CGFloat(max(bottomWidgets.count - 1, 0))) / CGFloat(max(bottomWidgets.count, 1))
                                ForEach(bottomWidgets, id: \.self) { key in
                                    sectionCard { notchWidgetView(for: key) }
                                        .frame(width: bw, height: rowHeight)
                                        .transition(.opacity.combined(with: .scale))
                                }
                            }
                        }
                        .padding(pad)
                    }
                }
                .animation(CloudTheme.springAnimation, value: orderedNotchWidgets)

                } // end home tab
            }
            .frame(width: mainContentWidth)
            .clipped()

            // Brain Dump sidebar (hidden when Brain Dump is a notch widget)
            if showBrainDumpSidebar {
                Spacer().frame(width: 6)

                if brainDumpOpen {
                    brainDumpPanel
                } else {
                    brainDumpTab
                }
            }
        }
        .frame(width: totalWidth, height: CloudTheme.panelHeight)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: CloudTheme.cornerRadius))
        .shadow(color: CloudTheme.panelShadow, radius: 20, x: 0, y: 10)
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
                .padding(.top, 50)
                .padding(.leading, 8)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                .transition(.opacity)
                .zIndex(10)
            }
        }
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

    // MARK: - Notch Widget View

    @ViewBuilder
    private func notchWidgetView(for key: String) -> some View {
        switch key {
        case "tasks":
            TodoListView(dataStore: dataStore, datePickerTaskID: $datePickerTaskID)
        case "projects":
            ProjectsView(dataStore: dataStore)
        case "pomodoro":
            CompactPomodoroView(timer: pomodoroTimer)
        case "notes":
            NotesView(dataStore: dataStore)
        case "calendar":
            CompactUpNextView(calendarManager: calendarManager)
        case "brainDump":
            BrainDumpView(dataStore: dataStore)
        default:
            EmptyView()
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

    private static let notchWidgetLabels: [(key: String, label: String, icon: String)] = [
        ("tasks", "Tasks", "checklist"),
        ("projects", "Projects", "folder.fill"),
        ("pomodoro", "Pomodoro", "timer"),
        ("notes", "Notes", "note.text"),
        ("calendar", "Calendar", "calendar"),
        ("brainDump", "Brain Dump", "brain.head.profile")
    ]

    private static let desktopWidgetLabels: [(key: String, label: String, icon: String)] = [
        ("tasks", "Tasks", "checklist"),
        ("calendar", "Calendar", "calendar"),
        ("notes", "Notes", "note.text"),
        ("brainDump", "Brain Dump", "brain.head.profile"),
        ("projects", "Projects", "folder.fill")
    ]

    private var widgetPickerDropdown: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // NOTCH PANEL section
                Text("NOTCH PANEL")
                    .font(.system(size: 8, weight: .heavy))
                    .foregroundStyle(CloudTheme.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.top, 6)
                    .padding(.bottom, 4)

                ForEach(Self.notchWidgetLabels, id: \.key) { item in
                    let enabled = panelManager.isNotchWidgetEnabled(item.key)
                    let isLastOne = enabled && panelManager.enabledNotchWidgets.count <= 1
                    HStack(spacing: 6) {
                        Image(systemName: item.icon)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(enabled ? CloudTheme.accentBlue : CloudTheme.textSecondary)
                            .frame(width: 14)
                        Text(item.label)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(enabled ? CloudTheme.textPrimary : CloudTheme.textSecondary)
                        Spacer()
                        Image(systemName: enabled ? "minus.circle.fill" : "plus.circle.fill")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(enabled
                                ? (isLastOne ? CloudTheme.textSecondary.opacity(0.4) : Color.red.opacity(0.7))
                                : Color.green.opacity(0.7))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(enabled ? CloudTheme.accentBlue.opacity(0.06) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(CloudTheme.springAnimation) {
                            panelManager.toggleNotchWidget(item.key)
                        }
                    }
                }

                Divider()
                    .overlay(CloudTheme.borderBlue.opacity(0.4))
                    .padding(.vertical, 6)

                // DESKTOP WIDGETS section
                Text("DESKTOP WIDGETS")
                    .font(.system(size: 8, weight: .heavy))
                    .foregroundStyle(CloudTheme.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 4)

                ForEach(Self.desktopWidgetLabels, id: \.key) { item in
                    let enabled = panelManager.isWidgetEnabled(item.key)
                    HStack(spacing: 6) {
                        Image(systemName: item.icon)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(enabled ? CloudTheme.accentBlue : CloudTheme.textSecondary)
                            .frame(width: 14)
                        Text(item.label)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(enabled ? CloudTheme.textPrimary : CloudTheme.textSecondary)
                        Spacer()
                        Image(systemName: enabled ? "minus.circle.fill" : "plus.circle.fill")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(enabled ? Color.red.opacity(0.7) : Color.green.opacity(0.7))
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
        }
        .frame(width: 170, maxHeight: 320)
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
