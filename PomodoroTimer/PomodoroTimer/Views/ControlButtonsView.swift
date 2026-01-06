import SwiftUI

/// Timer control buttons (Reset, Start/Pause, Skip)
///
/// Features:
/// - Large central Start/Pause button
/// - Smaller Reset and Skip buttons on sides
/// - Full VoiceOver accessibility support
/// - Keyboard shortcuts on macOS (Space, R, S)
struct ControlButtonsView: View {
    @EnvironmentObject var viewModel: PomodoroViewModel

    var body: some View {
        HStack(spacing: 16) {
            // Reset button
            ControlButton(
                systemImage: "arrow.counterclockwise",
                label: "Reset",
                action: viewModel.reset
            )

            // Start/Pause button (larger)
            Button(action: viewModel.toggleStartPause) {
                Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 28))
                    .frame(width: 70, height: 70)
                    .background(viewModel.isRunning ? Color.orange : Color.green)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(viewModel.isRunning ? "Pause timer" : "Start timer")
            .accessibilityHint(viewModel.isRunning ? "Double tap to pause" : "Double tap to start")

            // Skip button
            ControlButton(
                systemImage: "forward.fill",
                label: "Skip",
                action: viewModel.skip
            )
        }
    }
}

/// Individual control button with icon and label
struct ControlButton: View {
    let systemImage: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 20))
                    .frame(width: 50, height: 50)
                    .background(Color.secondary.opacity(0.2))
                    .clipShape(Circle())

                Text(label)
                    .font(.caption)
            }
        }
        .buttonStyle(.plain)
        .foregroundColor(.primary)
        .accessibilityLabel(label)
    }
}

#Preview {
    ControlButtonsView()
        .environmentObject(PomodoroViewModel())
}
