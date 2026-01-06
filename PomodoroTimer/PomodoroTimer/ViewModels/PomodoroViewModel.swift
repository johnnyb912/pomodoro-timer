import SwiftUI
import Combine

/// Main view model for the Pomodoro timer app
///
/// This class bridges the PomodoroEngine to the SwiftUI views, handling:
/// - UI state publishing via @Published properties
/// - Timer loop management
/// - Persistence (settings and state)
/// - Service coordination (notifications, sound, haptics)
/// - App lifecycle events
@MainActor
final class PomodoroViewModel: ObservableObject {
    // MARK: - Published State

    /// Current phase of the timer
    @Published private(set) var phase: PomodoroPhase = .work

    /// Seconds remaining in current session
    @Published private(set) var secondsRemaining: Int = 25 * 60

    /// Whether the timer is currently running
    @Published private(set) var isRunning: Bool = false

    /// Number of completed work sessions in current cycle
    @Published private(set) var completedWorkSessions: Int = 0

    /// Progress through current session (0.0 to 1.0)
    @Published private(set) var progress: Double = 0

    /// User settings with automatic persistence
    @Published var settings: PomodoroSettings {
        didSet {
            saveSettings()
            engine.updateSettings(settings)
        }
    }

    /// Whether settings sheet is showing
    @Published var showingSettings = false

    /// Whether in-app alert is showing (for notification fallback)
    @Published var showingInAppAlert = false

    /// Message for in-app alert
    @Published var alertMessage = ""

    // MARK: - Services

    private let notificationService = NotificationService()
    private let soundService = SoundService()
    private let hapticService = HapticService()

    // MARK: - Private Properties

    private var engine: PomodoroEngine
    private var timerCancellable: AnyCancellable?
    private var backgroundDate: Date?

    // MARK: - Computed Properties

    /// Target number of work sessions before long break
    var cycleTarget: Int { settings.longBreakInterval }

    /// Total duration for current phase in seconds
    var totalDurationForCurrentPhase: Int {
        settings.duration(for: phase)
    }

    // MARK: - Initialization

    init() {
        // Load settings from persistence
        let loadedSettings = Self.loadSettings()
        self.settings = loadedSettings

        // Load or create initial state
        let loadedState = Self.loadState() ?? TimerState.initial(settings: loadedSettings)
        self.engine = PomodoroEngine(state: loadedState, settings: loadedSettings)

        // Sync UI state from engine
        syncFromEngine()

        // Handle recovery if app was running when closed
        recoverIfNeeded()

        // Request notification permission
        Task {
            await notificationService.requestAuthorization()
        }

        // Start the timer update loop
        startTimerLoop()

        // Setup app lifecycle observers
        setupLifecycleObservers()
    }

    // MARK: - Public Actions

    /// Toggle between start and pause
    func toggleStartPause() {
        if isRunning {
            engine.pause()
            hapticService.lightImpact()
        } else {
            engine.start()
            scheduleNotification()
            hapticService.mediumImpact()
        }
        syncFromEngine()
        saveState()
    }

    /// Reset timer to initial state
    func reset() {
        engine.reset()
        notificationService.cancelPending()
        syncFromEngine()
        saveState()
        hapticService.lightImpact()
    }

    /// Skip to next phase
    func skip() {
        _ = engine.skip()
        notificationService.cancelPending()
        syncFromEngine()
        saveState()
        hapticService.mediumImpact()

        if settings.autoStartNextSession {
            toggleStartPause()
        }
    }

    // MARK: - Timer Loop

    private func startTimerLoop() {
        timerCancellable = Timer.publish(every: 0.25, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.timerTick()
            }
    }

    private func timerTick() {
        guard isRunning else { return }

        // Sync with end date for accuracy
        engine.synchronize(with: Date())
        syncFromEngine()

        if engine.secondsRemaining <= 0 {
            handleSessionComplete()
        }

        // Save periodically (every ~4 seconds to reduce writes)
        if Int(Date().timeIntervalSince1970) % 4 == 0 {
            saveState()
        }
    }

    // MARK: - Session Completion

    private func handleSessionComplete() {
        let previousPhase = phase
        let nextPhase = engine.sessionCompleted()

        notificationService.cancelPending()

        // Play sound and haptic feedback
        if settings.soundEnabled {
            soundService.playCompletionSound()
        }
        hapticService.successNotification()

        syncFromEngine()
        saveState()

        // Show in-app alert if notifications are denied
        Task {
            let authorized = await notificationService.isAuthorized()
            if !authorized {
                alertMessage = "\(previousPhase.displayName) complete! Time for \(nextPhase.displayName)."
                showingInAppAlert = true
            }
        }

        // Auto-advance if enabled
        if settings.autoStartNextSession {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.toggleStartPause()
            }
        }
    }

    // MARK: - Notifications

    private func scheduleNotification() {
        Task {
            await notificationService.scheduleSessionEnd(
                phase: phase,
                in: TimeInterval(secondsRemaining)
            )
        }
    }

    // MARK: - State Sync

    private func syncFromEngine() {
        phase = engine.currentPhase
        secondsRemaining = engine.secondsRemaining
        isRunning = engine.isRunning
        completedWorkSessions = engine.completedWorkSessions
        progress = engine.progress
    }

    private func recoverIfNeeded() {
        guard engine.isRunning else { return }

        engine.synchronize(with: Date())

        if engine.secondsRemaining <= 0 {
            // Timer would have completed while app was closed
            handleSessionComplete()
        } else {
            // Timer still running, reschedule notification
            scheduleNotification()
        }

        syncFromEngine()
    }

    // MARK: - Lifecycle

    private func setupLifecycleObservers() {
        #if os(iOS)
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.appWillResignActive()
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.appDidBecomeActive()
        }
        #elseif os(macOS)
        NotificationCenter.default.addObserver(
            forName: NSApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.appWillResignActive()
        }

        NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.appDidBecomeActive()
        }
        #endif
    }

    private func appWillResignActive() {
        backgroundDate = Date()
        saveState()
    }

    private func appDidBecomeActive() {
        guard isRunning else { return }
        recoverIfNeeded()
        backgroundDate = nil
    }

    // MARK: - Persistence

    private static let settingsKey = "pomodoro_settings"
    private static let stateKey = "pomodoro_state"

    private static func loadSettings() -> PomodoroSettings {
        guard let data = UserDefaults.standard.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(PomodoroSettings.self, from: data) else {
            return .default
        }
        return settings
    }

    private func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: Self.settingsKey)
        }
    }

    private static func loadState() -> TimerState? {
        guard let data = UserDefaults.standard.data(forKey: stateKey),
              let state = try? JSONDecoder().decode(TimerState.self, from: data) else {
            return nil
        }
        return state
    }

    private func saveState() {
        if let data = try? JSONEncoder().encode(engine.state) {
            UserDefaults.standard.set(data, forKey: Self.stateKey)
        }
    }
}
