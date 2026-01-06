import SwiftUI

/// Horizontal row of dots showing completed work sessions
///
/// Features:
/// - Shows progress through the current cycle (e.g., 3/4 sessions)
/// - Filled dots for completed sessions
/// - Empty dots for remaining sessions
/// - Combined accessibility label for VoiceOver
struct SessionIndicatorsView: View {
    let completed: Int
    let total: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index < completed ? Color.red : Color.gray.opacity(0.3))
                    .frame(width: 12, height: 12)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Session \(completed) of \(total)")
    }
}

#Preview {
    VStack(spacing: 20) {
        SessionIndicatorsView(completed: 0, total: 4)
        SessionIndicatorsView(completed: 1, total: 4)
        SessionIndicatorsView(completed: 2, total: 4)
        SessionIndicatorsView(completed: 3, total: 4)
        SessionIndicatorsView(completed: 4, total: 4)
    }
}
