import SwiftUI

/// Main entry point for the Pomodoro Timer application
///
/// Supports both iOS and macOS platforms with:
/// - Shared view model across all scenes
/// - macOS keyboard shortcuts (Space, R, S)
/// - macOS-specific window configuration
@main
struct PomodoroTimerApp: App {
    @StateObject private var viewModel = PomodoroViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        #if os(macOS)
        .commands {
            // Remove default "New" menu item
            CommandGroup(replacing: .newItem) { }

            // Add Timer menu with keyboard shortcuts
            CommandMenu("Timer") {
                Button(viewModel.isRunning ? "Pause" : "Start") {
                    viewModel.toggleStartPause()
                }
                .keyboardShortcut(.space, modifiers: [])

                Button("Reset") {
                    viewModel.reset()
                }
                .keyboardShortcut("r", modifiers: [])

                Button("Skip") {
                    viewModel.skip()
                }
                .keyboardShortcut("s", modifiers: [])
            }
        }
        .windowResizability(.contentSize)
        #endif
    }
}
