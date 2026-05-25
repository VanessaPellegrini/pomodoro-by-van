import Foundation
import SwiftData
import AudioToolbox

@MainActor
@Observable
final class TimerService {
    var phase: PomodoroPhase = .work
    var remainingSeconds: Int = 0
    var totalSeconds: Int = 0
    var isRunning: Bool = false
    var currentRound: Int = 1
    var selectedTag: Tag?

    var workDuration: Int
    var shortBreakDuration: Int
    var longBreakDuration: Int
    var roundsBeforeLongBreak: Int
    var autoStartBreaks: Bool
    var autoStartPomodoros: Bool
    var soundEnabled: Bool
    var notificationsEnabled: Bool

    @ObservationIgnored nonisolated(unsafe) private var timer: Timer?
    @ObservationIgnored private var targetDate: Date?
    @ObservationIgnored private let modelContext: ModelContext
    @ObservationIgnored private let notificationService = NotificationService.shared

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }

    var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        let defaults = UserDefaults.standard

        self.workDuration = defaults.object(forKey: "workDuration") as? Int ?? 25
        self.shortBreakDuration = defaults.object(forKey: "shortBreakDuration") as? Int ?? 5
        self.longBreakDuration = defaults.object(forKey: "longBreakDuration") as? Int ?? 15
        self.roundsBeforeLongBreak = defaults.object(forKey: "roundsBeforeLongBreak") as? Int ?? 4
        self.autoStartBreaks = defaults.object(forKey: "autoStartBreaks") as? Bool ?? false
        self.autoStartPomodoros = defaults.object(forKey: "autoStartPomodoros") as? Bool ?? false
        self.soundEnabled = defaults.object(forKey: "soundEnabled") as? Bool ?? true
        self.notificationsEnabled = defaults.object(forKey: "notificationsEnabled") as? Bool ?? true

        self.totalSeconds = workDuration * 60
        self.remainingSeconds = self.totalSeconds
    }

    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(workDuration, forKey: "workDuration")
        defaults.set(shortBreakDuration, forKey: "shortBreakDuration")
        defaults.set(longBreakDuration, forKey: "longBreakDuration")
        defaults.set(roundsBeforeLongBreak, forKey: "roundsBeforeLongBreak")
        defaults.set(autoStartBreaks, forKey: "autoStartBreaks")
        defaults.set(autoStartPomodoros, forKey: "autoStartPomodoros")
        defaults.set(soundEnabled, forKey: "soundEnabled")
        defaults.set(notificationsEnabled, forKey: "notificationsEnabled")
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        targetDate = Date().addingTimeInterval(Double(remainingSeconds))

        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        targetDate = nil
    }

    func reset() {
        pause()
        totalSeconds = durationFor(phase: phase)
        remainingSeconds = totalSeconds
    }

    func skip() {
        pause()
        completeCurrentPhase()
        advancePhase()
    }

    func updateDurations() {
        if !isRunning {
            totalSeconds = durationFor(phase: phase)
            remainingSeconds = totalSeconds
        }
    }

    private func tick() {
        guard let targetDate else { return }
        let remaining = Int(ceil(targetDate.timeIntervalSinceNow))

        if remaining <= 0 {
            remainingSeconds = 0
            completeCurrentPhase()
            advancePhase()
        } else {
            remainingSeconds = remaining
        }
    }

    private func completeCurrentPhase() {
        if phase == .work {
            let session = PomodoroSession(
                phase: .work,
                duration: Double(totalSeconds),
                tagID: selectedTag?.id
            )
            session.complete()
            modelContext.insert(session)
            try? modelContext.save()
        }

        if soundEnabled {
            AudioServicesPlaySystemSound(1007)
        }

        if notificationsEnabled {
            let title = phase == .work ? "Pomodoro completado" : "Descanso terminado"
            let body = phase == .work ? "Hora de un descanso" : "Hora de enfocarse"
            notificationService.scheduleNotification(title: title, body: body)
        }
    }

    private func advancePhase() {
        switch phase {
        case .work:
            if currentRound >= roundsBeforeLongBreak {
                phase = .longBreak
                currentRound = 1
            } else {
                phase = .shortBreak
            }
            if autoStartBreaks { start() }
        case .shortBreak:
            phase = .work
            currentRound += 1
            if autoStartPomodoros { start() }
        case .longBreak:
            phase = .work
            if autoStartPomodoros { start() }
        }

        totalSeconds = durationFor(phase: phase)
        remainingSeconds = totalSeconds
    }

    private func durationFor(phase: PomodoroPhase) -> Int {
        switch phase {
        case .work: return workDuration * 60
        case .shortBreak: return shortBreakDuration * 60
        case .longBreak: return longBreakDuration * 60
        }
    }

    deinit {
        timer?.invalidate()
    }
}
