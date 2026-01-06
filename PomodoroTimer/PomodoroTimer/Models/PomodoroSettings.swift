import Foundation

/// User-configurable settings for the Pomodoro timer
struct PomodoroSettings: Codable, Equatable {
    /// Duration of work sessions in minutes
    var workDurationMinutes: Int

    /// Duration of short breaks in minutes
    var shortBreakMinutes: Int

    /// Duration of long breaks in minutes
    var longBreakMinutes: Int

    /// Number of work sessions before a long break
    var longBreakInterval: Int

    /// Whether to automatically start the next session
    var autoStartNextSession: Bool

    /// Whether sound is enabled for session completion
    var soundEnabled: Bool

    /// Default settings matching standard Pomodoro Technique
    static let `default` = PomodoroSettings(
        workDurationMinutes: 25,
        shortBreakMinutes: 5,
        longBreakMinutes: 15,
        longBreakInterval: 4,
        autoStartNextSession: false,
        soundEnabled: true
    )

    /// Returns the duration in seconds for a given phase
    func duration(for phase: PomodoroPhase) -> Int {
        switch phase {
        case .work: return workDurationMinutes * 60
        case .shortBreak: return shortBreakMinutes * 60
        case .longBreak: return longBreakMinutes * 60
        }
    }
}
