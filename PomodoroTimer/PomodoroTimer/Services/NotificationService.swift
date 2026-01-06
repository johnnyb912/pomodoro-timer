import UserNotifications

/// Service for managing local notifications
///
/// This actor handles:
/// - Requesting notification authorization
/// - Scheduling session completion notifications
/// - Canceling pending notifications
///
/// If the user denies notification permission, the app will
/// fall back to in-app alerts via the view model.
actor NotificationService {
    private let center = UNUserNotificationCenter.current()

    /// Request notification authorization from the user
    func requestAuthorization() async {
        do {
            try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Notification authorization failed: \(error)")
        }
    }

    /// Check if notifications are currently authorized
    func isAuthorized() async -> Bool {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    /// Schedule a notification for when the current session ends
    /// - Parameters:
    ///   - phase: The current phase that is ending
    ///   - timeInterval: Seconds until the notification should fire
    func scheduleSessionEnd(phase: PomodoroPhase, in timeInterval: TimeInterval) async {
        // Cancel any existing notifications first
        center.removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = "\(phase.displayName) Complete!"

        switch phase {
        case .work:
            content.body = "Great work! Time for a break."
        case .shortBreak, .longBreak:
            content.body = "Break's over. Ready to focus?"
        }

        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, timeInterval),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "sessionEnd",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }

    /// Cancel all pending notifications
    func cancelPending() {
        center.removeAllPendingNotificationRequests()
    }
}
