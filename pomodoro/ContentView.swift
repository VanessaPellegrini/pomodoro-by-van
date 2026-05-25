import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var timerService: TimerService?

    var body: some View {
        Group {
            if let timerService {
                TabView {
                    TimerView(timerService: timerService)
                        .tabItem {
                            Label("Timer", systemImage: "timer")
                        }

                    HistoryView()
                        .tabItem {
                            Label("Historial", systemImage: "clock.arrow.circlepath")
                        }

                    StatisticsView()
                        .tabItem {
                            Label("Estadisticas", systemImage: "chart.bar.fill")
                        }

                    SettingsView(timerService: timerService)
                        .tabItem {
                            Label("Ajustes", systemImage: "gearshape")
                        }
                }
                .tint(.red)
            }
        }
        .onAppear {
            if timerService == nil {
                timerService = TimerService(modelContext: modelContext)
            }
        }
    }
}
