# Build and Run Instructions

## Prerequisites

- **Xcode 15.0 or later** (recommended)
- **macOS 13.0 (Ventura) or later** for development
- Apple Developer account (free tier works for development)

## Quick Start

### Option 1: Open in Xcode (Recommended)

1. **Open the project**
   ```bash
   cd PomodoroTimer
   open PomodoroTimer.xcodeproj
   ```

2. **Select a destination**
   - For iOS: Select an iPhone simulator (e.g., "iPhone 15")
   - For macOS: Select "My Mac"

3. **Build and run**
   - Press `⌘R` or click the Play button

### Option 2: Command Line Build

```bash
# Navigate to project directory
cd PomodoroTimer

# Build for iOS Simulator
xcodebuild -scheme PomodoroTimer \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build

# Build for macOS
xcodebuild -scheme PomodoroTimer \
  -destination 'platform=macOS' \
  build

# Run tests
xcodebuild -scheme PomodoroTimer \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  test
```

## Project Configuration

### Targets

| Target | Description |
|--------|-------------|
| `PomodoroTimer` | Main app (iOS + macOS multiplatform) |
| `PomodoroTimerTests` | Unit tests for PomodoroEngine |

### Deployment Targets

| Platform | Minimum Version |
|----------|-----------------|
| iOS | 16.0 |
| macOS | 13.0 |

### Supported Devices

- **iPhone**: All models running iOS 16+
- **iPad**: All models running iPadOS 16+
- **Mac**: Intel and Apple Silicon Macs running macOS 13+

## Xcode Project Setup (If Creating from Scratch)

If you need to recreate the Xcode project:

1. **Create New Project**
   - File → New → Project
   - Choose "Multiplatform" → "App"
   - Product Name: `PomodoroTimer`
   - Organization Identifier: Your reverse domain (e.g., `com.yourname`)
   - Interface: SwiftUI
   - Language: Swift
   - **Uncheck** "Use Core Data"
   - **Uncheck** "Include Tests" (we'll add manually)

2. **Set Up File Structure**
   Create these groups in the project navigator:
   - `Models`
   - `Engine`
   - `ViewModels`
   - `Views`
   - `Services`
   - `Utilities`

3. **Add Test Target**
   - File → New → Target
   - Choose "Unit Testing Bundle"
   - Name: `PomodoroTimerTests`
   - Add `PomodoroEngineTests.swift` to this target

4. **Configure Capabilities (Optional)**

   For iOS target, add these capabilities if desired:
   - **Background Modes**: Enable "Background fetch" for better timer recovery

## Code Signing

### Development

For development and testing, automatic signing works:

1. Select the project in navigator
2. Select "PomodoroTimer" target
3. Under "Signing & Capabilities":
   - Check "Automatically manage signing"
   - Select your team (or personal team for free accounts)

### Distribution

For App Store distribution:
1. Create an App ID in Apple Developer portal
2. Create provisioning profiles
3. Configure signing in Xcode

## Troubleshooting

### Common Issues

**"No such module 'SwiftUI'"**
- Ensure deployment target is iOS 16.0+ or macOS 13.0+
- Clean build folder: `⇧⌘K`

**"Code signing error"**
- Verify team is selected in Signing & Capabilities
- For personal team, you may need to trust the developer certificate on device

**Tests fail to build**
- Ensure `@testable import PomodoroTimer` matches the module name
- Verify test target has "Host Application" set to PomodoroTimer

**macOS app won't open**
- Check System Preferences → Security & Privacy → Allow apps from identified developers

### Clean Build

If you encounter strange issues:

```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/PomodoroTimer-*

# Or in Xcode
# Product → Clean Build Folder (⇧⌘K)
```

## Verification Commands

```bash
# Verify project opens correctly
xcodebuild -list -project PomodoroTimer.xcodeproj

# Check available schemes
xcodebuild -scheme PomodoroTimer -showBuildSettings

# List available simulators
xcrun simctl list devices
```
