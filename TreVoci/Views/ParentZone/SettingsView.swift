import SwiftUI

struct SettingsView: View {
    @Environment(PersistenceService.self) private var persistence
    @State private var showResetAlert = false
    @State private var editingName = false
    @State private var nameText = ""

    let onReset: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(Color.bark)

            VStack(spacing: 0) {
                // Child's name
                nameRow

                Divider().padding(.horizontal, 16)

                // Languages
                languagesRow

                Divider().padding(.horizontal, 16)

                // Default speaker
                speakerRow

                Divider().padding(.horizontal, 16)

                // Session length
                sessionLengthRow

                Divider().padding(.horizontal, 16)

                // Auto language rotation
                autoRotationRow

                Divider().padding(.horizontal, 16)

                // Bedtime mode
                bedtimeModeRow
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.04), radius: 8, y: 2)

            // Reset
            Button(action: { showResetAlert = true }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Reset All Data")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Color.chineseRed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.chineseRed.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .accessibilityLabel("Reset all data")
            .accessibilityAddTraits(.isButton)
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    onReset()
                }
            } message: {
                Text("This will erase all listening history, settings, and return to the welcome screen.")
            }

            // About
            aboutSection
        }
        .onAppear {
            nameText = persistence.state.childName
        }
    }

    // MARK: - Name Row

    private var nameRow: some View {
        HStack {
            Label("Child's Name", systemImage: "person.fill")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.bark)
            Spacer()
            if editingName {
                TextField("Name", text: $nameText)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.trailing)
                    .frame(width: 120)
                    .onSubmit {
                        persistence.update { $0.childName = nameText }
                        editingName = false
                    }
                Button("Done") {
                    persistence.update { $0.childName = nameText }
                    editingName = false
                }
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color.coral)
            } else {
                Text(persistence.state.displayName)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.stone)
                Button {
                    nameText = persistence.state.childName
                    editingName = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.stone)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Languages Row

    private var languagesRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Languages", systemImage: "globe")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.bark)
                Spacer()
                Text("at least 2")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.stone)
            }

            HStack(spacing: 8) {
                ForEach(Language.allCases) { lang in
                    let isSelected = persistence.state.isLanguageSelected(lang)
                    Button {
                        toggleSettingsLanguage(lang)
                    } label: {
                        HStack(spacing: 4) {
                            Text(lang.flag)
                                .font(.system(size: 14))
                            Text(lang.displayName)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(isSelected ? .white : Color.bark)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(isSelected ? lang.primaryColor : Color.sand.opacity(0.5))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(lang.displayName), \(isSelected ? "selected" : "not selected")")
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func toggleSettingsLanguage(_ lang: Language) {
        let current = Set(persistence.state.selectedLanguages)
        if current.contains(lang.rawValue) {
            guard current.count > 2 else { return }
            persistence.update { state in
                state.selectedLanguages.removeAll { $0 == lang.rawValue }
            }
        } else {
            persistence.update { state in
                state.selectedLanguages.append(lang.rawValue)
            }
        }
    }

    // MARK: - Speaker Row

    private var speakerRow: some View {
        HStack {
            Label("Default Speaker", systemImage: "speaker.wave.2.fill")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.bark)
            Spacer()
            AirPlayPickerButton()
                .frame(width: 30, height: 30)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Session Length Row

    private var sessionLengthRow: some View {
        HStack {
            Label("Songs per Session", systemImage: "music.note.list")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.bark)
            Spacer()
            HStack(spacing: 12) {
                Button {
                    let current = persistence.state.sessionLength
                    if current > 1 {
                        persistence.update { $0.sessionLength = current - 1 }
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(persistence.state.sessionLength > 1 ? Color.coral : Color.sand)
                }
                .disabled(persistence.state.sessionLength <= 1)

                Text("\(persistence.state.sessionLength)")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(Color.bark)
                    .frame(width: 24)

                Button {
                    let current = persistence.state.sessionLength
                    if current < 5 {
                        persistence.update { $0.sessionLength = current + 1 }
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(persistence.state.sessionLength < 5 ? Color.coral : Color.sand)
                }
                .disabled(persistence.state.sessionLength >= 5)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Auto Rotation Row

    private var autoRotationRow: some View {
        HStack {
            Label("Auto Language Rotation", systemImage: "arrow.triangle.2.circlepath")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.bark)
            Spacer()
            Toggle("", isOn: Binding(
                get: { persistence.state.autoLanguageRotation },
                set: { val in persistence.update { $0.autoLanguageRotation = val } }
            ))
            .tint(Color.coral)
            .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Bedtime Mode Row

    private var bedtimeModeRow: some View {
        HStack {
            Label("Bedtime Mode", systemImage: "moon.fill")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.bark)
            Spacer()
            Toggle("", isOn: Binding(
                get: { persistence.state.bedtimeMode },
                set: { val in persistence.update { $0.bedtimeMode = val } }
            ))
            .tint(Color.coral)
            .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - About

    private var aboutSection: some View {
        VStack(spacing: 6) {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            Text("Tre Voci v\(version)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(Color.stone)
            Text("Made with \u{2764}\u{FE0F} in Dubai")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.mist)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}

// Uses shared AirPlayPickerButton from Views/Shared/

#if DEBUG
#Preview {
    ScrollView {
        SettingsView(onReset: {})
            .padding(20)
    }
    .background(Color.cream)
    .environment(PersistenceService())
}
#endif
