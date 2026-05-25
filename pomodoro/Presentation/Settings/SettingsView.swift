import SwiftUI

struct SettingsView: View {
    @Bindable var timerService: TimerService

    var body: some View {
        NavigationStack {
            Form {
                timerSection
                automationSection
                generalSection
                tagsSection
            }
            .navigationTitle("Configuracion")
        }
    }

    private var timerSection: some View {
        Section("Timer") {
            Stepper("Trabajo: \(timerService.workDuration) min", value: $timerService.workDuration, in: 1...60)
                .onChange(of: timerService.workDuration) {
                    timerService.saveSettings()
                    timerService.updateDurations()
                }

            Stepper("Descanso corto: \(timerService.shortBreakDuration) min", value: $timerService.shortBreakDuration, in: 1...30)
                .onChange(of: timerService.shortBreakDuration) {
                    timerService.saveSettings()
                }

            Stepper("Descanso largo: \(timerService.longBreakDuration) min", value: $timerService.longBreakDuration, in: 1...60)
                .onChange(of: timerService.longBreakDuration) {
                    timerService.saveSettings()
                }

            Stepper("Rondas: \(timerService.roundsBeforeLongBreak)", value: $timerService.roundsBeforeLongBreak, in: 1...10)
                .onChange(of: timerService.roundsBeforeLongBreak) {
                    timerService.saveSettings()
                }
        }
    }

    private var automationSection: some View {
        Section("Automatico") {
            Toggle("Iniciar descansos", isOn: $timerService.autoStartBreaks)
                .onChange(of: timerService.autoStartBreaks) {
                    timerService.saveSettings()
                }

            Toggle("Iniciar pomodoros", isOn: $timerService.autoStartPomodoros)
                .onChange(of: timerService.autoStartPomodoros) {
                    timerService.saveSettings()
                }
        }
    }

    private var generalSection: some View {
        Section("General") {
            Toggle("Sonidos", isOn: $timerService.soundEnabled)
                .onChange(of: timerService.soundEnabled) {
                    timerService.saveSettings()
                }

            Toggle("Notificaciones", isOn: $timerService.notificationsEnabled)
                .onChange(of: timerService.notificationsEnabled) {
                    timerService.saveSettings()
                    if timerService.notificationsEnabled {
                        Task {
                            _ = await NotificationService.shared.requestPermission()
                        }
                    }
                }
        }
    }

    private var tagsSection: some View {
        Section {
            NavigationLink("Gestionar etiquetas") {
                TagsManagementView()
            }
        }
    }
}
