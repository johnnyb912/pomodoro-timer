import Foundation

/// Represents the current state of the Pomodoro timer
/// This struct is serializable for persistence and recovery
struct TimerState: Codable {
    /// Current phase of the timer
    var phase: PomodoroPhase

    /// Seconds remaining in the current session
    var secondsRemaining: Int

    /// Whether the timer is currently running
    var isRunning: Bool

    /// Number of work sessions completed in the current cycle
    var completedWorkSessions: Int

    /// The date when the timer will end (only valid when running)
    var endDate: Date?

    /// The date when the timer was paused (for recovery)
    var pausedAt: Date?

    /// Creates an initial state based on settings
    static func initial(settings: PomodoroSettings) -> TimerState {
        TimerState(
            phase: .work,
            secondsRemaining: settings.duration(for: .work),
            isRunning: false,
            completedWorkSessions: 0,
            endDate: nil,
            pausedAt: nil
        )
    }
}
