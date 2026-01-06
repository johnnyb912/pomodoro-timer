import SwiftUI

// MARK: - Design System
// Precise, minimal design inspired by Linear, Notion, and Stripe
// Direction: Precision & Utility — calm, technical, non-distracting
// Depth: Borders-only with surface color shifts

enum DesignSystem {
    // MARK: - Spacing (4px grid)
    enum Spacing {
        static let micro: CGFloat = 4      // Icon gaps
        static let tight: CGFloat = 8      // Within components
        static let standard: CGFloat = 12  // Between related elements
        static let comfortable: CGFloat = 16  // Section padding
        static let generous: CGFloat = 24  // Between sections
        static let major: CGFloat = 32     // Major separation
        static let xlarge: CGFloat = 48    // Page-level spacing
    }

    // MARK: - Border Radius (sharp system for technical feel)
    enum Radius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 6
        static let large: CGFloat = 8
        static let xlarge: CGFloat = 12
    }

    // MARK: - Typography
    enum Typography {
        // Timer display - monospace, large
        static let timerSize: CGFloat = 72
        static let timerWeight: Font.Weight = .light

        // Phase label
        static let phaseLabelSize: CGFloat = 13
        static let phaseLabelWeight: Font.Weight = .medium

        // Section headers
        static let sectionSize: CGFloat = 11
        static let sectionWeight: Font.Weight = .semibold

        // Body text
        static let bodySize: CGFloat = 14
        static let bodyWeight: Font.Weight = .regular

        // Small/caption
        static let captionSize: CGFloat = 12
        static let captionWeight: Font.Weight = .medium
    }

    // MARK: - Animation
    enum Animation {
        static let micro: Double = 0.15
        static let standard: Double = 0.2
        static let slow: Double = 0.25

        static var easing: SwiftUI.Animation {
            .timingCurve(0.25, 1, 0.5, 1, duration: standard)
        }
    }
}

// MARK: - Color Palette
// Cool neutrals (slate) with single accent
extension Color {
    // MARK: - Backgrounds
    static let backgroundPrimary = Color("BackgroundPrimary")
    static let backgroundSecondary = Color("BackgroundSecondary")
    static let backgroundTertiary = Color("BackgroundTertiary")

    // MARK: - Foregrounds (4-level hierarchy)
    static let foregroundPrimary = Color("ForegroundPrimary")
    static let foregroundSecondary = Color("ForegroundSecondary")
    static let foregroundMuted = Color("ForegroundMuted")
    static let foregroundFaint = Color("ForegroundFaint")

    // MARK: - Borders
    static let borderSubtle = Color("BorderSubtle")
    static let borderDefault = Color("BorderDefault")

    // MARK: - Accent (single color for meaning)
    static let accentWork = Color("AccentWork")
    static let accentBreak = Color("AccentBreak")
    static let accentLongBreak = Color("AccentLongBreak")

    // MARK: - Phase Colors
    static func phaseColor(for phase: PomodoroPhase) -> Color {
        switch phase {
        case .work: return .accentWork
        case .shortBreak: return .accentBreak
        case .longBreak: return .accentLongBreak
        }
    }

    // MARK: - Semantic
    static let success = Color("Success")
    static let warning = Color("Warning")
    static let error = Color("Error")
}

// MARK: - Fallback Colors (when asset catalog colors not available)
extension Color {
    static var backgroundPrimaryFallback: Color {
        #if os(macOS)
        Color(nsColor: .windowBackgroundColor)
        #else
        Color(uiColor: .systemBackground)
        #endif
    }

    static var backgroundSecondaryFallback: Color {
        #if os(macOS)
        Color(nsColor: .controlBackgroundColor)
        #else
        Color(uiColor: .secondarySystemBackground)
        #endif
    }
}

// MARK: - View Modifiers

/// Card container with consistent styling
struct CardStyle: ViewModifier {
    var padding: CGFloat = DesignSystem.Spacing.comfortable

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.large))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.large)
                    .stroke(Color.borderSubtle, lineWidth: 0.5)
            )
    }
}

/// Button with consistent styling
struct PrimaryButtonStyle: ButtonStyle {
    var isActive: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: DesignSystem.Typography.captionSize, weight: .medium))
            .foregroundColor(isActive ? .white : .foregroundPrimary)
            .padding(.horizontal, DesignSystem.Spacing.comfortable)
            .padding(.vertical, DesignSystem.Spacing.standard)
            .background(isActive ? Color.accentWork : Color.backgroundTertiary)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                    .stroke(Color.borderSubtle, lineWidth: 0.5)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeOut(duration: DesignSystem.Animation.micro), value: configuration.isPressed)
    }
}

/// Secondary/ghost button style
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: DesignSystem.Typography.captionSize, weight: .medium))
            .foregroundColor(.foregroundSecondary)
            .padding(.horizontal, DesignSystem.Spacing.standard)
            .padding(.vertical, DesignSystem.Spacing.tight)
            .background(configuration.isPressed ? Color.backgroundTertiary : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.small))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeOut(duration: DesignSystem.Animation.micro), value: configuration.isPressed)
    }
}

/// Icon button style
struct IconButtonStyle: ButtonStyle {
    var size: CGFloat = 40
    var isHighlighted: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(isHighlighted ? .white : .foregroundSecondary)
            .frame(width: size, height: size)
            .background(isHighlighted ? Color.accentWork : Color.backgroundTertiary)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                    .stroke(Color.borderSubtle, lineWidth: 0.5)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: DesignSystem.Animation.micro), value: configuration.isPressed)
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle(padding: CGFloat = DesignSystem.Spacing.comfortable) -> some View {
        modifier(CardStyle(padding: padding))
    }
}
