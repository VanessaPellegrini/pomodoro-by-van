import SwiftUI
import _SwiftData_SwiftUI

struct TimerView: View {
    let timerService: TimerService

    @Query(sort: \Tag.name) var tags: [Tag]

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                portraitLayout
            } else {
                landscapeLayout
            }
        }
        .animation(.easeInOut(duration: 0.3), value: horizontalSizeClass)
    }

    private var portraitLayout: some View {
        VStack(spacing: 32) {
            Spacer()

            CircularTimerView(
                progress: timerService.progress,
                remainingTime: timerService.formattedTime,
                phase: timerService.phase,
                isRunning: timerService.isRunning
            )

            PhaseIndicatorView(
                currentRound: timerService.currentRound,
                totalRounds: timerService.roundsBeforeLongBreak
            )
            .padding(.top, -8)

            TagPicker(selectedTag: Binding(
                get: { timerService.selectedTag },
                set: { timerService.selectedTag = $0 }
            ))
            .padding(.top, 8)

            Spacer()

            controls
                .padding(.bottom, 40)
        }
        .padding()
    }

    private var landscapeLayout: some View {
        HStack(spacing: 40) {
            CircularTimerView(
                progress: timerService.progress,
                remainingTime: timerService.formattedTime,
                phase: timerService.phase,
                isRunning: timerService.isRunning
            )

            VStack(spacing: 24) {
                Spacer()

                PhaseIndicatorView(
                    currentRound: timerService.currentRound,
                    totalRounds: timerService.roundsBeforeLongBreak
                )

                TagPicker(selectedTag: Binding(
                    get: { timerService.selectedTag },
                    set: { timerService.selectedTag = $0 }
                ))

                Spacer()

                controls
            }
        }
        .padding(32)
    }

    private var controls: some View {
        HStack(spacing: 20) {
            Button {
                timerService.reset()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .frame(width: 50, height: 50)
                    .background(Color.gray.opacity(0.1), in: Circle())
            }

            Button {
                if timerService.isRunning {
                    timerService.pause()
                } else {
                    timerService.start()
                }
            } label: {
                Image(systemName: timerService.isRunning ? "pause.fill" : "play.fill")
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: 80, height: 80)
                    .background(timerService.phase.color, in: Circle())
                    .shadow(color: timerService.phase.color.opacity(0.4), radius: 8, y: 4)
            }

            Button {
                timerService.skip()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .frame(width: 50, height: 50)
                    .background(Color.gray.opacity(0.1), in: Circle())
            }
        }
    }
}
