import SwiftUI

struct PhaseIndicatorView: View {
    let currentRound: Int
    let totalRounds: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...totalRounds, id: \.self) { round in
                Circle()
                    .fill(round <= currentRound ? Color.red : Color.gray.opacity(0.3))
                    .frame(width: 10, height: 10)
                    .animation(.easeInOut(duration: 0.3), value: currentRound)
            }

            Text("Ronda \(currentRound)/\(totalRounds)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
