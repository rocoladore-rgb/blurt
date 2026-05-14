import SwiftUI
import AppKit
import AVFoundation
import ServiceManagement

// MARK: - Root window

struct SettingsView: View {
    enum Section: String, CaseIterable, Identifiable {
        case general       = "General"
        case hotkey        = "Hotkey"
        case formality     = "Formality"
        case vocabulary    = "Vocabulary"
        case voiceCommands = "Voice Commands"
        case appProfiles   = "App Profiles"
        case transcription = "Transcription"
        case history       = "History"

        var id: Self { self }

        var icon: String {
            switch self {
            case .general:       return "gearshape"
            case .hotkey:        return "command"
            case .formality:     return "textformat"
            case .vocabulary:    return "text.bubble"
            case .voiceCommands: return "waveform.and.mic"
            case .appProfiles:   return "rectangle.stack"
            case .transcription: return "waveform"
            case .history:       return "clock"
            }
        }
    }

    @State private var selection: Section? = .general

    var body: some View {
        NavigationSplitView {
            List(Section.allCases, selection: $selection) { section in
                Label(section.rawValue, systemImage: section.icon)
                    .tag(section)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            Group {
                switch selection ?? .general {
                case .general:       GeneralSettingsView()
                case .hotkey:        HotkeySettingsView()
                case .formality:     FormalitySettingsView()
                case .vocabulary:    VocabularySettingsView()
                case .voiceCommands: PlaceholderView(title: "Voice Commands",
                                         icon: "waveform.and.mic",
                                         message: "Create voice shortcuts that trigger actions — coming soon.")
                case .appProfiles:   PlaceholderView(title: "App Profiles",
                                         icon: "rectangle.stack",
                                         message: "Set different formality levels per app — coming soon.")
                case .transcription: TranscriptionSettingsView()
                case .history:       HistorySettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(minWidth: 680, minHeight: 460)
    }
}

// MARK: - Placeholder

private struct PlaceholderView: View {
    let title: String
    let icon: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.title2.bold())
            Text(message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - General

private struct GeneralSettingsView: View {
    @ObservedObject private var settings = BlurtSettings.shared
    @State private var launchAtLogin = false

    var body: some View {
        Form {
            Section("Startup") {
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { enabled in
                        settings.launchAtLogin = enabled
                    }
            }

            Section {
                Toggle("Always show pill", isOn: $settings.alwaysShowPill)
                Text("When off, the recording pill only appears while recording.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Pill Window")
            }
        }
        .formStyle(.grouped)
        .onAppear { launchAtLogin = settings.launchAtLogin }
        .navigationTitle("General")
        .padding()
    }
}

// MARK: - Hotkey

private struct HotkeySettingsView: View {
    private var hasAccess: Bool { AXIsProcessTrusted() }

    var body: some View {
        Form {
            Section("Current Hotkey") {
                HStack {
                    Text("Record voice")
                    Spacer()
                    KeyBadge("fn")
                    Text("Hold")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }

            Section {
                Text("Hold the hotkey to record. Release to transcribe and insert text into the focused app. Custom hotkey configuration is coming in a future update.")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }

            Section("Permissions") {
                HStack {
                    Image(systemName: hasAccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundStyle(hasAccess ? .green : .orange)
                    Text("Accessibility Access")
                    Spacer()
                    if !hasAccess {
                        Button("Open Settings") {
                            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                                NSWorkspace.shared.open(url)
                            }
                        }
                        .buttonStyle(.link)
                    }
                }

                HStack {
                    Image(systemName: micStatus.icon)
                        .foregroundStyle(micStatus.color)
                    Text("Microphone Access")
                    Spacer()
                    if micStatus != .authorized {
                        Button("Open Settings") {
                            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
                                NSWorkspace.shared.open(url)
                            }
                        }
                        .buttonStyle(.link)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Hotkey")
        .padding()
    }

    private enum MicStatus: Equatable {
        case authorized, denied, undetermined
        var icon: String {
            switch self {
            case .authorized:   return "checkmark.circle.fill"
            case .denied:       return "xmark.circle.fill"
            case .undetermined: return "questionmark.circle.fill"
            }
        }
        var color: Color {
            switch self {
            case .authorized:   return .green
            case .denied:       return .red
            case .undetermined: return .orange
            }
        }
    }

    private var micStatus: MicStatus {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:                    return .authorized
        case .denied, .restricted:           return .denied
        case .notDetermined:                 return .undetermined
        @unknown default:                    return .undetermined
        }
    }
}

private struct KeyBadge: View {
    let label: String
    init(_ label: String) { self.label = label }

    var body: some View {
        Text(label)
            .font(.system(size: 12, weight: .medium, design: .monospaced))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(nsColor: .separatorColor)))
    }
}

// MARK: - Formality

private struct FormalitySettingsView: View {
    @ObservedObject private var settings = BlurtSettings.shared

    var body: some View {
        Form {
            Section {
                Picker("Preset", selection: $settings.preset) {
                    ForEach(FormattingPreset.allCases, id: \.self) { preset in
                        Text(preset.displayName).tag(preset)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()

                presetDescription
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Formality Preset")
            }

            Section("Processing") {
                Toggle("Add punctuation", isOn: $settings.enablePunctuation)
                    .disabled(settings.preset == .casual)
                Toggle("Remove filler words", isOn: $settings.enableFillerRemoval)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Formality")
        .padding()
    }

    private var presetDescription: Text {
        switch settings.preset {
        case .casual:  return Text("Relaxed tone. Contractions kept. Only filler words stripped.")
        case .neutral: return Text("Natural tone. Contractions kept. Punctuation and capitalisation added.")
        case .formal:  return Text("Professional tone. Contractions expanded. Full punctuation applied.")
        }
    }
}

// MARK: - Vocabulary

private struct VocabularySettingsView: View {
    @ObservedObject private var settings = BlurtSettings.shared
    @State private var newFillerWord = ""
    @State private var newSubFrom    = ""
    @State private var newSubTo      = ""

    var body: some View {
        Form {
            Section("Built-in Filler Words") {
                let all = FillerWords.unconditional + FillerWords.contextual
                ForEach(all, id: \.self) { word in
                    HStack(spacing: 6) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                        Text(word)
                    }
                }
            }

            Section {
                ForEach(settings.customFillerWords, id: \.self) { word in
                    Text(word)
                }
                .onDelete { indices in
                    settings.customFillerWords.remove(atOffsets: indices)
                }

                HStack {
                    TextField("Add word...", text: $newFillerWord)
                        .onSubmit { addFillerWord() }
                    Button("Add", action: addFillerWord)
                        .disabled(newFillerWord.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            } header: {
                Text("Custom Filler Words")
            } footer: {
                Text("Removed in addition to the built-in list above.")
            }

            Section {
                ForEach(settings.wordSubstitutions, id: \.self) { pair in
                    let parts = pair.components(separatedBy: "\t")
                    HStack(spacing: 6) {
                        Text(parts.first ?? "")
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(parts.dropFirst().joined(separator: "\t"))
                    }
                }
                .onDelete { indices in
                    settings.wordSubstitutions.remove(atOffsets: indices)
                }

                HStack {
                    TextField("From...", text: $newSubFrom)
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.secondary)
                    TextField("To...", text: $newSubTo)
                        .onSubmit { addSubstitution() }
                    Button("Add", action: addSubstitution)
                        .disabled(newSubFrom.trimmingCharacters(in: .whitespaces).isEmpty ||
                                  newSubTo.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            } header: {
                Text("Word Substitutions")
            } footer: {
                Text("e.g. \"gonna\" → \"going to\". Applied after filler removal.")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Vocabulary")
        .padding()
    }

    private func addFillerWord() {
        let w = newFillerWord.trimmingCharacters(in: .whitespaces).lowercased()
        guard !w.isEmpty, !settings.customFillerWords.contains(w) else { return }
        settings.customFillerWords.append(w)
        newFillerWord = ""
    }

    private func addSubstitution() {
        let from = newSubFrom.trimmingCharacters(in: .whitespaces).lowercased()
        let to   = newSubTo.trimmingCharacters(in: .whitespaces)
        guard !from.isEmpty, !to.isEmpty else { return }
        let pair = "\(from)\t\(to)"
        guard !settings.wordSubstitutions.contains(pair) else { return }
        settings.wordSubstitutions.append(pair)
        newSubFrom = ""
        newSubTo   = ""
    }
}

// MARK: - Transcription

private struct TranscriptionSettingsView: View {
    @ObservedObject private var settings = BlurtSettings.shared

    var body: some View {
        Form {
            Section("Whisper Model") {
                Picker("Model", selection: $settings.modelSize) {
                    ForEach(WhisperModelSize.allCases, id: \.self) { size in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(size.displayName)
                            Text(size.details)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .tag(size)
                    }
                }
                .pickerStyle(.radioGroup)
            }

            Section {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                        .padding(.top, 1)
                    Text("Changing the model downloads a new file. The current model stays active until the new one is ready. Model files are stored in ~/Library/Application Support/Blurt/.")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Transcription")
        .padding()
    }
}

// MARK: - History

private struct HistorySettingsView: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Transcription History")
                .font(.title2.bold())
            Text("Your recent transcriptions will appear here.\nHistory tracking is coming in a future update.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .navigationTitle("History")
    }
}
