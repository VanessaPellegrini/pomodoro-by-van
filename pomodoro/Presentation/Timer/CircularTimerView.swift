import SwiftUI

struct CircularTimerView: View {
    let progress: Double
    let remainingTime: String
    let phase: PomodoroPhase
    let isRunning: Bool

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var size: CGFloat {
        horizontalSizeClass == .compact ? 280 : 220
    }

    private var fontSize: CGFloat {
        horizontalSizeClass == .compact ? 64 : 48
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(phase.color.opacity(0.15), lineWidth: 8)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    phase.color,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            VStack(spacing: 8) {
                Image(systemName: phase.systemImage)
                    .font(.title2)
                    .foregroundStyle(phase.color)
                    .symbolEffect(.pulse, options: .repeating, isActive: isRunning)

                Text(remainingTime)
                    .font(.system(size: fontSize, weight: .thin, design: .rounded))
                    .foregroundStyle(.primary)
                    .monospacedDigit()
                    .contentTransition(.numericText())

                Text(phase.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .animation(.easeInOut(duration: 0.3), value: horizontalSizeClass)
        .animation(.easeInOut(duration: 0.3), value: phase)
    }
}
