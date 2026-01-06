import SwiftUI

/// Minimal session progress indicators
/// Small dots showing completed sessions in the current cycle
struct SessionIndicatorsView: View {
    let completed: Int
    let total: Int

    private var captionFont: Font {
        .system(
            size: DesignSystem.Typography.captionSize,
            weight: DesignSystem.Typography.captionWeight,
            design: .monospaced
        )
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.tight) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index < completed ? Color.foregroundPrimary : Color.clear)
                    .frame(width: 6, height: 6)
                    .overlay(
                        Circle()
                            .stroke(
                                index < completed ? Color.foregroundPrimary : Color.borderDefault,
                                lineWidth: 1
                            )
                    )
            }

            // Session count text
            Text("\(completed)/\(total)")
                .font(captionFont)
                .foregroundColor(Color.foregroundMuted)
                .padding(.leading, DesignSystem.Spacing.tight)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Session \(completed) of \(total)")
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.generous) {
        SessionIndicatorsView(completed: 0, total: 4)
        SessionIndicatorsView(completed: 1, total: 4)
        SessionIndicatorsView(completed: 2, total: 4)
        SessionIndicatorsView(completed: 3, total: 4)
        SessionIndicatorsView(completed: 4, total: 4)
    }
    .padding()
    .background(Color.backgroundPrimary)
}
