import SwiftUI

struct PomodoroView: View {
    @ObservedObject var timer: PomodoroTimer

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle().stroke(CloudTheme.surfaceBlue, lineWidth: 8).frame(width: 160, height: 160)
                Circle()
                    .trim(from: 0, to: timer.progress)
                    .stroke(CloudTheme.gradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: timer.progress)
                VStack(spacing: 4) {
                    Text(timer.timeString)
                        .font(.system(size: 40, weight: .light, design: .rounded))
                        .foregroundStyle(CloudTheme.textPrimary)
                        .monospacedDigit()
                    Text(timer.isBreak ? "Break" : "Focus")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(timer.isBreak ? CloudTheme.checkGreen : CloudTheme.accentBlue)
                        .padding(.horizontal, 10).padding(.vertical, 3)
                        .background((timer.isBreak ? CloudTheme.checkGreen : CloudTheme.primaryBlue).opacity(0.12))
                        .clipShape(Capsule())
                }
            }
            HStack(spacing: 20) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(CloudTheme.textSecondary)
                    .frame(width: 40, height: 40).background(CloudTheme.surfaceBlue).clipShape(Circle())
                    .onTapGesture { timer.reset() }
                Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(CloudTheme.textOnAccent)
                    .frame(width: 52, height: 52).background(CloudTheme.gradient).clipShape(Circle())
                    .shadow(color: CloudTheme.cardShadow, radius: 6, x: 0, y: 3)
                    .onTapGesture { timer.toggleRunning() }
                Image(systemName: "forward.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(CloudTheme.textSecondary)
                    .frame(width: 40, height: 40).background(CloudTheme.surfaceBlue).clipShape(Circle())
                    .onTapGesture { timer.skip() }
            }
            Spacer()
        }
    }
}

// MARK: - Pomodoro Timer (persists state to UserDefaults)

final class PomodoroTimer: ObservableObject {
    @Published var remainingSeconds: Int {
        didSet { UserDefaults.standard.set(remainingSeconds, forKey: "pomo_remaining") }
    }
    @Published var isRunning = false
    @Published var isBreak: Bool {
        didSet { UserDefaults.standard.set(isBreak, forKey: "pomo_isBreak") }
    }
    @Published var completedSessions: Int {
        didSet { UserDefaults.standard.set(completedSessions, forKey: "pomo_sessions") }
    }

    // Callback for stat tracking
    var onFocusSessionCompleted: (() -> Void)?

    private var timer: Timer?
    private let focusDuration = 25 * 60
    private let breakDuration = 5 * 60

    // Timestamp when timer was last running, so we can account for time while panel was closed
    private var runStartDate: Date? {
        didSet {
            if let date = runStartDate {
                UserDefaults.standard.set(date.timeIntervalSince1970, forKey: "pomo_runStart")
            } else {
                UserDefaults.standard.removeObject(forKey: "pomo_runStart")
            }
        }
    }

    init() {
        let defaults = UserDefaults.standard
        let savedRemaining = defaults.integer(forKey: "pomo_remaining")
        self.isBreak = defaults.bool(forKey: "pomo_isBreak")
        self.completedSessions = defaults.integer(forKey: "pomo_sessions")
        self.remainingSeconds = savedRemaining > 0 ? savedRemaining : 25 * 60

        // Restore running state — account for elapsed time while panel was closed
        let runStartTimestamp = defaults.double(forKey: "pomo_runStart")
        if runStartTimestamp > 0 {
            let elapsed = Int(Date().timeIntervalSince1970 - runStartTimestamp)
            let newRemaining = self.remainingSeconds - elapsed
            if newRemaining > 0 {
                self.remainingSeconds = newRemaining
                // Auto-resume
                start()
            } else {
                // Timer would have completed while closed
                self.remainingSeconds = 0
                timerCompleted()
            }
        }
    }

    var totalDuration: Int { isBreak ? breakDuration : focusDuration }
    var progress: CGFloat { CGFloat(totalDuration - remainingSeconds) / CGFloat(totalDuration) }
    var focusMinutes: Int { completedSessions * 25 }

    var timeString: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    func toggleRunning() {
        if isRunning { pause() } else { start() }
    }

    func start() {
        isRunning = true
        runStartDate = Date().addingTimeInterval(-Double(totalDuration - remainingSeconds))
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
            } else {
                self.timerCompleted()
            }
        }
    }

    func pause() {
        isRunning = false
        runStartDate = nil
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        pause()
        remainingSeconds = isBreak ? breakDuration : focusDuration
    }

    func skip() {
        pause()
        if !isBreak { completedSessions += 1 }
        isBreak.toggle()
        remainingSeconds = isBreak ? breakDuration : focusDuration
    }

    private func timerCompleted() {
        pause()
        if !isBreak {
            completedSessions += 1
            onFocusSessionCompleted?()
        }
        isBreak.toggle()
        remainingSeconds = isBreak ? breakDuration : focusDuration
        sendNotification()
    }

    private func sendNotification() {
        let content = NSUserNotification()
        content.title = "Cloud"
        content.informativeText = isBreak ? "Focus session complete! Take a break." : "Break's over! Time to focus."
        content.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(content)
    }
}
