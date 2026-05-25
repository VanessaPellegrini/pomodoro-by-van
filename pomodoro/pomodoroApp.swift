import SwiftUI
import SwiftData

@main
struct pomodoroApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [PomodoroSession.self, Tag.self])
    }
}
