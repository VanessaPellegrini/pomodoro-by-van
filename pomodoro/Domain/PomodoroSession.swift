import Foundation
import SwiftData

@Model
final class PomodoroSession {
    @Attribute(.unique) var id: UUID
    var startTime: Date
    var endTime: Date?
    var phase: String
    var duration: TimeInterval
    var completed: Bool
    var tagID: UUID?

    init(startTime: Date = .now, phase: PomodoroPhase, duration: TimeInterval, tagID: UUID? = nil) {
        self.id = UUID()
        self.startTime = startTime
        self.phase = phase.rawValue
        self.duration = duration
        self.completed = false
        self.tagID = tagID
    }

    var pomodoroPhase: PomodoroPhase {
        PomodoroPhase(rawValue: phase) ?? .work
    }

    func complete() {
        self.endTime = .now
        self.completed = true
    }
}
