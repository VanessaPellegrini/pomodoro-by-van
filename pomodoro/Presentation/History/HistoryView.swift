import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \PomodoroSession.startTime, order: .reverse) private var sessions: [PomodoroSession]
    @Query(sort: \Tag.name) private var tags: [Tag]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    ContentUnavailableView {
                        Label("Sin sesiones", systemImage: "clock.badge.questionmark")
                    } description: {
                        Text("Completa tu primer pomodoro para verlo aqui")
                    }
                } else {
                    List {
                        ForEach(groupedByDate) { group in
                            Section(group.label) {
                                ForEach(group.sessions, id: \.id) { session in
                                    sessionRow(session)
                                }
                                .onDelete { offsets in
                                    for index in offsets {
                                        modelContext.delete(group.sessions[index])
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Historial")
        }
    }

    private func sessionRow(_ session: PomodoroSession) -> some View {
        HStack(spacing: 12) {
            Image(systemName: session.pomodoroPhase.systemImage)
                .foregroundStyle(session.pomodoroPhase.color)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(session.pomodoroPhase.displayName)
                    .font(.subheadline.weight(.medium))

                HStack(spacing: 8) {
                    Text(session.startTime, style: .time)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let tagID = session.tagID,
                       let tag = tags.first(where: { $0.id == tagID }) {
                        Text(tag.name)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(tag.color.opacity(0.15))
                            .foregroundStyle(tag.color)
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()

            Text(session.durationFormatted)
                .font(.caption)
                .foregroundStyle(.secondary)

            if session.completed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }

    private var groupedByDate: [DateGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.startTime)
        }

        return grouped
            .map { date, sessions in
                let label: String
                if calendar.isDateInToday(date) {
                    label = "Hoy"
                } else if calendar.isDateInYesterday(date) {
                    label = "Ayer"
                } else {
                    label = date.formatted(.dateTime.month().day().weekday(.wide))
                }
                return DateGroup(id: date, label: label, sessions: sessions)
            }
            .sorted { $0.id > $1.id }
    }
}

extension PomodoroSession {
    var durationFormatted: String {
        "\(Int(duration) / 60) min"
    }
}

private struct DateGroup: Identifiable {
    let id: Date
    let label: String
    let sessions: [PomodoroSession]
}
