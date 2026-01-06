import AVFoundation
import AudioToolbox

/// Service for playing sound effects
///
/// Uses system sounds which are available on both iOS and macOS
/// without requiring any bundled audio assets.
final class SoundService {
    /// Play the completion sound when a session ends
    ///
    /// Uses system sound 1007 which is the "Tri-tone" notification sound.
    /// This is a universally recognized alert sound available on both platforms.
    func playCompletionSound() {
        // System sound 1007 is the "Tri-tone" notification sound
        // Available on both iOS and macOS
        AudioServicesPlaySystemSound(1007)
    }
}
