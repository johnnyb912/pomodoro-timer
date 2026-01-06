import SwiftUI

/// Minimal linear progress bar showing session progress
/// Design: slim horizontal bar, fills left to right
struct ProgressRingView: View {
    let progress: Double
    let phase: PomodoroPhase

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.borderSubtle)

                // Progress fill
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.phaseColor(for: phase))
                    .frame(width: geometry.size.width * CGFloat(min(max(progress, 0), 1)))
                    .animation(.easeOut(duration: DesignSystem.Animation.standard), value: progress)
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.generous) {
        ProgressRingView(progress: 0.0, phase: .work)
            .frame(height: 4)

        ProgressRingView(progress: 0.25, phase: .work)
            .frame(height: 4)

        ProgressRingView(progress: 0.5, phase: .shortBreak)
            .frame(height: 4)

        ProgressRingView(progress: 0.75, phase: .shortBreak)
            .frame(height: 4)

        ProgressRingView(progress: 1.0, phase: .longBreak)
            .frame(height: 4)
    }
    .padding(DesignSystem.Spacing.generous)
    .background(Color.backgroundPrimary)
}
