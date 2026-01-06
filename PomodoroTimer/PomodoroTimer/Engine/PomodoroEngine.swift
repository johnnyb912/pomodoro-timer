import Foundation

/// Pure logic engine for Pomodoro timer - no UI dependencies, fully testable
///
/// This class encapsulates all timer logic including:
/// - Phase transitions (work → short break → work → ... → long break)
/// - Session counting and cycle management
/// - Time synchronization for background recovery
///
/// Design decisions:
/// - Skipping work does NOT count as completed (user didn't finish)
/// - Settings changes apply to NEXT session, not current
/// - Session count resets after long break completes or on manual reset
final class PomodoroEngine {
    // MARK: - Properties

    /// Current timer state (mutable)
    private(set) var state: TimerState

    /// Current settings (can be updated mid-session)
    private(set) var settings: PomodoroSettings

    // MARK: - Initialization

    init(state: TimerState, settings: PomodoroSettings) {
        self.state = state
        self.settings = settings
    }

    // MARK: - State Queries

    /// Current phase of the timer
    var currentPhase: PomodoroPhase { state.phase }

    /// Seconds remaining in current session
    var secondsRemaining: Int { state.secondsRemaining }

    /// Whether the timer is currently running
    var isRunning: Bool { state.isRunning }

    /// Number of completed work sessions in current cycle
    var completedWorkSessions: Int { state.completedWorkSessions }

    /// Target number of work sessions before long break
    var cycleTarget: Int { settings.longBreakInterval }

    /// Total duration for the current phase in seconds
    var totalDurationForCurrentPhase: Int {
        settings.duration(for: state.phase)
    }

    /// Progress through current session (0.0 to 1.0)
    var progress: Double {
        let total = Double(totalDurationForCurrentPhase)
        guard total > 0 else { return 0 }
        return 1.0 - (Double(state.secondsRemaining) / total)
    }

    // MARK: - Actions

    /// Start the timer from paused state
    func start() {
        guard !state.isRunning else { return }
        state.isRunning = true
        state.endDate = Date().addingTimeInterval(TimeInterval(state.secondsRemaining))
        state.pausedAt = nil
    }

    /// Pause the running timer
    func pause() {
        guard state.isRunning else { return }
        state.isRunning = false
        state.pausedAt = Date()
        state.endDate = nil
    }

    /// Reset timer to initial state
    func reset() {
        state = TimerState.initial(settings: settings)
    }

    /// Skip to the next phase without completing current session
    /// - Returns: The new phase after skipping
    @discardableResult
    func skip() -> PomodoroPhase {
        // Skipping work does NOT count as completed
        // Skipping break moves to next work session
        let nextPhase = determineNextPhase(completedWork: state.phase != .work)
        transitionTo(nextPhase)
        return nextPhase
    }

    /// Called when timer reaches zero - handles session completion
    /// - Returns: The next phase to transition to
    @discardableResult
    func sessionCompleted() -> PomodoroPhase {
        let wasWork = state.phase == .work
        let nextPhase = determineNextPhase(completedWork: wasWork)
        transitionTo(nextPhase)
        return nextPhase
    }

    /// Update remaining time based on current date (for background recovery)
    /// - Parameter currentDate: The current date to synchronize against
    func synchronize(with currentDate: Date) {
        guard state.isRunning, let endDate = state.endDate else { return }

        let remaining = Int(endDate.timeIntervalSince(currentDate))
        // Clamp to zero to avoid negative values from clock changes
        state.secondsRemaining = max(0, remaining)
    }

    /// Tick one second (for display updates when timer is running)
    func tick() {
        guard state.isRunning, state.secondsRemaining > 0 else { return }
        state.secondsRemaining -= 1
    }

    /// Update settings - changes apply to next session
    /// - Parameter newSettings: The new settings to apply
    func updateSettings(_ newSettings: PomodoroSettings) {
        settings = newSettings
        // Settings apply to next session, not current
    }

    // MARK: - Private Methods

    /// Determine the next phase based on current state and whether work was completed
    private func determineNextPhase(completedWork: Bool) -> PomodoroPhase {
        switch state.phase {
        case .work:
            var newCompletedSessions = state.completedWorkSessions
            if completedWork {
                newCompletedSessions += 1
            }
            // Update state for next phase determination
            state.completedWorkSessions = newCompletedSessions

            if newCompletedSessions >= settings.longBreakInterval {
                return .longBreak
            } else {
                return .shortBreak
            }

        case .shortBreak:
            return .work

        case .longBreak:
            // Reset cycle after long break
            state.completedWorkSessions = 0
            return .work
        }
    }

    /// Transition to a new phase
    private func transitionTo(_ phase: PomodoroPhase) {
        state.phase = phase
        state.secondsRemaining = settings.duration(for: phase)
        state.isRunning = false
        state.endDate = nil
        state.pausedAt = nil
    }
}
