# Pomodoro Timer

A native Pomodoro Technique timer app for iOS and macOS, built with SwiftUI.

## Features

- **Standard Pomodoro workflow**: 25-minute work sessions, 5-minute short breaks, 15-minute long breaks after 4 sessions
- **Customizable durations**: Adjust work, short break, and long break times
- **Cross-platform**: Single codebase runs on iPhone and Mac
- **Persistent state**: Timer recovers correctly after app restart or backgrounding
- **Local notifications**: Get notified when sessions complete
- **Accessibility**: VoiceOver support, Dynamic Type, high contrast colors
- **macOS keyboard shortcuts**: Space (start/pause), R (reset), S (skip)
- **Haptic feedback**: Tactile feedback on iOS for all interactions

## Screenshots

```
┌─────────────────────┐
│        Work         │
│    ╭───────────╮    │
│    │           │    │
│    │   25:00   │    │
│    │           │    │
│    ╰───────────╯    │
│      ○ ○ ○ ○        │
│                     │
│   ↺   ▶   ⏭        │
│       ⚙️            │
└─────────────────────┘
```

## Requirements

- iOS 16.0+ / macOS 13.0+
- Xcode 15.0+

## Installation

1. Clone the repository
2. Open `PomodoroTimer/PomodoroTimer.xcodeproj` in Xcode
3. Select your target (iOS Simulator, iPhone, or My Mac)
4. Build and run (⌘R)

See [docs/BUILD.md](docs/BUILD.md) for detailed build instructions.

## Project Structure

```
PomodoroTimer/
├── PomodoroTimer/
│   ├── PomodoroTimerApp.swift     # App entry point
│   ├── Models/                     # Data models
│   │   ├── PomodoroPhase.swift
│   │   ├── PomodoroSettings.swift
│   │   └── TimerState.swift
│   ├── Engine/                     # Pure logic (testable)
│   │   └── PomodoroEngine.swift
│   ├── ViewModels/                 # MVVM view models
│   │   └── PomodoroViewModel.swift
│   ├── Views/                      # SwiftUI views
│   │   ├── ContentView.swift
│   │   ├── TimerDisplayView.swift
│   │   ├── ProgressRingView.swift
│   │   ├── SessionIndicatorsView.swift
│   │   ├── ControlButtonsView.swift
│   │   └── SettingsView.swift
│   ├── Services/                   # Platform services
│   │   ├── NotificationService.swift
│   │   ├── SoundService.swift
│   │   └── HapticService.swift
│   └── Utilities/
│       └── TimeFormatter.swift
├── PomodoroTimerTests/
│   └── PomodoroEngineTests.swift
└── docs/
    ├── BUILD.md
    ├── QA_CHECKLIST.md
    ├── FUTURE_ENHANCEMENTS.md
    └── NOTES.md
```

## Architecture

The app follows MVVM architecture with a clean separation of concerns:

- **PomodoroEngine**: Pure Swift class with all timer logic. No UI dependencies, fully unit testable.
- **PomodoroViewModel**: ObservableObject that bridges the engine to SwiftUI views.
- **Views**: Declarative SwiftUI views that observe the view model.
- **Services**: Platform-specific functionality (notifications, sound, haptics).

## Testing

Run unit tests from Xcode (⌘U) or command line:

```bash
xcodebuild -scheme PomodoroTimer \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  test
```

See [docs/QA_CHECKLIST.md](docs/QA_CHECKLIST.md) for manual testing checklist.

## Settings

| Setting | Default | Range |
|---------|---------|-------|
| Work Duration | 25 min | 1-120 min |
| Short Break | 5 min | 1-60 min |
| Long Break | 15 min | 1-60 min |
| Long Break Interval | 4 sessions | 2-10 |
| Auto-start Next | Off | - |
| Sound | On | - |

## Keyboard Shortcuts (macOS)

| Key | Action |
|-----|--------|
| Space | Start / Pause |
| R | Reset |
| S | Skip |

## Documentation

- [Build Instructions](docs/BUILD.md)
- [QA Checklist](docs/QA_CHECKLIST.md)
- [Future Enhancements](docs/FUTURE_ENHANCEMENTS.md)
- [Implementation Notes](docs/NOTES.md)

## Design Decisions

- **Settings apply to next session**: Changing durations mid-session doesn't affect the current timer
- **Skipping work doesn't count**: Skipping a work session doesn't increment the completed count
- **Session count resets after long break**: Completing a long break starts a fresh cycle

## Future Enhancements

See [docs/FUTURE_ENHANCEMENTS.md](docs/FUTURE_ENHANCEMENTS.md) for planned features including:

- macOS menu bar extra
- Daily stats tracking
- Widget support
- Focus mode integration
- Apple Watch app

## License

See [LICENSE](LICENSE) for details.
