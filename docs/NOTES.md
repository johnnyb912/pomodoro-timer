# Implementation Notes

Technical notes and implementation details for features not included in the initial release.

---

## macOS Menu Bar Extra

The menu bar extra feature was not implemented to keep the initial release minimal. Here's how to add it:

### Implementation Steps

1. **Modify `PomodoroTimerApp.swift`:**

```swift
import SwiftUI

@main
struct PomodoroTimerApp: App {
    @StateObject private var viewModel = PomodoroViewModel()

    var body: some Scene {
        // Main window
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        #if os(macOS)
        .commands {
            CommandGroup(replacing: .newItem) { }
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

        // Menu bar extra
        MenuBarExtra {
            MenuBarView()
                .environmentObject(viewModel)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: phaseIcon)
                Text(TimeFormatter.format(seconds: viewModel.secondsRemaining))
                    .monospacedDigit()
            }
        }
        .menuBarExtraStyle(.window)
        #endif
    }

    #if os(macOS)
    private var phaseIcon: String {
        switch viewModel.phase {
        case .work: return "brain.head.profile"
        case .shortBreak: return "cup.and.saucer"
        case .longBreak: return "figure.walk"
        }
    }
    #endif
}
```

2. **Create `MenuBarView.swift`:**

```swift
import SwiftUI

#if os(macOS)
struct MenuBarView: View {
    @EnvironmentObject var viewModel: PomodoroViewModel
    @Environment(\.openWindow) var openWindow

    var body: some View {
        VStack(spacing: 12) {
            // Phase and time
            VStack(spacing: 4) {
                Text(viewModel.phase.displayName)
                    .font(.headline)
                    .foregroundColor(phaseColor)

                Text(TimeFormatter.format(seconds: viewModel.secondsRemaining))
                    .font(.system(size: 32, weight: .light, design: .monospaced))
            }
            .padding(.top, 8)

            // Session indicators
            HStack(spacing: 4) {
                ForEach(0..<viewModel.cycleTarget, id: \.self) { index in
                    Circle()
                        .fill(index < viewModel.completedWorkSessions ? Color.red : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }

            Divider()

            // Controls
            HStack(spacing: 16) {
                Button(action: viewModel.reset) {
                    Image(systemName: "arrow.counterclockwise")
                }
                .buttonStyle(.plain)

                Button(action: viewModel.toggleStartPause) {
                    Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)

                Button(action: viewModel.skip) {
                    Image(systemName: "forward.fill")
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 4)

            Divider()

            // Footer
            HStack {
                Button("Open Window") {
                    NSApp.activate(ignoringOtherApps: true)
                }
                .buttonStyle(.plain)
                .font(.caption)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.caption)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .frame(width: 200)
    }

    private var phaseColor: Color {
        switch viewModel.phase {
        case .work: return .red
        case .shortBreak: return .green
        case .longBreak: return .blue
        }
    }
}
#endif
```

### Considerations

- **Shared State**: The `@StateObject` must be shared between WindowGroup and MenuBarExtra
- **Icon Updates**: The menu bar icon should update to show current time
- **Window Activation**: Add button to bring main window to front
- **Quit Option**: Include quit button since closing window doesn't quit macOS apps

---

## Preventing Screen Sleep (iOS)

Keeping the screen awake during timer sessions improves user experience but impacts battery.

### Implementation

Add to `PomodoroViewModel.swift`:

```swift
// Add to syncFromEngine() or toggleStartPause()
private func updateIdleTimerState() {
    #if os(iOS)
    // Only disable idle timer when running AND setting is enabled
    UIApplication.shared.isIdleTimerDisabled = isRunning && settings.preventScreenSleep
    #endif
}
```

Add setting to `PomodoroSettings.swift`:

```swift
struct PomodoroSettings: Codable, Equatable {
    // ... existing properties ...
    var preventScreenSleep: Bool

    static let `default` = PomodoroSettings(
        // ... existing defaults ...
        preventScreenSleep: false  // Default off to save battery
    )
}
```

Add toggle to `SettingsView.swift`:

```swift
#if os(iOS)
Section("Display") {
    Toggle("Keep screen on during timer", isOn: $viewModel.settings.preventScreenSleep)
        .accessibilityLabel("Prevent screen sleep")

    Text("Keeping the screen on will use more battery.")
        .font(.footnote)
        .foregroundColor(.secondary)
}
#endif
```

