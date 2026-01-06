import SwiftUI

/// Large countdown display showing remaining time in MM:SS format
///
/// Features:
/// - Monospaced font for stable width during countdown
/// - Dynamic Type support via minimumScaleFactor
/// - VoiceOver-friendly accessibility label
struct TimerDisplayView: View {
    let seconds: Int

    private var timeString: String {
        TimeFormatter.format(seconds: seconds)
    }

    var body: some View {
        Text(timeString)
            .font(.system(size: 56, weight: .light, design: .monospaced))
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
    VStack(spacing: 20) {
        TimerDisplayView(seconds: 1500)
        TimerDisplayView(seconds: 65)
        TimerDisplayView(seconds: 5)
    }
}
