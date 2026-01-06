import SwiftUI

/// Main content view with precise, minimal design
/// Design direction: Precision & Utility — calm, technical, non-distracting
struct ContentView: View {
    @EnvironmentObject var viewModel: PomodoroViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.width < 500

            ZStack {
                // Background
                Color.backgroundPrimary
                    .ignoresSafeArea()

                if isCompact {
                    compactLayout
                } else {
                    wideLayout
                }
            }
        }
        .sheet(isPresented: $viewModel.showingSettings) {
            SettingsView()
                .environmentObject(viewModel)
        }
        .alert("Session Complete", isPresented: $viewModel.showingInAppAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.alertMessage)
        }
    }

    // MARK: - Compact Layout (iPhone)

    private var compactLayout: some View {
        VStack(spacing: 0) {
            Spacer()

            // Timer card
            VStack(spacing: DesignSystem.Spacing.generous) {
                // Phase indicator
                phaseIndicator

                // Timer display
                TimerDisplayView(seconds: viewModel.secondsRemaining)

                // Progress bar
                ProgressRingView(
                    progress: viewModel.progress,
                    phase: viewModel.phase
                )
                .frame(height: 4)
                .padding(.horizontal, DesignSystem.Spacing.major)

                // Session indicators
                SessionIndicatorsView(
                    completed: viewModel.completedWorkSessions,
                    total: viewModel.cycleTarget
                )
            }
            .padding(DesignSystem.Spacing.generous)
            .cardStyle(padding: DesignSystem.Spacing.generous)
            .padding(.horizontal, DesignSystem.Spacing.comfortable)

            Spacer()

            // Controls
            VStack(spacing: DesignSystem.Spacing.comfortable) {
                ControlButtonsView()
                    .environmentObject(viewModel)

                settingsButton
            }
            .padding(.bottom, DesignSystem.Spacing.major)
        }
    }

    // MARK: - Wide Layout (Mac / iPad)

    private var wideLayout: some View {
        HStack(spacing: DesignSystem.Spacing.xlarge) {
            Spacer()

            // Timer card
            VStack(spacing: DesignSystem.Spacing.generous) {
                phaseIndicator

                TimerDisplayView(seconds: viewModel.secondsRemaining)

                ProgressRingView(
                    progress: viewModel.progress,
                    phase: viewModel.phase
                )
                .frame(height: 4)
                .padding(.horizontal, DesignSystem.Spacing.major)

                SessionIndicatorsView(
                    completed: viewModel.completedWorkSessions,
                    total: viewModel.cycleTarget
                )
            }
            .padding(DesignSystem.Spacing.major)
            .cardStyle(padding: DesignSystem.Spacing.major)
            .frame(minWidth: 320, maxWidth: 400)

            // Controls panel
            VStack(spacing: DesignSystem.Spacing.generous) {
                ControlButtonsView()
                    .environmentObject(viewModel)

                Divider()
                    .background(Color.borderSubtle)

                settingsButton
            }
            .frame(width: 160)

            Spacer()
        }
        .padding(DesignSystem.Spacing.xlarge)
    }

    // MARK: - Components

    private var phaseIndicator: some View {
        HStack(spacing: DesignSystem.Spacing.tight) {
            Circle()
                .fill(Color.phaseColor(for: viewModel.phase))
                .frame(width: 6, height: 6)

            Text(viewModel.phase.displayName.uppercased())
                .font(.system(
                    size: DesignSystem.Typography.sectionSize,
                    weight: DesignSystem.Typography.sectionWeight
                ))
                .tracking(0.5)
                .foregroundColor(.foregroundMuted)
        }
        .accessibilityLabel(viewModel.phase.accessibilityLabel)
    }

    private var settingsButton: some View {
        Button {
            viewModel.showingSettings = true
        } label: {
            HStack(spacing: DesignSystem.Spacing.tight) {
                Image(systemName: "gearshape")
                    .font(.system(size: 13, weight: .medium))
                Text("Settings")
                    .font(.system(
                        size: DesignSystem.Typography.captionSize,
                        weight: DesignSystem.Typography.captionWeight
                    ))
            }
            .foregroundColor(.foregroundMuted)
        }
        .buttonStyle(SecondaryButtonStyle())
        .accessibilityLabel("Open settings")
    }
}

#Preview {
    ContentView()
        .environmentObject(PomodoroViewModel())
}
