import Foundation

#if os(iOS)
import UIKit
#endif

/// Service for haptic feedback on iOS devices
///
/// This service provides tactile feedback for user interactions:
/// - Light impact: pause, reset actions
/// - Medium impact: start, skip actions
/// - Success notification: session completion
///
/// On macOS, all methods are no-ops since haptics are not available.
final class HapticService {
    /// Light haptic feedback for subtle interactions
    func lightImpact() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }

    /// Medium haptic feedback for primary actions
    func mediumImpact() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }

    /// Success notification feedback for completed sessions
    func successNotification() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
}
