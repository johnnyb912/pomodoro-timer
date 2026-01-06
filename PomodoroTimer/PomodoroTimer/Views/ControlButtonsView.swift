import SwiftUI

/// Timer control buttons with minimal design
/// Precise, subtle buttons with consistent sizing
struct ControlButtonsView: View {
    @EnvironmentObject var viewModel: PomodoroViewModel

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.standard) {
            // Reset button
            Button(action: viewModel.reset) {
                Image(systemName: "arrow.counterclockwise")
            }
            .buttonStyle(IconButtonStyle(size: 44))
            .accessibilityLabel("Reset timer")

            // Start/Pause button (primary action)
            Button(action: viewModel.toggleStartPause) {
                Image(systemName: viewModel.isRunning ? "pause" : "play.fill")
                    .font(.system(size: 18, weight: .semibold))
            }
            .buttonStyle(IconButtonStyle(size: 56, isHighlighted: true))
            .accessibilityLabel(viewModel.isRunning ? "Pause timer" : "Start timer")
            .accessibilityHint(viewModel.isRunning ? "Double tap to pause" : "Double tap to start")

            // Skip button
            Button(action: viewModel.skip) {
                Image(systemName: "forward.fill")
            }
            .buttonStyle(IconButtonStyle(size: 44))
            .accessibilityLabel("Skip to next session")
        }
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.generous) {
        ControlButtonsView()
            .environmentObject(PomodoroViewModel())
    }
    .padding(DesignSystem.Spacing.major)
    .background(Color.backgroundPrimary)
}
