import Foundation

/// Utility for formatting time values
enum TimeFormatter {
    /// Format seconds into MM:SS display string
    /// - Parameter seconds: Total seconds to format
    /// - Returns: Formatted string like "25:00" or "05:30"
    static func format(seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
