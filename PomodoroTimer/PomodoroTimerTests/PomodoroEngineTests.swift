import XCTest
@testable import PomodoroTimer

/// Unit tests for PomodoroEngine
///
/// Tests cover:
/// - Initial state
/// - Start/pause behavior
/// - Phase transitions (work → short break → work → long break)
/// - Skip behavior (doesn't count work as completed)
/// - Reset behavior
/// - Time synchronization
/// - Progress calculation
/// - Settings updates
final class PomodoroEngineTests: XCTestCase {
    var settings: PomodoroSettings!
    var engine: PomodoroEngine!

    override func setUp() {
        super.setUp()
        settings = PomodoroSettings(
            workDurationMinutes: 25,
            shortBreakMinutes: 5,
            longBreakMinutes: 15,
            longBreakInterval: 4,
            autoStartNextSession: false,
            soundEnabled: true
        )
        let state = TimerState.initial(settings: settings)
        engine = PomodoroEngine(state: state, settings: settings)
    }

    override func tearDown() {
        engine = nil
        settings = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertEqual(engine.currentPhase, .work)
        XCTAssertEqual(engine.secondsRemaining, 25 * 60)
        XCTAssertFalse(engine.isRunning)
        XCTAssertEqual(engine.completedWorkSessions, 0)
    }

    func testInitialProgress() {
        XCTAssertEqual(engine.progress, 0, accuracy: 0.01)
    }

    // MARK: - Start/Pause Tests

    func testStartSetsRunningState() {
        engine.start()
        XCTAssertTrue(engine.isRunning)
        XCTAssertNotNil(engine.state.endDate)
    }

    func testPauseFromRunning() {
        engine.start()
        engine.pause()
        XCTAssertFalse(engine.isRunning)
        XCTAssertNil(engine.state.endDate)
    }

    func testDoubleStartIsNoOp() {
        engine.start()
        let initialEndDate = engine.state.endDate
        engine.start()
        XCTAssertEqual(engine.state.endDate, initialEndDate)
    }

    func testPauseWhenNotRunningIsNoOp() {
        engine.pause()
        XCTAssertFalse(engine.isRunning)
    }

    // MARK: - Phase Transition Tests

    func testWorkToShortBreakTransition() {
        let nextPhase = engine.sessionCompleted()

        XCTAssertEqual(nextPhase, .shortBreak)
        XCTAssertEqual(engine.currentPhase, .shortBreak)
        XCTAssertEqual(engine.completedWorkSessions, 1)
        XCTAssertEqual(engine.secondsRemaining, 5 * 60)
        XCTAssertFalse(engine.isRunning)
    }

    func testShortBreakToWorkTransition() {
        // First complete a work session
        _ = engine.sessionCompleted()
        XCTAssertEqual(engine.currentPhase, .shortBreak)

        // Then complete the break
        let nextPhase = engine.sessionCompleted()

        XCTAssertEqual(nextPhase, .work)
        XCTAssertEqual(engine.currentPhase, .work)
        XCTAssertEqual(engine.completedWorkSessions, 1) // Still 1
    }

    func testLongBreakAfterFourWorkSessions() {
        // Complete 4 work sessions with short breaks between
        for i in 1...4 {
            let afterWork = engine.sessionCompleted()

            if i < 4 {
                XCTAssertEqual(afterWork, .shortBreak, "Session \(i) should lead to short break")
                let afterBreak = engine.sessionCompleted()
                XCTAssertEqual(afterBreak, .work)
            } else {
                XCTAssertEqual(afterWork, .longBreak, "Session 4 should lead to long break")
            }
        }

        XCTAssertEqual(engine.currentPhase, .longBreak)
        XCTAssertEqual(engine.secondsRemaining, 15 * 60)
    }

