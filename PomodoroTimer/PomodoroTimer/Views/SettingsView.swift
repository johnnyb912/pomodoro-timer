import SwiftUI

/// Settings screen with minimal, precise design
/// Clean form layout with consistent typography
struct SettingsView: View {
    @EnvironmentObject var viewModel: PomodoroViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // Durations section
                Section {
                    durationRow(
                        label: "Work",
                        value: $viewModel.settings.workDurationMinutes,
                        range: 1...120,
                        accessibilityLabel: "Work duration"
                    )

                    durationRow(
                        label: "Short break",
                        value: $viewModel.settings.shortBreakMinutes,
                        range: 1...60,
                        accessibilityLabel: "Short break duration"
                    )

                    durationRow(
                        label: "Long break",
                        value: $viewModel.settings.longBreakMinutes,
                        range: 1...60,
                        accessibilityLabel: "Long break duration"
                    )
                } header: {
                    sectionHeader("DURATIONS")
                }

                // Cycle section
                Section {
                    HStack {
                        Text("Sessions before long break")
                            .font(.system(size: DesignSystem.Typography.bodySize))
                            .foregroundColor(Color.foregroundPrimary)

                        Spacer()

                        Stepper(
                            "\(viewModel.settings.longBreakInterval)",
                            value: $viewModel.settings.longBreakInterval,
                            in: 2...10
                        )
                        .labelsHidden()
                        .fixedSize()

                        Text("\(viewModel.settings.longBreakInterval)")
                            .font(.system(
                                size: DesignSystem.Typography.bodySize,
                                weight: .medium,
                                design: .monospaced
                            ))
                            .foregroundColor(Color.foregroundSecondary)
                            .frame(width: 24, alignment: .trailing)
                    }
                    .accessibilityLabel("Long break interval")
                    .accessibilityValue("Every \(viewModel.settings.longBreakInterval) work sessions")
                } header: {
                    sectionHeader("CYCLE")
                }

                // Behavior section
                Section {
                    Toggle(isOn: $viewModel.settings.autoStartNextSession) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Auto-start next session")
                                .font(.system(size: DesignSystem.Typography.bodySize))
                                .foregroundColor(Color.foregroundPrimary)
                            Text("Automatically begin the next timer")
                                .font(.system(size: DesignSystem.Typography.captionSize))
                                .foregroundColor(Color.foregroundMuted)
                        }
                    }
                    .tint(Color.accentWork)
                    .accessibilityLabel("Auto-start next session")

                    Toggle(isOn: $viewModel.settings.soundEnabled) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sound")
                                .font(.system(size: DesignSystem.Typography.bodySize))
                                .foregroundColor(Color.foregroundPrimary)
                            Text("Play sound when session completes")
                                .font(.system(size: DesignSystem.Typography.captionSize))
                                .foregroundColor(Color.foregroundMuted)
                        }
                    }
                    .tint(Color.accentWork)
                    .accessibilityLabel("Sound enabled")
                } header: {
                    sectionHeader("BEHAVIOR")
                }

                // Info section
                Section {
                    HStack(spacing: DesignSystem.Spacing.tight) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 13))
                            .foregroundColor(Color.foregroundMuted)
                        Text("Duration changes apply to the next session")
                            .font(.system(size: DesignSystem.Typography.captionSize))
                            .foregroundColor(Color.foregroundMuted)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.backgroundPrimary)
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(
                        size: DesignSystem.Typography.bodySize,
                        weight: .medium
                    ))
                    .foregroundColor(Color.foregroundPrimary)
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 380, minHeight: 420)
        #endif
    }

    // MARK: - Components

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(
                size: DesignSystem.Typography.sectionSize,
                weight: DesignSystem.Typography.sectionWeight
            ))
            .tracking(0.5)
            .foregroundColor(Color.foregroundMuted)
    }

    private func durationRow(
        label: String,
        value: Binding<Int>,
        range: ClosedRange<Int>,
        accessibilityLabel: String
    ) -> some View {
        HStack {
            Text(label)
                .font(.system(size: DesignSystem.Typography.bodySize))
                .foregroundColor(Color.foregroundPrimary)

            Spacer()

            Stepper(
                "\(value.wrappedValue) min",
                value: value,
                in: range
            )
            .labelsHidden()
            .fixedSize()

            Text("\(value.wrappedValue)")
                .font(.system(
                    size: DesignSystem.Typography.bodySize,
                    weight: .medium,
                    design: .monospaced
                ))
                .foregroundColor(Color.foregroundSecondary)
                .frame(width: 32, alignment: .trailing)

            Text("min")
                .font(.system(size: DesignSystem.Typography.captionSize))
                .foregroundColor(Color.foregroundMuted)
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue("\(value.wrappedValue) minutes")
    }
}

#Preview {
    SettingsView()
        .environmentObject(PomodoroViewModel())
}
