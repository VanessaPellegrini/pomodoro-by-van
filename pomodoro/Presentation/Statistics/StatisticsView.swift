import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Query private var sessions: [PomodoroSession]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    todayStatsCards
                    weekChart
                    streakCard
                }
                .padding()
            }
            .navigationTitle("Estadisticas")
        }
    }

    private var todayStatsCards: some View {
        let workToday = workSessionsToday
        let minutesToday = workToday.reduce(0) { $0 + Int($1.duration) } / 60

        return HStack(spacing: 12) {
            StatCard(title: "Hoy", value: "\(workToday.count)", subtitle: "pomodoros")
            StatCard(title: "Hoy", value: "\(minutesToday)", subtitle: "minutos")
            StatCard(title: "Racha", value: "\(currentStreak)", subtitle: "dias")
        }
    }

    private var weekChart: some View {
        let data = weekSessionCounts
        let maxCount = max(data.map(\.count).max() ?? 1, 1)

        return VStack(alignment: .leading, spacing: 12) {
            Text("Esta semana")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data) { day in
                    VStack(spacing: 6) {
                        if day.count > 0 {
                            Text("\(day.count)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        RoundedRectangle(cornerRadius: 4)
                            .fill(day.isToday ? Color.red : Color.red.opacity(0.3))
                            .frame(
                                width: 32,
                                height: max(4, CGFloat(day.count) / CGFloat(maxCount) * 120)
                            )

                        Text(day.label)
                            .font(.caption2)
                            .foregroundStyle(day.isToday ? .primary : .secondary)
                            .fontWeight(day.isToday ? .bold : .regular)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var streakCard: some View {
        VStack(spacing: 8) {
            Image(systemName: currentStreak > 0 ? "flame.fill" : "flame")
                .font(.largeTitle)
                .foregroundStyle(currentStreak > 0 ? .orange : .secondary)

            Text("Racha actual: \(currentStreak) dias")
                .font(.subheadline.weight(.medium))

            Text(currentStreak > 0 ? "Sigue asi!" : "Completa un pomodoro hoy para empezar")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var workSessionsToday: [PomodoroSession] {
        let calendar = Calendar.current
        return sessions.filter {
            $0.phase == "work" && $0.completed && calendar.isDateInToday($0.startTime)
        }
    }

    private var weekSessionCounts: [DayData] {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        )!

        let workSessionsByDay = Dictionary(
            grouping: sessions.filter { $0.phase == "work" && $0.completed }
        ) { calendar.startOfDay(for: $0.startTime) }

        let labels = ["L", "M", "X", "J", "V", "S", "D"]

        return (0..<7).map { i in
            let date = calendar.date(byAdding: .day, value: i, to: weekStart)!
            let weekdayIndex = (calendar.component(.weekday, from: date) + 5) % 7
            let count = workSessionsByDay[calendar.startOfDay(for: date)]?.count ?? 0

            return DayData(
                label: labels[weekdayIndex],
                count: count,
                isToday: calendar.isDateInToday(date)
            )
        }
    }

    private var currentStreak: Int {
        let calendar = Calendar.current
        let workDays = Set(
            sessions.compactMap { session -> Date? in
                guard session.phase == "work", session.completed else { return nil }
                return calendar.startOfDay(for: session.startTime)
            }
        )

        var streak = 0
        var date = calendar.startOfDay(for: .now)

        if !workDays.contains(date) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: date) else { return 0 }
            date = yesterday
        }

        while workDays.contains(date) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = prev
        }

        return streak
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title.weight(.bold))
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct DayData: Identifiable {
    let label: String
    let count: Int
    let isToday: Bool
    var id: String { label }
}
