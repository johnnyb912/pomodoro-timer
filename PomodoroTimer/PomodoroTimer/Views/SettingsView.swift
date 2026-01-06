import SwiftUI

/// Settings screen for configuring Pomodoro timer behavior
///
/// Allows customization of:
/// - Work, short break, and long break durations
/// - Long break interval (sessions before long break)
/// - Auto-start behavior
/// - Sound on/off
///
/// Note: Changes to durations apply to the next session, not the current one.
struct SettingsView: View {
    @EnvironmentObject var viewModel: PomodoroViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Durations") {
                    Stepper(
                        "Work: \(viewModel.settings.workDurationMinutes) min",
                        value: $viewModel.settings.workDurationMinutes,
                        in: 1...120
                    )
                    .accessibilityLabel("Work duration")
                    .accessibilityValue("\(viewModel.settings.workDurationMinutes) minutes")

                    Stepper(
                        "Short Break: \(viewModel.settings.shortBreakMinutes) min",
                        value: $viewModel.settings.shortBreakMinutes,
                        in: 1...60
                    )
                    .accessibilityLabel("Short break duration")
                    .accessibilityValue("\(viewModel.settings.shortBreakMinutes) minutes")

                    Stepper(
                        "Long Break: \(viewModel.settings.longBreakMinutes) min",
                        value: $viewModel.settings.longBreakMinutes,
                        in: 1...60
                    )
                    .accessibilityLabel("Long break duration")
                    .accessibilityValue("\(viewModel.settings.longBreakMinutes) minutes")
                }

                Section("Cycle") {
                    Stepper(
                        "Long break every \(viewModel.settings.longBreakInterval) sessions",
                        value: $viewModel.settings.longBreakInterval,
                        in: 2...10
                    )
                    .accessibilityLabel("Long break interval")
                    .accessibilityValue("Every \(viewModel.settings.longBreakInterval) work sessions")
                }

                Section("Behavior") {
                    Toggle("Auto-start next session", isOn: $viewModel.settings.autoStartNextSession)
                        .accessibilityLabel("Auto-start next session")

                    Toggle("Sound enabled", isOn: $viewModel.settings.soundEnabled)
                        .accessibilityLabel("Sound enabled")
                }

                Section {
                    Text("Changes to durations apply to the next session.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 350, minHeight: 400)
        #endif
    }
}

#Preview {
    SettingsView()
        .environmentObject(PomodoroViewModel())
}