    func testCycleResetsAfterLongBreak() {
        // Fast forward to long break
        for _ in 1...4 {
            _ = engine.sessionCompleted() // work -> break
            if engine.currentPhase != .longBreak {
                _ = engine.sessionCompleted() // break -> work
            }
        }

        XCTAssertEqual(engine.currentPhase, .longBreak)
        XCTAssertEqual(engine.completedWorkSessions, 4)

        // Complete long break
        let afterLongBreak = engine.sessionCompleted()

        XCTAssertEqual(afterLongBreak, .work)
        XCTAssertEqual(engine.completedWorkSessions, 0) // Reset!
    }

    // MARK: - Skip Tests

    func testSkipWorkDoesNotCountAsCompleted() {
        _ = engine.skip()

        XCTAssertEqual(engine.currentPhase, .shortBreak)
        XCTAssertEqual(engine.completedWorkSessions, 0) // Not incremented
    }

    func testSkipBreakMovesToWork() {
        // First go to break
        _ = engine.sessionCompleted()
        XCTAssertEqual(engine.currentPhase, .shortBreak)

        // Skip the break
        let afterSkip = engine.skip()

        XCTAssertEqual(afterSkip, .work)
        XCTAssertEqual(engine.completedWorkSessions, 1) // Preserved
    }

    func testSkipLongBreakResetsSessionCount() {
        // Fast forward to long break
        for _ in 1...4 {
            _ = engine.sessionCompleted()
            if engine.currentPhase != .longBreak {
                _ = engine.sessionCompleted()
            }
        }

        XCTAssertEqual(engine.currentPhase, .longBreak)

        // Skip long break
        _ = engine.skip()

        XCTAssertEqual(engine.currentPhase, .work)
        XCTAssertEqual(engine.completedWorkSessions, 0) // Reset after long break
    }

    // MARK: - Reset Tests

    func testResetRestoresInitialState() {
        // Make some progress
        engine.start()
        _ = engine.sessionCompleted()
        _ = engine.sessionCompleted()

        // Reset
        engine.reset()

        XCTAssertEqual(engine.currentPhase, .work)
        XCTAssertEqual(engine.secondsRemaining, 25 * 60)
        XCTAssertFalse(engine.isRunning)
        XCTAssertEqual(engine.completedWorkSessions, 0)
    }

    func testResetClearsEndDate() {
        engine.start()
        engine.reset()

        XCTAssertNil(engine.state.endDate)
    }

    // MARK: - Synchronization Tests

    func testSynchronizeUpdatesRemainingTime() {
        engine.start()

        // Simulate 5 minutes passing
        let futureDate = Date().addingTimeInterval(5 * 60)
        engine.synchronize(with: futureDate)

        // Should have ~20 minutes remaining (25 - 5)
        XCTAssertEqual(engine.secondsRemaining, 20 * 60, accuracy: 2)
    }

    func testSynchronizeWithPastEndDateClampsToZero() {
        engine.start()

        // Simulate 30 minutes passing (past the 25 min duration)
        let futureDate = Date().addingTimeInterval(30 * 60)
        engine.synchronize(with: futureDate)

        XCTAssertEqual(engine.secondsRemaining, 0)
    }

    func testSynchronizeOnlyWorksWhenRunning() {
        let initialRemaining = engine.secondsRemaining

        // Not running, sync should do nothing
        let futureDate = Date().addingTimeInterval(5 * 60)
        engine.synchronize(with: futureDate)

        XCTAssertEqual(engine.secondsRemaining, initialRemaining)
    }

    func testSynchronizeWithoutEndDateDoesNothing() {
        // Start and pause to clear endDate
        engine.start()
        engine.pause()

        let remaining = engine.secondsRemaining
        let futureDate = Date().addingTimeInterval(5 * 60)
        engine.synchronize(with: futureDate)

        XCTAssertEqual(engine.secondsRemaining, remaining)
    }

    // MARK: - Progress Tests

    func testProgressCalculation() {
        // At start, progress should be 0
        XCTAssertEqual(engine.progress, 0, accuracy: 0.01)

        // Simulate half the time elapsed
        engine.start()
        let halfwayDate = Date().addingTimeInterval(12.5 * 60)
        engine.synchronize(with: halfwayDate)

        XCTAssertEqual(engine.progress, 0.5, accuracy: 0.01)
    }

