import SwiftUI

/// Main content view that adapts layout based on screen size
///
/// Provides two layouts:
/// - Compact: Vertical stack for iPhone portrait
/// - Wide: Horizontal layout for Mac and landscape
struct ContentView: View {
    @EnvironmentObject var viewModel: PomodoroViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.width < 500

            if isCompact {
                compactLayout
            } else {
                wideLayout
            }
        }
        .background(backgroundColor)
        .sheet(isPresented: $viewModel.showingSettings) {
            SettingsView()
                .environmentObject(viewModel)
        }
        .alert("Session Complete", isPresented: $viewModel.showingInAppAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.alertMessage)
        }
        #if os(iOS)
        .statusBarHidden(false)
        #endif
    }

    // MARK: - Layouts

    private var compactLayout: some View {
        VStack(spacing: 24) {
            Spacer()

            phaseLabel

            timerSection

            SessionIndicatorsView(
                completed: viewModel.completedWorkSessions,
                total: viewModel.cycleTarget
            )

            Spacer()

            ControlButtonsView()
                .environmentObject(viewModel)

            settingsButton

            Spacer()
        }
        .padding()
    }

    private var wideLayout: some View {
        HStack(spacing: 40) {
            VStack(spacing: 20) {
                phaseLabel
                timerSection
                SessionIndicatorsView(
                    completed: viewModel.completedWorkSessions,
                    total: viewModel.cycleTarget
                )
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 24) {
                ControlButtonsView()
                    .environmentObject(viewModel)
                settingsButton
            }
            .frame(width: 200)
        }
        .padding(40)
    }

    // MARK: - Components

    private var phaseLabel: some View {
        Text(viewModel.phase.displayName)
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(phaseColor)
            .accessibilityLabel(viewModel.phase.accessibilityLabel)
    }

    private var timerSection: some View {
        ZStack {
            ProgressRingView(
                progress: viewModel.progress,
                color: phaseColor
            )
            .frame(width: 220, height: 220)

            TimerDisplayView(seconds: viewModel.secondsRemaining)
        }
    }

    private var settingsButton: some View {
        Button {
            viewModel.showingSettings = true
        } label: {
            Label("Settings", systemImage: "gearshape")
                .font(.body)
        }
        .buttonStyle(.plain)
        .foregroundColor(.secondary)
        .accessibilityLabel("Open settings")
    }

    // MARK: - Colors

    private var phaseColor: Color {
        switch viewModel.phase {
        case .work: return .red
        case .shortBreak: return .green
        case .longBreak: return .blue
        }
    }

    private var backgroundColor: Color {
        #if os(macOS)
        return Color(nsColor: .windowBackgroundColor)
        #else
        return Color(uiColor: .systemBackground)
        #endif
    }
}

#Preview {
    ContentView()
        .environmentObject(PomodoroViewModel())
}
