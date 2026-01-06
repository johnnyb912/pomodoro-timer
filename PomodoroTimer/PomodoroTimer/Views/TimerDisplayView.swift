import SwiftUI

/// Large countdown display showing remaining time in MM:SS format
/// Monospace digits with tabular nums for stable width
struct TimerDisplayView: View {
    let seconds: Int

    private var timeString: String {
        TimeFormatter.format(seconds: seconds)
    }

    private var timerFont: Font {
        .system(
            size: DesignSystem.Typography.timerSize,
            weight: DesignSystem.Typography.timerWeight,
            design: .monospaced
        )
    }

    var body: some View {
        Text(timeString)
            .font(timerFont)
            .monospacedDigit()
            .tracking(-2)
            .foregroundColor(Color.foregroundPrimary)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .accessibilityLabel(accessibilityTimeLabel)
    }

    private var accessibilityTimeLabel: String {
        let mins = seconds / 60
        let secs = seconds % 60
        if mins > 0 && secs > 0 {
            return "\(mins) minutes and \(secs) seconds remaining"
        } else if mins > 0 {
            return "\(mins) minutes remaining"
        } else {
            return "\(secs) seconds remaining"
        }
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.generous) {
        TimerDisplayView(seconds: 1500)
        TimerDisplayView(seconds: 65)
        TimerDisplayView(seconds: 5)
    }
    .padding()
    .background(Color.backgroundPrimary)
}
