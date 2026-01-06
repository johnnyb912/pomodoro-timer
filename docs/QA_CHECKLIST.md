# Manual QA Checklist

Use this checklist to verify the Pomodoro Timer app is working correctly before release.

## Test Environment

- [ ] iOS Simulator (iPhone 15 or similar)
- [ ] Physical iOS device (if available)
- [ ] macOS native

---

## Basic Functionality

### 1. Initial State
- [ ] App launches showing Work phase
- [ ] Timer displays "25:00"
- [ ] Timer is not running (Play button visible)
- [ ] Session indicators show 0/4 (empty dots)
- [ ] Progress ring is empty (0%)

### 2. Start Timer
- [ ] Tap Start button
- [ ] Timer counts down
- [ ] Progress ring fills gradually
- [ ] Button changes to Pause icon
- [ ] (iOS) Haptic feedback on start

### 3. Pause Timer
- [ ] Tap Pause button while running
- [ ] Timer stops counting
- [ ] Button changes to Play icon
- [ ] Time is preserved (doesn't reset)
- [ ] (iOS) Haptic feedback on pause

### 4. Resume Timer
- [ ] Tap Play button after pause
- [ ] Timer continues from paused time
- [ ] Does not restart from beginning

### 5. Skip During Work
- [ ] Tap Skip during Work phase
- [ ] Transitions to Short Break
- [ ] Session count stays at 0 (not incremented)
- [ ] Timer resets to 5:00

### 6. Complete Work Session
- [ ] Start work timer (use short duration in settings for testing)
- [ ] Let timer reach 0:00
- [ ] Notification fires (if permitted)
- [ ] Sound plays (if enabled)
- [ ] (iOS) Success haptic
- [ ] Transitions to Short Break
- [ ] Session count increments to 1

### 7. Complete Short Break
- [ ] Let short break timer complete
- [ ] Transitions back to Work
- [ ] Session count remains at 1

### 8. Long Break After 4 Sessions
- [ ] Complete 4 work sessions with breaks between
- [ ] After 4th work session → Long Break (15 min)
- [ ] Session indicators show 4/4

### 9. Cycle Reset After Long Break
- [ ] Complete the long break
- [ ] Returns to Work phase
- [ ] Session count resets to 0/4

### 10. Reset Button
- [ ] Tap Reset at any point
- [ ] Returns to Work phase
- [ ] Timer shows 25:00
- [ ] Session count resets to 0
- [ ] Timer is paused

---

## Settings

### 11. Open Settings
- [ ] Tap Settings button
- [ ] Settings sheet appears
- [ ] All controls are visible and functional

### 12. Change Durations
- [ ] Change Work duration (e.g., to 30 min)
- [ ] Change Short Break duration
- [ ] Change Long Break duration
- [ ] Close settings
- [ ] Verify current session is unchanged
- [ ] Skip to next session
- [ ] Verify new duration is applied

### 13. Change Long Break Interval
- [ ] Set interval to 2 sessions
- [ ] Complete 2 work sessions
- [ ] Verify Long Break occurs after 2nd session

### 14. Auto-Start Toggle
- [ ] Enable auto-start
- [ ] Complete a session
- [ ] Verify next session starts automatically

### 15. Sound Toggle
- [ ] Disable sound
- [ ] Complete a session
- [ ] Verify no sound plays
- [ ] Re-enable sound
- [ ] Complete a session
- [ ] Verify sound plays

---

## Background & Recovery

### 16. Background Timer (iOS)
- [ ] Start timer
- [ ] Press Home button to background app
- [ ] Wait 2+ minutes
- [ ] Return to app
- [ ] Verify timer shows correct remaining time

### 17. App Termination Recovery
- [ ] Start timer
- [ ] Force quit the app
- [ ] Relaunch app
- [ ] Verify timer recovers with correct remaining time
- [ ] Verify timer state (running/paused) is restored

### 18. Settings Persistence
- [ ] Change settings
- [ ] Force quit app
- [ ] Relaunch app
- [ ] Verify settings are preserved

---

## Notifications

### 19. Notification Permission Granted
- [ ] Grant notification permission when prompted
- [ ] Start timer
- [ ] Background app
- [ ] Let timer complete
- [ ] Verify notification appears

### 20. Notification Permission Denied
- [ ] Deny notification permission (or revoke in Settings)
- [ ] Complete a session while app is open
- [ ] Verify in-app alert appears instead

---

## Platform-Specific

### iOS Specific

### 21. Haptic Feedback
- [ ] Start timer → Medium haptic
- [ ] Pause timer → Light haptic
- [ ] Skip timer → Medium haptic
- [ ] Reset timer → Light haptic
- [ ] Complete session → Success haptic

### 22. Portrait/Landscape
- [ ] App works in portrait mode
- [ ] App adapts layout in landscape mode (wider layout)

### macOS Specific

### 23. Keyboard Shortcuts
- [ ] Press Space → Start/Pause
- [ ] Press R → Reset
- [ ] Press S → Skip

### 24. Timer Menu
- [ ] Timer menu exists in menu bar
- [ ] Start/Pause menu item works
- [ ] Reset menu item works
- [ ] Skip menu item works

### 25. Window Behavior
- [ ] Window opens at appropriate size
- [ ] Layout is appropriate for window size

---

## Accessibility

### 26. VoiceOver (iOS)
- [ ] Enable VoiceOver
- [ ] Navigate to timer display → Reads remaining time
- [ ] Navigate to phase label → Reads phase name
- [ ] Navigate to Start button → Reads "Start timer"
- [ ] Navigate to session indicators → Reads "Session X of Y"

### 27. Dynamic Type
- [ ] Increase text size in Settings → Accessibility
- [ ] Verify text scales appropriately
- [ ] Verify layout doesn't break at largest sizes

### 28. High Contrast
- [ ] Enable Increase Contrast in Accessibility settings
- [ ] Verify colors remain visible and distinct

---

## Edge Cases

### 29. Clock Change
- [ ] Start timer
- [ ] Manually change device clock forward
- [ ] Return to app
- [ ] Verify timer doesn't show negative time

### 30. Settings Change Mid-Session
- [ ] Start a work session
- [ ] Open settings and change work duration
- [ ] Verify current session keeps original duration
- [ ] Verify change applies to next work session

### 31. Rapid Button Presses
- [ ] Rapidly tap Start/Pause multiple times
- [ ] Verify app doesn't crash or behave unexpectedly

### 32. Memory Warning (iOS)
- [ ] Start timer
- [ ] Trigger memory warning (via Simulator → Debug → Simulate Memory Warning)
- [ ] Verify app continues functioning

---

## Test Sign-Off

| Platform | Tester | Date | Pass/Fail | Notes |
|----------|--------|------|-----------|-------|
| iOS Simulator | | | | |
| iOS Device | | | | |
| macOS | | | | |
