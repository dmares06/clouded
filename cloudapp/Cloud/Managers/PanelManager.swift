import AppKit
import SwiftUI

// MARK: - Custom Panel that accepts keyboard input

final class KeyablePanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
    override var acceptsFirstResponder: Bool { true }

    override func mouseDown(with event: NSEvent) {
        makeKey()
        super.mouseDown(with: event)
    }
}

final class KeyableWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

final class FirstClickHostingView<Content: View>: NSHostingView<Content> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}

enum SpotlightPosition: String {
    case top, bottom
}

final class PanelManager: ObservableObject {
    private var panel: KeyablePanel?
    private var spotlightWindow: NSWindow?
    private var spotlightView: SpotlightArchView?
    @Published var isVisible = false
    @Published var spotlightAtTop: Bool {
        didSet { UserDefaults.standard.set(spotlightAtTop ? "top" : "bottom", forKey: "spotlight_position") }
    }

    // Desktop widgets
    static let allWidgetKeys = ["tasks", "calendar", "notes", "brainDump", "projects"]
    private var widgetWindows: [String: NSWindow] = [:]
    @Published var enabledWidgets: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(enabledWidgets), forKey: "enabled_widgets")
        }
    }
    var widgetsVisible: Bool { !enabledWidgets.isEmpty }

    // Notch panel widgets
    static let allNotchWidgetKeys = ["tasks", "projects", "pomodoro", "notes", "calendar", "brainDump"]
    @Published var enabledNotchWidgets: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(enabledNotchWidgets), forKey: "enabled_notch_widgets")
        }
    }

    func toggleNotchWidget(_ key: String) {
        if enabledNotchWidgets.contains(key) {
            guard enabledNotchWidgets.count > 1 else { return }
            enabledNotchWidgets.remove(key)
        } else {
            enabledNotchWidgets.insert(key)
        }
    }

    func isNotchWidgetEnabled(_ key: String) -> Bool {
        enabledNotchWidgets.contains(key)
    }

    let dataStore = DataStore()
    let calendarManager = CalendarManager()
    let pomodoroTimer = PomodoroTimer()

    private let pillWidth: CGFloat = 120
    private let pillHeight: CGFloat = 18

    init() {
        let defaults = UserDefaults.standard
        if let saved = defaults.array(forKey: "enabled_widgets") as? [String] {
            self.enabledWidgets = Set(saved)
        } else {
            self.enabledWidgets = Set(PanelManager.allWidgetKeys)
            defaults.set(PanelManager.allWidgetKeys, forKey: "enabled_widgets")
        }

        let defaultNotch = ["tasks", "projects", "pomodoro", "notes", "calendar"]
        if let savedNotch = defaults.array(forKey: "enabled_notch_widgets") as? [String] {
            self.enabledNotchWidgets = Set(savedNotch)
        } else {
            self.enabledNotchWidgets = Set(defaultNotch)
            defaults.set(defaultNotch, forKey: "enabled_notch_widgets")
        }

        let posString = defaults.string(forKey: "spotlight_position") ?? "top"
        self.spotlightAtTop = (posString == "top")
    }

    func toggleWidget(_ key: String) {
        if enabledWidgets.contains(key) {
            enabledWidgets.remove(key)
            hideWidgetWindow(key)
        } else {
            enabledWidgets.insert(key)
            showWidgetWindow(key)
        }
        repositionWidgets()
    }

    func isWidgetEnabled(_ key: String) -> Bool {
        enabledWidgets.contains(key)
    }

    func setup() {
        pomodoroTimer.onFocusSessionCompleted = { [weak self] in
            self?.dataStore.recordFocusSession(minutes: 25)
        }
        createPanel()
        createSpotlightPill()
        createDesktopWidgets()
        showWidgets()

        // When Cloud loses focus, drop widgets behind other windows
        NotificationCenter.default.addObserver(
            forName: NSApplication.didResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self, self.widgetsVisible else { return }
            for (key, window) in self.widgetWindows where self.enabledWidgets.contains(key) {
                window.level = .init(rawValue: Int(CGWindowLevelForKey(.normalWindow)) - 1)
                window.orderBack(nil)
            }
        }

        // When Cloud gains focus, bring widgets back
        NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self, self.widgetsVisible else { return }
            for (key, window) in self.widgetWindows where self.enabledWidgets.contains(key) {
                window.level = .init(rawValue: Int(CGWindowLevelForKey(.normalWindow)))
                window.orderFront(nil)
            }
        }

        // Fallback: detect clicks outside our windows (LSUIElement apps may not get resign notifications)
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown]) { [weak self] event in
            guard let self = self, self.widgetsVisible else { return }
            let mouse = NSEvent.mouseLocation
            let inWidget = self.widgetWindows.values.contains { $0.frame.contains(mouse) }
            let inPanel = self.panel?.frame.contains(mouse) ?? false
            if !inWidget && !inPanel {
                for (key, window) in self.widgetWindows where self.enabledWidgets.contains(key) {
                    window.level = .init(rawValue: Int(CGWindowLevelForKey(.normalWindow)) - 1)
                    window.orderBack(nil)
                }
            }
        }
    }

    func togglePanel() {
        if isVisible {
            hidePanel()
        } else {
            showPanel()
        }
    }

    func showPanel() {
        guard let panel = panel, let screen = NSScreen.main else { return }

        let screenFrame = screen.frame
        let panelWidth = CloudTheme.panelWidth + 32
        let panelHeight = CloudTheme.panelHeight
        let panelX = screenFrame.midX - panelWidth / 2

        let panelY: CGFloat
        let startOffsetY: CGFloat
        if spotlightAtTop {
            panelY = screenFrame.maxY - panelHeight - 6
            startOffsetY = 14  // slides down from above
        } else {
            panelY = screenFrame.minY + 6
            startOffsetY = -14  // slides up from below
        }

        let finalFrame = NSRect(x: panelX, y: panelY, width: panelWidth, height: panelHeight)
        let startFrame = NSRect(x: panelX, y: panelY + startOffsetY, width: panelWidth, height: panelHeight)

        panel.setFrame(startFrame, display: false)
        panel.alphaValue = 0
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
            panel.animator().setFrame(finalFrame, display: true)
        }

        isVisible = true
        spotlightView?.setGlow(true)

        // Hide the pill so it doesn't cover the panel
        spotlightWindow?.orderOut(nil)
    }

    func hidePanel() {
        guard let panel = panel else { return }

        let slideOffset: CGFloat = spotlightAtTop ? 14 : -14
        let slideFrame = NSRect(
            x: panel.frame.origin.x,
            y: panel.frame.origin.y + slideOffset,
            width: panel.frame.width,
            height: panel.frame.height
        )

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.15
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0
            panel.animator().setFrame(slideFrame, display: true)
        }, completionHandler: { [weak self] in
            panel.orderOut(nil)
            self?.isVisible = false
            self?.spotlightView?.setGlow(false)

            // Bring the pill back
            self?.spotlightWindow?.orderFrontRegardless()
        })
    }

    // MARK: - Desktop Widgets

    func showWidgets() {
        for key in enabledWidgets {
            showWidgetWindow(key)
        }
        repositionWidgets()
    }

    func hideAllWidgets() {
        for (_, window) in widgetWindows {
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.2
                ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
                window.animator().alphaValue = 0
            }, completionHandler: {
                window.orderOut(nil)
            })
        }
        enabledWidgets.removeAll()
    }

    private func showWidgetWindow(_ key: String) {
        guard let w = widgetWindows[key] else { return }
        w.alphaValue = 0
        w.orderFront(nil)
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.3
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            w.animator().alphaValue = 1
        }
    }

    private func hideWidgetWindow(_ key: String) {
        guard let w = widgetWindows[key] else { return }
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.2
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            w.animator().alphaValue = 0
        }, completionHandler: {
            w.orderOut(nil)
        })
    }

    private static let widgetHeights: [String: CGFloat] = [
        "tasks": 220,
        "calendar": 160,
        "notes": 150,
        "brainDump": 160,
        "projects": 170
    ]

    func repositionWidgets() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let widgetWidth: CGFloat = 200
        let margin: CGFloat = 16
        let spacing: CGFloat = 10
        let x = screenFrame.minX + margin

        var currentY = screenFrame.maxY - margin

        for key in PanelManager.allWidgetKeys {
            guard enabledWidgets.contains(key), let window = widgetWindows[key] else { continue }
            let height = PanelManager.widgetHeights[key] ?? 160
            currentY -= height
            window.setFrame(NSRect(x: x, y: currentY, width: widgetWidth, height: height), display: true)
            currentY -= spacing
        }
    }

    private func createDesktopWidgets() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let widgetWidth: CGFloat = 200
        let margin: CGFloat = 16
        let x = screenFrame.minX + margin

        // Create all widget windows at a temporary position; repositionWidgets() will lay them out
        let tempFrame = NSRect(x: x, y: screenFrame.maxY - 220 - margin, width: widgetWidth, height: 220)

        widgetWindows["tasks"] = makeWidgetWindow(
            frame: tempFrame,
            content: DesktopTasksWidget(dataStore: dataStore)
        )
        widgetWindows["calendar"] = makeWidgetWindow(
            frame: tempFrame,
            content: DesktopCalendarWidget(calendarManager: calendarManager)
        )
        widgetWindows["notes"] = makeWidgetWindow(
            frame: tempFrame,
            content: DesktopNotesWidget(dataStore: dataStore)
        )
        widgetWindows["brainDump"] = makeWidgetWindow(
            frame: tempFrame,
            content: DesktopBrainDumpWidget(dataStore: dataStore)
        )
        widgetWindows["projects"] = makeWidgetWindow(
            frame: tempFrame,
            content: DesktopProjectsWidget(dataStore: dataStore)
        )
    }

    private func makeWidgetWindow<Content: View>(frame: NSRect, content: Content) -> NSWindow {
        let window = KeyableWindow(
            contentRect: frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.normalWindow)))
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .managed]
        window.ignoresMouseEvents = false
        window.hasShadow = true
        window.isMovableByWindowBackground = true
        window.hidesOnDeactivate = false

        let hostingView = FirstClickHostingView(rootView: content)
        window.contentView = hostingView
        return window
    }

    // MARK: - Main Panel

    private func createPanel() {
        let contentView = NotchPanelView(
            dataStore: dataStore,
            calendarManager: calendarManager,
            pomodoroTimer: pomodoroTimer,
            panelManager: self,
            onClose: { [weak self] in self?.hidePanel() }
        )

        let hostingView = FirstClickHostingView(rootView: contentView)

        let panel = KeyablePanel(
            contentRect: NSRect(x: 0, y: 0, width: CloudTheme.panelWidth + 32, height: CloudTheme.panelHeight),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.isMovable = false
        panel.contentView = hostingView
        panel.hidesOnDeactivate = false
        panel.becomesKeyOnlyIfNeeded = false

        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            guard let self = self, self.isVisible else { return }
            if let panel = self.panel {
                let mouse = NSEvent.mouseLocation
                if !panel.frame.contains(mouse) {
                    self.hidePanel()
                }
            }
        }

        self.panel = panel
    }

    // MARK: - Spotlight Pill

    private func createSpotlightPill() {
        guard let screen = NSScreen.main else { return }

        let position: SpotlightPosition = spotlightAtTop ? .top : .bottom
        let screenFrame = screen.frame
        let visibleFrame = screen.visibleFrame
        let x = screenFrame.midX - pillWidth / 2
        let y: CGFloat
        if position == .top {
            y = visibleFrame.maxY - pillHeight + 6  // peeks below menu bar
        } else {
            y = screenFrame.minY - 6  // mostly hidden below screen bottom
        }

        let window = NSWindow(
            contentRect: NSRect(x: x, y: y, width: pillWidth, height: pillHeight),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .screenSaver
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        window.ignoresMouseEvents = false
        window.hasShadow = false

        let pillView = SpotlightArchView(
            position: position,
            onHoverTrigger: { [weak self] in
                guard let self = self, !self.isVisible else { return }
                self.showPanel()
            },
            onRightClick: { [weak self] in
                self?.showSpotlightContextMenu()
            }
        )

        window.contentView = pillView
        window.orderFrontRegardless()

        self.spotlightWindow = window
        self.spotlightView = pillView
    }

    private func showSpotlightContextMenu() {
        let menu = NSMenu()
        let title = spotlightAtTop ? "Move to Bottom" : "Move to Top"
        let item = NSMenuItem(title: title, action: #selector(moveSpotlightAction), keyEquivalent: "")
        item.target = self
        menu.addItem(item)

        if let window = spotlightWindow {
            let location = NSPoint(x: window.frame.midX, y: window.frame.midY)
            menu.popUp(positioning: nil, at: window.convertPoint(fromScreen: location), in: spotlightView)
        }
    }

    @objc private func moveSpotlightAction() {
        spotlightAtTop.toggle()

        // Remove old spotlight and recreate
        spotlightWindow?.orderOut(nil)
        spotlightWindow = nil
        spotlightView = nil
        createSpotlightPill()
    }
}

// MARK: - Spotlight Arch View

final class SpotlightArchView: NSView {
    private let position: SpotlightPosition
    private var onHoverTrigger: () -> Void
    private var onRightClick: () -> Void
    private var trackingArea: NSTrackingArea?
    private var hoverTimer: Timer?
    private var glowing = false

    private let archLayer = CAShapeLayer()
    private let glowLayer = CAShapeLayer()
    private let labelLayer = CATextLayer()

    init(position: SpotlightPosition = .top, onHoverTrigger: @escaping () -> Void, onRightClick: @escaping () -> Void = {}) {
        self.position = position
        self.onHoverTrigger = onHoverTrigger
        self.onRightClick = onRightClick
        super.init(frame: .zero)
        wantsLayer = true
        layer?.masksToBounds = false
        setupLayers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    private func setupLayers() {
        guard let layer = self.layer else { return }

        // Keep a transparent outer layer for geometry consistency without a visible halo.
        glowLayer.fillColor = NSColor.clear.cgColor
        glowLayer.strokeColor = nil
        layer.addSublayer(glowLayer)

        // Main arch shape
        archLayer.fillColor = NSColor(red: 0.02, green: 0.40, blue: 0.75, alpha: 1.0).cgColor
        archLayer.strokeColor = nil
        layer.addSublayer(archLayer)

        // "Cloud" label
        labelLayer.string = "Cloud"
        labelLayer.font = NSFont.boldSystemFont(ofSize: 8)
        labelLayer.fontSize = 8
        labelLayer.foregroundColor = NSColor.white.withAlphaComponent(0.8).cgColor
        labelLayer.alignmentMode = .center
        labelLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0
        layer.addSublayer(labelLayer)
    }

    private func archPath(in rect: NSRect, inset: CGFloat = 0) -> CGPath {
        let path = CGMutablePath()
        if position == .top {
            // Bottom half of ellipse — downward arch (original behavior)
            let archRect = CGRect(
                x: rect.minX + inset,
                y: rect.minY - rect.height + inset,
                width: rect.width - inset * 2,
                height: rect.height * 2 - inset * 2
            )
            path.addEllipse(in: archRect)
        } else {
            // Top half of ellipse — upward arch
            let archRect = CGRect(
                x: rect.minX + inset,
                y: rect.minY - inset,
                width: rect.width - inset * 2,
                height: rect.height * 2 - inset * 2
            )
            path.addEllipse(in: archRect)
        }
        return path
    }

    override func layout() {
        super.layout()
        let rect = bounds

        // Glow — slightly larger
        let glowRect = rect.insetBy(dx: -4, dy: -2)
        glowLayer.path = archPath(in: glowRect)
        glowLayer.frame = CGRect(x: -4, y: -2, width: glowRect.width, height: glowRect.height)

        // Main arch
        archLayer.path = archPath(in: rect)
        archLayer.frame = rect

        // "Cloud" label — centered in the visible arch area
        let labelHeight: CGFloat = 10
        let labelY: CGFloat
        if position == .top {
            labelY = rect.minY + (rect.height - labelHeight) / 2 - 1
        } else {
            labelY = rect.minY + (rect.height - labelHeight) / 2 + 1
        }
        labelLayer.frame = CGRect(x: rect.minX, y: labelY, width: rect.width, height: labelHeight)
    }

    func setGlow(_ on: Bool) {
        glowing = on
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        archLayer.fillColor = on
            ? NSColor(red: 0.10, green: 0.50, blue: 0.90, alpha: 1.0).cgColor
            : NSColor(red: 0.02, green: 0.40, blue: 0.75, alpha: 1.0).cgColor
        glowLayer.fillColor = NSColor.clear.cgColor
        CATransaction.commit()
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let existing = trackingArea {
            removeTrackingArea(existing)
        }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        trackingArea = area
    }

    override func mouseEntered(with event: NSEvent) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.15)
        archLayer.fillColor = NSColor(red: 0.10, green: 0.55, blue: 0.95, alpha: 1.0).cgColor
        glowLayer.fillColor = NSColor.clear.cgColor
        CATransaction.commit()

        hoverTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { [weak self] _ in
            self?.onHoverTrigger()
        }
    }

    override func mouseExited(with event: NSEvent) {
        hoverTimer?.invalidate()
        hoverTimer = nil

        if !glowing {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.2)
            archLayer.fillColor = NSColor(red: 0.02, green: 0.40, blue: 0.75, alpha: 1.0).cgColor
            glowLayer.fillColor = NSColor.clear.cgColor
            CATransaction.commit()
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        onRightClick()
    }
}
