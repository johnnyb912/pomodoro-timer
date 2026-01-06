# Future Enhancements

Prioritized list of potential improvements for the Pomodoro Timer app.

## Priority Levels

- **P0**: Critical / High Impact - Should be done soon
- **P1**: Important - Significant user value
- **P2**: Nice to Have - Good improvements
- **P3**: Low Priority - Future consideration

---

## P0 - Critical / High Impact

### Menu Bar Extra (macOS)
**Effort: Medium**

Add a menu bar item showing remaining time with quick controls.

**Implementation:**
```swift
// In PomodoroTimerApp.swift
#if os(macOS)
MenuBarExtra {
    MenuBarView()
        .environmentObject(viewModel)
} label: {
    Label(TimeFormatter.format(seconds: viewModel.secondsRemaining),
          systemImage: "timer")
}
.menuBarExtraStyle(.window)
#endif
```

**Tasks:**
- [ ] Create `MenuBarView.swift` with compact controls
- [ ] Share `@StateObject` viewModel between scenes
- [ ] Add menu bar icon assets
- [ ] Test window/menu bar interaction

---

### Daily Stats Tracking
**Effort: Medium**

Track completed pomodoros per day with local persistence.

**Tasks:**
- [ ] Create `DailyStats` model with date and count
- [ ] Add `StatsService` using UserDefaults or Core Data
- [ ] Create `StatsView` showing today's count
- [ ] Add weekly/monthly summary view
- [ ] Reset counter at midnight (use calendar calculations)

---

## P1 - Important

### Prevent Screen Sleep (iOS)
**Effort: Low**

Keep screen on during active timer sessions.

**Implementation:**
```swift
// In PomodoroViewModel
private func updateIdleTimer() {
    #if os(iOS)
    UIApplication.shared.isIdleTimerDisabled = isRunning
    #endif
}
```

**Considerations:**
- Add user setting to enable/disable
- Battery impact warning in settings
- Only enable during work sessions (not breaks)

---

### Widget Support
**Effort: High**

iOS and macOS widgets showing current timer state.

**Tasks:**
- [ ] Create Widget extension target
- [ ] Implement `TimelineProvider`
- [ ] Design widget layouts (small, medium)
- [ ] Handle widget tap to open app
- [ ] Use App Groups for shared data

---

### Focus Mode Integration
**Effort: Medium**

Trigger iOS Focus mode when timer starts.

**Tasks:**
- [ ] Request Focus authorization
- [ ] Create "Pomodoro" Focus configuration
- [ ] Enable Focus on timer start
- [ ] Disable Focus on break or pause
- [ ] Handle user override gracefully

---

## P2 - Nice to Have

### Custom Sounds
**Effort: Medium**

Let users choose from system sounds or import audio.

**Tasks:**
- [ ] List available system sounds
- [ ] Create sound picker UI
- [ ] Preview sounds before selection
- [ ] Persist sound selection
- [ ] Support custom audio file import

---

### iCloud Sync
**Effort: High**

Sync settings and stats across devices.

**Tasks:**
- [ ] Enable iCloud capability
- [ ] Use NSUbiquitousKeyValueStore for settings
- [ ] Design conflict resolution strategy
- [ ] Handle offline/online transitions
- [ ] Test across multiple devices

---

### Watch App
**Effort: High**

Companion app for Apple Watch.

**Tasks:**
- [ ] Create watchOS target
- [ ] Design compact Watch UI
- [ ] Implement WatchConnectivity
- [ ] Handle independent operation
- [ ] Add complications

---

### Shortcuts Integration
**Effort: Medium**

Expose actions to Shortcuts app.

**Tasks:**
- [ ] Add App Intents framework
- [ ] Create StartTimerIntent
- [ ] Create PauseTimerIntent
- [ ] Create SkipIntent
- [ ] Add Siri phrase suggestions

---

## P3 - Low Priority

### Themes
**Effort: Low**

Custom color schemes beyond phase colors.

**Tasks:**
- [ ] Define theme structure (colors, assets)
- [ ] Create 3-5 built-in themes
- [ ] Add theme picker in settings
- [ ] Persist theme selection

---

### CSV Export
**Effort: Low**

Export session history for analysis.

**Tasks:**
- [ ] Track session history with timestamps
- [ ] Create CSV generation function
- [ ] Add share sheet integration
- [ ] Include date range filtering

---

### Session Notes
**Effort: Medium**

Add optional notes to completed sessions.

**Tasks:**
- [ ] Add note field to session model
- [ ] Show note input after session
- [ ] Display notes in stats view
- [ ] Search/filter by notes

---

### Multiple Timer Presets
**Effort: Medium**

Save different timer configurations.

**Tasks:**
- [ ] Create Preset model
- [ ] Add preset management UI
- [ ] Quick-switch between presets
- [ ] Include "52/17" and other popular techniques

---

### Ambient Sounds
**Effort: Medium**

Play background sounds during work sessions.

**Tasks:**
- [ ] Bundle ambient audio files (rain, cafe, etc.)
- [ ] Create audio player service
- [ ] Add volume control
- [ ] Pause during breaks
- [ ] Mix with completion sound

---

## Implementation Notes

### Adding a New Feature

1. Create feature branch from `main`
2. Update models if needed
3. Add service if needed
4. Create/modify views
5. Update view model
6. Add unit tests
7. Update QA checklist
8. Create PR for review

### Testing New Features

- Add unit tests for any new engine logic
- Add UI tests for critical flows
- Update QA checklist with new test cases
- Test on both iOS and macOS
- Test with VoiceOver enabled

### Performance Considerations

- Profile with Instruments before/after
- Monitor memory usage
- Test battery impact (especially background features)
- Measure app launch time
