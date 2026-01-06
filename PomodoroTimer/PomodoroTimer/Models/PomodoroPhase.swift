import Foundation

/// Represents the current phase of the Pomodoro timer
enum PomodoroPhase: String, Codable, CaseIterable {
    case work
    case shortBreak
    case longBreak

    /// Human-readable display name for the phase
    var displayName: String {
        switch self {
        case .work: return "Work"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        }
    }

    /// Accessibility label for VoiceOver
    var accessibilityLabel: String {
        switch self {
        case .work: return "Work session"
        case .shortBreak: return "Short break"
        case .longBreak: return "Long break"
        }
    }
}
