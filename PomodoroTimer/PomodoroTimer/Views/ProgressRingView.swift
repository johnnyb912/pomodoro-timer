import SwiftUI

/// Circular progress indicator showing session progress
///
/// Features:
/// - Background ring with reduced opacity
/// - Animated foreground ring that fills clockwise
/// - Customizable color and line width
/// - High contrast friendly (uses solid colors)
struct ProgressRingView: View {
    let progress: Double
    let color: Color
    var lineWidth: CGFloat = 12

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)

            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.25), value: progress)
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressRingView(progress: 0.0, color: .red)
            .frame(width: 150, height: 150)
        ProgressRingView(progress: 0.25, color: .red)
            .frame(width: 150, height: 150)
        ProgressRingView(progress: 0.75, color: .green)
            .frame(width: 150, height: 150)
        ProgressRingView(progress: 1.0, color: .blue)
            .frame(width: 150, height: 150)
    }
}