### Important Considerations

1. **Battery Impact**: Warn users about battery drain
2. **Work Only**: Consider only preventing sleep during work sessions, not breaks
3. **App Lifecycle**: Reset `isIdleTimerDisabled` to `false` when app goes to background
4. **Testing**: Test on physical device (simulator doesn't sleep)

### Cleanup

Add to `appWillResignActive()`:

```swift
private func appWillResignActive() {
    backgroundDate = Date()
    saveState()

    #if os(iOS)
    // Always allow screen to sleep when backgrounded
    UIApplication.shared.isIdleTimerDisabled = false
    #endif
}
```

---

## Edge Case: System Time Changes

The app handles system time changes by using `endDate` for synchronization. Here's the detailed behavior:

### Problem
If a user changes their system clock while the timer is running:
- Moving clock forward: Timer would show negative time
- Moving clock backward: Timer would show more time than expected

### Solution (Already Implemented)

In `PomodoroEngine.synchronize(with:)`:

```swift
func synchronize(with currentDate: Date) {
    guard state.isRunning, let endDate = state.endDate else { return }

    let remaining = Int(endDate.timeIntervalSince(currentDate))
    // Clamp to zero to avoid negative values
    state.secondsRemaining = max(0, remaining)
}
```

### Additional Considerations

For production apps, consider:

1. **NTP Time**: Use network time for critical applications
2. **Monotonic Clock**: Use `ProcessInfo.processInfo.systemUptime` for elapsed time
3. **Significant Time Change**: Listen for `UIApplication.significantTimeChangeNotification`

```swift
// Example: Detect significant time changes
NotificationCenter.default.addObserver(
    forName: UIApplication.significantTimeChangeNotification,
    object: nil,
    queue: .main
) { [weak self] _ in
    self?.handleSignificantTimeChange()
}
```

---

## Design Decisions

### Why Settings Apply to Next Session

**Decision**: When users change duration settings mid-session, changes apply to the *next* session, not the current one.

**Rationale**:
1. **Predictability**: Users can see exactly how long the current session is
2. **No Jarring Changes**: Suddenly adding or removing time mid-session is confusing
3. **Simple Implementation**: No need to recalculate progress or handle edge cases

**Alternative Considered**: Apply immediately with confirmation dialog. Rejected due to added complexity and potential for accidental changes.

### Why Skipping Work Doesn't Count

**Decision**: Skipping a work session does NOT count toward the session count.

**Rationale**:
1. **Integrity**: Session count represents completed work, not attempted work
2. **Prevents Gaming**: Users can't skip to long break without doing work
3. **Clear Mental Model**: "4 work sessions → long break" means 4 *completed* sessions

**Alternative Considered**: Count skipped sessions as half-credit. Rejected as overly complex.

### Why Auto-Advance is Off by Default

**Decision**: Auto-start next session is disabled by default.

**Rationale**:
1. **User Control**: Users should explicitly choose to continue
2. **Break Awareness**: Easy to miss that break started/ended
3. **Battery**: Prevents indefinite running if user forgets about app

---

## Architecture Notes

### Why MVVM?

The app uses MVVM (Model-View-ViewModel) architecture:

- **Model**: `PomodoroSettings`, `TimerState`, `PomodoroPhase`
- **View**: SwiftUI views (`ContentView`, etc.)
- **ViewModel**: `PomodoroViewModel`
- **Engine**: `PomodoroEngine` (pure logic, no UI dependencies)

The `PomodoroEngine` is separated from the ViewModel to:
1. Enable unit testing without UI dependencies
2. Keep pure logic isolated from platform-specific code
3. Make the code easier to reason about

### Timer Accuracy

The app uses two mechanisms for accurate timing:

1. **Display Timer**: `Timer.publish(every: 0.25)` for UI updates
2. **Actual Time**: `endDate` stored when timer starts

By synchronizing against `endDate` on each tick, the timer remains accurate even if:
- The app was backgrounded
- The timer loop was delayed
- The system was under load

### State Persistence Strategy

State is persisted using `UserDefaults` with JSON encoding:

- **Settings**: Saved on every change
- **Timer State**: Saved periodically (every ~4 seconds) and on background
- **Recovery**: On launch, state is loaded and synchronized with current time

This approach is simple and sufficient for the app's needs. For more complex apps, consider Core Data or SwiftData.