    func testProgressAtCompletion() {
        engine.start()
        let endDate = Date().addingTimeInterval(25 * 60)
        engine.synchronize(with: endDate)

        XCTAssertEqual(engine.progress, 1.0, accuracy: 0.01)
    }

    // MARK: - Settings Update Tests

    func testSettingsUpdateDoesNotAffectCurrentSession() {
        let initialSeconds = engine.secondsRemaining

        var newSettings = settings!
        newSettings.workDurationMinutes = 50
        engine.updateSettings(newSettings)

        // Current session should be unchanged
        XCTAssertEqual(engine.secondsRemaining, initialSeconds)

        // But next session should use new duration
        _ = engine.sessionCompleted() // -> short break
        _ = engine.sessionCompleted() // -> work

        XCTAssertEqual(engine.secondsRemaining, 50 * 60)
    }

    func testSettingsUpdateAffectsBreakDuration() {
        var newSettings = settings!
        newSettings.shortBreakMinutes = 10
        engine.updateSettings(newSettings)

        _ = engine.sessionCompleted() // -> short break

        XCTAssertEqual(engine.secondsRemaining, 10 * 60)
    }

    // MARK: - Custom Interval Tests

    func testCustomLongBreakInterval() {
        var customSettings = settings!
        customSettings.longBreakInterval = 2
        engine.updateSettings(customSettings)
        engine.reset()

        // Complete 2 work sessions
        _ = engine.sessionCompleted() // work 1 -> short break
        _ = engine.sessionCompleted() // short break -> work
        _ = engine.sessionCompleted() // work 2 -> should be long break

        XCTAssertEqual(engine.currentPhase, .longBreak)
    }

    func testLargeIntervalValue() {
        var customSettings = settings!
        customSettings.longBreakInterval = 8
        engine.updateSettings(customSettings)
        engine.reset()

        // Complete 7 work sessions - should still be short breaks
        for i in 1...7 {
            let phase = engine.sessionCompleted()
            XCTAssertEqual(phase, .shortBreak, "Session \(i) should lead to short break")
            _ = engine.sessionCompleted() // short break -> work
        }

        // 8th work session should lead to long break
        let phase = engine.sessionCompleted()
        XCTAssertEqual(phase, .longBreak)
    }

    // MARK: - Tick Tests

    func testTickDecrementsTime() {
        engine.start()
        let before = engine.secondsRemaining
        engine.tick()
        XCTAssertEqual(engine.secondsRemaining, before - 1)
    }

    func testTickDoesNothingWhenPaused() {
        let before = engine.secondsRemaining
        engine.tick()
        XCTAssertEqual(engine.secondsRemaining, before)
    }

    func testTickDoesNothingAtZero() {
        engine.start()
        // Sync to zero
        let endDate = Date().addingTimeInterval(25 * 60)
        engine.synchronize(with: endDate)

        engine.tick()
        XCTAssertEqual(engine.secondsRemaining, 0)
    }

    // MARK: - Computed Properties Tests

    func testCycleTarget() {
        XCTAssertEqual(engine.cycleTarget, 4)

        var newSettings = settings!
        newSettings.longBreakInterval = 6
        engine.updateSettings(newSettings)

        XCTAssertEqual(engine.cycleTarget, 6)
    }

    func testTotalDurationForCurrentPhase() {
        // Work phase
        XCTAssertEqual(engine.totalDurationForCurrentPhase, 25 * 60)

        // Short break
        _ = engine.sessionCompleted()
        XCTAssertEqual(engine.totalDurationForCurrentPhase, 5 * 60)

        // Go to long break
        _ = engine.sessionCompleted() // -> work
        _ = engine.sessionCompleted() // -> short break
        _ = engine.sessionCompleted() // -> work
        _ = engine.sessionCompleted() // -> short break
        _ = engine.sessionCompleted() // -> work
        _ = engine.sessionCompleted() // -> long break

        XCTAssertEqual(engine.totalDurationForCurrentPhase, 15 * 60)
    }
}
