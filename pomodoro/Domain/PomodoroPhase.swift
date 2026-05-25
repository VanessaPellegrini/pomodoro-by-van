import SwiftUI

enum PomodoroPhase: String, Codable, CaseIterable, Identifiable {
    case work
    case shortBreak
    case longBreak

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .work: "Trabajo"
        case .shortBreak: "Descanso"
        case .longBreak: "Descanso largo"
        }
    }

    var systemImage: String {
        switch self {
        case .work: "flame.fill"
        case .shortBreak: "leaf.fill"
        case .longBreak: "bed.double.fill"
        }
    }

    var color: Color {
        switch self {
        case .work: .red
        case .shortBreak: .green
        case .longBreak: .blue
        }
    }
}
